import 'package:flutter_test/flutter_test.dart';
import 'package:bookshelf/utils/validators.dart';

void main() {
  group('Auth Validators Tests', () {
    test('Email validator', () {
      expect(AppValidators.validateEmail(''), equals('Email is required'));
      expect(AppValidators.validateEmail('   '), equals('Email is required'));
      expect(AppValidators.validateEmail('invalid-email'), equals('Please enter a valid email address'));
      expect(AppValidators.validateEmail('test@'), equals('Please enter a valid email address'));
      expect(AppValidators.validateEmail('test@domain'), equals('Please enter a valid email address'));
      expect(AppValidators.validateEmail('test@domain.com'), isNull);
    });

    test('Login Password validator', () {
      expect(AppValidators.validateLoginPassword(''), equals('Password is required'));
      expect(AppValidators.validateLoginPassword('123'), isNull);
    });

    test('Register Password validator', () {
      expect(AppValidators.validateRegisterPassword(''), equals('Password is required'));
      expect(AppValidators.validateRegisterPassword('12345'), equals('Password must be at least 6 characters'));
      expect(AppValidators.validateRegisterPassword('123456'), isNull);
    });

    test('Confirm Password validator', () {
      expect(AppValidators.validateConfirmPassword('', '123456'), equals('Confirm password is required'));
      expect(AppValidators.validateConfirmPassword('123457', '123456'), equals('Passwords do not match'));
      expect(AppValidators.validateConfirmPassword('123456', '123456'), isNull);
    });
  });

  group('Book Validators Tests', () {
    test('Title validator', () {
      expect(AppValidators.validateTitle(''), equals('Title is required'));
      expect(AppValidators.validateTitle('   '), equals('Title is required'));
      expect(AppValidators.validateTitle('A' * 101), equals('Title must be at most 100 characters'));
      expect(AppValidators.validateTitle('Valid Title'), isNull);
    });

    test('Author validator', () {
      expect(AppValidators.validateAuthor(''), equals('Author is required'));
      expect(AppValidators.validateAuthor('   '), equals('Author is required'));
      expect(AppValidators.validateAuthor('B' * 61), equals('Author must be at most 60 characters'));
      expect(AppValidators.validateAuthor('Valid Author'), isNull);
    });

    test('Genre validator', () {
      expect(AppValidators.validateGenre(null), equals('Please choose a genre'));
      expect(AppValidators.validateGenre(''), equals('Please choose a genre'));
      expect(AppValidators.validateGenre('Choose genre'), equals('Please choose a genre'));
      expect(AppValidators.validateGenre('Invalid Genre'), equals('Please choose a genre'));
      expect(AppValidators.validateGenre('Fiction'), isNull);
      expect(AppValidators.validateGenre('Non-Fiction'), isNull);
      expect(AppValidators.validateGenre('Academic'), isNull);
      expect(AppValidators.validateGenre('Other'), isNull);
    });

    test('Status validator', () {
      expect(AppValidators.validateStatus(null), equals('Please choose a status'));
      expect(AppValidators.validateStatus(''), equals('Please choose a status'));
      expect(AppValidators.validateStatus('Choose status'), equals('Please choose a status'));
      expect(AppValidators.validateStatus('Invalid Status'), equals('Please choose a status'));
      expect(AppValidators.validateStatus('To Read'), isNull);
      expect(AppValidators.validateStatus('Reading'), isNull);
      expect(AppValidators.validateStatus('Finished'), isNull);
    });

    test('Rating validator', () {
      expect(AppValidators.validateRating(null), isNull);
      expect(AppValidators.validateRating(''), isNull);
      expect(AppValidators.validateRating('   '), isNull);
      expect(AppValidators.validateRating('abc'), equals('Rating must be a whole number from 0 to 5'));
      expect(AppValidators.validateRating('-1'), equals('Rating must be a whole number from 0 to 5'));
      expect(AppValidators.validateRating('6'), equals('Rating must be a whole number from 0 to 5'));
      expect(AppValidators.validateRating('3.5'), equals('Rating must be a whole number from 0 to 5'));
      expect(AppValidators.validateRating('0'), isNull);
      expect(AppValidators.validateRating('5'), isNull);
      expect(AppValidators.validateRating('3'), isNull);
    });

    test('Notes validator', () {
      expect(AppValidators.validateNotes(null), isNull);
      expect(AppValidators.validateNotes(''), isNull);
      expect(AppValidators.validateNotes('C' * 301), equals('Notes must be at most 300 characters'));
      expect(AppValidators.validateNotes('C' * 300), isNull);
    });
  });
}
