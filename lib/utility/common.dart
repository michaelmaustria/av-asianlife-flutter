import 'package:shared_preferences/shared_preferences.dart';

class Common {

  static String formatMobileNo(String data) {

    if(data != null && data != '') {
      String saved1 = data.substring(0, 2);
      String saved2 = data.substring(data.length - 2, data.length);

      return '$saved1*******$saved2';
    }
    getMobileNo();
  }

   static getMobileNo() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String mobileno = prefs.getString('mobileno'??'');
    return mobileno;
  }

  static String formatEmail(String data) {
    if(data != null && data != '') {
      String saved1 = data.substring(0, 2);
      String saved2 = data.substring(data.indexOf('@'), data.length);
      String replace = data.substring(3, data.indexOf('@'));

      String formatted1 = replace.replaceAll(
          RegExp(r'[a-zA-Z?=.*[!@#$%^&*£()+-_0-9]'), '*');

      return '$saved1$formatted1$saved2';
    }
    getEmail();
  }
  static getEmail() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email'??'');
    print(email);
    return email;
  }


  static String phoneNumberValidator(String value) {
    Pattern pattern = r'^(?:[+0]9)?[0-9]{11}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Mobile Number';
    else
      return null;
  }


  static String validateInputLength(String input) {
    if (input.length < 1)
      return 'Input is too short.';
    else
      return null;
  }


  static String validatePassword(String password) {
    Pattern pattern = r'^(?=.*[A-Z])(?=.*[0-9]).{8,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(password))
      return 'Invalid format.';
    else
      return null;
  }


  static String validateUserName(String username) {
    Pattern pattern = r'\s\b|\b\s';
    RegExp regex = RegExp(pattern);

    if(regex.hasMatch(username))
      return 'Invalid format.';
    if (username.length < 4)
      return 'Username is too short.';
    else
      return null;
  }


  static String validateEmail(String email) {
    //Regex pattern will validate for a correct email format...
    //e.g john_doe02@example.com
    Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(email))
      return 'Enter a valid email.';
    else
      return null;
  }
}