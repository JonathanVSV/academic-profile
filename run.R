# Need to declare globalvar so that changing language directs to the correct url
site_url = "https://jonathanvsv.github.io/academic-profile"
Sys.setenv(BABELQUARTO_CI_URL= site_url)

# Register languages if not already declared in _quarto.yml
# babelquarto::register_main_language(main_language = "en", project_path = getwd())
# 
# babelquarto::register_further_languages(further_languages = "es", project_path = getwd())

# Create website
babelquarto::render_website(
  project_path = ".",
  site_url = site_url,
  profile = NULL,
  preview = rlang::is_interactive()
)

# See preview
servr::httw("docs")

# Bash code to fix some syntax in some posts
find -type f -exec sed -i 's/{{ site.url }}{{ site.baseurl }}//g' {} +