# Repository Guidelines

## Project Structure & Module Organization

The site uses the al-folio Jekyll layout. All authoring content now lives under `content/` (`content/_pages/`, `content/_posts/`, `content/_projects/`, `content/_news/`, and `content/_data/` for shared YAML lists). Presentation pieces sit in `theme/_layouts/` (page shells), `theme/_includes/` (Liquid snippets), and `theme/_sass/` (variables, themes, and component partials). Static assets belong in `assets/`, while helper scripts (`bin/cibuild`, `bin/deploy`) and configuration (`_config.yml`, `Gemfile`, `package.json`) live at the repository root.

## Build, Test, and Development Commands

Run these from the project root as needed:

```
bundle install && npm install          # install Ruby gems and Prettier plugins
bundle exec jekyll serve --livereload  # live server on http://127.0.0.1:4000
docker compose up                      # containerized dev environment
bin/cibuild                            # production build (runs `jekyll build`)
bin/deploy --user                      # master → gh-pages deployment
npx prettier --check .                 # formatting gate
```

## Coding Style & Naming Conventions

Use two-space indentation for Liquid, Markdown, YAML, and JSON; keep prose wrapped to ≈100 characters. Follow standard Jekyll front matter (quoted titles, ISO dates, absolute permalinks). Name collection files in kebab-case to match their `title` slug, and keep new assets in an `assets/<type>/<feature>` folder. Prettier plus `@shopify/prettier-plugin-liquid` is the single source of truth—run `npx prettier --write .` whenever templates, Sass, or JS change, and extend `theme/_sass/_variables.scss` rather than hard-coding colors or spacing.

## Testing Guidelines

Before pushing, run `bin/cibuild` (or `bundle exec jekyll build`) to catch Liquid errors and missing includes, then `npx prettier --check .` to mirror the CI formatter job. Link health is enforced upstream via `.github/workflows/broken-links*.yml`; locally, install [lychee](https://github.com/lycheeverse/lychee) and execute `lychee "./**/*.md" "./**/*.html"` to reproduce failures. Provide screenshots or Lighthouse notes when modifying layouts, and keep `_site/` ignored.

## Commit & Pull Request Guidelines

Write imperative commit subjects (`Add dark-mode palette`) and reference issues with `Fixes #ID` in the body. PR descriptions should summarize the change, list manual checks (serve, build, prettier, lychee), and mention configuration knobs that reviewers must update. Visual tweaks benefit from before/after screenshots; functional updates should explain how to reproduce the behavior. Convert WIP drafts only after CI is green and `bin/deploy --no-push` succeeds locally.

## Security & Configuration Tips

Avoid committing secrets—configure analytics keys and API tokens through environment variables read when `JEKYLL_ENV=production`. Before deploying, verify `url` and `baseurl` in `_config.yml`, and prefer `JEKYLL_ENV=production bundle exec jekyll build` for accurate asset minification. Review `robots.txt`, `assets/`, and `content/_data/*.yml` for accidental personal information, and keep third-party embeds behind opt-in flags in `content/_data/settings.yml`.
