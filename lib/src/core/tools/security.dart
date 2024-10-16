import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class StorageSecurity {
  final _random = Random.secure();
  final String? password;
  late Uint8List _encryptedPassword;
  late Encrypter _enc;
  StorageSecurity(this.password) {
    _encryptedPassword = _generateEncryptPassword(password!);
    _enc = Encrypter(Salsa20(Key(_encryptedPassword)));
  }
  Uint8List _generateEncryptPassword(String password) {
    var blob = Uint8List.fromList(md5.convert(utf8.encode(password)).bytes);
    assert(blob.length == 16);
    return blob;
  }

  Uint8List _randBytes(int length) {
    return Uint8List.fromList(
        List<int>.generate(length, (i) => _random.nextInt(256)));
  }

  String encrypt(String value) {
    final iv = _randBytes(8);
    final ivEncoded = base64.encode(iv);
    assert(ivEncoded.length == 12);
    final encoded = _enc.encrypt(json.encode(value), iv: IV(iv)).base64;
    return '$ivEncoded$encoded';
  }

  String? decrypt(String value) {
    assert(value.length >= 12);
    final iv = base64.decode(value.substring(0, 12));

    // Extract the real input
    value = value.substring(12);

    // Decode the input
    return json.decode(_enc.decrypt64(value, iv: IV(iv))) as String?;
  }
}
