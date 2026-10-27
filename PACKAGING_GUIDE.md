# BookShelf - Packaging Guide for Submission (PRM393)

To ensure full marks in the automated and manual grading pipelines, the project zip must be structured precisely as specified.

---

## 1. Structure Requirements

- **`pubspec.yaml` MUST be at the top level of the zip file** (do NOT zip an enclosing parent folder; select files directly or zip directory contents).
- **Mandatory items included:**
  - `pubspec.yaml`
  - `pubspec.lock`
  - `lib/` (all models, services, providers, screens, widgets, utils, main.dart, firebase_options.dart)
  - `android/` (build configuration, Kotlin DSL scripts, google-services.json template)
  - `assets/` (project assets and documentation)
  - `firestore.rules` (final security rules)
  - `SETUP_GUIDE.md`, `PACKAGING_GUIDE.md`, `SCREENSHOT_CHECKLIST.md`

- **MUST BE EXCLUDED:**
  - `build/` (build artifacts, very large)
  - `.dart_tool/` (temporary cache)
  - `.git/` (git history)
  - `.idea/` and `.vscode/` (IDE settings)
  - Any private admin/service-account JSON keys (`*.json` service keys)

---

## 2. Recommended PowerShell Command to Create the Submission Zip

Open PowerShell inside `d:\PE_PRM393` and run:

```powershell
# 1. Clean flutter build cache first
flutter clean

# 2. Re-fetch dependencies so pubspec.lock is up to date
flutter pub get

# 3. Create clean zip archive with pubspec.yaml at top level
$exclude = @("build", ".dart_tool", ".git", ".idea", ".vscode")
$filesToZip = Get-ChildItem -Path . | Where-Object { $exclude -notcontains $_.Name }

Compress-Archive -Path $filesToZip.FullName -DestinationPath "..\BookShelf_PRM393_Submission.zip" -Force
```

---

## 3. Verification of the Created Zip

After creating `BookShelf_PRM393_Submission.zip`:
1. Open the zip file.
2. Verify that `pubspec.yaml` is visible immediately inside the root of the archive (NOT inside `BookShelf_PRM393_Submission/...`).
3. Verify that `build/` and `.dart_tool/` are NOT present.
4. Total zip size should typically be **< 15 MB**.
