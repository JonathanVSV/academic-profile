---
title: "Regular expressions in R"
date: 2022-03-05T10:34:30-04:00
categories:
  - blog
tags:
  - post
  - r
  - regular expressions
  - strings
  - characters
layout: splash
---

# Regular expressions in R

Regular expressions in R are a very useful way to work with strings and patterns found in them. For this exercise we are going to use the `stringr` package.

Regular expressions are expressions that describe patterns in strings. They are very useful to find general patterns instead of having to indicate every possible combination. For example, you can use regular expressions to find letters, numbers and other special characters.

## Escaping special characters

Using regular expressions you need to escape special characters. For example, special characters such as `.` or `\`, need to be escaped with a preceding `\\`. Thus, to look for a point in a string you would use `\\.`. Other specual characters such as punctutaion characters, parentheses and brackets need to be escaped.

## Groups of characters

Regular expressions enable looking for groups of characters. For example, letters, numbers, spaces, etc. Such groups of characters are usually written `[:group:]`. Examples of these groups are: 

```r
[:digit:] # digits
[:alpha:] # letters
[:lower:] # lowercase letters
[:upper:] # uppercase letters
[:alnum:] # letters and numbers
[:punct:] # punctuation
[:graph:] # all the previous
[:space:] # spaces
[:blank:] # space and tab
. # every character
```


## Quantifiers

Additionally, to indicating groups of characters, you can indicate how many instances of the character or group of characters you are interested in finding. The quantifiers are:

```r
x? # zero or one
x* # zero or more
a+ # one or more
x{n} # n times
x{n,} # n or more
x{n,m} # between n and m
```

Let's do a simple example with `tidyverse` that contains `stringr`. In this example we will use `str_extract` that extracts only the first match with the indicated pattern. If you wish to extract all the matches, you might use `str_extract_all` and then `unnest`.

```r
library(tidyverse)

df1 <- tibble(char = c("letters", "LETTERS", 43561, "lett342", "letters321;ok.no"))

df1 |>
  mutate(letter = str_extract(char, "[:alpha:]"),
         letters = str_extract(char, "[:alpha:]+"),
         numbers = str_extract(char, "[:digit:]+"),
         punct = str_extract(char, "[:punct:]"))
```

Resulting in the following:

```r
## A tibble: 5 x 5
#  char             letter letters numbers punct
#  <chr>            <chr>  <chr>   <chr>   <chr>
#1 letters          l      letters NA      NA   
#2 LETTERS          L      LETTERS NA      NA   
#3 43561            NA     NA      43561   NA   
#4 lett342          l      lett    342     NA   
#5 letters321;ok.no l      letters 321     ;  
```

## Position in string

Additional expressions can refer to the position of a pattern in a string. For example, if the pattern is at the start or end of the string.

```r
^x # start of the string
x$ # end of the string
```

## More specific groups

If you are not intereseted in any of the general groups of characters you can create your own group of characters of interest. This can be done with the following expressions.

```r
x|y # or
[xy] # one of
[^xy] # anything but 
[a-f] # range
```

Continuing with the example

```r
df1 |>
  mutate(a = str_extract(char, "[a-f]+"),
         b = str_extract(char, "[e|s]+"),
         c = str_extract(char, "[^t]+"),
         d = str_extract(char, "[ls]+"))
```

```r
## A tibble: 5 x 5
#  char             a     b     c       d    
#  <chr>            <chr> <chr> <chr>   <chr>
#1 letters          e     e     le      l    
#2 LETTERS          NA    NA    LETTERS NA   
#3 43561            NA    NA    43561   NA   
#4 lett342          e     e     le      l    
#5 letters321;ok.no e     e     le      l   
```

## Lookarounds

Lookarounds are used to include characters that precede or proceed after the pattern of interest that can help determine the exact pattern we are interested in. There are four lookarounds:

```r
x(?=y) # x followed by y
x(?!y)  # x not followed by y
(?<=y)x # x preceded by y
(?<!y)x # x not preceded by y
```

## General groups used afterwards

In some cases, you are not interested just in extracting a string pattern, but you might want to actually use that precise string (instead of the general pattern). In this cases, you might define groups using `()` and then refer to each group by its order of appearance.

For example, in this case we will replace "lett" for the first group character, which is only an "e".

```r
df1 |>
  mutate(a = str_replace(char, "l(e)tt", "\\1"))
```

```r
## A tibble: 5 x 2
#  char             a            
#  <chr>            <chr>        
#1 letters          eers         
#2 LETTERS          LETTERS      
#3 43561            43561        
#4 lett342          e342         
#5 letters321;ok.no eers321;ok.no
```