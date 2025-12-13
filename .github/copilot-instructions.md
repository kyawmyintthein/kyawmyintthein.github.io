# GitHub Copilot Instructions

## Project Overview
This is a **Hugo-based personal blog** deployed to **GitHub Pages** for Kyaw Myint Thein (Joe). The site uses the PaperMod theme and focuses on technology, life experiences, and travel content.

## Architecture & Key Files

### Hugo Configuration
- **`config.toml`**: Main Hugo config using **PaperMod theme** (not hugo-theme-codex, despite both being git submodules)
- Profile mode is enabled with custom profile photo at `/images/profile-square.jpg`
- Base URL: `https://kyawmyintthein.github.io/`

### Content Structure
- **`content/blog/`**: Blog posts (markdown files with frontmatter)
- **`content/about.md`**: About page
- **`content/_index.md`**: Home page (uses Profile Mode, so this is minimal)
- **`archetypes/default.md`**: Template for new posts - includes `draft: true` by default

### Build Output (Git-Ignored)
- **`public/`**: Hugo-generated static site (cleaned on each build)
- **`resources/_gen/`**: Hugo cache (cleaned on each deployment)

### Themes (Git Submodules)
- **`themes/PaperMod/`**: Active theme (submodule)
- **`themes/hugo-theme-codex/`**: Inactive theme (submodule, not used)

## Developer Workflows

### Local Development
```bash
make run        # Start Hugo dev server
make dev        # Start with drafts and future posts enabled
make build      # Build production site locally
make clean      # Remove public/ directory
```

**Important**: Use `hugo server --disableFastRender` to ensure CSS/asset changes rebuild correctly.

### Content Creation
1. Create new post: `hugo new blog/post-name.md` (uses `archetypes/default.md` template)
2. Set `draft: false` when ready to publish (archetype defaults to `draft: true`)
3. Add tags for categorization (e.g., `tags: ["technology", "travel"]`)

### Deployment
- **Automated**: Push to `master` branch triggers `.github/workflows/gh-pages.yml`
- **Manual**: Run `make deploy` (commits and pushes) OR trigger workflow manually via GitHub Actions UI
- **DO NOT** use Jekyll - GitHub Pages is configured to use **GitHub Actions only** (see `GITHUB_PAGES_CONFIG.md`)

### GitHub Actions Workflow (`.github/workflows/gh-pages.yml`)
- Cleans `public/` and `resources/_gen/` before each build
- Fetches git submodules (themes) automatically
- Creates `static/.nojekyll` to prevent GitHub Jekyll processing
- Generates `static/deployment-check.txt` with build metadata
- Builds with `hugo --minify --cleanDestinationDir`
- Uploads and deploys to GitHub Pages

## Project-Specific Conventions

### Frontmatter Standards
All blog posts in `content/blog/` must include:
```yaml
---
title: "Post Title"
date: 2025-07-27T15:30:00Z  # ISO 8601 format with Z timezone
draft: false                 # Must be false to publish
tags: ["tag1", "tag2"]       # Array format
---
```

### Static Assets
- Place images in `static/images/` (accessible as `/images/` in URLs)
- Favicons: `static/favicon.png` and `static/favicon.svg`
- The `.nojekyll` file in `static/` is critical - prevents GitHub Pages from treating this as a Jekyll site

### Cache Busting
When deployment caching is an issue, the workflow includes timestamp comments in test posts (see `content/blog/test-deployment.md` for pattern).

## Common Pitfalls

1. **Theme not found**: Run `git submodule update --init --recursive` to fetch theme submodules
2. **CSS not updating**: Use `--disableFastRender` flag with Hugo server
3. **Drafts appearing**: Ensure `draft: false` in frontmatter before pushing to master
4. **GitHub Pages showing old content**: Check that GitHub Pages source is set to "GitHub Actions" not "Deploy from branch" (see `GITHUB_PAGES_CONFIG.md`)

## External Dependencies
- Hugo (latest extended version required for SCSS processing)
- Git submodules for themes (PaperMod, hugo-theme-codex)
- GitHub Actions for deployment
