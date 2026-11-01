# 📱 Nirbhor (নির্ভর / KajerLok) - Mobile Application

A cross-platform on-demand service seeker & provider mobile platform built with **Flutter**, **Dart**, **GetX**, and **Google Maps**.

---

## 📑 Table of Contents (সূচিপত্র)

1. [Prerequisites (পূর্বশর্ত)](#-1-prerequisites-পবরবশরত)
2. [Project Cloning (প্রজেক্ট ক্লোন করা)](#-2-clone-the-repository-পরজককট-ককলন-কর)
3. [Opening in IDE (VS Code / Antigravity)](#-3-open-in-ide-vs-code--antigravity)
4. [Installing Dependencies (প্যাকেজ ইন্সটল)](#-4-install-dependencies-পযককজ-ইনসটল)
5. [Backend & API Configuration (এপিআই কনফিগারেশন)](#-5-backend--api-configuration-এপআই-কনফগকরশন)
6. [Device Setup: Physical Phone & Emulator (ডিভাইস প্রস্তুত করা)](#-6-device-setup-ডভইস-পরসতত-কর)
7. [Running the App (অ্যাপ রান করা)](#-7-run-the-app-অযপ-রন-কর)
8. [Building the App: APK & AAB (অ্যাপ বিল্ড করা)](#-8-building-the-app-অযপ-বলড-কর)
9. [Troubleshooting & Common Fixes (সাধারণ সমস্যা ও সমাধান)](#-9-troubleshooting--common-fixes-সধরণ-সমসয-ও-সমধন)

---

## 🛠 1. Prerequisites (পূর্বশর্ত)

Before setting up the project, make sure the following tools are installed on your computer:

| Tool | Recommended Version | Download Link |
| :--- | :--- | :--- |
| **Git** | 2.x or latest | [git-scm.com](https://git-scm.com/) |
| **Flutter SDK** | **3.10.x** to **3.27.x** (Dart 3.x) | [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install) |
| **Android Studio** | Latest (Hedgehog / Iguana / Koala / Ladybug) | [developer.android.com/studio](https://developer.android.com/studio) |
| **VS Code / Antigravity** | Latest version | [code.visualstudio.com](https://code.visualstudio.com/) |

### Verify your environment:
Open your Terminal (macOS/Linux) or Command Prompt/PowerShell (Windows) and run:
```bash
flutter doctor
```
> [!IMPORTANT]
> Ensure that **Flutter**, **Android toolchain**, and **VS Code / Android Studio** have green checkmarks (`✓`).
> If Android licenses are missing, accept them with:
> ```bash
> flutter doctor --android-licenses
> ```

---

## 📥 2. Clone the Repository (প্রজেক্ট ক্লোন করা)

Open your terminal or command prompt, navigate to your desired directory, and clone the repository:

```bash
# Clone the repository
git clone <YOUR_REPOSITORY_GIT_URL>

# Enter the Flutter project directory
cd Nirbhor
```

---

## 💻 3. Open in IDE (VS Code / Antigravity)

### In VS Code or Google Antigravity:
1. Open **VS Code** or **Antigravity**.
2. Go to **File** ➔ **Open Folder...** (or press `Cmd + O` on Mac / `Ctrl + O` on Windows).
3. Select the `Nirbhor` project folder.
4. **Install Required Extensions:**
   - In the Extensions tab (`Ctrl+Shift+X` or `Cmd+Shift+X`), search and install:
     - **Flutter** (by Dart Code)
     - **Dart** (by Dart Code)

---

## 📦 4. Install Dependencies (প্যাকেজ ইন্সটল)

In the IDE integrated terminal (press `Ctrl + ~` or `` Cmd + ` ``), run:

```bash
flutter pub get
```

*Note for macOS / iOS users:*
If you intend to test or build for iOS:
```bash
cd ios
pod install
cd ..
```

---

## 🌐 5. Backend & API Configuration (এপিআই কনফিগারেশন)

The application communicates with the backend via [`lib/service/api_url.dart`](file:///Users/riyajuddineusouf/Development/projects/Final_Year_Project/Nirbhor/lib/service/api_url.dart).

1. Open `lib/service/api_url.dart`.
2. Select your desired `baseUrl`:

```dart
class ApiUrl {
  // Option A: Live Production / Staging Server (Default)
  static const String baseUrl = "https://nirbhor-backend-6yuf.onrender.com/api/v1";

  // Option B: Local Android Emulator (10.0.2.2 maps to computer's localhost)
  // static const String baseUrl = "http://10.0.2.2:8000/api/v1";

  // Option C: Local Physical Device (Replace with your computer's Wi-Fi IPv4 address)
  // static const String baseUrl = "http://192.168.0.xxx:8000/api/v1";
```

> [!TIP]
> - For **Android Emulator**: `http://10.0.2.2:8000/api/v1` connects directly to a locally running backend on port 8000.
> - For **Physical Mobile Phone via Wi-Fi**: Both computer and mobile must be connected to the exact same Wi-Fi network. Use your computer's local IP (e.g. `192.168.x.x`).

---

## 📱 6. Device Setup (ডিভাইস প্রস্তুত করা)

### Option A: Physical Android Phone (আসল ফোন)
1. Open your phone's **Settings** ➔ **About Phone**.
2. Tap on **Build Number** 7 times continuously until you see *"You are now a developer!"*.
3. Go back to **Settings** ➔ **System** / **Additional Settings** ➔ **Developer Options**.
4. Enable **USB Debugging** (ইউএসবি ডিবাগিং চালু করুন).
5. Connect your phone to your computer with a USB cable.
6. A prompt will appear on your phone screen: *"Allow USB debugging?"* ➔ Check *"Always allow from this computer"* and tap **OK / Allow**.
7. In terminal, verify your device is connected:
   ```bash
   flutter devices
   ```
   *(Your phone model should be listed here)*

### Option B: Android Emulator (কম্পিউটার এমুলেটর)
1. Open **Android Studio** ➔ **Device Manager** (or Virtual Device Manager).
2. Create or select a virtual device (e.g. Pixel 7 / Pixel 8, Android 13 or 14).
3. Click the **Play (▶)** button to launch the emulator.

---

## 🚀 7. Run the App (অ্যাপ রান করা)

### Method 1: Using Terminal (সহজ পদ্ধতি)
```bash
# Run on the connected device or open emulator
flutter run

# If multiple devices are connected, specify the device ID:
flutter devices
flutter run -d <DEVICE_ID>
```

### Method 2: Using VS Code / Antigravity GUI
1. In the bottom-right status bar of VS Code / Antigravity, click the device selector and select your connected phone or running emulator.
2. Open [`lib/main.dart`](file:///Users/riyajuddineusouf/Development/projects/Final_Year_Project/Nirbhor/lib/main.dart).
3. Press **F5** or click **Run without Debugging** (`Ctrl + F5` or `Cmd + F5`).

### During Development:
- Press **`r`** in terminal: **Hot Reload** (instant UI update without restart).
- Press **`R`** in terminal: **Hot Restart** (re-initializes state).
- Press **`q`** in terminal: Quit / Stop the app.

---

## 🏗 8. Building the App (অ্যাপ বিল্ড করা)

When you need to export installable files (`.apk` or `.aab`) to share with friends, clients, or publish to the Google Play Store:

### 1. Build Debug APK (দ্রুত টেস্ট করার জন্য)
Ideal for testing on any Android phone without signature requirements:
```bash
flutter build apk --debug
```
📁 **Output Path:**
```
build/app/outputs/flutter-apk/app-debug.apk
```

---

### 2. Build Release APK (ইনস্টলেবল প্রোডাকশন APK)
Single standalone APK file optimized for production:
```bash
flutter build apk --release
```
📁 **Output Path:**
```
build/app/outputs/flutter-apk/app-release.apk
```

---

### 3. Build Split ABI APKs (ফাইল সাইজ ছোট করার জন্য)
Splits APK into architecture-specific files (armeabi-v7a, arm64-v8a, x86_64). This significantly reduces the APK download and install size:
```bash
flutter build apk --split-per-abi
```
📁 **Output Path:**
```
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk (For modern phones)
build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk (For older 32-bit phones)
```

---

### 4. Build Android App Bundle - AAB (Google Play Store-এর জন্য)
Required when uploading to the Google Play Console:
```bash
flutter build appbundle --release
```
📁 **Output Path:**
```
build/app/outputs/bundle/release/app-release.aab
```

---

### 5. Build iOS (macOS & Xcode Required)
```bash
flutter build ios --release
# Or generate an IPA archive for TestFlight / App Store:
flutter build ipa --release
```

---

## 🔧 9. Troubleshooting & Common Fixes (সাধারণ সমস্যা ও সমাধান)

### 🔴 Problem 1: `flutter pub get` or Gradle build fails
**Solution:** Clean cache and rebuild:
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
flutter run
```

### 🔴 Problem 2: Phone is connected via USB, but `flutter devices` says "No devices found"
**Solution:**
1. Make sure your USB cable supports **data transfer** (some cables are charge-only).
2. On your phone, change USB connection mode from *Charging only* to **File Transfer / MTP**.
3. Re-toggle **Developer Options** ➔ **USB Debugging** (turn off and on).
4. Run `adb devices` in terminal to check if unauthorized; accept the RSA dialog on your phone screen.

### 🔴 Problem 3: Android license error (`Android SDK licenses not accepted`)
**Solution:**
```bash
flutter doctor --android-licenses
```
*(Press `y` and Enter to accept all agreements)*

### 🔴 Problem 4: Google Maps is blank or grey screen
**Solution:**
- Ensure the phone has an active internet connection (Wi-Fi or Mobile Data).
- Google Maps API key is configured inside:
  - `android/app/src/main/AndroidManifest.xml` (`com.google.android.geo.API_KEY`)
  - [`lib/service/api_url.dart`](file:///Users/riyajuddineusouf/Development/projects/Final_Year_Project/Nirbhor/lib/service/api_url.dart) (`mapKey`)

---

## 👥 Contributors & Support

- **Project:** Nirbhor (নির্ভর / KajerLok)
- **Framework:** Flutter (GetX architecture)
- For issues, raise a ticket or reach out to the project development team.
