import 'package:flutter/material.dart';
import '../models/book.dart';
import '../utils/constants.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusToRead:
        return const Color(0xFFE65100); // Deep Orange
      case AppConstants.statusReading:
        return const Color(0xFF1565C0); // Blue
      case AppConstants.statusFinished:
        return const Color(0xFF2E7D32); // Green
      default:
        return Colors.grey.shade700;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case AppConstants.statusToRead:
        return const Color(0xFFFFF3E0);
      case AppConstants.statusReading:
        return const Color(0xFFE3F2FD);
      case AppConstants.statusFinished:
        return const Color(0xFFE8F5E9);
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(book.status);
    final statusBgColor = _getStatusBgColor(book.status);

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Icon / Badge
              Container(
                width: 44,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Center(
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: Colors.blue.shade700,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title, Author, Genre, Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF212121),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by ${book.author}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Badges for Genre and Status
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        // Genre badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            book.genre,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),

                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            book.status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),

                        // Rating badge if present
                        if (book.rating != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 13,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${book.rating}/5',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Favorite star toggle
              IconButton(
                icon: Icon(
                  book.favorite ? Icons.star_rounded : Icons.star_border_rounded,
                  color: book.favorite ? Colors.amber.shade700 : Colors.grey.shade400,
                  size: 28,
                ),
                tooltip: book.favorite ? 'Remove from favorites' : 'Mark as favorite',
                onPressed: onFavoriteToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
