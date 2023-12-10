import 'dart:convert';
import 'package:encrypt/encrypt.dart';

class EncriptionManager {
  String encrypt(String plainText) {
    final key = Key.fromUtf8('J7kT9pR3qYbWvXzA6F8eDcS2gU1iO0hL');
    final iv = IV.fromUtf8('yqBvWvXzA6F9j12k');

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

    Encrypted encrypted = encrypter.encrypt(plainText, iv: iv);

    return encrypted.base64;
  }

  String decrypt(String encryptedText) {
    final key = Key.fromUtf8('J7kT9pR3qYbWvXzA6F8eDcS2gU1iO0hL');
    final iv = IV.fromUtf8('yqBvWvXzA6F9j12k');

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

    try {
      Encrypted encryptedData = Encrypted.fromBase64(encryptedText);
      String decrypted = encrypter.decrypt(encryptedData, iv: iv);
      return decrypted;
    } catch (e) {
      print("Error decrypting: $e");
      return e.toString(); // Handle the error appropriately
    }
  }
}
