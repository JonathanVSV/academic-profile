# Create gallery thumbnails for the Figures and photos page.
# Run this after adding a new image to the ::: {.gallery} block in figs.qmd /
# figs.es.qmd. Thumbnails go to assets/images/thumbs/<name>.jpg (max 640 px),
# and gallery-thumbs.lua swaps them in automatically when the site renders.
library(magick)

img_dir   <- "assets/images"
thumb_dir <- file.path(img_dir, "thumbs")
dir.create(thumb_dir, showWarnings = FALSE)

# Images used in the gallery (read from the English page)
figs <- readLines("figs.qmd", encoding = "UTF-8")
imgs <- unique(regmatches(figs, regexpr("assets/images/[^)]+", figs)))

for (src in imgs) {
  out <- file.path(thumb_dir, paste0(tools::file_path_sans_ext(basename(src)), ".jpg"))
  if (file.exists(out) && file.mtime(out) >= file.mtime(src)) next  # up to date
  image_read(src)[1] |>
    image_background("white") |>          # flatten transparent PNGs
    image_resize("640x640>") |>
    image_write(out, format = "jpeg", quality = 82)
  message("thumbnail: ", out)
}
