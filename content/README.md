# Content Directory

Everyday edits live here. All folders keep their standard Jekyll names, but they sit under `content/` so you can navigate straight to copy updates without touching theme code.

## What's inside

- `_pages/`: standalone site pages (about, cv, publications, repositories, etc.)
- `_posts/`: blog posts (`YYYY-MM-DD-title.md`); leave drafts in `_drafts/` if needed
- `_projects/`: project cards surfaced on `/projects/`
- `_news/`: short news items that flow into the home page widget
- `_data/`: shared YAML (CV, repositories, venues, settings)
- `_bibliography/`: BibTeX sources consumed by jekyll-scholar

## Tips

- Front matter works the same as before—`permalink`, `layout`, and `nav` keys still control routing and menus.
- Collections for news/projects already point here via `collections_dir: content` in `_config.yml`.
- Keep assets (images, PDFs) in `assets/` and reference them relatively (e.g., `/assets/img/...`).
