---
title: "Map accuracy in R"
date: 2025-03-17T16:34:00-00:00
categories:
  - blog
tags:
  - post
  - r
  - map accuracy
  - unbiased area estimates
  - map validation
  - Olofsson
  - stratified random sampling
layout: splash
---

# Map accuracy in R

This post will show you how to validate a classification map using the Olofsson et al., 2014 best practices protocol and the `mapaccuracy` package.

```r
library(mapaccuracy)
library(tidyverse)
```

## Data

This data simulates the map accuracy results obtained from a stratified random sampling. This validation procedure is a modification of the Olofsson et al., 2014 recommendations, in which a buffer stratum is used to try to contain omission errors in the rarest classes (i.e., deforestation), following recommendations by Olofsson et al., 2020 and Arévalo et al., 2021.

The two datasets you will need to obtain the validation main results are: area estimates (obtained from cell counting in the classification) and results obtained from the stratified random sampling indicating the map (i.e., classified) and reference (i.e., visual interpretation of field data) classes.

```r
areas2 <- tibble(Clase = c("Forest loss", "Perm Forest", "Perm Non-forest", "Buff Perm Forest", "Buff Perm Non-forest"),
                 ha = c(5, 1950, 8000, 50, 25))

df <- tibble(Map = c(rep("Forest loss", 50),
                      rep("Perm Forest", 360),
                      rep("Perm Non-forest", 90),
                      rep("Buff Perm Forest", 50),
                      rep("Buff Perm Non-forest", 25)),
             Reference = c(rep("Forest loss", 43),
                            rep("Perm Non-forest", 2),
                            rep("Perm Forest", 5),
                            rep("Perm Non-forest", 10),
                            rep("Perm Forest", 350),
                            rep("Perm Non-forest", 81),
                            rep("Perm Forest", 9),
                            rep("Buff Perm Forest", 48),
                            rep("Forest loss", 2),
                            rep("Buff Perm Non-forest", 25)))
```

## Process

Convert area estimates to a vector with names and calculate the total area.

```r
areas <- areas2$ha
names(areas) <- areas2$Clase

totalarea <- sum(areas2$ha)
```

Then, let's calculate the map accuracy estimates using Olofsson et al., 2014 equations.

```r
resul <- olofsson(df$Reference, df$Map, Nh = areas)
```

Here, the results object contains estimates such as: Overall accuracy, User's accuracy, Producer's accuracy, unbiased area estimates (as proportion), Standard error of the accuracies (overall, user's and producer's) and area estimates, and the matrix expressed in area weights.  

```r
resul
# $OA
# [1] 0.9145696
# 
# $UA
# Forest loss         Perm Forest      Perm Non-forest    Buff Perm Forest 
# 0.8600000           0.9722222           0.9000000           0.9600000 
# Buff Perm Non-forest 
# 1.0000000 
# 
# $PA
# Forest loss         Perm Forest      Perm Non-forest    Buff Perm Forest 
# 0.6825397           0.7031153           0.9925057           1.0000000 
# Buff Perm Non-forest 
# 1.0000000 
# 
# $area
# Forest loss         Perm Forest      Perm Non-forest    Buff Perm Forest 
# 0.0006281157        0.2688268528        0.7232668661        0.0047856431 
# Buff Perm Non-forest 
# 0.0024925224 
# 
# $SEoa
# [1] 0.02542024
# 
# $SEua
# Forest loss         Perm Forest      Perm Non-forest    Buff Perm Forest 
# 0.049569576         0.008673299         0.031799936         0.027994168 
# Buff Perm Non-forest 
# 0.000000000 
# 
# $SEpa
# Forest loss         Perm Forest      Perm Non-forest    Buff Perm Forest 
# 0.152157323         0.066365204         0.002328898         0.000000000 
# Buff Perm Non-forest 
# 0.000000000 
# 
# $SEa
# Forest loss         Perm Forest      Perm Non-forest    Buff Perm Forest 
# 0.0001417231        0.0254198567        0.0254198515        0.0001395522 
# Buff Perm Non-forest 
# 0.0000000000 
# 
# $matrix
# Forest loss  Perm Forest Perm Non-forest Buff Perm Forest
# Forest loss        0.0004287139 4.985045e-05   1.994018e-05               NA
# Perm Forest                     NA 1.890163e-01   5.400465e-03               NA
# Perm Non-forest                  NA 7.976072e-02   7.178465e-01               NA
# Buff Perm Forest      0.0001994018           NA             NA      0.004785643
# Buff Perm Non-forest             NA           NA             NA               NA
# sum                   0.0006281157 2.688269e-01   7.232669e-01      0.004785643
# Buff Perm Non-forest          sum
# Forest loss                       NA 0.0004985045
# Perm Forest                          NA 0.1944167498
# Perm Non-forest                       NA 0.7976071785
# Buff Perm Forest                     NA 0.0049850449
# Buff Perm Non-forest         0.002492522 0.0024925224
# sum                         0.002492522 1.0000000000
```

Afterward, you need to sum some area estimates and errors to merge the buffer classes with the total classes (e.g., Buff Perm Forest with Perm Forest). And calculate the lower and upeer limits of the unbiased area estimates, assuming a normal distribution. The classes you need to sum will vary depending on the sampling design used to validate the map.

```r
exp_df <- tibble(clase = names(resul$area),
                 area = resul$area * totalarea,
                 SEa = resul$SEa * totalarea)

# Sum errors
exp_df$areaSum <- 0
exp_df$SEaSum <- 0

# Perm Forest
exp_df$areaSum[2] <- exp_df$area[2] + exp_df$area[5]
exp_df$SEaSum[2] <- exp_df$SEa[2] + exp_df$SEa[5]

# Perm Non-forest
exp_df$areaSum[3] <- exp_df$area[3] + exp_df$area[4]
exp_df$SEaSum[3] <- exp_df$SEa[3] + exp_df$SEa[4]

# Forest loss
exp_df$areaSum[1] <- exp_df$area[1]
exp_df$SEaSum[1] <- exp_df$SEa[1]

exp_df |>
  slice_head(n = 3) |>
  mutate(LIC = areaSum - 1.96 * SEaSum,
         UIC = areaSum + 1.96 * SEaSum) 
```

And you get your unbiased area estimates with a confidence interval.

```r
# A tibble: 3 × 7
# clase             area    SEa areaSum SEaSum     LIC     UIC
# <chr>             <dbl>  <dbl>   <dbl>  <dbl>   <dbl>   <dbl>
# 1 Forest loss     6.3    1.42     6.3   1.42    3.51    9.09
# 2 Perm Forest     2696.  255.    2721.  255.   2222.   3221.  
# 3 Perm Non-forest 7254.  255.    7302.  256.   6800.   7805.  
```

## References

Arévalo, P., Olofsson, P., & Woodcock, C. E. (2020). Continuous monitoring of land change activities and post-disturbance dynamics from Landsat time series: A test methodology for REDD+ reporting. Remote Sensing of Environment, 238, 111051. https://doi.org/10.1016/j.rse.2019.01.013

Olofsson, P., Foody, G. M., Herold, M., Stehman, S. V., Woodcock, C. E., & Wulder, M. A. (2014). Good practices for estimating area and assessing accuracy of land change. Remote Sensing of Environment, 148, 42–57. https://doi.org/10.1016/j.rse.2014.02.015

Olofsson, P., Arévalo, P., Espejo, A. B., Green, C., Lindquist, E., McRoberts, R. E., & Sanz, M. J. (2020). Mitigating the effects of omission errors on area and area change estimates. Remote Sensing of Environment, 236. https://doi.org/10.1016/j.rse.2019.111492

