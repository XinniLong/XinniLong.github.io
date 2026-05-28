# Theme Directory

Presentation assets now live under `theme/` so you can adjust layouts or Sass without wading through content. Nothing about how Liquid works has changed—only the folder paths.

## What's inside

- `_layouts/`: page shells referenced by `layout:` in front matter
- `_includes/`: reusable Liquid snippets (components, scripts, social blocks)
- `_sass/`: variables and partials imported from `assets/css/main.scss`

## Tips

- `sass.sass_dir` already points to `theme/_sass`, so `@import` statements in `assets/css/main.scss` continue to work.
- Include tags such as `{% include figure.liquid %}` automatically resolve to `theme/_includes` via `_config.yml`.
- Keep structural or stylistic changes here; content updates belong in `content/`.
