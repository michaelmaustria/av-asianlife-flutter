
import 'package:av_asian_life/data_manager/login_response.dart';
import 'package:av_asian_life/data_manager/member.dart';
import 'package:av_asian_life/data_manager/principal_info.dart';
import 'package:av_asian_life/data_manager/user.dart';
import 'package:av_asian_life/login/model/login_model.dart';
import 'package:av_asian_life/utility/my_preference_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../mvp_base.dart';
import '../login_contract.dart';

class LoginPresenter implements ILoginPresenter {

  ILoginView _loginView;
  ILoginModel _loginModel = LoginModel();

  String cardno;

  @override
  void onAttach(IBaseView view) {
    print('onAttach: $view');
    _loginView = view;
  }

  setCardNo() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('cardno', this.cardno);
  }

  @override
  void initLoginProcess(User user) async {
    print('getLoginInfo');
    _loginModel.sendLoginRequest(user).then((LoginResponse response) async {
      print('Presenter: Card Number: ${response.cardno}');
      this.cardno = response.cardno;
      setCardNo();
      if(response.cardno != null) {
        if(response.msgCode != '017'){
          //await _loginModel.Login();
          _testLoginData(user);
          _initGetMemberInfo(response, user);
        } else {
          _loginView.onError(response.cardno, response.msgDescription);
        }
      }else{
        if(response.msgDescription == 'You have entered an invalid verification code.')
          _loginView.onError('', 'You have logged in with an invalid account. Please Sign Up again.');
        else
          _loginView.onError('', LoginModel.errorMessage);
      }
    });
  }

  _testLoginData(User user) async {
    print('testLoginData');
    MyPreferenceHandler myPreferenceHandler = MyPreferenceHandler();
    bool hasUserAuthData = await myPreferenceHandler.hasUserAuthData();

    if(hasUserAuthData) {
      User aUser = await myPreferenceHandler.getAuthData();
      print('Saved: ${aUser?.username} | New: ${user?.username}');
      if (aUser?.username != user?.username) {
        print('New login account: Destroying previous user data.');
        myPreferenceHandler.destroyUserData();
      }
    }
  }

  _initGetMemberInfo(LoginResponse response, User user) {
    print('initGetMemberInfo');
    _loginModel.getMemberInfo(response.cardno).then((Member memberData) {
      if(memberData.cardno != ''){
        print('Presenter: getMember Success, Init SaveUserData');
        _saveUserData(user.username, user.password, memberData.cardno);
        _loginView.onSuccess(memberData);
      }else{
        _loginView.onError('', response.msgDescription);
      }
    });
  }

  void _saveUserData(String username, String password, String cardNo) async {
    MyPreferenceHandler myPreferenceHandler = MyPreferenceHandler();
    myPreferenceHandler.setUserData(username, password, cardNo);
    print('LoginData Saved: $cardNo');
  }

  @override
  String validatePassword(String password) {
    if (password.length < 5)
      return 'Enter a valid password';
    else
      return null;
  }

  @override
  String validateUserName(String username) {
    Pattern pattern = r'\s\b|\b\s';
    RegExp regex = RegExp(pattern);

    if(regex.hasMatch(username))
      return 'Invalid format.';
    if (username.length < 4)
      return 'Username is to short.';
    else
      return null;
  }

  @override
  String validateEmail(String value) {
    //Regex pattern will validate for a correct email format...
    //e.g john_doe02@example.com
    Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter a valid email.';
    else
      return null;
  }

}
