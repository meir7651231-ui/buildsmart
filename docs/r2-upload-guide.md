# העלאת תמונות ל-R2 — מדריך מהיר

## פרטי R2 (קבועים)

| פרמטר | ערך |
|--------|-----|
| Bucket | `buildsmart-images` |
| Account ID | `f073d9d0648cb201cd4af7bc9b34e8e3` |
| Public URL | `https://pub-51f8c6ddf2de47e6b63e0f9588211cba.r2.dev` |
| S3 Endpoint | `https://f073d9d0648cb201cd4af7bc9b34e8e3.r2.cloudflarestorage.com` |

מפתחות R2 נמצאים ב: Cloudflare Dashboard → R2 → Manage R2 API tokens

---

## העלאה מ-Windows (PowerShell) — 3 צעדים

### 1. clone + ענף
```powershell
git clone https://github.com/meir7651231-ui/buildsmart.git
cd buildsmart
git checkout claude/whats-happening-LyY9G
```
> אם repo כבר קיים: `git pull && git checkout claude/whats-happening-LyY9G`

### 2. pip (פעם אחת בלבד)
```powershell
pip install boto3
```

### 3. הרץ upload (מפתחות רק בטרמינל — לא בקובץ)
```powershell
$env:AWS_ACCESS_KEY_ID     = "ACCESS_KEY_כאן"
$env:AWS_SECRET_ACCESS_KEY = "SECRET_KEY_כאן"

python -c "
import boto3, pathlib, os
s3 = boto3.client('s3',
    endpoint_url='https://f073d9d0648cb201cd4af7bc9b34e8e3.r2.cloudflarestorage.com',
    aws_access_key_id=os.environ['AWS_ACCESS_KEY_ID'],
    aws_secret_access_key=os.environ['AWS_SECRET_ACCESS_KEY'],
    region_name='auto')
src = pathlib.Path(r'C:\Users\User\buildsmart\app_flutter\assets\huliot_smartlock\products')
files = sorted(src.glob('*.jpg'))
print(f'Found {len(files)} files')
ok=0
for f in files:
    s3.upload_file(str(f), 'buildsmart-images', f'huliot_smartlock/products/{f.name}', ExtraArgs={'ContentType':'image/jpeg'})
    ok+=1; print(f'{ok}: {f.name}')
print(f'DONE - {ok} uploaded')
"
```

**תוצאה צפויה:** `DONE - 159 uploaded`

### 4. אימות (אחרי upload)
```powershell
curl -I https://pub-51f8c6ddf2de47e6b63e0f9588211cba.r2.dev/huliot_smartlock/products/sml_p11_a.jpg
```
ציפייה: `HTTP/2 200`

---

## העלאה לתיקייה אחרת (לא huliot)

שנה רק את `src` ואת ה-key prefix:

```python
src = pathlib.Path(r'C:\Users\User\buildsmart\app_flutter\assets\<FOLDER>')
key = f"<FOLDER>/{f.name}"
```

דוגמה לתיקיית lipskey:
```python
src = pathlib.Path(r'C:\Users\User\buildsmart\app_flutter\assets\lipskey\products')
key = f"lipskey/products/{f.name}"
```

---

## מבנה ה-bucket

```
buildsmart-images/
├── huliot_smartlock/
│   ├── pages/        ← page_01.jpg … page_43.jpg  (כבר עלו)
│   └── products/     ← sml_p*.jpg + spec_sml_p*.jpg  (עלו היום)
├── lipskey/
│   └── products/     ← תמונות lipskey
└── polyroll/
    └── products/     ← תמונות polyroll
```

---

## אחרי כל upload — החלף מפתח!

כל מפתח שנחשף בצ'אט / terminal צריך להיות מוחלף:
Cloudflare Dashboard → R2 → Manage R2 API tokens → Delete + Create new
