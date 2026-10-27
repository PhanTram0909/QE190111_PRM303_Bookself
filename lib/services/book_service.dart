import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../utils/doc_id_helper.dart';

class BookService {
  final FirebaseFirestore? _customFirestore;

  BookService({FirebaseFirestore? firestore}) : _customFirestore = firestore;

  FirebaseFirestore get _firestore =>
      _customFirestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _booksCollection =>
      _firestore.collection('books');

  /// Real-time stream of books owned by the current user.
  /// Queries only by userId to avoid requiring composite indexes.
  Stream<List<Book>> getUserBooksStream(String userId) {
    return _booksCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
    });
  }

  /// Adds a new book with a deterministic document ID to enforce uniqueness
  /// of (userId, title, author) case-insensitively.
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
    final docId = generateBookDocId(userId, title, author);
    final docRef = _booksCollection.doc(docId);

    // Check if the book already exists for this user
    final existingDoc = await docRef.get();
    if (existingDoc.exists) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'already-exists',
        message: 'A book with this title and author already exists in your library.',
      );
    }

    final newBook = Book(
      id: docId,
      userId: userId,
      title: title.trim(),
      author: author.trim(),
      genre: genre.trim(),
      status: status.trim(),
      rating: rating,
      favorite: favorite,
      notes: notes.trim(),
    );

    await docRef.set(newBook.toMap(forCreate: true));
  }

  /// Updates a book. If title or author has changed, enforces deterministic ID
  /// consistency by performing create-new + delete-old atomically in a batch/transaction.
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
    final trimmedTitle = newTitle.trim();
    final trimmedAuthor = newAuthor.trim();
    final newDocId = generateBookDocId(oldBook.userId, trimmedTitle, trimmedAuthor);

    if (newDocId == oldBook.id) {
      // Title and author did not change (or only formatting/case that results in same deterministic ID)
      final docRef = _booksCollection.doc(oldBook.id);
      final updateData = <String, dynamic>{
        'title': trimmedTitle,
        'author': trimmedAuthor,
        'genre': newGenre.trim(),
        'status': newStatus.trim(),
        'rating': clearRating ? null : newRating,
        'notes': newNotes.trim(),
        'favorite': newFavorite,
      };
      await docRef.update(updateData);
    } else {
      // Title or author changed -> Must create new doc with newDocId and delete old doc
      final newDocRef = _booksCollection.doc(newDocId);
      final oldDocRef = _booksCollection.doc(oldBook.id);

      await _firestore.runTransaction((transaction) async {
        final newDocSnapshot = await transaction.get(newDocRef);
        if (newDocSnapshot.exists) {
          throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'already-exists',
            message: 'A book with the updated title and author already exists.',
          );
        }

        final updatedBook = Book(
          id: newDocId,
          userId: oldBook.userId,
          title: trimmedTitle,
          author: trimmedAuthor,
          genre: newGenre.trim(),
          status: newStatus.trim(),
          rating: clearRating ? null : newRating,
          favorite: newFavorite,
          notes: newNotes.trim(),
          createdAt: oldBook.createdAt,
        );

        transaction.set(newDocRef, updatedBook.toMap());
        transaction.delete(oldDocRef);
      });
    }
  }

  /// Toggles favorite status of a book.
  Future<void> toggleFavorite({
    required String bookId,
    required bool currentFavorite,
  }) async {
    await _booksCollection.doc(bookId).update({
      'favorite': !currentFavorite,
    });
  }

  /// Deletes a book by its document ID.
  Future<void> deleteBook(String bookId) async {
    await _booksCollection.doc(bookId).delete();
  }
}
