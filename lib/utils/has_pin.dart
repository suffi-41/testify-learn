import 'dart:convert';
import 'package:crypto/crypto.dart';

String hashPin(String pin) {
  final bytes = utf8.encode(pin); // convert to bytes
  final digest = sha256.convert(bytes); // hash it
  return digest.toString();
}
