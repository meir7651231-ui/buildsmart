# חוזה · `projectToScreen`

מוצא: `buildsmart/app_flutter/lib/features/fittings/render/camera.dart:102-118`.

`ScreenPoint projectToScreen(Mat4 proj, Mat4 view, Vec3 world, double width, double height)` —
מקרין נקודת-עולם למסך דרך `proj·view` (column-major, כמו ה-shader).

- `clip.w == 0` ⇒ `ScreenPoint(0,0,0,0)`.
- NDC = `clip.{x,y,z}/clip.w`; `sx=(ndcX*.5+.5)*width`; `sy=(1-(ndcY*.5+.5))*height` (ציר-Y מתהפך).
- טיפוסי-שכן מוטבעים: `Vec3` (x,y,z), `Mat4` (m,mul,apply), `ScreenPoint`.
- מתמטיקה טהורה, אפס import.
