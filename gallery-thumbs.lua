-- gallery-thumbs.lua
-- Inside a ::: {.gallery} block, show a small thumbnail on the page while
-- the lightbox still opens the full-size image.
-- Thumbnails live in a "thumbs/" folder next to each original, with the same
-- file name but a .jpg extension (create them with make_thumbs.R). If a
-- thumbnail is missing, the original image is shown, so nothing breaks.
-- Runs at "post-render", after Quarto has wrapped images in lightbox links.

local function thumb_path(src)
  local dir, file = src:match("^(.*/)([^/]+)$")
  if not dir then dir, file = "", src end
  local stem = file:gsub("%.[^.]+$", "")
  return dir .. "thumbs/" .. stem .. ".jpg"
end

local function file_exists(p)
  local f = io.open(p, "r")
  if f then f:close() return true end
  return false
end

local function use_thumb(img)
  local t = thumb_path(img.src)
  if file_exists(t) then img.src = t end
  img.attributes["loading"] = "lazy"
  return img
end

return {
  Div = function(div)
    if not div.classes:includes("gallery") then return nil end
    return div:walk({ Image = use_thumb })
  end
}
