---
title: "Web scraping with r"
date: 2023-06-09T18:19:00-00:00
categories:
  - blog
tags:
  - post
  - r
  - rvest
  - web scraping
  - website data extraction
layout: splash
---

# Web scraping with R

This post will show you how to get data from a webpage (also known as web scraping) with R and the rvest package. This analysis was performed to complement the data obtained from the spotify API. Since I could not obtain all the data I was interested in from the latter API, I decided to web scrape the bandcamp site.

The first thing is to load the necessary packages: rvest for the webscraping and purrr for making loops.

```r
library(rvest)
library(purrr)
library(stringr)
library(tibble)
library(tidyr)
library(dplyr)
```

Then, indicate the website of interest. In this case, bandcamp.

```r
site_url <- "https://bandcamp.com/"
```

Here is the dataframe I am going to use to consult the data from bandcamp.

```r
nogenre <- structure(list(artist = c("Discipline", "Back from the Futer", 
"La Plante Sauvage", "Quella Vecchia Locanda", "Daal", "Bobby Prince", 
"Greco Bastian", "Wayfarer", "Flub", "Schizofrnatik", "Endolith", 
"Energetic Mind", "Thanatopsis", "Mary Halvorson Octet", "4 ciénegas"
), album = c("Unfolded Like Staircase", "Aavikko", "Alain Goraguer", 
"Quella Vecchia Locanda", "Decalgue of Darkness", "Doom 2 OST", 
"Greco Bastian", "A Romance with Violence", "Flub", "Funk From Hell", 
"Voyager", "Bonniesongs", "Requiem", "Away With You", "Cuatro ciénegas"
), genre = c(NA_character_, NA_character_, NA_character_, NA_character_, 
NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, 
NA_character_, NA_character_, NA_character_, NA_character_, NA_character_, 
NA_character_), url = c(NA, NA, NA, NA, NA, "https://www.youtube.com/watch?v=OyHqGSO67wo", 
NA, NA, NA, NA, NA, NA, NA, NA, NA)), row.names = c(37L, 13L, 
77L, 113L, 32L, 19L, 60L, 151L, 54L, 121L, 49L, 50L, 137L, 95L, 
2L), class = "data.frame")
```

The next step is creating a function that will be used to make the search in bandcamp. Some additional tweaks had to be made so that the function worked. Most of this part was defined by playing with the bandcamp's search bar and annotating how the url of the search was processed. Then, you need to inspect the web page to see the names of the sections you are interested in extracting. Finally, I just made some data wragnling to clean the data and export it more homogeneously.

The main functions for webscraping with rvest are `read_html`, `html_node` and `html_text`. The first one enables reading the html code of the indicated url. The second one enables extracting one node or section of this web page and finally, the third one converts the extracted object into text.

```r
rvest_func <- function(x){
  band_orig <- x
  # These substitutions were based on trial and error on the bandcamp website.
  # Substitute spaces by + sign to work with the syntax used to search for terms with more than one word.
  band <- gsub("\\s", "+", band_orig)
  # Transform ñ into the translation made in the search bar
  band <- gsub("ñ", "%C3%B1", band)
  # Set the url to search for a particular band
  url_sub2 <- paste0('search?q=',band,'&item_type')
  
  # build the url to be scraped by combining the site url with the band url
  df1 <- paste0(site_url, url_sub2) |> 
    # scrape the html
    read_html() |> 
    # Inspect the web page to see which sections are available and select the name of the one of interest
    html_node('.result-info') |>
    # Get the entries of interes
    html_node('.tags.data-search') |>
    # Retrieve the data as text
    html_text() |>
    # Replace new lines for nothing
    str_replace_all("\n", "") |>
    # Remove the tag "tags:"
    str_replace_all("tags: ", "") |>
    # Substitute multiple spaces for a single one
    str_replace_all("\\s+", " ") |>
    # Remove spaces between commas, ^ or at the end of the string
    str_replace_all("(?<=\\,)\\s+|^\\s+|\\s+$", "")
  
  # Separate each genre into its own column
  df1 <- separate_wider_delim(tibble(genre = df1), 
                              col = genre, 
                              delim = ",",
                              names = paste0("genre", 1:20),
                              too_few = "align_start") |>
    # Transform data into long format
    pivot_longer(everything(),
                 names_to = c("name")) |>
    # Drop NA entries 
    drop_na(value) |>
    # Select the value column
    select(value) |>
    # Rename
    rename("genre" = "value")
  
  # Return a tibble with the band name and genres extracted from bandcamp
  resul <- tibble(artist = rep(band_orig, nrow(df1)),
                  genre = df1 |> pull(genre))
  return(resul)
  }
```

Use map to apply the functino to each artist. Use possibly as a TryCatch; thus, if no genre was found for certain artist it will return the message "Error in file".

```r
resul_exp_nogenre <- map(nogenre |>
                             pull(artist), 
                         possibly(rvest_func, 
                                  otherwise = "Error in file"))
```

Then add the genres as a new column to the previous dataframe and add a counter (llist) that indicates how many genres were associated with each artist.

```r
prenogenre <- nogenre |>
  # Add the list with extracted genres to the original df
  mutate(lista = resul_exp_nogenre) |>
  # Set a value that indicates if no genres were found for certain artits.
  # Put 0 if that is the case (using the possibly) or the number of genres found
  mutate(llist = map(1:length(resul_exp_nogenre), possibly(function(i){
    nrow(resul_exp_nogenre[[i]])
  }, otherwise = 0))) |>
  # unnest, extract elements from list.
  unnest(llist) 
```

Then eliminate entries without a genre, and unnest the genres list. Obtain the final data frame.

```r
nogenreFill <- prenogenre |>
  # Eliminate artist for which no genre was found
  filter(llist >= 1) |>
  # Unnest  lista column
  unnest(lista,
         names_repair = "universal") |>
  # Rename column names
  rename("artist" = "artist...1",
         "genre" = "genre...6") |>
  # Select columns of interest.
  select(artist, album, genre, url)
```

A snapshot of the result:

![Example of the data obtained after web scraping the bandcamp site.](/assets/images/rvesttable.png)
