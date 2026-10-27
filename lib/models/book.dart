import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String userId;
  final String title;
  final String author;
  final String genre;
  final String status;
  final int? rating;
  final bool favorite;
  final String notes;
  final Timestamp? createdAt;

  const Book({
    required this.id,
    required this.userId,
    required this.title,
    required this.author,
    required this.genre,
    required this.status,
    this.rating,
    this.favorite = false,
    this.notes = '',
    this.createdAt,
  });

  Book copyWith({
    String? id,
    String? userId,
    String? title,
    String? author,
    String? genre,
    String? status,
    int? rating,
    bool? clearRating,
    bool? favorite,
    String? notes,
    Timestamp? createdAt,
  }) {
    return Book(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      status: status ?? this.status,
      rating: clearRating == true ? null : (rating ?? this.rating),
      favorite: favorite ?? this.favorite,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap({bool forCreate = false}) {
    final map = <String, dynamic>{
      'id': id,
      'userId': userId,
      'title': title,
      'author': author,
      'genre': genre,
      'status': status,
      'rating': rating,
      'favorite': favorite,
      'notes': notes,
    };
    if (forCreate) {
      map['createdAt'] = FieldValue.serverTimestamp();
    } else if (createdAt != null) {
      map['createdAt'] = createdAt;
    }
    return map;
  }

  factory Book.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Book(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      author: data['author'] as String? ?? '',
      genre: data['genre'] as String? ?? 'Other',
      status: data['status'] as String? ?? 'To Read',
      rating: data['rating'] is int ? data['rating'] as int : null,
      favorite: data['favorite'] as bool? ?? false,
      notes: data['notes'] as String? ?? '',
      createdAt: data['createdAt'] is Timestamp ? data['createdAt'] as Timestamp : null,
    );
  }

  factory Book.fromMap(String docId, Map<String, dynamic> data) {
    return Book(
      id: docId,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      author: data['author'] as String? ?? '',
      genre: data['genre'] as String? ?? 'Other',
      status: data['status'] as String? ?? 'To Read',
      rating: data['rating'] is int ? data['rating'] as int : null,
      favorite: data['favorite'] as bool? ?? false,
      notes: data['notes'] as String? ?? '',
      createdAt: data['createdAt'] is Timestamp ? data['createdAt'] as Timestamp : null,
    );
  }
}
