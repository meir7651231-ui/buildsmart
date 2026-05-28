# Conventions — app_flutter

## Theme / colors (light mode)
The whole app is light. Never ship white text on a light surface.
- scaffold/page bg: `0xFFF5F6FA` · cards/sheets/appbar: `0xFFFFFFFF`
- primary text/ink: `0xFF1A1A1A` · secondary/muted: `0xFF888888` / `black54`
- dividers on light: `0xFFEEEEEE` / `0xFFE5E5E5`
- brand orange: `BsTokens.brand` (`0xFFFF7A18`) · light-orange chip bg `0xFFFFE8D6`
- **White text is ONLY allowed on a colored surface** — a brand/orange/green/red
  button or badge, or an active selection pill (`active ? Colors.white : ...`).
  Anywhere else, white text is a bug (caught repeatedly during the dark→light
  migration). AppBars use `foregroundColor: 0xFF1A1A1A`.

## RTL / Hebrew
App is RTL. UI strings are Hebrew and must be grounded in the product/legacy,
not invented. Emoji render on device/real browser but show as □ in headless
screenshots — not a bug.

## Settings sections
ExpansionTile section headers show a **count badge in place of the chevron**
(orange, `_activeCount` = functional rows, excluding בבנייה placeholders).
When `_activeCount == 0` the chevron is kept instead of a "0" badge.

## Wiring discipline
A setting/button is ✅ only when it has a real effect AND a regression check.
Otherwise it's 🚧 (placeholder toast) or ⛔ (blocked — no price/rating/geo data,
no notification engine, no media/telephony, no server). Keep `../WIRING.md`
and `gaps_test.dart`/`wiring_test.dart` in sync.

## Inherited shell rules (from `app/RULES.md`, still honored)
- **R1**: 5 FABs (the *rule*; the Flutter shell currently realizes a 4-tab
  bottom-nav + cart-FAB, with only the BS dial wired — see `spec/shell-and-dials.md`
  §7). **R2**: no full-screen persona views — every feature is a dial/tab.
  **R6/R8**: Hebrew strings verbatim; never invent.

## Commit / branch / version
- Branch `claude/whats-happening-LyY9G`; no push to main without approval.
- Small commits; pull `--no-rebase` before push (parallel sessions merge often).
- Bump the version label in `home_shell.dart` on user-visible changes
  (format `vX.YY · DD.M.YY · <short note>`).
- Never commit the model identifier or internal IDs.
