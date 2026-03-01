# Lumicron — Photography Portfolio

A modern, fast, dark-mode-first photography portfolio static site built with Astro v5, Tailwind CSS, GSAP, and PhotoSwipe. Features fully localized, file-based content management suitable for GitHub Pages deployment.

## Tech Stack
* **Framework:** [Astro v5](https://astro.build/) - Excellent for strict static HTML outputs with isolated React/Vue/Svelte islands if needed. We use purely Astro components here for maximum performance.
* **Styling:** [Tailwind CSS v4](https://tailwindcss.com/) - Using a custom dark mode theme based around `#8B1A1A` and `#C4874A`.
* **Animations:** [GSAP](https://greensock.com/gsap/) & [AOS](https://michalsnik.github.io/aos/) - For smooth scroll reveals and parallax.
* **Lightbox:** [PhotoSwipe 5](https://photoswipe.com/) - High-performance mobile-friendly gallery zooming.
* **3D Effects:** [Vanilla-Tilt](https://micku7zu.github.io/vanilla-tilt.js/) - Interactive hover effects on featured images.

---

## Getting Started

1. **Install dependencies:**
   ```bash
   npm install
   ```
2. **Run local dev server:**
   ```bash
   npm run dev
   # or
   ./manage.sh dev
   ```
   *Open `http://localhost:4321/lumicron/` to preview.*

---

## File-Based Content Management (CMS)

All site data lives in the `/content` directory. No database is required. 

### 1. Site configuration (`content/site-config.json`)
Controls global names, tags, and social media links. Editing this file updates the site immediately.

### 2. Categories (`content/categories.json`)
A list of valid categories you can assign to albums or featured images.

### 3. Albums (`content/albums/`)
Each album lives in its own folder. 
* To create a new album, create a folder like `content/albums/my-trip/`.
* Inside, create an `_album.json` file mimicking the existing ones.
* Drop your `.jpg` photos directly into the folder. Astro will automatically optimize them at build time!

### 4. Blog Posts (`src/content/blog/`)
Markdown files for your stories and journals. Add frontmatter tags for `title`, `date`, `coverImage`, etc.

---

## CLI Helper Tool (`manage.sh`)

For convenience, you can use the bash script `manage.sh` to scaffold content quickly from your terminal without touching JSON files manually:

* **Create new album:**
  ```bash
  ./manage.sh new-album "Grand Canyon Trip" --category "landscapes"
  ```
* **Add photos to an album:**
  ```bash
  ./manage.sh add-photos grand-canyon-trip ./Downloads/DSC_0123.jpg
  ```
* **Add a category:**
  ```bash
  ./manage.sh new-category "Astrophotography"
  ```

---

## Deployment to GitHub Pages

The site is fully configured for automated deployment via GitHub Actions.

1. Create a GitHub repository and push this code.
2. In your repo settings: **Settings > Pages > Source: GitHub Actions**.
3. Push to the `main` branch. The Action (`.github/workflows/deploy.yml`) will automatically run, optimize the images, and publish the static site.

> **Note on Base Path:** If your repo is named `lumicron`, the `base: '/lumicron'` in `astro.config.mjs` is correct. If you are using a custom root domain (like `saifulphotography.com`), you should change `base: '/'` in your `astro.config.mjs`.

## Customizing The Brand

* **Logo:** Your vector logos are in `public/logo/lumicron-logo.svg` and `public/logo/lumicron-icon.svg`. Swap them out freely.
* **Colors:** Edit the CSS variables in `src/styles/global.css` under the `@theme` block wrapper.
