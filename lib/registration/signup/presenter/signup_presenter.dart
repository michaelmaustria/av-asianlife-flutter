
import 'package:av_asian_life/data_manager/signup_request.dart';
import 'package:av_asian_life/data_manager/signup_response.dart';
import 'package:av_asian_life/registration/signup/model/signup_model.dart';
import 'package:av_asian_life/utility/common.dart';

import '../../../mvp_base.dart';
import '../signup_contract.dart';

class SignUpPresenter implements ISignUpPresenter {

  ISignUpView _signUpView;
  ISignUpModel _signUpModel = SignUpModel();

  @override
  void onAttach(IBaseView view) {
    print('onAttach: $view');
    _signUpView = view;
  }

  @override
  void sendSignUpRequest(SignUpRequest request) {
    print('sendSignUpRequest');
    _signUpModel.postSignUpRequest(request).then((SignUpResponse response) {
      //Handle signUp response here
      if(response?.cardno != null) {
        print('sendSignUpRequest Success: ${response.cardno}');
        _signUpView.onSuccess(response);
      }else {
        String msg = '';
        if(response?.msgCode != null) {
          msg = response.msgDescription;
          _signUpView.onError(response.msgDescription);
        } else {
          if(response?.message != null) {
            msg = response?.message;
            _signUpView.onError(msg);
          }else {
            msg = 'An error occurred.';
            _signUpView.onError(msg);
          }
        }
        print('sendSignUpRequest Failed: $msg');
      }
    });
  }

  @override
  String phoneNumberValidator(String value) {
    return Common.phoneNumberValidator(value);
  }

  @override
  String validateInputLength(String input) {
    return Common.validateInputLength(input);
  }

  @override
  String validatePassword(String password) {
    return Common.validatePassword(password);
  }

  @override
  String validateUserName(String username) {
    return Common.validateUserName(username);
  }

  @override
  String validateEmail(String value) {
    return Common.validateEmail(value);
  }
}