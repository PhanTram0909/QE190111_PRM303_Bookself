import 'package:flutter_test/flutter_test.dart';
import 'package:bookshelf/utils/doc_id_helper.dart';

void main() {
  group('Deterministic Doc ID Tests', () {
    test('Identical title and author case-insensitively produce same ID', () {
      final id1 = generateBookDocId('user123', 'Dune', 'Frank Herbert');
      final id2 = generateBookDocId('user123', '  dune  ', 'frank herbert ');
      expect(id1, equals(id2));
      expect(id1.startsWith('user123_'), isTrue);
      expect(id1.length, equals('user123_'.length + 64)); // 64 hex characters
    });

    test('Different users produce different IDs for same book', () {
      final id1 = generateBookDocId('userA', 'Dune', 'Frank Herbert');
      final id2 = generateBookDocId('userB', 'Dune', 'Frank Herbert');
      expect(id1, isNot(equals(id2)));
    });

    test('Different titles produce different IDs', () {
      final id1 = generateBookDocId('user123', 'Dune', 'Frank Herbert');
      final id2 = generateBookDocId('user123', 'Dune Messiah', 'Frank Herbert');
      expect(id1, isNot(equals(id2)));
    });
  });
}
