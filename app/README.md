# BuildSmart — App (V2)

ניהול רכש, תקציב ומשימות לאתרי בנייה. שלד פרויקט חדש שיחליף בהדרגה את האב-טיפוס שבשורש המאגר (`../index.html`).

## הסטאק

- **Preact 10** — UI (4KB, API של React)
- **Vite 5** — dev server + build
- **TypeScript 5** — type-safety
- **vite-plugin-pwa** — service worker + manifest אוטומטיים (Workbox)
- **Capacitor 6** — אריזה ל-iOS / Android (תיוסף בשלב הבא)
- **@fontsource** — Heebo / Rubik self-hosted

## פקודות

```bash
npm install        # התקנה ראשונית
npm run dev        # dev server עם HMR (http://localhost:5173)
npm run build      # build ל-dist/
npm run preview    # preview של ה-build
npm run typecheck  # בדיקת טיפוסים בלבד
```

## מבנה התיקיות

```
app/
├── index.html              # entry HTML (RTL, lang=he)
├── vite.config.ts          # Vite + PWA config
├── capacitor.config.ts     # Capacitor config (לעתיד)
├── tsconfig.json
├── public/                 # נכסים סטטיים
└── src/
    ├── main.tsx            # entry, mount ל-#app
    ├── app.tsx             # shell של האפליקציה
    ├── components/         # קומפוננטים משותפים
    ├── views/              # מסכים
    ├── store/              # state management
    ├── lib/                # utilities
    └── styles/
        ├── tokens.css      # design tokens (צבעים, גדלים, פונטים)
        └── global.css      # reset + סגנון בסיס
```

## הוספת iOS / Android (שלב הבא)

```bash
npm install @capacitor/ios @capacitor/android
npx cap add ios       # דורש Xcode (macOS בלבד)
npx cap add android   # דורש Android Studio
npm run cap:ios       # build + open ב-Xcode
npm run cap:android   # build + open ב-Android Studio
```

## מיגרציה מהאב-טיפוס

האב-טיפוס המקורי ב-`../index.html` נשאר כרפרנס ויזואלי. כל view ייבנה מחדש כאן ב-Preact, view-by-view, תוך שימוש בעיצוב tokens שכבר הועתק (`src/styles/tokens.css`).
