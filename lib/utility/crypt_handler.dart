
import 'package:flutter_string_encryption/flutter_string_encryption.dart';

class CryptHandler {
  static final _crypt = new PlatformStringCryptor();
  static final _passPhrase = '5m@rtw@v3';
  static final _salt = '15y1EP1EmFqY50wus8acKw==';

  Future<String> _getKey() async
  => await _crypt.generateKeyFromPassword(_passPhrase, _salt);

  Future<String> encrypt(String text) async
  => await _crypt.encrypt(text, await _getKey());

  Future<String> decrypt(String encrypted) async
  => await _crypt.decrypt(encrypted, await _getKey());
}