---
title: "Landscape metrics in R"
date: 2023-01-14T11:52:00-00:00
categories:
  - blog
tags:
  - post
  - r
  - landscape ecology
  - landscape metrics
  - patch metrics
  - fragmentation
  - connectivity
  - fragstats
layout: splash
---

# Landscape metrics in R

Landscape metrics are frequently used in landscape ecology to asses the spatial structure of a landscape. Thus, these metrics usually summarise fragmentation and connectivity patterns. The usual inputs to calculate thees metrics is a classification which has the spatial structure of different land covers / land uses.

## Data

For this example, I am going to use a raster obtained from the Global Forest Watch dataset, where I defined forest as those areas with higher than 70 % tree cover in the 2000 and then used the year of loss bands to calculate the remaining forest cover for each year. Additionally, we are going to use a landscapes extent shape, which cover the regions of interest.

```r
library(sf)
library(tidyverse)
library(stars)
library(tmap)
library(landscapemetrics)

forest <- read_stars("Data/GFC_remainingForest_2000-2021.tif")
plots <- st_read("Data/landscapes.shp")
```

## Landscape metrics calculation

The first to do is crop the image to the extent of the rois

```r
# Crop to roi
forest <- st_crop(forest, st_bbox(plots))

# Check everything is ok 
plot(forest)
```

Then you can clip the image to the rois, so the landscape metrics are calculateed for each roi. In this step, you need to convert the image object from starts proxy oboject to stars, thus, that's the reason to do the `st_as_stars`. Here we are analyzing only the roi's; however, you could also use a moving window approach to calculate the metrics for each pixel neighborhood.

```r
list_3y_plots <- lapply(1:dim(forest)[3], function(i){
  # Select i band
  x <- st_as_stars(forest[,,,i])
  # Reclassify raster into 1 and NA
  # x[x<1] <- NA
  lapply(1:nrow(plots), function(j){
    x[plots |>
        slice(j)]
  })
})
```

Then, you can define the metrics of interest to calculate for each landscape. You can consult the complete list of metrics in: https://r-spatialecology.github.io/landscapemetrics/reference/index.html

```r
# Define type of metrics that we want
metrics <- list_lsm(level = "class", 
                    type = c("aggregation metric"), #, "area and edge metric"), 
                    simplify = TRUE)
```

Then, calculate each metric for each lanscape

```r
# Calculate metrics
metris_3y <- lapply(list_3y_plots, function(x){
  lapply(x, function(y){
    calculate_lsm(y, 
                  what = metrics,
                  full_name = TRUE)
  })
})

names(metris_3y) <- 1:dim(forest)[3]
```

Make some wrangling to get the data outside the nested lists and bind them into a single dataframe.

```r
# Rename nested lists
for(i in 1:length(metris_3y)){
  names(metris_3y[[i]]) <- plots$Paisaje
}

metris_3y_bis <- lapply(metris_3y, function(x){
  bind_rows(x, .id = "plot")
})

metris_3y_bis <- bind_rows(metris_3y_bis, .id = "year")
```

Filter to stay only with the class of interest and write the results to a csv.

```r
# Filter only to stay with class 1 metrics (i.e., forest)
metris_3y_bis |>
  filter(class == 1) |>
  write.csv("Results/forest_class_aggr_metrics_3y_byplot.csv")
```
