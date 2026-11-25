# Sukoon — Habit & Self-Care App (Flutter)

Ek hi code se Android aur iPhone dono ki app. Saara data phone mein save hota hai (koi server ya login nahi chahiye).

## 1. Computer par Flutter lagayein (sirf pehli dafa)

1. Flutter install karein: https://docs.flutter.dev/get-started/install
2. Android ke liye Android Studio install karein (is ke saath Android SDK aur emulator aata hai).
3. Terminal mein chalayein:
   ```
   flutter doctor
   ```
   Jo cheez laal (✗) ho, `flutter doctor` usi ka hal batata hai. Sab hara (✓) ho jaye to aage barhein.

## 2. Project chalayein

1. Zip file ko unzip karein. `sukoon_app` naam ka folder banega.
2. Terminal mein us folder ke andar jayein:
   ```
   cd sukoon_app
   ```
3. Android aur iPhone ke folders banayein (yeh aap ke `lib/` code ko nahi chhedta):
   ```
   flutter create . --org com.yourcompany --project-name sukoon --platforms android,ios
   ```
   `com.yourcompany` ki jagah apni company ka naam likhein (jaise `com.usmanapps`). Yeh baad mein Play Store par app ki pehchaan banti hai.
4. Packages download karein:
   ```
   flutter pub get
   ```
5. Phone USB se lagayein (Developer options mein USB debugging on) ya emulator chalayein, phir:
   ```
   flutter run
   ```

## 3. Tests chalayein

```
flutter test
```
14 tests hain jo streak, badges, challenges, Self-Care plan aur data save hone ke rules check karte hain. Sab pass hone chahiye.

## 4. Play Store ke liye file banana

```
flutter build appbundle --release
```
File yahan banegi: `build/app/outputs/bundle/release/app-release.aab`
(Upload se pehle signing key banana zaroori hai: https://docs.flutter.dev/deployment/android)

Sirf testing ke liye APK:
```
flutter build apk --release
```

## 5. App ka naam badalna

- `lib/theme/app_theme.dart` mein `AppConfig.appName`.
- Android: `android/app/src/main/AndroidManifest.xml` mein `android:label`.
- iPhone: `ios/Runner/Info.plist` mein `CFBundleDisplayName`.

## Folder structure

```
lib/
  main.dart                  App shuru hoti hai, onboarding ya home dikhata hai
  core/                      Saare rules (pure Dart, tests ke saath)
    app_data.dart            Habits, streak, mood, pani, journal, Self-Care, challenges
    achievements.dart        11 badges aur 5 challenges ki list
    self_care_library.dart   Self-Care suggestions aur plan banane ka tareeqa
    models.dart, dates.dart
  data/app_store.dart        Data phone mein save karta hai aur screens ko update karta hai
  theme/app_theme.dart       Rang, fonts, app ka naam
  widgets/common.dart        Card, buttons, icons jo har jagah use hote hain
  screens/                   Saari screens
    onboarding_screen.dart   4 qadam ka shuruaati setup
    home_shell.dart          Neeche wali navigation (Today, Habits, Achievements, Me)
    today_screen.dart        Aaj ki routine, mood, pani, journal
    focus_screen.dart        Timer aur saans ki guide
    habits_screen.dart       Habit add / edit / delete
    self_care_setup_screen.dart, self_care_day_screen.dart
    achievements_screen.dart Badges aur Challenges tabs
    profile_screen.dart      Heatmap, settings, journal history, reset
assets/fonts/                Plus Jakarta Sans + Fraunces (OFL license, app ke andar)
test/core_test.dart          Rules ke tests
```

## Ahem rules (jaise app mein bane hain)

- **Streak:** Din tab ginta hai jab us din ki aadhi routine mukammal ho (Rescue mode mein 1 habit kaafi). Aaj ka din abhi khatam nahi hua, is liye aaj streak nahi tootti.
- **Mood:** Drained → Rescue (3 habits, 2 min), Low → Lite, baqi → Full. User haath se bhi mode badal sakta hai.
- **Self-Care Day:** Streak pause ho to us din routine chhootne se streak nahi tootti. Plan mein 4 suggestions + raat ki reflection hoti hai, aur ek plan mein koi suggestion do dafa nahi aati.
- **Badges:** Har badge sirf ek dafa milta hai.
- **Challenges:** Ek waqt mein zyada se zyada 3. Ek din chhootne par grace day, doosra chhootne par challenge khatam (dobara shuru kiya ja sakta hai).

## Agle marhale (is version mein nahi)

AI Coach, notifications, login/cloud backup, namaz ke auqaat, Ramzan mode, Squad, dark mode. In ke liye server, API keys ya mazeed packages chahiye.

## Agar koi masla aaye

- `flutter clean` phir `flutter pub get` phir `flutter run`.
- Error ka poora text copy karke bhejein, main hal bata dunga.
