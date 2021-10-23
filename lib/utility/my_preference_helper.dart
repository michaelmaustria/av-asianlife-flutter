
import 'package:av_asian_life/data_manager/user.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'crypt_handler.dart';

class MyPreferenceHandler {

  SharedPreferences _prefs;

  static const String SP_USER_NAME = 'user-name';
  static const String SP_PASSWORD = 'password';
  static const String SP_CARD_NO = 'card-no';
  static const String INSTALL_DATA = 'install-data';

  static const String AUTH_USER = 'auth_user';
  static const String AUTH_PASS = 'auth_pass';

  static const String APP_VERSION = 'app-version';
  static const String BUILD_NUMBER = 'build-number';

  static const String APP_DESTROY = 'app-destroy';

  static const String QUICK_VIEW = 'no';

  static const String REG_USER = 'reg_user';
  static const String REG_PASS = 'reg_pass';
  static const String REG_CARDNO = 'reg_card-no';

  var _crypt = CryptHandler();

  Future<bool> hasUserData() async {
    _prefs = await SharedPreferences.getInstance();
    var username = _prefs.getString(SP_USER_NAME);
    var password = _prefs.getString(SP_PASSWORD);

    if(username != null && password != null)
      return true;
    else
      return false;
  }

  Future<User> getUserData() async {
    _prefs = await SharedPreferences.getInstance();

    var username = await _crypt.decrypt(_prefs.getString(SP_USER_NAME));
    var password = await _crypt.decrypt( _prefs.getString(SP_PASSWORD));
    var cardNo = await _crypt.decrypt(_prefs.getString(SP_CARD_NO));

    User user = User(username: username, password: password, cardNo: cardNo);

    print('MyPreferenceHandler: ${user?.username}, ${user?.password}, ${user?.cardNo}');

    return user;
  }

  Future setUserData(String username, String password, String cardNo) async {
    _prefs = await SharedPreferences.getInstance();

    String encUser = await _crypt.encrypt(username);
    String encPass = await _crypt.encrypt(password);
    String encCard = await _crypt.encrypt(cardNo);

    _prefs.setString(SP_USER_NAME, encUser);
    _prefs.setString(SP_PASSWORD, encPass);
    _prefs.setString(SP_CARD_NO, encCard);
  }

  Future<bool> releaseUserData() async {
    _prefs = await SharedPreferences.getInstance();

    _prefs.setString(AUTH_USER, _prefs.getString(SP_USER_NAME));
    _prefs.setString(AUTH_PASS, _prefs.getString(SP_PASSWORD));

    await _prefs.remove(SP_USER_NAME);
    await _prefs.remove(SP_PASSWORD);
    await _prefs.remove(SP_CARD_NO);
    return true;
  }

  Future<bool> destroyUserData() async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.remove(AUTH_USER);
    await _prefs.remove(AUTH_PASS);
    await _prefs.remove(SP_USER_NAME);
    await _prefs.remove(SP_PASSWORD);
    await _prefs.remove(SP_CARD_NO);
    return true;
  }

  Future<bool> destroyAllData() async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.remove(AUTH_USER);
    await _prefs.remove(AUTH_PASS);
    await _prefs.remove(SP_USER_NAME);
    await _prefs.remove(SP_PASSWORD);
    await _prefs.remove(SP_CARD_NO);
    await _prefs.remove(INSTALL_DATA);
    return true;
  }

  void setInstallData(bool isFresh) async {
    _prefs = await SharedPreferences.getInstance();
    _prefs.setBool(INSTALL_DATA, isFresh);
  }

  Future<bool> getInstallData() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs.getBool(INSTALL_DATA);
  }

  Future<bool> hasUserAuthData() async {
    _prefs = await SharedPreferences.getInstance();
    print('getUserAuthData');
    try{
      if(_prefs.getString(AUTH_USER) != null && _prefs.getString(AUTH_PASS) != null)
        return true;
      else
        return false;
    } catch (e) {
      print('getUserAuthData: $e');
      return false;
    }
  }

  Future<User> getAuthData() async {
    _prefs = await SharedPreferences.getInstance();

    var username = await _crypt.decrypt(_prefs.getString(AUTH_USER));
    var password = await _crypt.decrypt(_prefs.getString(AUTH_PASS));

    print('getAuthData: $username, $password');

    return User(username: username, password: password);
  }

  void setDestroyFlag(bool isDestroyed) async {
    _prefs = await SharedPreferences.getInstance();
    _prefs.setBool(APP_DESTROY, isDestroyed);
  }

  Future<bool> getDestroyFlag() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs.getBool(APP_DESTROY);
  }

  void setAppVersionData(String version, String build) async {
    _prefs = await SharedPreferences.getInstance();
    _prefs.setString(APP_VERSION, version);
    _prefs.setString(BUILD_NUMBER, build);
  }

  Future<String> getAppVersion() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs.getString(APP_VERSION);
  }

  Future<String> getBuildNumber() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs.getString(BUILD_NUMBER);
  }

  Future setQuickView(String useQuickView,) async {
    _prefs = await SharedPreferences.getInstance();

    _prefs.setString(QUICK_VIEW, useQuickView);
  }

  Future<String> getQuickView() async {
    _prefs = await SharedPreferences.getInstance();

    var useQuickView = _prefs.getString(QUICK_VIEW);

    print('QuickView: $useQuickView');

    return useQuickView;
  }

  Future setRegDetails(String username, String password, String cardNo) async {
    _prefs = await SharedPreferences.getInstance();

    String encUser = await _crypt.encrypt(username);
    String encPass = await _crypt.encrypt(password);
    String encCardno = await _crypt.encrypt(cardNo);

    _prefs.setString(REG_USER, encUser);
    _prefs.setString(REG_PASS, encPass);
    _prefs.setString(REG_CARDNO, encCardno);

  }

  Future<User> getRegDetails() async {
    _prefs = await SharedPreferences.getInstance();

    var username = await _crypt.decrypt(_prefs.getString(REG_USER));
    var password = await _crypt.decrypt( _prefs.getString(REG_PASS));
    var cardno = await _crypt.decrypt( _prefs.getString(REG_CARDNO));

    User user = User(username: username, password: password, cardNo: cardno);

    print('QuickView: ${user?.username}, ${user?.password}, ${user?.cardNo}');

    return user;
  }
}

