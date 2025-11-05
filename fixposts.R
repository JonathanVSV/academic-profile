library(tidyverse)

lista_arch <- list.files("posts/preposts",
           ".md",
           full.names = TRUE) 

df_exp <- lista_arch|>
  map(function(x) {
    df <- readLines(x, warn = FALSE)
    df <- str_replace_all(df, "\\{% highlight md %\\}", "```md") |>
      # str_replace_all("\\{% endhighlight %\\}", "```") |>
      str_replace_all("\\{% highlight r %\\}", "```r") |>
      # str_replace_all("\\{% endhighlight %\\}", "```") |>
      str_replace_all("\\{% highlight yml %\\}", "```yml") #|>
      # str_replace_all("\\{% endhighlight %\\}", "```")
  })

walk(1:length(df_exp), function(i){
    writeLines(df_exp[i], paste0("posts/",basename(lista_arch[i])))
  }) 
