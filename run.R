# Para crear la página
babelquarto::render_website(file.path(getwd()))

# Ver cómo va quedando la página
servr::httw("docs")

# Código bash para sutituir lua block codes por sintáxis ```
find -type f -exec sed -i 's/{{ site.url }}{{ site.baseurl }}//g' {} +