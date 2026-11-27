# Dayloop — Play Store Release Guide

Har box ek command hai. **Ek waqt mein ek box** copy karein aur Enter dabayein. Lafz `powershell` khud kabhi na likhein. Saari commands project folder mein chalani hain:

```powershell
cd E:\Projects\Dayloop
```

---

## 1. Package ID (sirf ek dafa, pehle upload se PEHLE)

Play Store par app ki pehchaan yahi ID hoti hai. Upload ke baad yeh kabhi nahi badal sakti.

```powershell
(Get-Content .\android\app\build.gradle.kts) -replace 'applicationId = "[^"]*"', 'applicationId = "com.innovexa.dayloop"' | Set-Content .\android\app\build.gradle.kts
```

Check karein:
```powershell
Select-String -Path .\android\app\build.gradle.kts -Pattern "applicationId"
```

## 2. App ka naam aur icon

App ka naam:
```powershell
(Get-Content .\android\app\src\main\AndroidManifest.xml) -replace 'android:label="[^"]*"', 'android:label="Dayloop"' | Set-Content .\android\app\src\main\AndroidManifest.xml
```

Icon banane ke liye (yeh `assets/branding/icon.png` se Android aur iPhone ke saare sizes khud bana deta hai):
```powershell
flutter pub get
```
```powershell
dart run flutter_launcher_icons
```

## 3. "Contact us" email button ke liye Android setting

Android 11 aur us se naye phones par email app kholne ke liye yeh zaroori hai:
```powershell
(Get-Content .\android\app\src\main\AndroidManifest.xml -Raw) -replace '<application', "<queries>`n        <intent>`n            <action android:name=`"android.intent.action.SENDTO`" />`n            <data android:scheme=`"mailto`" />`n        </intent>`n    </queries>`n    <application" | Set-Content .\android\app\src\main\AndroidManifest.xml
```

Check karein (ek dafa `mailto` nazar aana chahiye):
```powershell
Select-String -Path .\android\app\src\main\AndroidManifest.xml -Pattern "mailto"
```

## 4. Signing key (.jks) banana — sirf ek dafa

Yeh key app ka "dastakhat" hai. **Agar yeh file ya password kho gaya, to aap Play Store par app update nahi kar sakenge.** Is ki backup USB/Google Drive par zaroor rakhein, aur isay kabhi Git par upload na karein.

Keys ke liye folder:
```powershell
New-Item -ItemType Directory -Force E:\Keys
```

Key banayein (Android Studio ke saath aane wala `keytool` istemal hota hai):
```powershell
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkey -v -keystore E:\Keys\dayloop-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Yeh password poochega (do dafa), phir naam, company (Innovexa Technologies), shehar, mulk (PK). Aakhir mein `yes` likhein. Password kahin likh kar mehfooz kar lein.

> Agar "keytool not found" aaye to Android Studio kisi aur jagah install hai. Yeh chala kar raasta dhoondhein:
> `Get-ChildItem "C:\Program Files" -Recurse -Filter keytool.exe -ErrorAction SilentlyContinue | Select-Object FullName`

## 5. key.properties

`android` folder mein `key.properties` file banayein. `APNA_PASSWORD` ki jagah woh password likhein jo upar rakha tha:

```powershell
Set-Content .\android\key.properties "storePassword=APNA_PASSWORD`nkeyPassword=APNA_PASSWORD`nkeyAlias=upload`nstoreFile=E:/Keys/dayloop-upload.jks"
```

Check karein ke yeh file Git mein nahi jayegi (output mein `key.properties` aana chahiye):
```powershell
Select-String -Path .\android\.gitignore -Pattern "key.properties|jks"
```

## 6. build.gradle.kts mein signing lagana

`android\app\build.gradle.kts` VS Code mein kholein aur teen jagah tabdeeli karein.

**(a) File ke bilkul upar,** `plugins {` se pehle:
```kotlin
import java.io.FileInputStream
import java.util.Properties
```

**(b) `android {` wali line se pehle:**
```kotlin
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

**(c) `android { ... }` ke andar,** `buildTypes {` se pehle:
```kotlin
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
```

Aur `buildTypes { release { ... } }` ke andar yeh line:
```kotlin
signingConfig = signingConfigs.getByName("debug")
```
badal kar yeh kar dein:
```kotlin
signingConfig = signingConfigs.getByName("release")
```

> Agar yeh mushkil lage, to apni `build.gradle.kts` file chat mein bhej dein, main tayyar shuda file wapas bhej dunga.

## 7. APK aur AAB banana

| Kya | Kis liye | Command | File kahan banti hai |
|---|---|---|---|
| Debug APK (unsigned / debug key) | Sirf apni testing | `flutter build apk --debug` | `build\app\outputs\flutter-apk\app-debug.apk` |
| Signed release APK | Doston ko dena, asal testing | `flutter build apk --release` | `build\app\outputs\flutter-apk\app-release.apk` |
| **Final AAB (Play Store)** | **Play Console mein upload** | `flutter build appbundle --release` | `build\app\outputs\bundle\release\app-release.aab` |

Check karein ke release APK aap ki key se sign hui hai (Owner mein aap ka naam aana chahiye, "Android Debug" nahi):
```powershell
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -printcert -jarfile build\app\outputs\flutter-apk\app-release.apk
```

Har naye update se pehle `pubspec.yaml` mein `version: 1.0.0+1` ko barhayein, jaise `1.0.1+2`. `+` ke baad wala number har upload par pichle se bara hona chahiye.

## 8. Play Store listing ka saaman

| Cheez | Size | File |
|---|---|---|
| App icon | 512 × 512 PNG | `store_assets/icon-512x512.png` |
| Feature graphic | 1024 × 500 PNG | `store_assets/feature-graphic-1024x500.png` |
| Phone screenshots | 9:16 (1080 × 1920), kam az kam 2 | Design canvas ke "Play Store" page se download karein, aur 2-4 asal screenshots phone se lein (Today, Badges, Self-Care Day, Settings) |

**App name:** Dayloop

**Short description (80 characters tak):**
Calm daily rituals, mood-based routines, self-care days and badges.

**Full description:**
Dayloop helps you build calm, steady habits that bend with your energy instead of breaking.

• Daily rituals — morning, afternoon and evening habits with a focus timer and breathing guide.
• Energy check-in — tell Dayloop how you feel and your routine resizes to Full, Lite or a 2-minute Rescue version. Lite days still count toward your streak.
• Weekly Self-Care Day — one day a week planned for rest, reading, relaxation and meditation, with streaks paused.
• Badges and challenges — earn badges, join 7 to 21 day challenges, with one grace day so a single miss never ruins your progress.
• Water tracker and one-line journal.
• 12-week consistency heatmap.
• Beautiful light and dark themes with 10 colour schemes.
• Private by design — no account, no ads, no tracking. Everything stays on your phone.

**Category:** Health & Fitness  ·  **Contact email:** innovexa.technologies01@gmail.com

## 9. Privacy policy (website par)

Play Console ko privacy policy ka **web link** chahiye. Tayyar page: `docs/privacy-policy.html`.

Sab se aasaan free tareeqa, **GitHub Pages**:
1. Project GitHub par push karein (neeche section 11).
2. GitHub par repo → **Settings → Pages**.
3. **Source:** Deploy from a branch. **Branch:** `main`, folder **`/docs`**, phir Save.
4. 1-2 minute baad link milega: `https://USERNAME.github.io/REPO/privacy-policy.html`
5. Yahi link Play Console mein **App content → Privacy policy** mein daalein.

App ke andar bhi yahi policy **Profile → ⚙️ Settings → Privacy policy** mein hai, aur "Contact us" se seedha email app khulti hai.

## 10. Data safety aur delete account

- **Delete account:** Dayloop mein login/sign-up nahi hai, is liye account delete page ki zaroorat **nahi**. Play Console mein "Does your app allow users to create an account?" ka jawab **No** dein.
- **Data safety form:** "Does your app collect or share any of the required user data types?" ka jawab **No** dein, kyun ke saara data sirf phone par rehta hai aur kisi server par nahi jata. Profile photo bhi sirf phone par save hoti hai.
- Data mitane ka tareeqa: app mein **Settings → Reset all data**, ya app uninstall.

## 11. Repository (Git) link badalna

Abhi kaun sa link laga hai:
```powershell
git remote -v
```

Naya link lagane ke liye (yeh `.git\config` file mein khud update ho jata hai, file haath se kholne ki zaroorat nahi):
```powershell
git remote set-url origin https://github.com/USERNAME/dayloop.git
```

Agar `git remote -v` kuch na dikhaye (remote laga hi nahi), to:
```powershell
git remote add origin https://github.com/USERNAME/dayloop.git
```

Code upload karna:
```powershell
git add .
```
```powershell
git commit -m "Dayloop 1.0.0 release"
```
```powershell
git push -u origin main
```

> `key.properties` aur `.jks` kabhi push na karein. Push se pehle `git status` chala kar dekh lein ke yeh list mein nahi hain.

## 12. Testing checklist (release se pehle)

**Navigation**
- [ ] Badges, Habits ya Profile tab par **Back** dabayein: app Today par aaye.
- [ ] Today par **Back** dabayein: app band ho.
- [ ] Settings, Privacy policy, Self-Care, Focus jaisi screens par Back se pichli screen aaye.
- [ ] Onboarding mein Back pichle qadam par jaye.

**Features**
- [ ] Naya user: onboarding ke 4 qadam, phir Today screen.
- [ ] Habit check/uncheck karein: progress ring aur "rituals left" badlein.
- [ ] Habit par tap: focus timer chale, khatam hone par habit done ho.
- [ ] Mood chunein: routine Full, Lite ya Rescue mein badle.
- [ ] Pani +/− aur journal likhna. App band karke kholein: sab save ho.
- [ ] Habit add, edit aur delete.
- [ ] Self-Care Day: plan, swap, Surprise me, rating.
- [ ] Badges aur Challenges: join, leave, aur progress.
- [ ] Profile: gallery se photo, camera se photo, photo remove, naam edit.
- [ ] Settings: Light, Dark, System aur 10 schemes. Har screen par text saaf parha jaye.
- [ ] Contact us se email app khule, aur Privacy policy khule.
- [ ] Reset all data se onboarding par wapas jaye.

**Phones**
- [ ] Chhota phone (5.5") aur bara phone (6.7"): kuch kata hua ya overlap na ho.
- [ ] Internet band karke bhi app poori chale.
- [ ] Phone ka font bara karke (Settings → Display → Font size) bhi layout theek rahe.
