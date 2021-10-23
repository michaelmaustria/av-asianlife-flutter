
import 'package:av_asian_life/data_manager/signup_request.dart';
import 'package:av_asian_life/data_manager/signup_response.dart';

import '../../mvp_base.dart';

abstract class ISignUpModel extends IBaseModel{
  Future<SignUpResponse> postSignUpRequest(SignUpRequest request);
}

abstract class ISignUpView extends IBaseView {
  void onSuccess(SignUpResponse response);
  void onError(String message);

}

abstract class ISignUpPresenter extends IBasePresenter {
  void sendSignUpRequest(SignUpRequest request);

  String phoneNumberValidator(String value);
  String validateInputLength(String input);
  String validateUserName(String username);
  String validatePassword(String password);
  String validateEmail(String email);

}