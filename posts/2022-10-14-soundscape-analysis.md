---
title: "Soundscape analysis in R"
date: 2022-10-14T17:08:00-00:00
categories:
  - blog
tags:
  - post
  - r
  - soundscape
  - sound ecology
  - passive acoustic monitoring
layout: splash
---

# Soundscape in R

## Introduction

Soundscape can be defined as the collection of sounds that are recorded from a particular landscape. Soundscapes typically can have three main components: biophony, geophony and anthropohony. Depending on the type of landscape and weather conditions certain components can be the predominant ones.

There are two approaches for studying soundscapes: 1) focusing on the complete soundscape without getting to know the identity of each species, 2) identifying each species in its sound signal. For this example, the first approach was chosen to analyse the data.

In this approach there are several indices you can calculate from the spectrogram. Each one focusing on different aspects of the heterogeneity of the spectral signals. Here is a brief list of the possible indices that can be calculated in R.

- Acoustic complexity index.
- Acoustic entropy index.
- Acoustic richness index.
- Number of frequency peaks.
- Amplitude index.
- Normalized difference soundscape index.
- Spectral entropy.
- Temporal entropy.
- Acoustic diversity index.
- Acoustic eveness.

## Spectrograms

Spectrograms are visual representations of recordings that can help identify the frequency at which sounds ocurr, as well as temporal patterns. For example, this is a spectrogram showing the sounds of a recording in a tropical rainforest. Please notice that the x-axis represents time in the recording, the y-axis, the dominant frequency in each sound and the color represents the instensity (or magnitude) of the sound in dB.

![Spectrogram](/assets/images/spectro.jpeg)]


The code to construct the previous spectrogram is the following

```r
audio <- readWave(file,
                  from = 5,
                  to = 200,
                  units = "seconds")

spectro(audio,
        f = 24000,
        wl = 512,
        flim = c(0,11.9),
        palette = viridis::viridis_pal(direction = -1,
                                       option = "magma"),
        collevels = seq(-35,0,5))
```

## Code to perform analysis

For this example, the acoustic diversity index will be calculated. Although the `soundscape` package contains a function that enables computing certain indices in parallel, a new function to do exactly that with any of the previous indices will be made.

First, we need to load the required packages and define some variables

```r
library(tuneR)
library(seewave)
library(audio)
library(phonTools)
library(tibble)
library(soundecology)
# library(kableExtra)
library(dplyr)
# library(pbapply)
library(ggplot2)
library(stringr)
# library(foreach)
# library(doParallel)
library(progress)
library(doSNOW)

# Variables

# Second to start analysis from recordings
start <- 5
# Second to end analysis from recordings 
end <- 290
# Threshold in decibels to ignore noise or background noise from sounds
threshdB <- -35
# Max frequency to be analysed
max_freq <- 12000
# Width of frequency bins used to make the spectrogram
freq_step <- 1000

# Lower freq for high pass filter
lowfreq <- 200
# Number of cores to make parallel processing
numCores <- 5 #parallel::detectCores(logical = F)-1
```

Next, we should locate the files that are going to be analysed.

```r
#--------------------Read files-------------------------------------
site <- "MySite"
audios <- list.files(paste0("E:/Data/Audios/", site),
                     "*.wav",
                     full.names = T,
                     include.dirs = T,
                     recursive = T)
```

Then, we need to define the functions we are going to use.
In this case, a filter function will be used to filter the sounds.

```r
# -------------------------Define functions---------------------------
filter_fun <- function(audio,
                       filtering = "none",
                       # frequency = 8000,
                       lower = 200,
                       higher = 9000){

  frequency <- audio@samp.rate

  # Filter low-pass
  if(filtering == "none"){
    audio2 <- audio
  }
  if(filtering == "low"){
    audio2 <- ffilter(audio,
                      f = frequency,
                      to = higher,
                      rescale = F)
  }
  if(filtering == "high"){
    audio2 <- ffilter(audio,
                      f = frequency,
                      from = lower,
                      rescale = F)
  }
  if(filtering == "band-pass"){
    audio2 <- ffilter(audio,
                      f = frequency,
                      from = lower,
                      to = higher,
                      rescale = F)
  }
  if(filtering == "band-stop"){
    audio2 <- ffilter(audio,
                      f = frequency,
                      from = lower,
                      to = higher,
                      rescale = F,
                      bandpass = FALSE)
  }
  if(filtering != "none"){
    audio <- Wave(audio2,
                  samp.rate = audio@samp.rate,
                  bit = audio@bit)
  }
  audio
}
```

Then a function is going to be made to calculate the alpha diversity indices of interest. In this case, only the acoustic diversity will be calculated. 

```r
alpha_ind <- function(audio){

  # Spectral entropy, calculated from the spectrogram, scaled between 0 and 1, also known as Pielou's eveness index,
  # SE = sh(spec(audio,
  #              f = 24000,
  #              wl = 512,
  #              flim = c(0,12)))
  # dividing the spectrogram into bins (default 10, each one of 1000 Hz) and taking the proportion of the signals in each bin above a threshold (default -50 dBFS). The ADI is the result of the Shannon index applied to these bins.
  AD = acoustic_diversity(audio,
                          max_freq = max_freq,
                          db_threshold = threshdB,
                          freq_step = freq_step)$adi_left

  tibble(AD)
}
```

And finally, the function that will include the previous two functions: filtering and calculating the alpha diversity indices.

```r
calc_f <- function(x){
  audio1 <- readWave(x,
                     from = start,
                     to = end,
                     units = "seconds")
  audio_f1 <- filter_fun(audio1,
                         filtering = "high",
                         lower = lowfreq)#,
  #higher = 9000)
  resul1 <- alpha_ind(audio1)
  resul1 |>
    mutate(file = x) |>
    select(file, AD) |>
    as.data.frame()
}
```

Then we can make the process in parallel and export a csv with the calculated indices, one for each file.

```r
# ------------------------Start parallel process--------------------------------

# registerDoParallel(numCores)

cl <- makeCluster(numCores)
registerDoSNOW(cl)

# Progress bar
pb <- txtProgressBar(max = length(audios), style = 3)
progress <- function(n) setTxtProgressBar(pb, n)
opts <- list(progress = progress)

df <- foreach(x = audios,
              .combine = rbind,
              .packages = c("seewave",
                            "dplyr",
                            "tuneR",
                            "soundecology"),
              .options.snow = opts) %dopar% {

  try(calc_f(x))

}

stopCluster(cl)
close(pb)

write.csv(df,
          paste0("Results/All",site,"_thresh",threshdB,"maxFreq",max_freq,".csv"))
```
