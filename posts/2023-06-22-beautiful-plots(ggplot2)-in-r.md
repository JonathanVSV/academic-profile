---
title: "Beautiful-plots(ggplot2)-in-r"
date: 2023-06-22T12:35:00-00:00
categories:
  - blog
tags:
  - post
  - r
  - ggplot2
  - plot
  - grammar of graphics
  - figures
layout: splash
---

# Beautiful plots in R using ggplot2

The purpose of this post is to show how to use the basic syntax of ggplot2, do some of the most common types of plots, as well as some customizations and facets. For this post we are going to use the iris dataset, as well as the skimr and cowplot packages. The first step consists of loading the desired packages, as well as the data and skimming over it. The first section will show some basic plots, while the next ones will show how to customize certain elements of the plots, like color, fill, facets and theme.

```r
library(ggplot2)
library(skimr)
library(cowplot)

data(iris)
skim(iris)
```

Then we can start building our different plots.

# Basic plots

## Scatterplot

```r
iris |>
  ggplot(aes(x = Sepal.Length, y = Sepal.Width)) +
  geom_point()
```

![Scatterplot.](/assets/images/scatter.png)]


## Line plot

```r
iris |>
  ggplot(aes(x = Sepal.Length, y = Sepal.Width)) +
  geom_line()
```

![Line plot](/assets/images/line.png)](

## Bar plot

```r
iris |>
  ggplot(aes(x = Species)) +
  geom_bar()
```

![Bar plot](/assets/images/bar.png)]


## Column plot

```r
iris |>
  group_by(Species) |>
  summarise(meanSL = mean(Sepal.Length)) |>
  ggplot(aes(x = Species,
             y = meanSL)) +
  geom_col()
```

![Column plot.](/assets/images/col.png)


## Box plot

```r
iris |>
  ggplot(aes(x = Species,
             y = Sepal.Length)) +
  geom_boxplot()
```

![Boxplot](/assets/images/box.png)


## Histogram plot

```r
iris |>
ggplot(aes(x = Sepal.Length)) +
  geom_histogram()
```

![Histogram](/assets/images/hist.png)


# Adding colors

## Color

```r
iris |>
  ggplot(aes(x = Sepal.Length, 
             y = Sepal.Width,
             col = Species)) +
  geom_point()
```

![Scatterplot with colors by factor.](/assets/images/color.png)


## Fill

```r
iris |>
  ggplot(aes(x = Species,
             fill = Species)) +
  geom_bar()
```

![Barplot with fill by factor.](/assets/images/fill.png)


## Customized colors

### Manual colors 

```r
iris |>
  ggplot(aes(x = Sepal.Length, 
             y = Sepal.Width,
             col = Species)) +
  geom_point() +
  scale_colour_manual(values = c("forestgreen", "royalblue", "firebrick2"))
```

![Scatterplot with manual colors by factor.](/assets/images/manualcol.png)


### Rcolorbrewer

```r
iris |>
  ggplot(aes(x = Sepal.Length, 
             y = Sepal.Width,
             col = Species)) +
  geom_point() +
  scale_colour_brewer(palette = "RdYlBu")
```

![Scatterplots with colors set by RColorbrewer.](/assets/images/colorbrewer.png)


# Axes

## Axes

```r
iris |>
  ggplot(aes(x = Sepal.Length, 
             y = Sepal.Width,
             col = Species)) +
  geom_point() +
  scale_y_continuous(breaks = seq(2, 4.5, 0.25),
                     limits = c(2, 4.5)) +
  scale_x_continuous(breaks = seq(4, 8, 0.5),
                     limits = c(4, 8))
```

![Scatterplot with customized axes.](/assets/images/axes.png)


## Axes labels

```r
iris |>
  ggplot(aes(x = Sepal.Length, 
             y = Sepal.Width,
             col = Species)) +
  geom_point() +
  labs(x = "Sepal length (cm)", 
       y = "Sepal width (cm)")
```

![Scatterplot with customized axes labels.](/assets/images/axeslab.png)


# Facets

## Facet grid

```r
iris |>
  ggplot(aes(x = Sepal.Length, 
             y = Sepal.Width,
             col = Species)) +
  geom_point() +
  facet_grid(~ Species)
```

![Scatterplot with facets set as a grid.](/assets/images/facetgrid.png)


## Facet wrap

```r
iris |>
  ggplot(aes(x = Sepal.Length, 
             y = Sepal.Width,
             col = Species)) +
  geom_point() +
  facet_grid(~ Species)
```

![Scatterplot with facets set as a wrap (multiple factors will be accumulated by each panel).](/assets/images/facetwrap.png)

# Theme

## Personalized theme

```r
my_theme <- theme_bw() + 
  theme(plot.title=element_text(size=18,hjust = 0.5),
        text=element_text(size=24,colour="black"),
        axis.text.x = element_text(size=18,
                                   colour="black",
                                   angle = 90, 
                                   hjust = 1,
                                   vjust = 0.5),
        axis.text.y = element_text(size=18,
                                   colour="black",
                                   angle = 0, 
                                   vjust = 0.5,
                                   hjust = 1),
        axis.title = element_text(size=18,
                                  colour="black",
                                  face = "bold"), 
        axis.line = element_line(colour = "black"),
        legend.title = element_text(size=18),
        legend.text = element_text(size=18),
        axis.line.x =element_line(colour="black"),
        axis.line.y =element_line(colour="black"),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        panel.border=element_blank(),
        panel.background=element_blank(),
        strip.background =element_rect(fill="gray90",
                                       colour = "black"),
        strip.text = element_text(size=18,
                                  colour="black",
                                  face = "bold"),
        plot.margin = unit(c(0.01,0.01,0.01,0.01), "cm"))

iris |>
  ggplot(aes(x = Sepal.Length, 
             y = Sepal.Width,
             col = Species)) +
  geom_point() +
  facet_wrap(~ Species) + 
  my_theme
```

![Scatterplot with facet wrap where several theme elements have been customized according to personal criteria.](/assets/images/mytheme.png)


## Cowplot theme

```r
iris |>
  ggplot(aes(x = Sepal.Length, 
             y = Sepal.Width,
             col = Species)) +
  geom_point() +
  facet_wrap(~ Species) + 
  theme_cowplot()
```

![Scatterplot with facet wrap where several theme elements have been customized according to the cowplot theme.](/assets/images/cowplottheme.png)]
