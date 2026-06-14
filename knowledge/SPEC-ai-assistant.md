# SPEC — עוזר‑AI ראשי בתוך האפליקציה (E3: canned → LLM אמיתי)

> **פארק v2 — אחרי השקה.** נכתב 14/6. **לא חוסם השקה** (ה‑AI hub מוסתר כרגע ב‑`kHideUnderConstruction`).
> מטרה: להחליף את 7/9 כלי‑ה‑AI ה‑canned ב‑LLM אמיתי (Claude) שחי **בתוך** BuildSmart — עונה בעברית, ממליץ חומרים, מחשב כמויות, בונה הזמנות, ועונה על סטטוס. הכל מאחורי דגל, אפס‑רגרסיה.

## מודל
- **ברירת‑מחדל: Claude Opus 4.8** — `claude-opus-4-8` ($5/$25 ל‑1M · 1M context · 128K out). המוח הכי חזק לעברית + היגיון + tool‑use.
- מנופי‑עלות: `claude-sonnet-4-6` ($3/$15) לנפח גבוה · `claude-haiku-4-5` ($1/$5) למשימות פשוטות/מיון.
- `thinking: {type:"adaptive"}` · `effort` לפי צורך · `max_tokens` שמרני (stream אם >16K).

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
