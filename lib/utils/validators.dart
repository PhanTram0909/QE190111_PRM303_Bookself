import 'constants.dart';

class AppValidators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final trimmed = value.trim();
    // Standard robust email pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
    );
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Password validation for Login
  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  // Password validation for Register
  static String? validateRegisterPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Book title validation
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    if (value.trim().length > 100) {
      return 'Title must be at most 100 characters';
    }
    return null;
  }

  // Book author validation
  static String? validateAuthor(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Author is required';
    }
    if (value.trim().length > 60) {
      return 'Author must be at most 60 characters';
    }
    return null;
  }

  // Book genre validation
  static String? validateGenre(String? value) {
    if (value == null ||
        value.trim().isEmpty ||
        value == AppConstants.genreDropdownHint ||
        !AppConstants.genres.contains(value)) {
      return 'Please choose a genre';
    }
    return null;
  }

  // Book status validation
  static String? validateStatus(String? value) {
    if (value == null ||
        value.trim().isEmpty ||
        value == AppConstants.statusDropdownHint ||
        !AppConstants.statuses.contains(value)) {
      return 'Please choose a status';
    }
    return null;
  }

  // Book rating validation (optional; if filled: integer 0..5)
  static String? validateRating(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    final trimmed = value.trim();
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed < 0 || parsed > 5) {
      return 'Rating must be a whole number from 0 to 5';
    }
    return null;
  }

  // Book notes validation (optional; <= 300 chars)
  static String? validateNotes(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional
    }
    if (value.length > 300) {
      return 'Notes must be at most 300 characters';
    }
    return null;
  }
}
