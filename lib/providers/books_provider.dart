import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../services/book_service.dart';

class BooksProvider extends ChangeNotifier {
  final BookService? _customBookService;
  BookService? _lazyBookService;

  StreamSubscription<List<Book>>? _booksSubscription;
  List<Book> _rawBooks = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filter & Search states
  String _selectedGenre = 'All';
  String _selectedStatus = 'All';
  bool _favoritesOnly = false;
  String _searchQuery = '';

  BooksProvider({BookService? bookService})
      : _customBookService = bookService;

  BookService get _bookService =>
      _customBookService ?? (_lazyBookService ??= BookService());

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get selectedGenre => _selectedGenre;
  String get selectedStatus => _selectedStatus;
  bool get favoritesOnly => _favoritesOnly;
  String get searchQuery => _searchQuery;

  List<Book> get allBooks => List.unmodifiable(_rawBooks);

  @visibleForTesting
  void setRawBooksForTesting(List<Book> books) {
    _rawBooks = books;
    notifyListeners();
  }

  /// Initializes the real-time stream for the current user's books.
  void initUser(String userId) {
    _booksSubscription?.cancel();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _booksSubscription = _bookService.getUserBooksStream(userId).listen(
      (books) {
        _rawBooks = books;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  /// Clears data and cancels subscription (e.g. on logout)
  void clear() {
    _booksSubscription?.cancel();
    _booksSubscription = null;
    _rawBooks = [];
    _selectedGenre = 'All';
    _selectedStatus = 'All';
    _favoritesOnly = false;
    _searchQuery = '';
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Filter setters
  void setGenre(String genre) {
    if (_selectedGenre != genre) {
      _selectedGenre = genre;
      notifyListeners();
    }
  }

  void setStatus(String status) {
    if (_selectedStatus != status) {
      _selectedStatus = status;
      notifyListeners();
    }
  }

  void setFavoritesOnly(bool value) {
    if (_favoritesOnly != value) {
      _favoritesOnly = value;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  void clearFilters() {
    _selectedGenre = 'All';
    _selectedStatus = 'All';
    _favoritesOnly = false;
    _searchQuery = '';
    notifyListeners();
  }

  /// Returns user's books sorted by title case-insensitive, ties by author case-insensitive,
  /// and filtered by genre, status, favoritesOnly, and search query.
  List<Book> get filteredBooks {
    final query = _searchQuery.trim().toLowerCase();

    final filtered = _rawBooks.where((book) {
      // Genre filter
      if (_selectedGenre != 'All' && book.genre != _selectedGenre) {
        return false;
      }
      // Status filter
      if (_selectedStatus != 'All' && book.status != _selectedStatus) {
        return false;
      }
      // Favorites filter
      if (_favoritesOnly && !book.favorite) {
        return false;
      }
      // Search query (title OR author contains text, case-insensitive, trimmed)
      if (query.isNotEmpty) {
        final titleMatches = book.title.toLowerCase().contains(query);
        final authorMatches = book.author.toLowerCase().contains(query);
        if (!titleMatches && !authorMatches) {
          return false;
        }
      }
      return true;
    }).toList();

    // Sort by title case-insensitive, ties by author case-insensitive
    filtered.sort((a, b) {
      final titleComp = a.title.toLowerCase().compareTo(b.title.toLowerCase());
      if (titleComp != 0) return titleComp;
      return a.author.toLowerCase().compareTo(b.author.toLowerCase());
    });

    return filtered;
  }

  /// Summary statistics for currently shown (filtered) books
  int get currentBooksCount => filteredBooks.length;

  int get currentFavoritesCount =>
      filteredBooks.where((b) => b.favorite).length;

  /// Breakdown with one row per status that appears (name + count),
  /// most books first; ties order: To Read, Reading, Finished.
  List<MapEntry<String, int>> get statusBreakdown {
    final counts = <String, int>{};
    for (final book in filteredBooks) {
      counts[book.status] = (counts[book.status] ?? 0) + 1;
    }

    const canonicalOrder = ['To Read', 'Reading', 'Finished'];

    final breakdown = counts.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) {
        final countCompare = b.value.compareTo(a.value);
        if (countCompare != 0) return countCompare;
        final indexA = canonicalOrder.indexOf(a.key);
        final indexB = canonicalOrder.indexOf(b.key);
        return indexA.compareTo(indexB);
      });

    return breakdown;
  }

  // Book operations
  Future<void> addBook({
    required String userId,
    required String title,
    required String author,
    required String genre,
    required String status,
    int? rating,
    String notes = '',
    bool favorite = false,
  }) async {
    await _bookService.addBook(
      userId: userId,
      title: title,
      author: author,
      genre: genre,
      status: status,
      rating: rating,
      notes: notes,
      favorite: favorite,
    );
  }

  Future<void> updateBook({
    required Book oldBook,
    required String newTitle,
    required String newAuthor,
    required String newGenre,
    required String newStatus,
    int? newRating,
    bool clearRating = false,
    required String newNotes,
    required bool newFavorite,
  }) async {
    await _bookService.updateBook(
      oldBook: oldBook,
      newTitle: newTitle,
      newAuthor: newAuthor,
      newGenre: newGenre,
      newStatus: newStatus,
      newRating: newRating,
      clearRating: clearRating,
      newNotes: newNotes,
      newFavorite: newFavorite,
    );
  }

  Future<void> toggleFavorite(Book book) async {
    await _bookService.toggleFavorite(
      bookId: book.id,
      currentFavorite: book.favorite,
    );
  }

  Future<void> deleteBook(String bookId) async {
    await _bookService.deleteBook(bookId);
  }

  @override
  void dispose() {
    _booksSubscription?.cancel();
    super.dispose();
  }
}
