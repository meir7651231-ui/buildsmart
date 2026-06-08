#!/usr/bin/env python3
"""Upload 159 Huliot SmartLock product images to Cloudflare R2."""
import boto3, pathlib, os, sys

ACCOUNT_ID = os.environ["R2_ACCOUNT_ID"]
BUCKET     = os.environ["R2_BUCKET"]
ACCESS_KEY = os.environ["AWS_ACCESS_KEY_ID"]
SECRET_KEY = os.environ["AWS_SECRET_ACCESS_KEY"]

s3 = boto3.client(
    "s3",
    endpoint_url=f"https://{ACCOUNT_ID}.r2.cloudflarestorage.com",
    aws_access_key_id=ACCESS_KEY,
    aws_secret_access_key=SECRET_KEY,
    region_name="auto",
)

src = pathlib.Path(__file__).parent / "app_flutter" / "assets" / "huliot_smartlock" / "products"
files = sorted(src.glob("*.jpg"))
print(f"Found {len(files)} files to upload")

ok, fail = 0, []
for f in files:
    key = f"huliot_smartlock/products/{f.name}"
    try:
        s3.upload_file(str(f), BUCKET, key,
                       ExtraArgs={"ContentType": "image/jpeg"})
        print(f"  ✅ {f.name}")
        ok += 1
    except Exception as e:
        print(f"  ❌ {f.name}: {e}", file=sys.stderr)
        fail.append(f.name)

print(f"\n{'✅' if not fail else '❌'} {ok}/{len(files)} uploaded"
      + (f"\nFailed: {fail}" if fail else ""))
sys.exit(1 if fail else 0)
