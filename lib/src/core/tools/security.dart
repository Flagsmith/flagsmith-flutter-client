import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';

class StorageSecurity {
  final _random = Random.secure();
  final String? password;
  late Uint8List _encryptedPassword;
  StorageSecurity(this.password) {
    _encryptedPassword = _generateEncryptPassword(password!);
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

  Uint8List _process(Uint8List input, Uint8List iv) {
    final engine = Salsa20Engine()
      ..init(true, ParametersWithIV(KeyParameter(_encryptedPassword), iv));
    return engine.process(input);
  }

  String encrypt(String value) {
    final iv = _randBytes(8);
    final ivEncoded = base64.encode(iv);
    assert(ivEncoded.length == 12);
    final input = Uint8List.fromList(utf8.encode(json.encode(value)));
    final encoded = base64.encode(_process(input, iv));
    return '$ivEncoded$encoded';
  }

  String? decrypt(String value) {
    assert(value.length >= 12);
    final iv = Uint8List.fromList(base64.decode(value.substring(0, 12)));

    value = value.substring(12);

    final cipher = base64.decode(value);
    final plain = _process(Uint8List.fromList(cipher), iv);
    return json.decode(utf8.decode(plain)) as String?;
  }
}
