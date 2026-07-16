cd C:\Users\User\Downloads\kiosk
git pull

$dir = "kiosk-video-app\app\src\main\java\com\kiosk\video"
$enc = New-Object System.Text.UTF8Encoding($false)

# 1. סיסמת ברירת מחדל
$f = "$dir\SettingsStore.kt"
$t = [IO.File]::ReadAllText($f).Replace("`r`n","`n")
$t = $t.Replace('const val DEFAULT_PIN = "1234"', 'const val DEFAULT_PIN = "MWmw2026"')
[IO.File]::WriteAllText($f, $t, $enc)

# 2. אפשר אותיות בסיסמה (דיאלוג)
$f = "$dir\PinDialog.kt"
$t = [IO.File]::ReadAllText($f).Replace("`r`n","`n")
$t = $t.Replace('input = s.filter { it.isDigit() }.take(8)', 'input = s.take(32)')
$t = $t.Replace('KeyboardType.NumberPassword', 'KeyboardType.Password')
[IO.File]::WriteAllText($f, $t, $enc)

# 3. אפשר אותיות בסיסמה (מסך הגדרות) + שחרור נעילות ביציאה
$f = "$dir\SettingsActivity.kt"
$t = [IO.File]::ReadAllText($f).Replace("`r`n","`n")
$t = $t.Replace('import android.os.Process', "import android.os.Process`nimport android.os.UserManager")
$t = $t.Replace('onValueChange = { pinField = it.filter { c -> c.isDigit() }.take(8) },', 'onValueChange = { pinField = it.take(32) },')
$t = $t.Replace('KeyboardType.NumberPassword', 'KeyboardType.Password')
$old = "            if (dpm.isDeviceOwnerApp(packageName)) {`n                dpm.clearDeviceOwnerApp(packageName)`n            }"
$new = "            if (dpm.isDeviceOwnerApp(packageName)) {`n                for (r in arrayOf(`n                    UserManager.DISALLOW_DEBUGGING_FEATURES,`n                    UserManager.DISALLOW_USB_FILE_TRANSFER,`n                    UserManager.DISALLOW_SAFE_BOOT,`n                    UserManager.DISALLOW_ADD_USER`n                )) {`n                    try { dpm.clearUserRestriction(admin, r) } catch (_: Throwable) {}`n                }`n                dpm.clearDeviceOwnerApp(packageName)`n            }"
if (-not $t.Contains($old)) { Write-Host "ERROR 3"; exit 1 }
$t = $t.Replace($old, $new)
[IO.File]::WriteAllText($f, $t, $enc)

# 4. נעילת ADB/USB כשהאפליקציה Device Owner
$f = "$dir\MainActivity.kt"
$t = [IO.File]::ReadAllText($f).Replace("`r`n","`n")
$t = $t.Replace('import android.os.Bundle', "import android.os.Bundle`nimport android.os.UserManager")
$old = "            dpm.setLockTaskPackages(admin, arrayOf(packageName))`n        }"
$new = "            dpm.setLockTaskPackages(admin, arrayOf(packageName))`n            try {`n                dpm.addUserRestriction(admin, UserManager.DISALLOW_DEBUGGING_FEATURES)`n                dpm.addUserRestriction(admin, UserManager.DISALLOW_USB_FILE_TRANSFER)`n                dpm.addUserRestriction(admin, UserManager.DISALLOW_SAFE_BOOT)`n                dpm.addUserRestriction(admin, UserManager.DISALLOW_ADD_USER)`n            } catch (_: Throwable) { }`n        }"
if (-not $t.Contains($old)) { Write-Host "ERROR 4"; exit 1 }
$t = $t.Replace($old, $new)
[IO.File]::WriteAllText($f, $t, $enc)

Write-Host "ALL PATCHED OK"
git add -A
git commit -m "kiosk: password MWmw2026 + lock ADB/USB under Device Owner"
git push