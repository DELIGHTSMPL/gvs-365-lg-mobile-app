# GVS 365 LG Mobile App - APK Build & Installation Guide

This document explains how to build the Android `.apk` package for the **GVS 365 LG Automation Mobile Application**.

---

## 🚀 Option 1: 1-Click Local Windows Build (`build_apk.bat`)

If Flutter & Android SDK are installed on your Windows PC:

1. Open this project directory in Terminal / Command Prompt:
   ```cmd
   y:
   cd "y:\0.1 - 2026 PLANNING\DHARMESH - 2026\AUTOMATION\GVS 365 LG AUTOMATION\GVS MOBILE APP"
   ```
2. Double-click or run `build_apk.bat`:
   ```cmd
   build_apk.bat
   ```
3. The generated release APK will be located at:
   - `build\app\outputs\flutter-apk\app-release.apk`
   - Copied to root as: `gvs_365_lg_app.apk`

---

## ☁️ Option 2: Cloud APK Build via GitHub Actions (Zero Local Setup)

If Flutter / Android SDK are not installed locally on your Windows PC:

1. Push this project folder to your GitHub repository.
2. Go to the **Actions** tab in your GitHub repository.
3. Select **Build GVS 365 LG Android APK** and click **Run workflow**.
4. Once completed (approx. 2-3 minutes), download the ready-to-install `.apk` zip file from **Artifacts**.

---

## 📱 How to Install on Android Devices

1. Transfer `gvs_365_lg_app.apk` to your Android phone via USB cable, WhatsApp, or Google Drive.
2. Open File Manager on the phone and tap `gvs_365_lg_app.apk`.
3. If prompted, select **Allow Installation from Unknown Sources**.
4. Tap **Install** and open **GVS 365 LG Mobile**.

---

## 📁 Key Features Included

- **Dashboard**: Live metrics for Active Calls, Total Logged, Active AMCs, and Digital Job Sheets.
- **Call Register**: Real-time logging of service calls, complaint tracking, technician assignment, status change.
- **Customer Directory**: Fast customer lookup, phone calling shortcut, equipment model & serial number mapping.
- **LG AMC Reports**: Annual Maintenance Contract tracking, expiration alerts, preventive service counters.
- **Digital Job Sheets**: Electronic job sheet creation with work done details, replaced parts listing, and digital sign-off.
- **Settings & Backend Sync**: Server API URL configuration for integration with ASP.NET backend.
