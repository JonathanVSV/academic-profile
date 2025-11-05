---
title: "AGB forest sampling calculations"
date: 2023-07-17T17:42:00-00:00
categories:
  - blog
tags:
  - post
  - r
  - BiOMASS
  - AGB
  - community attributes
  - plot-level calculations
layout: splash
---

# AGB forest sampling calculations

This post shows an example of how to calculate some common plot-level variables from a forest sampling.

```r
library(BIOMASS)
library(stringr)
library(tidyverse)
```

Read data

```r
# Field data with individual tree measures
df <- read.csv("D:/Drive/Jonathan_trabaggio/Doctorado/R/Ayuquila_Degradation/CleanData/df_all.csv",
               na.strings = "NA")

# Coordinates of each site.
coords <- read.csv("D:/Drive/Jonathan_trabaggio/Doctorado/R/Ayuquila_Degradation/Data/gpscoords.csv")
```

How the headers of the data look like the following for the `df` object.

```r
     Nombre              Especie Observaciones DAP1 DAP2 DAP3 DAP4 DAP5 DAP6 DAP7 DAP8 DAP9 DAP10 DAP11
1      <NA>                 <NA>          <NA> 3.44   NA   NA   NA   NA   NA   NA   NA   NA    NA    NA
2      <NA>                 <NA>          <NA> 6.81   NA   NA   NA   NA   NA   NA   NA   NA    NA    NA
3  lysiloma Lysiloma divaricatum          <NA> 3.12   NA   NA   NA   NA   NA   NA   NA   NA    NA    NA
4 leocarpus      Heliocarpus sp.          <NA> 8.72   NA   NA   NA   NA   NA   NA   NA   NA    NA    NA
5    muerto                 <NA>          <NA> 4.04   NA   NA   NA   NA   NA   NA   NA   NA    NA    NA
6 leocarpus      Heliocarpus sp.          <NA> 3.34   NA   NA   NA   NA   NA   NA   NA   NA    NA    NA
  DAP12 DAP13 DAP14 DAP15 DAP16 DAP17 DAP18 DAP19 DAP20 DAP21 DAP22 DAP23 DAP24 Altura  parcela         x
1    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA   1.66 Amacuau1 19°53.904
2    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA   4.56 Amacuau1 19°53.904
3    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA   3.65 Amacuau1 19°53.904
4    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA   5.29 Amacuau1 19°53.904
5    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA   2.69 Amacuau1 19°53.904
6    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA   3.02 Amacuau1 19°53.904
           y cobertura register Observaciones.sitio id   DAP1.BA DAP2.BA DAP3.BA DAP4.BA DAP5.BA DAP6.BA
1 104°06.428     70-80      Yan                <NA>  1  9.294088      NA      NA      NA      NA      NA
2 104°06.428     70-80      Yan                <NA>  2 36.423704      NA      NA      NA      NA      NA
3 104°06.428     70-80      Yan                <NA>  3  7.645380      NA      NA      NA      NA      NA
4 104°06.428     70-80      Yan                <NA>  4 59.720420      NA      NA      NA      NA      NA
5 104°06.428     70-80      Yan                <NA>  5 12.818955      NA      NA      NA      NA      NA
6 104°06.428     70-80      Yan                <NA>  6  8.761588      NA      NA      NA      NA      NA
  DAP7.BA DAP8.BA DAP9.BA DAP10.BA DAP11.BA DAP12.BA DAP13.BA DAP14.BA DAP15.BA DAP16.BA DAP17.BA DAP18.BA
1      NA      NA      NA       NA       NA       NA       NA       NA       NA       NA       NA       NA
2      NA      NA      NA       NA       NA       NA       NA       NA       NA       NA       NA       NA
3      NA      NA      NA       NA       NA       NA       NA       NA       NA       NA       NA       NA
4      NA      NA      NA       NA       NA       NA       NA       NA       NA       NA       NA       NA
5      NA      NA      NA       NA       NA       NA       NA       NA       NA       NA       NA       NA
6      NA      NA      NA       NA       NA       NA       NA       NA       NA       NA       NA       NA
  DAP19.BA DAP20.BA DAP21.BA DAP22.BA DAP23.BA DAP24.BA
1       NA       NA       NA       NA       NA       NA
2       NA       NA       NA       NA       NA       NA
3       NA       NA       NA       NA       NA       NA
4       NA       NA       NA       NA       NA       NA
5       NA       NA       NA       NA       NA       NA
6       NA       NA       NA       NA       NA       NA
```

and like the following for the `coords` file.

```r
      name elevation       date         x        y     xutm    ytum
1   LIMON1 1118.1133 2022/05/12 -104.1652 19.83815 587412.5 2193788
2 AMACUAU1  998.5761 2022/05/13 -104.1071 19.89840 593460.8 2200486
```

# Fix taxonomy and get wood density for AGB calculation

The first step is to get the corrected names of the species registered in the field. This information will be used to get the wood density by species, genus or family, depending on what info is available in the global woodensity database. Then this wood density is going to be used to calculate AGB as

```r
# Separate genus and species
df <- df |>
  mutate(genus = str_extract(Especie, "[A-z]+(?= )"),
         species = str_extract(Especie, "(?<= )[A-z]+(?=)")) |>
  mutate(across(species, ~gsub("sp|sp.","NA",.x)))

# Correct taxo names
taxo <- correctTaxo(genus = df$genus, 
                    species = df$species, 
                    useCache = F, 
                    verbose = FALSE)

# Add as new columns
df <- df |>
  mutate(genuscorr = taxo$genusCorrected,
         speciescorr = taxo$speciesCorrected)

# Get family according to APG 3
APG <- getTaxonomy(df$genuscorr, findOrder = TRUE)

# Add to original df
df <- df |>
  mutate(family = APG$family)

# Get wood density
dataWD <- getWoodDensity(
  genus = df$genuscorr,
  species = df$speciescorr,
  family = df$family,
  region = "World",
  stand = df$parcela
)

# add as columns to df
df <- df |>
  mutate(meanwood = dataWD$meanWD,
         sdwood = dataWD$sdWD,
         levelwood = dataWD$levelWD,
         nInd = dataWD$nInd)

# Compute AGB for all DAP
df_agb <- df |>
  mutate(across(matches("DAP[0-9]+$"), ~ computeAGB(D = .x,
                                                    WD = meanwood,
                                                    H = Altura))) |>
  select(id, matches("DAP[0-9]+$"))

colnames(df_agb) <- c("id", paste0(("AGB"), seq(1,24)))

# Join AGB by id
df <- df |>
  left_join(df_agb, "id")
```

After these steps we now got the individual AGB for each stem and individual, as new columns of the original df. So the next step is going to calculate these same metrics for each individual (e.g., individual AGB sum of all of its stems). Watch that you might need to change some parameters of the `subplot_size` definition according to your own sampling design.

```r
# Max DAP, plot extent
subplot_size <- df|>
  select(id, matches("DAP[0-9]+$")) |>
  pivot_longer(cols = -id, 
               names_to = c("AGB")) |>
  drop_na(value) |>
  group_by(id) |>
  summarise(DAP_max = max(value)) |>
  mutate(subplot_size = case_when(DAP_max >= 5 ~ 500,
                                  DAP_max >= 2.5 & DAP_max < 5 ~ 29,
                                  DAP_max < 2.5 ~ 0))

# AGB sum
AGB <- df|>
  select(id, starts_with("AGB")) |>
  pivot_longer(cols = -id, 
               names_to = c("AGB")) |>
  drop_na(value) |>
  group_by(id) |>
  summarise(AGB_sum = sum(value))

# number of stems
Stems <- df|>
  select(id, starts_with("AGB")) |>
  pivot_longer(cols = -id, 
               names_to = c("AGB")) |>
  drop_na(value) |>
  group_by(id) |>
  summarise(Stem_sum = n())

# Basal area
BA <- df|>
  select(id, ends_with("BA")) |>
  pivot_longer(cols = -id, 
               names_to = c("BA")) |>
  drop_na(value) |>
  group_by(id) |>
  summarise(BA_sum = sum(value))

# Join previous calculation to original df
df <- df |>
  left_join(AGB, "id") |>
  left_join(BA, "id") |>
  left_join(Stems, "id") |>
  left_join(subplot_size, "id")

# Select variables of interest
df <- df |>
  select(parcela, x, y, cobertura, Observaciones.sitio, 
         id, subplot_size, AGB_sum, BA_sum, Stem_sum, Altura, 
         genuscorr, speciescorr, meanwood, levelwood,
         register) 
```

Now that we have the individual measures we need to calculate the per plot variables: AGBplot, BAplot, Dplot, Stemplot, Hmplot, H10plot. Since some of these measures are sums, extrapolated to 1 ha sums, means, etc, each one is summarised using the most common function to calculate it (e.g., AGB sum, height mean). Finally, we assume that the best registered coordinates are located in the  `coords` file; thus, these coordinates are pasted on to the final result.

```r
# -------------------Per plot variables------------------------------
# Summarise variables that need to be extrapolated
vars1 <- df |>
  group_by(parcela, subplot_size) |>
  # Sums by subplot_size
  summarise(AGBsubplot = sum(AGB_sum),
            BAsubplot = sum(BA_sum) / 10000,
            Dsubplot = n(),
            Stemsubplot = sum(Stem_sum)) |>
  # Extrapolate to 1 ha according to the subplot size
  mutate(across(c(AGBsubplot, BAsubplot, Dsubplot, Stemsubplot), ~.x * 10000 / subplot_size)) |>
  ungroup() |>
  group_by(parcela) |>
  # Sum both subplot estimates
  summarise(AGBplot = sum(AGBsubplot),
            BAplot = sum(BAsubplot),
            Dplot = sum(Dsubplot),
            Stemplot = sum(Stemsubplot))

# Calculate top 10 mean height
vars2 <- df |>
  group_by(parcela) |>
  slice_max(Altura, n = 10) |>
  summarise(H10plot = mean(Altura))

# Cover
vars3 <- df |>
  select(parcela, cobertura) |>
  separate(col = cobertura, 
           sep = "-",
           into = c("cob1", "cob2")) |>
  mutate(across(starts_with("cob"), ~as.numeric(.x))) |>
  group_by(parcela) |>
  summarise(cob = mean(c(cob1, cob2), na.rm = T))

# Mean height
vars4 <- df |>
  group_by(parcela) |>
  summarise(Hmplot = mean(Altura))

# Join all calculations
resul <- vars1 |>
  left_join(vars2, "parcela") |>
  left_join(vars3, "parcela") |>
  left_join(df |> 
              select(c(x, y, parcela)) |>
              distinct(parcela, .keep_all = T),
            "parcela") |>
  left_join(vars4, "parcela") |>
  select(parcela, x, y, cob, AGBplot, BAplot, Dplot, Stemplot, Hmplot, H10plot)

# Rename columns
colnames(resul) <- c("Plot", "Lat", "Long",
                     "Cob(%)", "AGB(Mgha-1)", "BA(m2ha-1)",
                     "Dplot(indha-1)", "Stemplot(stemha-1)",
                     "Hmean(m)", "H10mean(m)")

resul <- resul |>
  select(-c(Lat, Long))

coords <- coords |>
  rename("yutm" = "ytum") |>
  select(name, elevation, date, xutm, yutm) |>
  mutate(across(name, ~str_to_title(.x))) |>
  rename("Plot" = "name")

resul <- resul |>
  left_join(coords, "Plot") |>
  select(Plot, xutm, yutm, everything()) |>
  mutate(year = 2022)
```

Results look like the following.

```r
# A tibble: 2 × 13
  Plot     xutm   yutm `Cob(%)` `AGB(Mgha-1)` `BA(m2ha-1)` `Dplot(indha-1)` `Stemplot(stemha-1)` `Hmean(m)`
  <chr>   <dbl>  <dbl>    <dbl>         <dbl>        <dbl>            <dbl>                <dbl>      <dbl>
1 Amacu… 5.93e5 2.20e6       75          37.6         18.2            2919.                5159.       4.46
2 Limon1 5.87e5 2.19e6       75          52.8         29.4            2130.                4410.       3.77
# ℹ 4 more variables: `H10mean(m)` <dbl>, elevation <dbl>, date <chr>, year <dbl>
```