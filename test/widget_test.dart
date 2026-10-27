import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookshelf/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen smoke test - displays title, buttons and features',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    // Verify Title text "BookShelf"
    expect(find.text('BookShelf'), findsAtLeastNWidgets(1));

    // Verify Login and Register action buttons
    expect(find.text('Login'), findsAtLeastNWidgets(1));
    expect(find.text('Register'), findsAtLeastNWidgets(1));

    // Verify 3 required feature cards
    expect(find.text('Track your books'), findsOneWidget);
    expect(find.text('Sort by status'), findsOneWidget);
    expect(find.text('Rate your favorites'), findsOneWidget);
  });
}
