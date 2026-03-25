# Latency Log

Personal blog by Basil Eldho — technical notes on systems programming, networking, and distributed systems.

Live at [latencylog.tech](https://latencylog.tech)

## Stack

- **Hugo** — static site generator with fully custom layouts (no theme)
- **GitHub Actions** — builds and deploys to GitHub Pages on push to `master`
- **Supabase** — anonymous comments and emoji reactions (PostgreSQL + REST API)

## Structure

```
content/posts/    blog posts (Markdown)
layouts/          Hugo templates
  _default/
    single.html   post page (includes comment/reaction system)
    list.html     post index
  index.html      home page
static/css/       stylesheet
migrations/       Supabase SQL migrations
.github/workflows deploy pipeline
```

## Running locally

```bash
hugo server
```

Requires Hugo extended v0.159.0+.

## Comments & Reactions

Backed by Supabase. Set `supabaseUrl` and `supabaseAnonKey` in `hugo.toml` under `[params]`. Run `migrations/001_init.sql` in the Supabase SQL editor to create the schema.

No login required — comments are anonymous. Reaction/vote deduplication is handled via `localStorage`.
