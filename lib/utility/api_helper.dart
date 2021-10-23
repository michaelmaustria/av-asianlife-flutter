
import 'package:flutter_string_encryption/flutter_string_encryption.dart';

class ApiHelper {

  static PlatformStringCryptor _crypt = new PlatformStringCryptor();
  static String _passPhrase = '5m@rtw@v3';
  static String _salt = '15y1EP1EmFqY50wus8acKw==';

  static Future<String> getBaseUrl() async {
    String key = await _crypt.generateKeyFromPassword(_passPhrase, _salt);

    var sE0 = '0BcxWYJvnncOaGpOdssSmg==:2Ot9DQDpxCdULk88354Cq+TYFr5TpglMjjn8+LZG7qk=:h9JcJrOfzjEq4Zd2yzM0D6Z1IE+/GDAnuPIcrVrnaQxo5dOZxv9P209g5oAogR4/';

    return await _crypt.decrypt(sE0, key);
  }

  static Future<String> getApiUser() async {
    String key = await _crypt.generateKeyFromPassword(_passPhrase, _salt);

    var sE1 = 'Fyu/o0Ak14+Kq4W4+jeVQQ==:Us8JVMd4WeekQTsErArwGzFvMDy2stLn7wGpmH/1qw8=:9Z4yX3j5sz9Pr9fV6+m+iA==';

    return await _crypt.decrypt(sE1, key);
  }

  static Future<String> getApiPass() async {
    String key = await _crypt.generateKeyFromPassword(_passPhrase, _salt);

    var sE2 = '3KIqNU+fZTwk+8GTeoRVFQ==:oS96VUpgkROOYfhh7YbjVpchcahnEscUO/zHvAukVYE=:fd8cujQdV3xMYQ97sb5zuA==';

    return await _crypt.decrypt(sE2, key);
  }

  static Future<String> getSFTPHost() async {
    String key = await _crypt.generateKeyFromPassword(_passPhrase, _salt);

    var host = 'Vx55w/mqp15ltxTgiPiJfw==:TyBOtQRvxfsFkaM44xhvNJ9vwQUpsIchORBSs0QtQiI=:4Tc8qoVbpUo9NgY5hsTTVg==';

    return await _crypt.decrypt(host, key);
  }

  static Future<int> getSFTPPort() async {
    String key = await _crypt.generateKeyFromPassword(_passPhrase, _salt);

    var port = 'FEG5C63+wBd9aRohi6DaQw==:YyM4bvN93oBI3sJ8OMlyYjWeXDDyzjkrVZ34KwZ8Gj4=:Ur9sXg8a7Z4msdClURHZHQ==';

    return int.parse(await _crypt.decrypt(port, key));
  }

  static Future<String> getSFTPUser() async {

    String key = await _crypt.generateKeyFromPassword(_passPhrase, _salt);

    var user = 'iBb39eQaqLgP0spuIuQtwg==:JUaAmcEwpjtOE7RGNBLGavy/oXbEqbVDSC9jCWQVN6w=:02tmYhCDxLbe1w3rOYOfNQ==';

    return await _crypt.decrypt(user, key);
  }

  static Future<String> getSFTPPass() async {
    String key = await _crypt.generateKeyFromPassword(_passPhrase, _salt);

    var pass = 'VzQICPFbrW01neHghEo0dA==:BvPQu4PIn+o5R/fkyYRxMns2ndBONAyhRfRazNctC88=:b1epAPkuPH/RRznKN4d3RQ==';

    return await _crypt.decrypt(pass, key);
  }

  static Future<String> getAPITokenUser() async {

    String key = await _crypt.generateKeyFromPassword(_passPhrase, _salt);

    var user = '6qAd5qgf17twyTb+Rwkgfw==:iYEaUNQkAMK6rXqT4B1bzTQpsnJlRRygRdE50mcVwns=:ebloCwDRjBuEzAiHQhXTQWawbmcwHsHqLeJi/AWjnQM=';

    return await _crypt.decrypt(user, key);
  }

  static Future<String> getAPITokenPass() async {

    String key = await _crypt.generateKeyFromPassword(_passPhrase, _salt);

    var user = 'izdVAESL73NbYdp2Zz1myg==:d3HomjTC33vuqq8Go/6c6OfAOCOXdAiajhO3a4qlDOc=:i8M36eENa2KJNZpnB5aPNw==';

    return await _crypt.decrypt(user, key);
  }
}