# BookShelf - Screenshot Checklist (17 Screenshots) & Submission Template

This document lists the **17 mandatory screenshots** required for the PRM393 practical exam submission, including suggested captions and capture instructions, followed by the submission metadata template.

---

## 17 Screenshots Checklist

### 1. Firebase Auth Users
- **Where to capture:** Firebase Console > Authentication > Users tab.
- **What to show:** At least one registered user (e.g. `testuser@example.com`) with Provider `password` and User UID visible.
- **Suggested Caption:** `01_firebase_auth_users.png - Firebase Authentication console showing active test user account.`

### 2. Firestore Data (>= 3 documents)
- **Where to capture:** Firebase Console > Firestore Database > Data tab.
- **What to show:** The `books` collection with at least 3 documents visible, showing fields (`id`, `userId`, `title`, `author`, `genre`, `status`, `favorite`, `rating`, `notes`, `createdAt`).
- **Suggested Caption:** `02_firestore_data_collection.png - Cloud Firestore 'books' collection displaying sample books with exact field schema.`

### 3. Published Rules Tab
- **Where to capture:** Firebase Console > Firestore Database > Rules tab.
- **What to show:** The published security rules editor containing the custom rules, with status "Published" and timestamp.
- **Suggested Caption:** `03_published_firestore_rules.png - Cloud Firestore Security Rules published successfully with deterministic ID checks.`

### 4. Register Validation Errors
- **Where to capture:** In app, Register screen.
- **What to show:** Submit clicked with empty fields or invalid email/short password. Validation messages visible below fields:
  - `"Email is required"` or `"Please enter a valid email address"`
  - `"Password is required"` or `"Password must be at least 6 characters"`
  - `"Confirm password is required"` or `"Passwords do not match"`
- **Suggested Caption:** `04_register_validation_errors.png - Register screen displaying field-level custom validation error messages.`

### 5. Register Success
- **Where to capture:** In app, Register screen immediately after submit.
- **What to show:** Green SnackBar displaying `"Registration successful"`.
- **Suggested Caption:** `05_register_success.png - Register screen displaying 'Registration successful' notification.`

### 6. Login Empty Form Validation
- **Where to capture:** In app, Login screen.
- **What to show:** Submit clicked with empty email & password. Messages visible:
  - `"Email is required"`
  - `"Password is required"`
- **Suggested Caption:** `06_login_empty_validation.png - Login screen showing 'Email is required' and 'Password is required' under fields.`

### 7. List Screen After Login (>= 3 books)
- **Where to capture:** In app, BooksListScreen.
- **What to show:** Header showing user's email + "Logout" button, plus at least 3 books displayed in the list with titles, authors, genres, statuses, and favorite stars.
- **Suggested Caption:** `07_list_screen_after_login.png - BooksListScreen displaying user's email in header, Logout button, and multiple cataloged books.`

### 8. Add Book Form Validation Errors
- **Where to capture:** In app, Add New Book form on List screen.
- **What to show:** Tapping "Add Book" with blank fields. Messages visible:
  - `"Title is required"`
  - `"Author is required"`
  - `"Please choose a genre"`
  - `"Please choose a status"`
- **Suggested Caption:** `08_add_book_validation_errors.png - Add Book form displaying required field error messages on submit.`

### 9. Add Book Success
- **Where to capture:** In app, List screen immediately after adding a valid book.
- **What to show:** Green SnackBar displaying `"Book added"`, form cleared, and new book appearing immediately in the list.
- **Suggested Caption:** `09_add_book_success.png - Form cleared with 'Book added' SnackBar and real-time update in book list.`

### 10. Filter: Genre
- **Where to capture:** In app, List screen.
- **What to show:** Genre filter dropdown set to a specific genre (e.g. `Academic`), showing only books matching that genre.
- **Suggested Caption:** `10_filter_by_genre.png - Instant genre filter applied showing only 'Academic' books.`

### 11. Filter: Status
- **Where to capture:** In app, List screen.
- **What to show:** Status filter dropdown set to `To Read` (or `Reading` / `Finished`), showing only books in that status.
- **Suggested Caption:** `11_filter_by_status.png - Instant status filter applied showing only books with status 'To Read'.`

### 12. Filter: Favorites Only Switch
- **Where to capture:** In app, List screen.
- **What to show:** The "favorites only" Switch toggled ON, showing only starred books.
- **Suggested Caption:** `12_filter_favorites_only.png - 'favorites only' switch enabled, displaying only favorited books.`

### 13. Search Box Filter
- **Where to capture:** In app, List screen.
- **What to show:** Search box containing text (e.g., `Martin` or `Dune`), with list instantly filtering to books whose title or author contains the search term.
- **Suggested Caption:** `13_search_box_filtering.png - Real-time case-insensitive search by title or author.`

### 14. Summary Section (> 1 status breakdown)
- **Where to capture:** In app, List screen Summary card.
- **What to show:** `Books: N`, `Favorites: N`, and the Status Breakdown showing multiple statuses (e.g. `To Read: 2`, `Reading: 1`, `Finished: 2`) ordered with most books first (and canonical tie-breaking).
- **Suggested Caption:** `14_summary_status_breakdown.png - Summary card displaying total books, favorites count, and breakdown sorted by count.`

### 15. Detail View
- **Where to capture:** In app, tapping a book to open BookDetailScreen.
- **What to show:** Book title, author, genre, status, rating (e.g. `5 / 5`), notes, and favorite star toggle with Edit and Delete buttons.
- **Suggested Caption:** `15_book_detail_view.png - BookDetailScreen displaying full book metadata and actions.`

### 16. Detail Edit Validation & After Save
- **Where to capture:** In app, Detail screen in Edit mode.
- **What to show:**
  - View A: Form inputs with validation errors (e.g. clearing title showing `"Title is required"`).
  - View B: Successful save returning to view mode with updated details and `"Book updated successfully"`.
- **Suggested Caption:** `16_detail_edit_and_save.png - Detail screen edit mode with validation and subsequent saved state.`

### 17. Favorite Toggle, Delete Dialog & Empty State
- **Where to capture:**
  - View A: Delete confirmation dialog with "Cancel" and "Delete" buttons.
  - View B: Fresh account login showing `"No books found"`.
- **Suggested Caption:** `17_delete_dialog_and_empty_state.png - Delete confirmation dialog and 'No books found' empty state on a fresh account.`

---

## Submission Template (.docx / Text format)

Copy and fill out the following template for your official Word (.docx) document:

```text
================================================================================
                    PRM393 PRACTICAL EXAM SUBMISSION REPORT
================================================================================

Student Information:
--------------------------------------------------------------------------------
Student Code:            [YOUR_STUDENT_CODE, e.g., SE123456]
Full Name:               [YOUR_FULL_NAME, e.g., Nguyen Van A]

Project Links & Identifiers:
--------------------------------------------------------------------------------
GitHub Repository URL:   https://github.com/[username]/[repo_name]
APK Download Link:       https://github.com/[username]/[repo_name]/releases/download/v1.0.0/app-release.apk
Firebase Project ID:     bookshelf-prm393-exam

Grading Test Account Credentials:
--------------------------------------------------------------------------------
Test Account Email:      testuser@example.com
Test Account Password:   Password123!

================================================================================
```
