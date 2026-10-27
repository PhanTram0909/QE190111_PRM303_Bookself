# BookShelf - Final Self-Check List & Verification (PRM393)

This checklist maps all implemented features against the PRM393 exam specifications and auto-grader requirements.

---

## 1. Compliance Checklist (Exam Section 5 Mapping)

| Category | Requirement Item | Implemented In | Status |
|---|---|---|:---:|
| **Firestore** | Single collection `books` | `BookService`, `firestore.rules` | **PASS** |
| **Firestore** | Field names exact: `id`, `userId`, `title`, `author`, `genre`, `status`, `rating`, `favorite`, `notes`, `createdAt` | `lib/models/book.dart` | **PASS** |
| **Firestore** | Genre enum: `{Fiction, Non-Fiction, Academic, Other}` | `lib/utils/constants.dart`, `firestore.rules` | **PASS** |
| **Firestore** | Status enum: `{To Read, Reading, Finished}` | `lib/utils/constants.dart`, `firestore.rules` | **PASS** |
| **Rules #1** | Title: string, required (regex `.*\\S.*`), length <= 100 | `firestore.rules`, `AppValidators` | **PASS** |
| **Rules #2** | Author: string, required (regex `.*\\S.*`), length <= 60 | `firestore.rules`, `AppValidators` | **PASS** |
| **Rules #3** | Genre in the 4 allowed genres | `firestore.rules`, `AppValidators` | **PASS** |
| **Rules #4** | Status in the 3 allowed statuses | `firestore.rules`, `AppValidators` | **PASS** |
| **Rules #5** | Rating optional; if present: integer 0..5 | `firestore.rules`, `AppValidators` | **PASS** |
| **Rules #6** | Notes optional; if present: string length <= 300 | `firestore.rules`, `AppValidators` | **PASS** |
| **Rules #7** | Uniqueness: same user cannot save same title+author twice case-insensitively; enforced via deterministic doc ID (`userId_sha256(title_author)`); rules verify `request.resource.data.id == bookId == expectedDocId`; edit with title/author change implemented via transaction create-new + delete-old | `lib/utils/doc_id_helper.dart`, `BookService.updateBook()`, `firestore.rules` | **PASS** |
| **Rules #8** | Auth/ownership: users read/update/delete only `resource.data.userId == request.auth.uid`; create only `request.resource.data.userId == request.auth.uid`; userId cannot change on update; default deny all other collections | `firestore.rules` | **PASS** |
| **Indexing** | Query by `userId` only; no composite index needed | `BookService.getUserBooksStream()` | **PASS** |
| **Home Screen** | Public, first screen when logged out; Header: app name + Login + Register buttons; Title "BookShelf", short description, 3 feature cards ("Track your books", "Sort by status", "Rate your favorites") | `lib/screens/home_screen.dart` | **PASS** |
| **Auth Gate** | While resolving `authStateChanges` show centered loading indicator; no flash of List; back button on List screen cannot return to Login/Register | `lib/main.dart` (`AuthGate`) | **PASS** |
| **Register** | Email, password, confirm password; custom validation under fields; nothing shown before submit; errors disappear when valid; exact messages: `"Email is required"`, `"Please enter a valid email address"`, `"Password is required"`, `"Password must be at least 6 characters"`, `"Confirm password is required"`, `"Passwords do not match"`; on success shows `"Registration successful"`; Firebase error below submit button | `lib/screens/register_screen.dart` | **PASS** |
| **Login** | Email, password; custom validation under fields; exact messages: `"Email is required"`, `"Please enter a valid email address"`, `"Password is required"`; Firebase error below submit button; navigates to List screen | `lib/screens/login_screen.dart` | **PASS** |
| **List Header** | User's email + Logout button; Logout clears provider state and listeners, returns to Home | `lib/screens/books_list_screen.dart` | **PASS** |
| **Add Form** | Title, author, genre dropdown (`"Choose genre"`), status dropdown (`"Choose status"`), optional rating, optional notes; submit validation; exact messages: `"Title is required"`, `"Title must be at most 100 characters"`, `"Author is required"`, `"Author must be at most 60 characters"`, `"Please choose a genre"`, `"Please choose a status"`, `"Rating must be a whole number from 0 to 5"`, `"Notes must be at most 300 characters"`; on valid save shows `"Book added"`, form cleared; duplicate title+author shows Firestore error on form | `lib/screens/books_list_screen.dart` | **PASS** |
| **List Display** | Books sorted by title case-insensitive, ties by author case-insensitive; shows title, author, genre, status, favorite star toggle (updates at once, persists in Firestore), tap opens Detail; empty state shows `"No books found"` | `lib/screens/books_list_screen.dart`, `BookCard`, `EmptyState` | **PASS** |
| **Filters & Search** | Genre filter (All + 4 genres), Status filter (All + 3 statuses), `"favorites only"` Switch, Search box (title OR author contains text, case-insensitive, trimmed), `"Clear"` button resets all four; instant update | `lib/screens/books_list_screen.dart`, `BooksProvider` | **PASS** |
| **Summary** | Describes books currently shown: `"Books: N"`, `"Favorites: N"`, breakdown with one row per status appearing (`name: count`), most books first; ties order: `To Read`, `Reading`, `Finished` | `lib/screens/books_list_screen.dart`, `BooksProvider` | **PASS** |
| **Detail Screen** | Shows title, author, genre, status, rating, notes, favorite toggle; Edit action switches to inputs with `"Save"` and `"Cancel"`, same validation and exact messages as Add; Delete action opens confirmation dialog with `"Cancel"` and `"Delete"`; book removed immediately and after restart | `lib/screens/book_detail_screen.dart` | **PASS** |
| **Multi-account** | Provider state and listeners cleared on logout; new account shows only their books | `BooksProvider.clear()`, `BooksListScreen` | **PASS** |

---

## 2. What YOU Must Do Manually

Here is the exact checklist of tasks you need to complete in your browser, terminal, and Word editor:

### A. Firebase Console Configuration
1. Go to [Firebase Console](https://console.firebase.google.com/) and create your project (e.g., `bookshelf-prm393-exam`).
2. **Authentication:** Enable **Email/Password** provider under *Authentication > Sign-in method*.
3. **Firestore:** Create Firestore database in **production mode** (or test mode).
4. **Security Rules:**
   - In Firebase Console > *Firestore Database > Rules*, copy the contents of `d:\PE_PRM393\firestore.rules` and paste them.
   - Click **Publish**.
5. **Add Android App:**
   - Register Android app with package name: `com.example.bookshelf`.
   - Download the generated `google-services.json` and replace `d:\PE_PRM393\android\app\google-services.json`.
   - Update `d:\PE_PRM393\lib\firebase_options.dart` with your project's `apiKey`, `appId`, and `projectId` (or run `flutterfire configure`).

### B. Capture the 17 Required Screenshots
Follow `SCREENSHOT_CHECKLIST.md` to capture:
1. Firebase Auth users tab.
2. Firestore data tab (>= 3 docs).
3. Published Rules tab.
4. Register validation errors.
5. Register success SnackBar.
6. Login empty validation.
7. List screen after login (>= 3 books).
8. Add book validation errors.
9. Add book success SnackBar.
10. Genre filter in action.
11. Status filter in action.
12. "favorites only" switch ON.
13. Search box filter in action.
14. Summary card (> 1 status breakdown).
15. Detail view of a book.
16. Detail edit validation and saved state.
17. Delete confirmation dialog and empty state (`"No books found"`).

### C. Build and Release APK
In PowerShell inside `d:\PE_PRM393`:
```powershell
flutter build apk --release
```
1. Create a GitHub repository and push your code.
2. Under GitHub > **Releases**, create release `v1.0.0` and attach `build\app\outputs\flutter-apk\app-release.apk`.
3. Copy the release download URL.

### D. Prepare Submission Document (.docx)
1. Open `d:\PE_PRM393\SUBMISSION_INFO_TEMPLATE.docx` (or fill in the details from `SUBMISSION_INFO_TEMPLATE.txt`).
2. Insert your Student Code, Full Name, GitHub URL, APK Download Link, Firebase Project ID, and Test Account Credentials (`testuser@example.com` / `Password123!`).
3. Embed your 17 screenshots with their suggested captions.
4. Save as your final `.docx` submission report.

### E. Package Submission Zip
Run the command from `PACKAGING_GUIDE.md`:
```powershell
flutter clean
flutter pub get
$exclude = @("build", ".dart_tool", ".git", ".idea", ".vscode")
$filesToZip = Get-ChildItem -Path . | Where-Object { $exclude -notcontains $_.Name }
Compress-Archive -Path $filesToZip.FullName -DestinationPath "..\BookShelf_PRM393_Submission.zip" -Force
```
Ensure `pubspec.yaml` is directly at the top level of the zip file.
