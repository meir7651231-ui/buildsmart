# firebase-web-config — קלט ל-S0.2 (`firebase_options.dart`) · Web app

> **client config פומבי** — *לא סוד* (מוטמע בכל web-bundle; אבטחה = Security Rules S5, לא סודיות-config).
> מקור: Firebase console → Project settings → Your apps → **BuildSmart Web** · נמסר 06-09.
> **לצי:** מזה כותבים את `firebase_options.dart` (S0.2 · web). configים של **android/ios** — בהמשך (הוספת אפליקציות / flutterfire).

```js
const firebaseConfig = {
  apiKey: "AIzaSyDA7iDvD23dhQR5WQu62tyNj2wgyewlzog",
  authDomain: "buildsmart-b0b78.firebaseapp.com",
  projectId: "buildsmart-b0b78",
  storageBucket: "buildsmart-b0b78.firebasestorage.app",
  messagingSenderId: "483064122180",
  appId: "1:483064122180:web:d1f6bac271c87324ca6511",
  measurementId: "G-98BWCNC8Q4"
};
```

> ⚠️ **הועתק מצילום-מסך.** אם `Firebase.initializeApp` נכשל בזמן-ריצה — אמת תו-אחר-תו מול ה-console (כפתור copy ב-SDK config). אימות-הצלבה שעבר: `messagingSenderId`/project-number = `483064122180` (תואם deploy-log `projects/483064122180`).
