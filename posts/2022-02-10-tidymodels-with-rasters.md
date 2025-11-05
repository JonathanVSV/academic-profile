---
title: "Working with tidymodels and rasters in R"
date: 2022-02-10T10:10:30-04:00
categories:
  - blog
tags:
  - post
  - r
  - tidymodels
  - raster
layout: splash
---

# Working with tidymodels and rasters

Tidymodels is a package designed to make different types of models in a tidyverse-esque way. This package is particularly useful for implementing machine learning (ML) algorithms, as well as to divide your data into, training and test sets, etc. My particular personal interest was using this package to train models and then use those models to make predictions using raster data. 

For this procedure you should use additional packages, beside `tidymodels`. `sf` contains tools for working with spatial information saved in vectors. `yardstick` is a package that contains several functions to get evaluation metrics for the models. `raster` is a package that is going to be superseded by `terra` to work with rasters. Additionally, `fasterize` is a package useful to make transformations from vector to raster and finally, `doParallel` will help to make parallel processing in R.

```r
library(tidymodels)
library(sf)
library(yardstick)
library(raster)
library(fasterize)
library(doParallel)

tidymodels_prefer()
```

## Load data and do some preprocessing

The first thing is to load the labeled data from which we will train and test our model. In this example, we are going to work with spatial information, rasters and vectors. So, we generated a dataset of disturbance and non-disturbance areas using visual interpretation. For the sake of this model, we are going to take the data as spatially independent, however, keep in mind that there are other types of models that can take into account spatial dependency. Here we will use BFAST components and type of forest (tropical dry forest, TDF or temperate forest, TF) as independent variables, while the only dependent variable will be if an area correspnods to disturbance or not. The main idea of the script is to compare a baseline model, based on a magnitude threshold of 0.2 vs a more complex model that might include several other indepdendent variables.

```r
# Load raster and set names
im1 <- stack("bfast_components.tif")
names(im1) <- c("breakpoint","magnitude", "error", "history", 
                "r.squared", "amplitude", "trend", "Naperc")

# Choose subset of bands
im1 <- im1[[c(2,4:8)]]

# Load a forest type layer
forests_shp<- st_read("Forest_type.shp")

# Reproject
forests_shp <- forests_shp %>%
  st_transform(st_crs(im1[[1]]))

# Rasterize
forests_im <- fasterize(forests_shp, 
                        raster = raster(im1[[1]]),
                        field = "ID",
                        fun = "last")
# Set TF as 0
forests_im[forests_im==2] <- 0

# Stack all the independent variables as a multiband raster
im1 <- stack(forests_im, im1)
names(im1) <- c("Forest", "Magnitude", "History", "R2", "Ampl", "Trend", "NAperc")

# plot(im1)

# Read verified areas
tf <- st_read("238pts_Verified.shp")

# Make some recoding and eliminate unused variables
sample_extr <- tf %>%
  # Remove geometry, i.e., pass it to simple table
  st_set_geometry(NULL) %>%
  # Convert forest type as a numeric variable with 0 and 1
  mutate_at(vars(Forest), function(x) case_when(x == "Temperate_forest" ~ 0,
                                                x == "Tropical_dry_forest" ~ 1)) %>%
  # Convert change, the dependent variable as factor                                              
  mutate_at(vars(Change), function(x) as.factor(x)) %>%
  # Eliminate unused variables
  dplyr::select(-c(DateChange, Obs, cell, x, y, Breakp))

# Take a glimpse of the data
# glimpse(sample_extr)
```

## Divide dataset into training and test sets

After doing that short procedure you need to divide the complete dataset into training and test sets. This can easily be done using `tidymodels`. Additionally, I decided to use a separate vfold-cv-set (cross-validation set) to test the performance of different model architectures and obtain a standard error of the mean accuracy to decide which architecture could be considered as the best. After deciding the best model architecture, the the selected model will be trained and tested on the training and test datasets, respectively.

```r
# Set seed to make everything reproducible
set.seed(15)
sample_split <- initial_split(sample_extr, 
                              prop = 0.70,
                              # Stratification; save same proportions for some variable in train and test
                              strata = Change)

# Create training and test set
bfast_training <- sample_split %>%
  training()

bfast_test <- sample_split %>%
  testing()

# Ensure reproducibility
set.seed(5)
bfast_folds <- vfold_cv(bfast_training,
                        v = 3,
                        repeats = 40,
                        strata = Change)
```

Once you got the training and test sets, as well as the vfold-cv-set the next step will be to specify the models you are going to train. This can be done by specifying different recipes.

```r
# Specify algorithm to be used, engine and mode (classification or regression)
rf_model <- rand_forest() %>%
  set_engine("randomForest") %>%
  set_mode("classification")

# Recipes
# Model with all predictors, will be the template recipe to be used in the other recipes
bfast_recipe <- recipe(Change ~ ., 
                       data = bfast_training) %>%
  step_dummy(all_nominal(), -all_outcomes()) 

# Baseline model
baseline <- bfast_recipe %>% 
  step_mutate(base_line = ifelse(Magnitude <= -0.2, 1, 0)) %>%
  step_rm(c(Forest, R2, Ampl, NAperc, History, Trend, Magnitude))

# Random forests recipe
# Model with Magnitude, Trend,  History, NAperc, Ampl and R2, remove Forest
pred6_rec_rf <- 
  bfast_recipe %>% 
  step_rm(c(Forest)) 

# Model with Magnitude, Trend,  History, NAperc and Ampl, remove Forest and R2
pred5_rec_rf <- 
  bfast_recipe %>% 
  step_rm(c(Forest, R2)) 

# Model with Magnitude, Trend,  History and NAperc
pred4_rec_rf <- 
  bfast_recipe %>% 
  step_rm(c(Forest, R2, NAperc)) 

# Model with Magnitude, Trend and History
pred3_rec_rf <- 
  bfast_recipe %>% 
  step_rm(c(Forest, R2, NAperc, Ampl)) 

# Model with only Magnitude and Trend
pred2_rec_rf <- 
  bfast_recipe %>% 
  step_rm(c(Forest, R2, NAperc, Ampl, History)) 

# Model with only Magnitude
pred1_rec_rf <- 
  bfast_recipe %>% 
  step_rm(c(Forest, R2, NAperc, Ampl, History, Trend))

# Create a list of the models that area going to be trained
preprocessing <- 
  list(base = baseline,
       pred1 = pred1_rec_rf,
       pred2 = pred2_rec_rf,
       pred3 = pred3_rec_rf,
       pred4 = pred4_rec_rf,
       pred5 = pred5_rec_rf,
       pred6 = pred6_rec_rf,
       all = bfast_recipe
  )

# Create a workflow set
rf_models <- workflow_set(preproc = preprocessing, 
                          models = list(rf = rf_model), 
                          cross = FALSE)
```

Once all the recipes and workflow have been defined the next step is to fit or train the models. Remember we are going to first evaluate the models on the vfold-cv-set, then train it using the training dataset and evaluate it on the test set.

```r
# This is for running all variations of the model
# Define the number of nodes to be used for the training procedure. I recommend using 1 less than the total number of cores available in your computer
cl <- makePSOCKcluster(5)
registerDoParallel(cl)

# Fit all models using the vfold-cv-dataset
rf_results <- 
  rf_models %>% 
  # First argument tells type of fitting to be made
  # Fit resample takes vfolds of training and trains / tests
  workflow_map("fit_resamples", 
               # Options to `workflow_map()`: 
               seed = 10, verbose = TRUE,
               # Options to `fit_resamples()`: 
               resamples = bfast_folds)

# Collect metrics from the workflow and write the results to disk
rf_results %>%
  collect_metrics() %>% 
  # filter(.metric == "accuracy") %>%
  write.csv("Results/rf_modelcomp_allForest.csv")
```

After fitting all the models, you should choose the best architecture. In this case, I chose the one with non-significant difference in accuracy with the highest achieved one and tht included less independent variables. You can make a plot to see the results in a graphic way.

```r
# Choose best model according to accuracy
autoplot(
  rf_results,
  rank_metric = "accuracy",  # <- how to order models
  metric = "accuracy",       # <- which metric to visualize
  select_best = TRUE     # <- one point per workflow
)

print("Select simplest best model")
# Select model architecture with highest accuracy
rf_results %>% 
  rank_results(rank_metric = "accuracy", select_best = T) %>% 
  filter(.metric == "accuracy") 
```

After evaluating the results obtained in the vfold-cv-dataset, I chose the best model: "pred3_rf". So we are using that name as the model name to do the rest of the process. This names are automatically created when training the model.

```r
# Best model name
rf_best_model_id <- "pred3_rf"

# Pull the best model according to its id from workflow
# Then choose the model with highest accuracy parameters
# according to accuracy. This contains only the model that obtained the 
# highest accuracy in the vfold-cv-sets
rf_baseline_results <- rf_results %>% 
  extract_workflow_set_result("base_rf") %>%
  select_best(metric = "accuracy")

rf_truebest_results <- rf_results %>% 
  extract_workflow_set_result(rf_best_model_id) %>%
  select_best(metric = "accuracy") 

# Make last fit (i.e., train model from scratch using complete training data
# and then validate over validation data)
# Select best model using the previous object (bfast_best_results)
# These object contained the trained and verified model (using training and test sets)
rf_baseline_last_fit <- rf_results %>% 
  extract_workflow("base_rf") %>% 
  finalize_workflow(rf_baseline_results) %>% 
  last_fit(split = sample_split)

rf_truebest_last_fit <- rf_results %>% 
  extract_workflow(rf_best_model_id) %>% 
  finalize_workflow(rf_truebest_results) %>% 
  last_fit(split = sample_split)

# Get trained models for prediction
# Fit not last fit, aka, withouth predictions (only trained model).
# This are going to be used to make the predictions over the rasters
rf_baseline_fit_notlast <- rf_results %>% 
  extract_workflow("base_rf") %>% 
  finalize_workflow(rf_baseline_results) %>% 
  fit(bfast_training)

rf_truebest_fit_notlast <- rf_results %>% 
  extract_workflow(rf_best_model_id) %>% 
  finalize_workflow(rf_truebest_results) %>% 
  fit(bfast_training)
```

Now we have the trained models (`*_notlast`) and the trained and evaluated models (`*_last_fit`) on the test set. So the next step is to collect the predictions from the trained and evaluated models to calculate different evaluation metrics.

```r
# Collect predicions
rf_baseline_wkfl_preds <- rf_baseline_last_fit %>%
  collect_predictions()
rf_truebest_wkfl_preds <- rf_truebest_last_fit %>%
  collect_predictions()

# Write predictions vs truth
rf_baseline_wkfl_preds %>%
  select(Change, .pred_class) %>%
  write.csv("Results/PredictionsTruthRFBaseline.csv")
rf_truebest_wkfl_preds %>%
  select(Change, .pred_class) %>%
  write.csv("Results/PredictionsTruthRFBest.csv")

# Set the metrics to calculate
bfast_metrics <- metric_set(accuracy, 
                            roc_auc, 
                            precision, 
                            recall,
                            f_meas)

# Calculate metrics and write them to disk
rf_baseline_wkfl_preds %>%
  bfast_metrics(truth = Change, 
                estimate = .pred_class,
                event_level = "second", #To focus evaluation on 1
                .pred_1) %>%
  write.csv("Results/EvalMetricsRFBaseline.csv")
rf_truebest_wkfl_preds %>%
  bfast_metrics(truth = Change, 
                estimate = .pred_class,
                event_level = "second", #To focus evaluation on 1
                .pred_1) %>%
  write.csv("Results/EvalMetricsRFBest.csv")
```

Additionally, you might be interested in obtaining the ROC curves of each model, so you can do it using the following script. In this step, we will create a data frame containing the ROC curves, which can afterwards used to construct a plot showing this results.

```r
# ROC plots
rf_baseline_roc <- rf_baseline_wkfl_preds %>%
  roc_curve(truth = Change, 
            event_level = "second",
            .pred_1)  %>%
  add_column(Model = "Baseline")
rf_truebest_roc <-rf_truebest_wkfl_preds %>%
  roc_curve(truth = Change, 
            event_level = "second",
            .pred_1) %>%
  add_column(Model = rf_best_model_id)

plotter_rf <- bind_rows(rf_baseline_roc, rf_truebest_roc) %>%
  mutate("1 - specificity" = 1-specificity) 
```

The last step of the workflow is to spatialize the model, i.e., apply the model using the rasters to obtain a final disturbance / non-disturbance map.

```r
# Use model to make raster
# Function for applying model to rasters and obtain a raster as results
fun<-function(...){
  p<-predict(...)
  return(as.matrix(as.numeric(p[, 1, drop=T]))) 
}

# Make prediction
rf_baseline_pred_im <- raster::predict(im1, 
                              model = rf_baseline_fit_notlast, 
                              type="class", 
                              fun=fun)
# Write raster
writeRaster(rf_baseline_pred_im,
            paste0("ClassRaster/RFBaselineClass_","pred_AllForest.tif"),
            format = "GTiff",
            overwrite = T)

# Make prediction
rf_truebest_pred_im <- raster::predict(im1, 
                              model = rf_truebest_fit_notlast, 
                              type="class", 
                              fun=fun)
# Write raster
writeRaster(rf_truebest_pred_im,
            paste0("ClassRaster/RFTruebestClass_","pred_AllForest.tif"),
            format = "GTiff",
            overwrite = T)
```