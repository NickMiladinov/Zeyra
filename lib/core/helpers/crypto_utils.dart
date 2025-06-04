import 'dart:typed_data';

// Helper to convert bytes to hex string
String bytesToHex(Uint8List bytes) {
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}

// Helper to convert hex string to bytes
Uint8List hexToBytes(String hex) {
  if (hex.isEmpty) return Uint8List(0);
  if (hex.length % 2 != 0) {
    throw FormatException('Hex string must have an even number of characters', hex);
  }

  final List<int> intList = [];
  for (int i = 0; i < hex.length; i += 2) {
    try {
      intList.add(int.parse(hex.substring(i, i + 2), radix: 16));
    } catch (e) {
      // Throw a FormatException to indicate bad input, which is more robust for crypto utils.
      throw FormatException(
        'Invalid hex character encountered at index $i. Input hex: "$hex"',
        hex,
        i,
      );
    }
  }
  return Uint8List.fromList(intList);
} 