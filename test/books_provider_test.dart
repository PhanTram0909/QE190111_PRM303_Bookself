import 'package:flutter_test/flutter_test.dart';
import 'package:bookshelf/models/book.dart';
import 'package:bookshelf/providers/books_provider.dart';

void main() {
  group('BooksProvider Sorting Tests', () {
    test('User books sorted by title case-insensitive, ties by author', () {
      final provider = BooksProvider();
      final books = [
        const Book(
          id: '1',
          userId: 'user1',
          title: 'The Hobbit',
          author: 'Tolkien',
          genre: 'Fiction',
          status: 'Reading',
        ),
        const Book(
          id: '2',
          userId: 'user1',
          title: 'dune',
          author: 'Frank Herbert',
          genre: 'Fiction',
          status: 'Finished',
        ),
        const Book(
          id: '3',
          userId: 'user1',
          title: 'Dune',
          author: 'Brian Herbert',
          genre: 'Fiction',
          status: 'To Read',
        ),
        const Book(
          id: '4',
          userId: 'user1',
          title: 'Animal Farm',
          author: 'George Orwell',
          genre: 'Fiction',
          status: 'Finished',
        ),
      ];

      provider.setRawBooksForTesting(books);
      final sorted = provider.filteredBooks;

      expect(sorted[0].title, equals('Animal Farm'));
      // For "Dune" / "dune", title tie -> author alphabetical: Brian Herbert before Frank Herbert
      expect(sorted[1].title.toLowerCase(), equals('dune'));
      expect(sorted[1].author, equals('Brian Herbert'));
      expect(sorted[2].title.toLowerCase(), equals('dune'));
      expect(sorted[2].author, equals('Frank Herbert'));
      expect(sorted[3].title, equals('The Hobbit'));
    });
  });

  group('BooksProvider Filter & Search Tests', () {
    late BooksProvider provider;

    setUp(() {
      provider = BooksProvider();
      provider.setRawBooksForTesting([
        const Book(
          id: '1',
          userId: 'u1',
          title: 'Clean Code',
          author: 'Robert C. Martin',
          genre: 'Academic',
          status: 'Finished',
          favorite: true,
        ),
        const Book(
          id: '2',
          userId: 'u1',
          title: '1984',
          author: 'George Orwell',
          genre: 'Fiction',
          status: 'Finished',
          favorite: true,
        ),
        const Book(
          id: '3',
          userId: 'u1',
          title: 'Sapiens',
          author: 'Yuval Noah Harari',
          genre: 'Non-Fiction',
          status: 'Reading',
          favorite: false,
        ),
        const Book(
          id: '4',
          userId: 'u1',
          title: 'Refactoring',
          author: 'Martin Fowler',
          genre: 'Academic',
          status: 'To Read',
          favorite: false,
        ),
      ]);
    });

    test('Filter by Genre', () {
      provider.setGenre('Academic');
      final list = provider.filteredBooks;
      expect(list.length, equals(2));
      expect(list.every((b) => b.genre == 'Academic'), isTrue);
    });

    test('Filter by Status', () {
      provider.setStatus('Finished');
      final list = provider.filteredBooks;
      expect(list.length, equals(2));
      expect(list.every((b) => b.status == 'Finished'), isTrue);
    });

    test('Filter by Favorites only', () {
      provider.setFavoritesOnly(true);
      final list = provider.filteredBooks;
      expect(list.length, equals(2));
      expect(list.every((b) => b.favorite), isTrue);
    });

    test('Search box filters by title or author contains text case-insensitively', () {
      // Search by author "martin" (matches Robert C. Martin and Martin Fowler)
      provider.setSearchQuery('  martin  ');
      final list = provider.filteredBooks;
      expect(list.length, equals(2));

      // Search by title "84"
      provider.setSearchQuery('84');
      final list2 = provider.filteredBooks;
      expect(list2.length, equals(1));
      expect(list2.first.title, equals('1984'));
    });

    test('Clear button resets all four filters', () {
      provider.setGenre('Fiction');
      provider.setStatus('Finished');
      provider.setFavoritesOnly(true);
      provider.setSearchQuery('1984');
      expect(provider.filteredBooks.length, equals(1));

      provider.clearFilters();
      expect(provider.selectedGenre, equals('All'));
      expect(provider.selectedStatus, equals('All'));
      expect(provider.favoritesOnly, isFalse);
      expect(provider.searchQuery, isEmpty);
      expect(provider.filteredBooks.length, equals(4));
    });
  });

  group('BooksProvider Summary & Breakdown Tests', () {
    test('Summary counts and breakdown ordering with tie-breaking', () {
      final provider = BooksProvider();
      provider.setRawBooksForTesting([
        // 2 Finished
        const Book(id: '1', userId: 'u1', title: 'A', author: 'X', genre: 'Fiction', status: 'Finished', favorite: true),
        const Book(id: '2', userId: 'u1', title: 'B', author: 'X', genre: 'Fiction', status: 'Finished', favorite: true),
        // 2 To Read
        const Book(id: '3', userId: 'u1', title: 'C', author: 'X', genre: 'Fiction', status: 'To Read', favorite: false),
        const Book(id: '4', userId: 'u1', title: 'D', author: 'X', genre: 'Fiction', status: 'To Read', favorite: false),
        // 3 Reading
        const Book(id: '5', userId: 'u1', title: 'E', author: 'X', genre: 'Fiction', status: 'Reading', favorite: false),
        const Book(id: '6', userId: 'u1', title: 'F', author: 'X', genre: 'Fiction', status: 'Reading', favorite: true),
        const Book(id: '7', userId: 'u1', title: 'G', author: 'X', genre: 'Fiction', status: 'Reading', favorite: false),
      ]);

      expect(provider.currentBooksCount, equals(7));
      expect(provider.currentFavoritesCount, equals(3));

      final breakdown = provider.statusBreakdown;
      // Reading has 3 books -> comes first
      expect(breakdown[0].key, equals('Reading'));
      expect(breakdown[0].value, equals(3));

      // To Read and Finished both have 2 books -> tie-breaking order: To Read, Reading, Finished
      // So To Read comes before Finished
      expect(breakdown[1].key, equals('To Read'));
      expect(breakdown[1].value, equals(2));

      expect(breakdown[2].key, equals('Finished'));
      expect(breakdown[2].value, equals(2));
    });

    test('Breakdown only includes statuses with count > 0', () {
      final provider = BooksProvider();
      provider.setRawBooksForTesting([
        const Book(id: '1', userId: 'u1', title: 'A', author: 'X', genre: 'Fiction', status: 'Finished'),
      ]);

      final breakdown = provider.statusBreakdown;
      expect(breakdown.length, equals(1));
      expect(breakdown.first.key, equals('Finished'));
      expect(breakdown.first.value, equals(1));
    });
  });
}
