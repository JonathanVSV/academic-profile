---
title: "Presentations in R"
date: 2022-10-17T17:08:00-00:00
categories:
  - blog
tags:
  - post
  - r
  - xaringan
  - presentation
  - slides
  - powerpoint
layout: splash
---

# Presentations in R

Using the `xaringan` package, you can construct beautiful presentations using R. Essentially, the RMarkdown syntax is used to add text, tables and figures.

## Syntax summary

```md
--- to start a new slide
-- to show additional content in the same slide (previously hidden).
```

### Titles

Set titles.

```md
# Header 1
# Header 2
# Header 3
```

### Highlight

Highlight words in italic or bold font.

```md
_italic_, **bold**
```

### Lists

You can choose between three different types of lists: hyphens, numbered and bullets.

Hyphens
```md
- a
- b
```

Numbered
```md
1. a
2. b
```

Bullets
```md
* a
* b
```

### Add images

Although you can add images directly with markdown, I recommend using `knitr` to include images using r code. This way you can better control the size of the image (instead of using directly its size) and setting other options as its alignment.

```md
\`\`\`{r echo=F, out.width="90%", fig.align="center"}
knitr::include_graphics("img/test.png")
\`\`\`

```

### Two columns

There are two default styles to set the objects inside the slides in a two-column format: 

The first one puts your slides in two columns with each one expanding aprox. 50 % of the total width of the slide

```md
.pull-left[
  your content
]
.pull-right[
  your content
]
```

The second one puts your slides in two columns with the first expanding aprox. 25 % of the total width of the slide, and the second, 75 %.

```md
.left-column[
  your content
]
.right-column[
  your content
]
```

### Changing slide class

You can add special slides with a different theme than the default. One commonly used is the 'inverse' class, which is the theme used for the starting slide. Additionally, you can set other classes such as 'center' or 'bottom' or combine them to set the position of the text.

```md
class: center, bottom, inverse
```

### Background images

You can add images as background for certain slides by selecting the image and setting its position and size.

```md
background-image: url("img/end.png")
background-position: 50% 50%
background-size: cover
```

### Tables

You can use `kable` inside the `knitr` package to draw formatted tables.

```md
knitr::kable(tab1, 
             format = "html",
             table.attr = "style='width:80%;'") |>
  kable_styling(bootstrap_options = c("striped"), 
                full_width = T,
                font_size = 14) 
```

### Formulas

You can add formulas or use mathematica notation using `$$ $$` for equations or `$ $` for mathematical notations.

```md
$$OA = \displaystyle \frac {TP + TN} {TP + TN + FP + FN}$$
```

### Knit

Finally, when the document is ready, knit the document (string ball icon in Rstudio) to create the html file with the slides.

## Minimal example

In the following code the R code blocks are indicated with \`\`\` instead of the three block quotes

```yml

# Title slide

---
title: "My presentation"
author: |
    | Myself
    | Others
institute: "My Company"
date: "27/05/2022"
output:
  xaringan::moon_reader:
    css: [default, default-fonts, mystyle.css]
lib_dir: libs
nature:
  highlightStyle: github
highlightLines: true
countIncrementalSlides: false
---

```

```md  
\`\`\`{r setup, include=FALSE}
library(tidyverse)
library(kableExtra)
\`\`\`

# First slide

Text

\`\`\`{r echo=F, out.width="50%", fig.align="center"}
knitr::include_graphics("img/rxar.png")
\`\`\`

---
# Second slide

List:
  - 1.
  - 2. 
  - 3.
  - 4.

# Empty line
&nbsp;<br>

# Another image

\`\`\`{r echo=F, out.width="10%", fig.align="center"}
knitr::include_graphics("img/xaringan.png")
\`\`\`

---
# Third slide

.pull-left[
text at left
]

.pull-right[
text at right
]

---
# Fourth slide

A table.

\`\`\`{r echo=F, out.width="100%"}

tab1 <- data.frame(a = 1:4,
                   b = 4:7,
                   c = 5:8,
                   d = 12:15)

knitr::kable(tab1, 
             escape = FALSE, 
             format = "html",
             table.attr = "style='width:100%;'",
             col.names = c("0", 
                           "1", 
                           "2", 
                           "3"),
             align = c("l", rep("r", 3))) |>
  kable_styling(bootstrap_options = c("striped"), 
                full_width = T,
                font_size = 14) |>
  kableExtra::row_spec(1, extra_css = "border-top: 1px solid")
\`\`\`

---
background-image: url("img/r.png")
background-position: 50% 50%
background-size: cover
class: center, bottom, inverse

# ¡Thx!

## contact

```

The result is the following (click on the following broken link image to view the pdf presentation).

![Resulting slides](/assets/images/presentation.pdf)