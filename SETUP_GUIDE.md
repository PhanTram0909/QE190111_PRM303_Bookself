# BookShelf - Setup Guide (PRM393 Practical Exam)

This document provides step-by-step instructions to configure, run, test, and build the **BookShelf** Flutter application with Firebase.

---

## 1. Firebase Project Setup

1. Open the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project** (or select an existing project). Name it (e.g., `bookshelf-prm393`).
3. Disable Google Analytics (optional, to speed up setup) and click **Create Project**.

### Enable Firebase Authentication (Email/Password)
1. In the left sidebar, navigate to **Build > Authentication**.
2. Click **Get started**.
3. Under the **Sign-in method** tab, click **Email/Password**.
4. Enable the **Email/Password** toggle (leave "Email link" disabled) and click **Save**.

### Create Cloud Firestore Database
1. In the left sidebar, navigate to **Build > Firestore Database**.
2. Click **Create database**.
3. Choose a database location close to you (e.g., `asia-southeast1` or `us-central1`).
4. Select **Start in production mode** (or test mode) and click **Create**.

---

## 2. Configure Client-Side Firebase in Flutter

You can configure Firebase using either **FlutterFire CLI** (recommended) or manual file placement.

### Option A: FlutterFire CLI (Automatic)
1. Ensure Firebase CLI is installed and logged in:
   ```bash
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   ```
2. Run `flutterfire configure` inside the project root (`d:\PE_PRM393`):
   ```bash
   flutterfire configure
   ```
3. Select your Firebase project and select platforms **Android** (and Web/iOS if desired).
4. This automatically updates `lib/firebase_options.dart` and `android/app/google-services.json`.

### Option B: Manual Configuration
1. In Firebase Console, go to **Project Settings** (gear icon) > **General**.
2. Under **Your apps**, click the **Android** icon (`</>`).
3. Set the Android package name to:
   ```
   com.example.bookshelf
   ```
4. Download `google-services.json` and replace the template at:
   ```
   android/app/google-services.json
   ```
5. Update `lib/firebase_options.dart` with your project's `apiKey`, `appId`, and `projectId`.

> **IMPORTANT:** Only client-side Firebase config is used. NEVER place or commit an admin/service-account key.

---

## 3. Publish Firestore Security Rules

### Via Firebase Console (Fastest)
1. In Firebase Console, go to **Firestore Database > Rules**.
2. Copy the full contents of `firestore.rules` from this project.
3. Paste into the console editor and click **Publish**.

### Via Firebase CLI
```bash
firebase deploy --only firestore:rules
```

---

## 4. Firestore Rules Test Checklist (Rules Playground)

Open the **Rules Playground** tab in Firebase Console (Firestore > Rules > Rules Playground) to verify enforcement:

| # | Operation | Auth State | Path / Document Data | Expected Result |
|---|---|---|---|---|
| 1 | **get** | Signed Out | `/books/any_id` | **Denied** (Unauthenticated) |
| 2 | **create** | Authenticated (`uid: user123`) | `id: user123_<valid_hash>`, `userId: user123`, `title: "Dune"`, `author: "Frank Herbert"`, `genre: "Fiction"`, `status: "Reading"`, `favorite: false`, `createdAt: request.time` | **Allowed** |
| 3 | **create** | Authenticated (`uid: user123`) | Same as above, but `title: "   "` (whitespace only) | **Denied** (Title invalid) |
| 4 | **create** | Authenticated (`uid: user123`) | Same as above, but `title` > 100 characters | **Denied** (Title too long) |
| 5 | **create** | Authenticated (`uid: user123`) | Same as above, but `author: "   "` | **Denied** (Author invalid) |
| 6 | **create** | Authenticated (`uid: user123`) | Same as above, but `genre: "History"` (not in 4 genres) | **Denied** (Genre refused) |
| 7 | **create** | Authenticated (`uid: user123`) | Same as above, but `status: "Abandoned"` (not in 3 statuses) | **Denied** (Status refused) |
| 8 | **create** | Authenticated (`uid: user123`) | Same as above, but `rating: 7` or `-1` | **Denied** (Rating must be 0..5) |
| 9 | **create** | Authenticated (`uid: user123`) | Same as above, but `notes` > 300 characters | **Denied** (Notes too long) |
| 10 | **create** | Authenticated (`uid: user123`) | Random doc ID (does not match `userId + '_' + sha256(...)`) | **Denied** (Doc ID mismatch) |
| 11 | **create** | Authenticated (`uid: user123`) | `userId: "other_user"` | **Denied** (Cannot write other's userId) |
| 12 | **get / list** | Authenticated (`uid: user456`) | Document owned by `user123` | **Denied** (Cannot read other's doc) |

### Note on Composite Indexes
- **No composite indexes are required.**
- The app queries Firestore exclusively by `userId == auth.uid`, which uses single-field indexing.
- Multi-criteria sorting (title case-insensitive, ties by author) and status breakdowns are evaluated client-side for maximum performance and index-free execution.

---

## 5. Create Test Account & Sample Data

1. Run the app on an Android emulator or device:
   ```bash
   flutter run
   ```
2. On the **Home** screen, tap **Register** (or **Create Account**).
3. Register the test account:
   - Email: `testuser@example.com`
   - Password: `Password123!`
   - Confirm Password: `Password123!`
4. Upon successful registration, you will see `"Registration successful"` and land directly on the **BooksListScreen**.
5. Add at least **5 sample books** in at least **2 different statuses**:

| Title | Author | Genre | Status | Rating | Favorite | Notes |
|---|---|---|---|---|---|---|
| **Clean Code** | Robert C. Martin | Academic | Finished | 5 | Yes | A handbook of agile software craftsmanship. |
| **1984** | George Orwell | Fiction | Finished | 5 | Yes | Classic dystopian masterpiece. |
| **Dune** | Frank Herbert | Fiction | Reading | 4 | Yes | Science fiction epic set on Arrakis. |
| **Sapiens** | Yuval Noah Harari | Non-Fiction | To Read | null | No | A brief history of humankind. |
| **Refactoring** | Martin Fowler | Academic | To Read | 4 | No | Improving the design of existing code. |

---

## 6. Build Release APK

1. In terminal at project root, build the release APK:
   ```bash
   flutter build apk --release
   ```
2. The generated APK will be at:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

---

## 7. Upload to GitHub Releases

1. Push your repository to your GitHub account:
   ```bash
   git init
   git add .
   git commit -m "Complete BookShelf app for PRM393 practical exam"
   git remote add origin https://github.com/<your-username>/<your-repo-name>.git
   git branch -M main
   git push -u origin main
   ```
2. On GitHub, navigate to your repository > **Releases** > **Draft a new release**.
3. Tag version: `v1.0.0`.
4. Release title: `BookShelf v1.0.0 - Release APK`.
5. Attach the `app-release.apk` binary.
6. Click **Publish release**.
7. Copy the direct download URL for your submission form.
