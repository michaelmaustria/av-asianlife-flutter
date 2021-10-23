
import 'package:av_asian_life/data_manager/login_response.dart';
import 'package:av_asian_life/data_manager/member.dart';
import 'package:av_asian_life/data_manager/principal_info.dart';
import 'package:av_asian_life/data_manager/user.dart';

import '../mvp_base.dart';

abstract class ILoginModel extends IBaseModel{
  Future<LoginResponse> sendLoginRequest(User user);
  Future<Member> getMemberInfo(String cardNo);
  //Future Login();
}

abstract class ILoginView extends IBaseView {
  void onSuccess(Member member);
  void onError(String cardNo, String message);
}

abstract class ILoginPresenter extends IBasePresenter {

  void initLoginProcess(User user);

  String validateUserName(String username);
  String validatePassword(String password);
  String validateEmail(String email);
}

