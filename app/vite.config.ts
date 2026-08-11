import { defineConfig } from 'vite';
import preact from '@preact/preset-vite';
import { VitePWA } from 'vite-plugin-pwa';
import { fileURLToPath, URL } from 'node:url';

/* GitHub Pages serves the app at https://<user>.github.io/buildsmart/.
 * When building for Pages (CI sets GITHUB_PAGES=1), Vite must emit
 * asset URLs prefixed with /buildsmart/. Local dev + Vercel keep '/'. */
const isPages = process.env.GITHUB_PAGES === '1';
const base = isPages ? '/buildsmart/' : '/';

export default defineConfig({
  base,
  plugins: [
    preact(),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['favicon.svg'],
      manifest: {
        name: 'BuildSmart — רכש חומרי בנייה',
        short_name: 'BuildSmart',
        description: 'מערכת ניהול רכש, תקציב ומשימות לאתרי בנייה',
        lang: 'he',
        dir: 'rtl',
        start_url: base,
        scope: base,
        display: 'standalone',
        orientation: 'portrait',
        background_color: '#f4f5f3',
        theme_color: '#1f6f6b',
        icons: [
          {
            src: "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 192 192'%3E%3Crect width='192' height='192' rx='40' fill='%231f6f6b'/%3E%3Ctext x='96' y='128' font-size='96' font-family='Arial' font-weight='bold' fill='white' text-anchor='middle'%3EBS%3C/text%3E%3C/svg%3E",
            sizes: '192x192',
            type: 'image/svg+xml',
            purpose: 'any maskable',
          },
          {
            src: "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 512 512'%3E%3Crect width='512' height='512' rx='106' fill='%231f6f6b'/%3E%3Ctext x='256' y='340' font-size='256' font-family='Arial' font-weight='bold' fill='white' text-anchor='middle'%3EBS%3C/text%3E%3C/svg%3E",
            sizes: '512x512',
            type: 'image/svg+xml',
            purpose: 'any maskable',
          },
        ],
      },
      workbox: {
        globPatterns: ['**/*.{js,css,html,svg,png,ico,woff2}'],
        runtimeCaching: [
          {
            urlPattern: ({ request }: { request: Request }) => request.destination === 'document',
            handler: 'NetworkFirst',
            options: {
              cacheName: 'bs-html',
              networkTimeoutSeconds: 3,
            },
          },
          {
            urlPattern: ({ request }: { request: Request }) =>
              request.destination === 'script' ||
              request.destination === 'style' ||
              request.destination === 'font',
            handler: 'StaleWhileRevalidate',
            options: { cacheName: 'bs-assets' },
          },
          {
            urlPattern: ({ request }: { request: Request }) => request.destination === 'image',
            handler: 'CacheFirst',
            options: {
              cacheName: 'bs-images',
              expiration: { maxEntries: 200, maxAgeSeconds: 60 * 60 * 24 * 30 },
            },
          },
        ],
      },
      devOptions: { enabled: false },
    }),
  ],
  resolve: {
    alias: {
      react: 'preact/compat',
      'react-dom': 'preact/compat',
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
  server: {
    host: true,
    port: 5173,
  },
});
