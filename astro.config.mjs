import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://saiful-ull-502862.github.io',
  base: '/lumicron',
  output: 'static',
  vite: {
    plugins: [tailwindcss()]
  },
  integrations: [
    sitemap({
      // Keep the private curation tool out of the sitemap.
      filter: (page) => !page.includes('/review'),
    }),
  ],
});