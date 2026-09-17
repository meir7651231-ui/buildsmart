#!/usr/bin/env node
// ══════════════════════════════════════════════════════════════════════════
//  chrome.mjs — טוען אוצר-מילות-הכרום (§19). המנוע-עיוור קורא `L.<role>` במקום
//  מחרוזת-עברית-קשיחה; כל התוכן ב-'chrome.data.json' (אטום-דאטה, מוזרק).
//  T(key, vars) — תבנית עם {placeholders} ⇒ מילוי. אפס-לוגיקה, אפס-מילון-במנוע.
// ══════════════════════════════════════════════════════════════════════════
import fs from 'node:fs';
import * as R from '../root.mjs';
export const L = JSON.parse(fs.readFileSync((R.GEN_DIR + 'chrome.data.json'), 'utf8'));
export const T = (key, vars = {}) => Object.entries(vars).reduce((s, [n, v]) => s.split(`{${n}}`).join(String(v)), L[key]);
