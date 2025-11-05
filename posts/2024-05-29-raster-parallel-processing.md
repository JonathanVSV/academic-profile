---
title: "Raster parallel processing in R"
date: 2024-05-29T21:46:00-00:00
categories:
  - blog
tags:
  - post
  - r
  - parallel
  - raster
  - doparallel
  - foreach
layout: splash
---

# Raster parallel processing in R

This post shows how to parallelize raster processing in R.

First load the required packages

```r
library(raster)
library(parallel)
library(doParallel)
library(foreach)
```

Then read a raster example from the terra package

```r
r <- raster(system.file("ex/elev.tif", package = "terra"))
r <- stack(r, r)
```

Initialize cluster and run process in parallel. Notice that inside the `foreach` you should indicate the packages that need to be loaded into the parallel processing.

```r
cls <- makeCluster(2L)
registerDoParallel(cls)
clust_list_t <- foreach(i = 1:2, 
                        .packages = "raster") %dopar% {
                          if(i == 1){
                            ras <- r[[i]] * 3
                          }else{
                            ras <- r[[i]] * 5
                          }
                          
                          return(ras)
                        }
```