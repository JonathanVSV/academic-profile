---
title: "3D histograms in R"
date: 2023-01-06T15:57:00-00:00
categories:
 - blog
tags:
 - post
 - r
 - ggridges
 - 3d histograms
 - pretty plots
layout: splash
---

# 3D histograms in R

In this post I am going to show you how to construct a beautiful 3D histogram that can be a very nice way to show your frequency data. For this, I will use the `ggridges` package.

## ggridges

The `ggridges` package has functions to construct 3d histograms.

For this example we are going to load some data of the number of observations of Sentinel-2 1C images over different ecorregions in Mexico.
Here's an extract of that table, containing the frequency of pixels with number of valid observations (y2). The data was reduced to preserve the proportions with a smaller number of observations.

| desc_id                 | year | month | labels | y2 |
|-------------------------|------|-----|-----|---|
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 2 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 2 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 2 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 2 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 2 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 2 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 2 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 2 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 2 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 2 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 2 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 2 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 2 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 2 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 2 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 2 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 2 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 2 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 2 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 2 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 2 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 2 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 2 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 2 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 2 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 2 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 2 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 3 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 3 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 3 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 3 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 3 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 3 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 3 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 3 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 3 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 3 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 3 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 3 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 3 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 3 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 3 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 3 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 3 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 3 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 3 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 3 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 3 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 3 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 3 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 3 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 1 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 1 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 1 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 1 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 1 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 1 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 1 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 1 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 1 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 1 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 1 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 1 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 1 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 1 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 1 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 1 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 1 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 1 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 1 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 1 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 4 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 4 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 4 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 4 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 4 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 4 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 4 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 4 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 4 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 4 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 4 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 4 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 4 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 4 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 5 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 5 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 5 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 5 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 5 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 5 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 6 |
| Selvas  Calido  Humedas | 2018 | 1   | 5   | 0 |

```r
library(tidyverse)
library(ggridges)

df <- read.csv("Data/Ridges_plot2.csv")
```

Then we will calculate the mean for the groups of interest (ecoregion, month and year) and join them to the original df.

```r
temp <- df |>
  group_by(desc_id, month, year) |>
  summarise(mean = mean(y2)) |>
  ungroup() |>
  group_by(desc_id, year) |>
  arrange(desc(mean)) |>
  filter(year >= 2018) |>
  select(desc_id, year, month)

df <- df %>%
  left_join(temp, by = c("desc_id", "year", "month"))
```

Then we can create the 3d histogram with `geom_density_ridges_gradient` and save it as jpeg.

```r
df |>
  filter(year >= 2018) |>
  ggplot(aes(x = y2, 
             y = factor(month, levels = seq(1,12,1)),
             fill = after_stat(x))) +
  geom_density_ridges_gradient(scale = 2.10,
                               rel_min_height = 0.01,
                               alpha = 0.5,
                               gradient_lwd = 1,
                               panel_scaling = F,
                               show.legend = F,
                               bandwidth = 1) +
                               #quantile_lines=TRUE,
                               #quantile_fun=function(x,...)mean(x)) +
  scale_fill_viridis_c(name = "Número \nobservaciones",
                      #type = "seq",
                      #palette = "RdGn",
                      direction = -1,
                      alpha = 0.6,
                      option = "viridis") +
  scale_alpha(range = c(0.2,0.3)) +
  scale_x_continuous(limits = c(0,15.5),
                     breaks = seq(0,15,3),
                     expand = c(0,0.5)) +
  facet_grid(desc_id~year) +
  labs(x = "Número de observaciones",
       y = "Mes") +
  theme_bw() +
  theme(strip.background = element_rect(fill = "gray90"),
        strip.text.y = element_text(angle=0),
        axis.text.x = element_text(angle = 90,
                                   vjust = 0.5),
        text = element_text(size = 12),
        axis.text.y = element_text(size = 8)) 

ggsave("Plots/Histogramas_mensuales_ggridges.jpeg",
       width = 16,
       height = 28,
       units = "cm",
       dpi = 350)
```

![3D histogram with ggridges.](/assets/images/Histogramas_mensuales_ggridges.jpeg)]
