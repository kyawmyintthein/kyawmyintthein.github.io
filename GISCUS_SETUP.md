# Giscus Comments Setup Guide

This blog uses [Giscus](https://giscus.app/) for comments, which uses GitHub Discussions as a backend.

## Setup Steps

### 1. Enable GitHub Discussions
1. Go to your repository: https://github.com/kyawmyintthein/kyawmyintthein.github.io
2. Click on **Settings** tab
3. Scroll down to **Features** section
4. Check the box for **Discussions**

### 2. Install Giscus App
1. Visit https://github.com/apps/giscus
2. Click **Install**
3. Select **kyawmyintthein/kyawmyintthein.github.io** repository
4. Authorize the app

### 3. Get Your Giscus Configuration
1. Go to https://giscus.app/
2. Fill in the configuration:
   - **Repository**: `kyawmyintthein/kyawmyintthein.github.io`
   - **Page ↔️ Discussions Mapping**: pathname (already configured)
   - **Discussion Category**: Choose "General" or create "Blog Comments"
3. Copy the generated values:
   - `data-repo-id`
   - `data-category-id`

### 4. Update config.toml
Replace the empty values in `config.toml`:

```toml
[params.giscus]
  repo = "kyawmyintthein/kyawmyintthein.github.io"
  repoID = "PASTE_YOUR_REPO_ID_HERE"
  category = "General"  # or your chosen category name
  categoryID = "PASTE_YOUR_CATEGORY_ID_HERE"
```

### 5. Test Locally
```bash
make dev
```

Visit a blog post and check if the comments section appears at the bottom.

### 6. Deploy
```bash
git add .
git commit -m "Add Giscus comments"
git push
```

## Features Enabled
- ✅ Reactions (👍❤️🎉 etc.)
- ✅ Theme follows site (light/dark/auto)
- ✅ Lazy loading for better performance
- ✅ Comments appear on all blog posts
- ✅ Uses GitHub authentication

## How It Works
- Visitors comment using their GitHub account
- Comments are stored in GitHub Discussions
- Each blog post path maps to a discussion thread
- You can moderate comments via GitHub Discussions
- Fully integrated with your existing GitHub workflow

## Troubleshooting
- **Comments not showing**: Check that Discussions is enabled and Giscus app is installed
- **Wrong theme**: Adjust `theme` parameter in config.toml
- **Comments on wrong pages**: Verify `mapping = "pathname"` is set
