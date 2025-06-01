# El7a2ny Mobile App

A mobile application built using Flutter. This README provides clear instructions for both developers and non-developers to run or test the app.

---

## El7a2ny Overview

El7a2ny is an emergency mobile app that tackeles real-life emergency situations and help its users tackle them in a user-friendly way.

The app includes 3 main features:

 - ECG Analysis, export your apple smart watch ECG PDF analysis, import it into our mobile, do a checkup and diagnose your ECG analysis to ensure it is normal or has a kind of abnormalities, and will guide you to the correct procedures accordingly.

 - Skin burns, got a burn at your home from a stove or boiling water? take a picture and upload it to the app, we will segment the burn, and classify the degree and prompt you with the correct guidlines accordingly.

 - CPR analysis, with our educational CPR mode, you will be able to do CPR at your home or at centers, capture a video of yourself doing the CPR (Cardiopulmonary resuscitation), upload it to the application, wait for a full informative analysis of the results and how we detect your rate and depth of motion along with posture warnings. Also experience the real-time feature of CPR where you can use the application in case of emergencies, mount the mobile in a portatit mode, then start your live stream, and you are good to go.

---

## 🔧 Tech Stack

- **Flutter SDK:** 3.29.3 (channel stable)
- **Dart SDK:** 3.7.2
- **Engine Revision:** cf56914b32
- **DevTools:** 2.42.3

Compatible with Android 

---

## How to Run the App

There are two main ways to run this app depending on your background:

### 1. Using the APk provided (Recommended to prevent compatibility issues)


#### 🔹 Steps

Step 1:

You will find the APk at ""

or you can CD into Flutter root directly and run the following to build a fresh APK:

```bash
flutter build apk --debug --target-platform android-arm,android-arm64,android-x86  
```

Step 2:

Download the APK into your andriod smartphone, then launch the application, and you are ready.

### 2. Running Flutter + connecting your smartphone using USB and enter debug mode (Not Recommended due to compatibility issues of Flutter and Andriod)

#### 🔹 Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Android Studio or VS Code (with Flutter & Dart plugins)
- Android device

#### 🔹 Steps

```bash
# Enter Flutter root directory
cd Flutter

#Clean to remove any builds
flutter clean

# Get dependencies
flutter pub get

# Run the app on a connected device/emulator
flutter run
