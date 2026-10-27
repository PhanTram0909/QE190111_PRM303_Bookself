/// Application constants, predefined options, and exact string literals
class AppConstants {
  static const String appName = 'BookShelf';

  // Allowed Genres
  static const String genreFiction = 'Fiction';
  static const String genreNonFiction = 'Non-Fiction';
  static const String genreAcademic = 'Academic';
  static const String genreOther = 'Other';

  static const List<String> genres = [
    genreFiction,
    genreNonFiction,
    genreAcademic,
    genreOther,
  ];

  static const String genreDropdownHint = 'Choose genre';

  // Allowed Statuses
  static const String statusToRead = 'To Read';
  static const String statusReading = 'Reading';
  static const String statusFinished = 'Finished';

  static const List<String> statuses = [
    statusToRead,
    statusReading,
    statusFinished,
  ];

  static const String statusDropdownHint = 'Choose status';

  // Exact feedback and empty state strings
  static const String registrationSuccess = 'Registration successful';
  static const String bookAddedSuccess = 'Book added';
  static const String noBooksFound = 'No books found';
}
