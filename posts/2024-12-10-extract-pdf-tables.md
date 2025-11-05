---
title: "Extract tables from pdf in R"
date: 2024-12-12T13:19:00-00:00
categories:
  - blog
tags:
  - post
  - r
  - tabulizer
  - pdf
  - extract tables
layout: splash
---

This blog entry will show how to extract tables from a pdf, using tabulizer.
Load necessary packages.

```r
library(tabulizer)
library(tidyverse)
```

Read the pdf of interest, indicating the pages in which the table is located.

```r
table1 <- extract_tables("IUCN_mesoamerica_restoration.pdf",
                            output = "data.frame",
                            pages = c(388:417), 
                            area = NULL,
                            guess = TRUE
                            
)
```

Then join tables located in different pages as the same table. Substitute empty cells by NA and locate extra rows based on the NA located in the first column (Familia). Then join extra rows with the previous one.

```r
# Unir listas como filas de un mismo dataframe
exp_table <- dplyr::bind_rows(table1)
# Sustituir espacios en blanco por NA
exp_table[exp_table==""] <- NA
# Ver dónde hay NA en la columna de Familias para identificar filas extra
inds <- which(is.na(exp_table$Familia))

# PAra esas filas extra pegar el texto con la fila anterior
for(i in inds){
  if(!is.na(exp_table$Hábitat[i])){
    exp_table$Hábitat[(i-1)] <- paste(exp_table$Hábitat[(i-1)], exp_table$Hábitat[i], collapse = " ")  
  }
  if(!is.na(exp_table$Distribución[i])){
    exp_table$Distribución[(i-1)] <- paste(exp_table$Distribución[(i-1)], exp_table$Distribución[i], collapse = " ")
  }
}

```

Finally, export the result to a csv

```r
# Exportar
exp_table |>
  # Quitar columnas con NA en la columna familia
  filter(!is.na(Familia)) |>
  # Escribir
  write.csv("IUCN_ApendiceA1.csv",
            row.names = FALSE,
            fileEncoding = "UTF-8")
```