---
title: "Create certificates in R"
date: 2024-12-13T11:17:00-00:00
categories:
  - blog
tags:
  - post
  - r
  - certificates
  - labeleR
  - labels
  - participation
  - attendance
layout: splash
---

# Create participation certificates in R

This post will show you how to create certificates automatically using R. First, install and load the `labeleR` package. I will use `tibble` to create the the table containing the names.

```r
library(labeleR)
library(tibble)
```

Create or read the table containing the names

```r
df <- tibble(Names = c("John Smith", "Alejandra Pérez", "Hans Zimmer"))
```

# Attendees

Create attendees cerficates. Here you can indicate the language of the certificate (Spanish or English), the column name containing the names in df, the name of the Congress, date, hour, signer and logos. If you want to customize the certificate, you can use an Rmd template.

```r
create_attendance_certificate(
  data = df,
  path = "labeleR_output",
  filename = "attendance_certificates",
  language = "Spanish" ,
  name.column = "Names",
  # type = "Congress",
  title = "Congreso Nacional de Geografía ",
  date = "23/06/2024",
  hours = "24",
  # freetext = "taught by Professor S. Snape",
  signer = "Elmer Homero",
  signer.role = "Organizados",
  rpic = "Rlogo.png",
  lpic = "Rlogo.png",
  # keep.files = TRUE, 
  signature.pic = "signEx.png",
  template = "miFormato.Rmd"
)
```

I wanted to customize the template, so the easiest way is to first run the certificates with `keep.files = TRUE`. This will add the template Rmarkdown file to the output folder. You can copy paste this file and modify it at your will (knowing a little laTex). The following template enables adding a background image for the template. Notice that you could modify the spaces and area between the text.

Here is the code for the template in latex (since output is pdf).

```latex
---
title: ''
geometry: "left=2cm,right=2cm,top=1cm,bottom=1cm"
output:
  pdf_document: default
header-includes: \usepackage{tikz}
classoption: landscape
params:
  name.column.i: ""
  type: ""
  title: ""
  date: ""
  hours: ""
  freetext: ""
  signer: ""
  signer.role: ""
---

\begin{center}
\pagenumbering{gobble}

\begin{tikzpicture}[remember picture,overlay]
% draw image
\node[inner sep=0] at (current page.center)
{\includegraphics[width=\paperwidth,height=\paperheight]{D:/Drive/Jonathan_trabaggio/Doctorado/R/Sandbox/background.jpg}};
\end{tikzpicture}

% logos %
\includegraphics[height=3cm]{lpic.png} 
\hfill
\includegraphics[height=3cm]{rpic.png}
\linebreak
\vfill

{\fontsize{40pt}{40pt}\selectfont\bf Certificado de asistencia} 
\vfill

{\fontsize{40pt}{40pt}\selectfont `r params$name.column.i` } \\
\vfill

\Large

ha asistido al `r params$type` {\bf `r params$title`} \\
\vfill

`r params$freetext` \\
\vfill

con fecha `r params$date` \\
\vfill

y una duración de `r params$hours` hora(s). \\
\vfill

% firma %
Firmado por: \\
\vfill
\includegraphics[height=2cm]{spic.png}\\
`r params$signer` \\
`r params$signer.role` \\

\end{center}
\pagebreak
```

Once the past code is run with the corresponding template. This is the result

![Certificate](/assets/images/certificate.png)
