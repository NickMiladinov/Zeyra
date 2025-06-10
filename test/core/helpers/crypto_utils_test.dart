import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeyra/core/helpers/crypto_utils.dart'; // Adjust the import path as necessary

void main() {
  group('Crypto Utils Tests', () {

    group('bytesToHex', () {
      test('should correctly convert a simple byte array to a hex string', () {
        final bytes = Uint8List.fromList([10, 20, 30, 40, 50]);
        const expectedHex = '0a141e2832';
        expect(bytesToHex(bytes), expectedHex);
      });

      test('should correctly convert a byte array with high values', () {
        final bytes = Uint8List.fromList([255, 170, 0, 15]); // 0xFF, 0xAA, 0x00, 0x0F
        const expectedHex = 'ffaa000f';
        expect(bytesToHex(bytes), expectedHex);
      });

      test('should return an empty string for an empty byte array', () {
        final bytes = Uint8List(0);
        expect(bytesToHex(bytes), '');
      });

      test('should handle a single byte array', () {
        final bytes = Uint8List.fromList([16]); // 0x10
        const expectedHex = '10';
        expect(bytesToHex(bytes), expectedHex);
      });
    });

    group('hexToBytes', () {
      test('should correctly convert a valid hex string to a byte array', () {
        const hex = '0a141e2832';
        final expectedBytes = Uint8List.fromList([10, 20, 30, 40, 50]);
        expect(hexToBytes(hex), expectedBytes);
      });

      test('should correctly convert a hex string with letters to a byte array', () {
        const hex = 'ffaa000f';
        final expectedBytes = Uint8List.fromList([255, 170, 0, 15]);
        expect(hexToBytes(hex), expectedBytes);
      });
      
      test('should handle uppercase hex characters', () {
        const hex = 'FFAA000F';
        final expectedBytes = Uint8List.fromList([255, 170, 0, 15]);
        expect(hexToBytes(hex), expectedBytes);
      });

      test('should return an empty byte array for an empty string', () {
        const hex = '';
        expect(hexToBytes(hex), Uint8List(0));
      });

      test('should throw a FormatException for an odd-length hex string', () {
        const hex = '123'; // Invalid length
        expect(() => hexToBytes(hex), throwsA(isA<FormatException>()));
      });

      test('should throw a FormatException for a string with non-hex characters', () {
        const hex = '0011gg22'; // 'g' is not a hex character
        expect(() => hexToBytes(hex), throwsA(isA<FormatException>()));
      });
    });

  });
} 