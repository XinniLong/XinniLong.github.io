# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is an academic personal website built with the **al-folio** Jekyll theme. It's a static site generator that creates an academic portfolio including publications, CV, blog posts, projects, and news updates. The site is configured for Dr. Guolin Yin and deployed to GitHub Pages.

## Development Commands

### Local Development (Docker - Recommended)

```bash
# Pull and run the site locally (first time or to update image)
docker compose pull
docker compose up

# For the slim version (< 100MB)
docker compose -f docker-compose-slim.yml up

# Rebuild from scratch
docker compose up --build
```

The site will be available at `http://localhost:8080`.

### Local Development (Legacy/Native)

```bash
# Install dependencies
bundle install
pip install jupyter

# Serve the site locally
bundle exec jekyll serve
```

The site will be available at `http://localhost:4000`.

### Build Commands

```bash
# Build the site for production
JEKYLL_ENV=production bundle exec jekyll build

# Build and purge unused CSS
bundle exec jekyll build
purgecss -c purgecss.config.js
```

### Deployment

```bash
# Deploy to GitHub Pages (manual)
bin/deploy --user

# The GitHub Actions workflow automatically deploys on push to master
```

### Code Quality

```bash
# Format code with Prettier
npm run prettier
```

## Architecture

### Key Configuration Files

- `_config.yml`: Main site configuration including personal info, theme settings, Jekyll plugins, and third-party library versions
- `Gemfile`: Ruby dependencies for Jekyll and plugins
- `package.json`: Node dependencies for Prettier and Liquid formatting
- `purgecss.config.js`: Configuration for removing unused CSS

### Directory Structure

**Content Directories:**

- `content/_pages/`: Main site pages (about, CV, publications, projects, blog, etc.) written in Markdown/Liquid
- `content/_posts/`: Blog posts (currently populated via external sources)
- `content/_news/`: News/announcements shown on the homepage
- `content/_projects/`: Project entries with descriptions
- `content/_bibliography/`: BibTeX files for publications (uses Jekyll-Scholar)
- `content/_data/`: Structured data files (CV, repositories list, venues, coauthors)
- `assets/`: Static assets (images, PDFs, JSON resume, etc.)

**Template Directories:**

- `theme/_layouts/`: Page layout templates (about, post, cv, distill, bib, etc.)
- `theme/_includes/`: Reusable template components
- `theme/_sass/`: SCSS stylesheets
- `_plugins/`: Custom Jekyll plugins written in Ruby

**Build Output:**

- `_site/`: Generated static site (gitignored, created during build)

### Custom Jekyll Plugins

Located in `_plugins/`, these extend Jekyll's functionality:

- `external-posts.rb`: Fetches external blog posts from sources like Notion
- `google-scholar-citations.rb`: Fetches citation counts from Google Scholar
- `download-3rd-party.rb`: Downloads third-party libraries when configured
- `cache-bust.rb`: Adds cache-busting hashes to assets
- `hide-custom-bibtex.rb`: Filters BibTeX fields from publication display

### Important Jekyll Plugins

Defined in `_config.yml` and `Gemfile`:

- **jekyll-scholar**: Processes BibTeX bibliography files and generates publication pages
- **jekyll-imagemagick**: Creates responsive images in multiple sizes/formats
- **jekyll-jupyter-notebook**: Embeds Jupyter notebooks in blog posts
- **jekyll-minifier**: Minifies HTML, CSS, and JS
- **jekyll-paginate-v2**: Handles blog pagination
- **jekyll-feed**: Generates Atom/RSS feed

### Configuration Patterns

**Publications:**

- BibTeX entries go in `content/_bibliography/papers.bib`
- Configured via the `scholar:` section in `_config.yml`
- Supports extra fields like `pdf`, `code`, `slides`, `website`, `abstract`
- PDFs should be placed in `assets/pdf/`

**CV:**

- Can use either `assets/json/resume.json` (JSON Resume standard) or `content/_data/cv.yml`
- JSON format takes precedence when both exist

**External Blog Posts:**

- Configured in `_config.yml` under `external_sources:`
- Currently links to a Notion blog about Nexmon CSI setup

**Collections:**

- Defined in `_config.yml` under `collections:`
- News items and projects are Jekyll collections with custom permalinks

## Deployment Architecture

### GitHub Pages Deployment

The site uses a two-branch workflow:

- `master`: Source code and content
- `gh-pages`: Built static site (auto-generated, DO NOT edit manually)

**Automatic Deployment:**

1. Push to `master` branch triggers `.github/workflows/deploy.yml`
2. GitHub Actions builds the site with Jekyll
3. Result is pushed to `gh-pages` branch
4. GitHub Pages serves from `gh-pages`

**Manual Deployment Script:**
The `bin/deploy` script:

1. Checks for uncommitted changes
2. Builds site with `JEKYLL_ENV=production`
3. Runs PurgeCSS to remove unused styles
4. Creates deployment branch with built files
5. Pushes to `gh-pages`

### Configuration Settings

Site settings in `_config.yml`:

- `url`: `https://Guolin-Yin.github.io` (must match GitHub Pages URL)
- `baseurl`: Empty (root deployment)
- GitHub username: `Guolin-Yin`
- Google Scholar ID: `z7dNYr0AAAAJ`

## Common Tasks

### Adding a Publication

1. Add BibTeX entry to `content/_bibliography/papers.bib`
2. (Optional) Add PDF to `assets/pdf/`
3. Reference PDF in BibTeX with `pdf = {filename.pdf}`

### Updating CV

Edit either:

- `assets/json/resume.json` (JSON Resume format), or
- `content/_data/cv.yml` (YAML format)

### Adding a News Item

Create a new file in `content/_news/` with frontmatter and content.

### Modifying Theme Colors

Edit `--global-theme-color` in `theme/_sass/_themes.scss`.

### Adding Third-Party Libraries

Update the `third_party_libraries:` section in `_config.yml` with version and integrity hashes.

## Important Notes

- The site uses **Liquid templates** (not Jinja2) with `.liquid` extension
- Image optimization requires `imagemagick` to be installed locally
- The site includes Google verification file: `googlefb8f30a86b3a08c7.html`
- Dark/light mode is built-in and auto-detects user preference
- Search functionality is enabled across the site including bibliography
