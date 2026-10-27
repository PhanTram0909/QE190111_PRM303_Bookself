import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Khóa chống trùng: sha256 của "title|author" đã trim + lowercase
/// docId bắt buộc = userId + '_' + bookKey => mỗi user không thể lưu trùng title+author
String bookDocId(String uid, String title, String author) {
  final key = '${title.trim().toLowerCase()}|${author.trim().toLowerCase()}';
  return '${uid}_${sha256.convert(utf8.encode(key)).toString()}';
}

/// Alias for backwards compatibility across existing code & test suites
String generateBookDocId(String userId, String title, String author) {
  return bookDocId(userId, title, author);
}
