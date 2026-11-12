import 'dart:convert';
import 'dart:io';

/// Reads `test/fixtures/<name>` and decodes it as a JSON object.
Map<String, dynamic> jsonFixture(String name) {
  final text = File('test/fixtures/$name').readAsStringSync();
  return jsonDecode(text) as Map<String, dynamic>;
}
