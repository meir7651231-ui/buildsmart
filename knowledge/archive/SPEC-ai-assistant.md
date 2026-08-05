# SPEC — עוזר‑AI ראשי בתוך האפליקציה (E3: canned → LLM אמיתי)

> ## ✅ נבנה ופעיל (עדכון 23/6, אומת בקוד)
> **המפרט הזה מומש.** הצי בנה את העוזר ב‑v6.48–v6.73, ו**הבעלים אישר להשאיר פעיל (23/6).**
> - **קוד:** `functions/src/index.ts:147` (`export askClaude`) → `functions/src/claude.ts` (`@anthropic-ai/sdk`).
> - **נפרס:** "Deploy Firebase Rules + Functions" = success (@77df5eb).
> - **~15 פיצ'רי "✨ עם Claude"** + עוזר **agentic** (לוקח פעולות עם אישור): נסח‑דחייה · דוח‑יום · סיכום‑עסקי · הסבר‑אשראי · הצעה‑מקצועית · חיפוש‑חכם · "🤖 העוזר החכם" צ׳אט מעוגן ב‑AI hub · ועוד.
> - **`ANTHROPIC_API_KEY` ✅ מוגדר — והעוזר עובד** (אישר‑בעלים 23/6, end‑to‑end חי).
> - **עלות:** אגורות לשיחה (Haiku) · rate‑limit מגן · מומלץ G5 (התראת‑תקציב Blaze) לניטור.
>
> *(שאר המסמך = מפרט‑המקור 14/6, נשמר כרקע. הסטייה היחידה מהמימוש: מודל‑ברירת‑מחדל — ראה למטה.)*

> **פארק v2 (מקור 14/6) — בוצע.** מטרה הייתה: להחליף את כלי‑ה‑AI ה‑canned ב‑LLM אמיתי (Claude) שחי **בתוך** BuildSmart — עונה בעברית, ממליץ חומרים, מחשב כמויות, בונה הזמנות, ועונה על סטטוס. הכל מאחורי דגל, אפס‑רגרסיה.

## מודל
- **כפי שנבנה בפועל (`claude.ts`):** ברירת‑מחדל `claude-haiku-4-5-20251001` (זול, למשימות הצרות) · **allowlist** מתיר שדרוג ל‑`claude-sonnet-4-6` (הדרגה החזקה שהאפליקציה רשאית). מודל לא‑מורשה נחסם בשרת.
- *(המקור 14/6 הציע `claude-opus-4-8` כברירת‑מחדל; הצי בחר Haiku מטעמי‑עלות לפיצ'רים הצרים — אפשר להוסיף Opus ל‑allowlist אם נדרש מוח חזק יותר.)*
- `max_tokens` שמרני · rate‑limit `_claudeRate/{uid}` (server‑only) · injection‑audit (v6.70).

## ארכיטקטורה — proxy דרך השרת (המפתח אף פעם לא באפליקציה)
```
אפליקציה (callable) → Firebase Function `aiAssistant` → Anthropic API → חזרה
```
- מפתח‑Anthropic = **סוד** ב‑Function (`defineSecret`/Secret Manager) — **לא** בקליינט, **לא** ב‑repo, **לא** ב‑firebase_options.
- Function ב‑Node → `@anthropic-ai/sdk` (`client.messages.create`).
- **App Check** על ה‑callable + **rate‑limit פר‑uid** (מניעת ניצול/עלות).

## הסוכן — לולאת tool‑use בצד‑השרת
1. הקליינט שולח הודעת‑משתמש + הקשר (uid/role/סל נוכחי).
2. ה‑Function קורא ל‑Claude עם 4 הכלים (`tools`).
3. `stop_reason == "tool_use"` → ה‑Function מריץ את הכלי מול Firestore/קטלוג → מחזיר `tool_result` (עם `tool_use_id` תואם) → לולאה.
4. `stop_reason == "end_turn"` → מחזיר טקסט‑תשובה + רשימת‑פעולות שבוצעו לקליינט.
- לולאה ידנית: append כל `response.content` לפני tool_result · תקרת‑איטרציות ~5 · לפרסר tool input עם `JSON.parse` (לא string‑match).

## 4 הכלים (`name` · `description` · `input_schema`)
| כלי | תיאור (מתי לקרוא) | input |
|---|---|---|
| `search_catalog` | חיפוש מוצרים בקטלוג כשהמשתמש מתאר/מחפש מוצר | `{query, category?, limit?}` → מוצרים מ‑Firestore |
| `add_to_cart` | הוספת מוצר לסל של המשתמש | `{productId, qty}` → כתיבה לסל של ה‑uid |
| `compute_quantity` | חישוב כמות חומר נדרשת | `{material, area?, dimensions?}` → נוסחה |
| `order_status` | סטטוס/שלב הזמנה | `{orderId?}` → שלב, scoped ל‑uid (A4‑A6) |
> כל כלי **מאמת קלט בצד‑שרת** ומכבד את גבולות‑ה‑uid — אסור לתת ל‑LLM לעקוף הרשאות. פעולות הרסניות (אם יתווספו) דורשות אישור מפורש.

## בקרת‑עלות
- **Prompt caching:** `cache_control:{type:"ephemeral"}` על system‑prompt + הקשר‑קטלוג קבוע → ~0.1× בקריאות חוזרות.
- תקרת `max_tokens` · rate‑limit פר‑uid · התראות‑תקציב Blaze (G5).
- אומדן: **אגורות בודדות לשיחה** עם caching.

## גידור + הדלקה
- דגל `kAiAssistant` (`bool.fromEnvironment`, default **OFF**) — כמו שאר השרת.
- ON = מחבר את ה‑hub ל‑Function + מבטל `kHideUnderConstruction` על כלי‑ה‑AI שהפכו אמיתיים (השאר נשארים מוסתרים).
- **DoD:** משתמש שואל בעברית → Claude עונה + מבצע (חיפוש/הוספה‑לסל/חישוב/סטטוס) דרך השרת · המפתח לא בקליינט · עלות מכוסה · דמו (flag OFF) ללא שינוי.

## תלוי
- B8 (זהות) + A4‑A6 (scoped orders) ל‑`order_status`/`add_to_cart` פר‑uid · Functions deployed · App Check (G3) · Blaze budget (G5).
