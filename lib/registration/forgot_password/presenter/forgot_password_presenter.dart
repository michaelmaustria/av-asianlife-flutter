
import 'package:av_asian_life/data_manager/choose_where_to_send_code_response.dart';
import 'package:av_asian_life/data_manager/forgot_password_response.dart';
import 'package:av_asian_life/data_manager/signup_response.dart';
import 'package:av_asian_life/data_manager/verification_request.dart';
import 'package:av_asian_life/mvp_base.dart';
import 'package:av_asian_life/registration/forgot_password/model/forgot_password_model.dart';
import 'package:av_asian_life/utility/common.dart';
import 'package:av_asian_life/utility/my_preference_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:av_asian_life/data_manager/api_token.dart';

import '../forgot_password_contract.dart';

class ForgotPasswordPresenter implements IForgotPasswordPresenter {

  IForgotPasswordView _forgotPasswordView;
  IForgotPasswordModel _forgotPasswordModel = ForgotPasswordModel();

  @override
  void onAttach(IBaseView view) {
    print('onAttach: $view');
    _forgotPasswordView = view;
  }

  @override
  void sendForgotPasswordRequest(String username) {
    print('sendForgotPasswordRequest');
    _forgotPasswordModel.postForgotPasswordRequest(username).then((ForgotPasswordResponse response) {
      String msg = '';
      if(response?.msgCode != '015') {
        msg = response?.msgDescription;
        if (response?.msgCode != '015') {
          _forgotPasswordView.onError(response?.msgDescription, 'r-forgot');
        } else {
          _forgotPasswordView.onError(response?.msgDescription, 'r-forgot');
        }
      }else{
        //String cardNo = response.cardno;
        _forgotPasswordModel.postChooseWhereToSendCode(username).then((ChooseWhereToSendCodeResponse response ) {
          if(response.email != null || response.mobileno != null) {
            print('ChooseWhereToSendCode: success');
            _forgotPasswordView.forgotPasswordRequestSuccess(response, username);
          } else {
            print('ChooseWhereToSendCode: error');
            _forgotPasswordView.onError('An Error Occurred', 'r-forgot');
          }
        });

      }

      print(msg);
    });
  }

  @override
  void sendVerificationRequest(VerificationRequest request) {
    print('sendVerificationRequest');
    print('send code M: ${request.sendcodethru}');
    String msg = '';
    _forgotPasswordModel.postVerificationRequest(request).then((SignUpResponse response) {
      if(response?.msgCode != null) {
        msg = response?.msgDescription;
        print(msg);
        if (response?.msgCode == '018') {
          _forgotPasswordView.onSuccess(response, 'r-verification');
        } else {
          _forgotPasswordView.onError(response?.msgDescription, 'r-verification');
        }
      }else{
        msg = 'An error has occurred.';
        _forgotPasswordView.onError(msg, 'r-verification');
      }
      print('sendVerificationRequest: $msg');
    });
  }


  @override
  void reSendVerificationRequest(VerificationRequest request) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('reSendVerificationRequest');
    String msg = '';
    _forgotPasswordModel.postResendCode(prefs.getString('_username')).then((ForgotPasswordResponse res) {
      print('resendCode: ${res.cardno}');
      if(res?.cardno != null) {
        print('send code M: ${request.sendcodethru}');
        _forgotPasswordModel.postVerificationRequest(request).then((SignUpResponse response) {
          if(response?.msgCode != null) {
            msg = response?.msgDescription;
            print(msg);
            if (response?.msgCode != '018') {
              _forgotPasswordView.onError(response?.msgDescription, 'r-verification');
            }else {
              _forgotPasswordView.onSuccess(response, 'r-verification');
            }
          }else{
            msg = 'An error has occurred.';
            _forgotPasswordView.onError(msg, 'r-verification' );
          }

          print('reSendVerificationRequest: $msg');
        });
      }else{
        msg = res?.message;
        _forgotPasswordView.onError(msg, 'r-verification' );
        print('Error postResendCode');
      }
    });
  }

  @override
  void sendAccountVerification(VerificationRequest request) {
    print('sendAccountVerification');
    _forgotPasswordModel.postAccountVerification(request).then((SignUpResponse response){
      String msg = '';
      if(response?.msgCode != null) {
        msg = response?.msgDescription;
        if (response?.msgCode != '014') {
          _forgotPasswordView.accountVerificationSuccess(response);
        } else {
          _forgotPasswordView.onError(response?.msgDescription, 'account-v');
        }
      }else{
        msg = response?.message;
        _forgotPasswordView.onError(msg, 'account-v');
      }

      print(msg);
    });
  }


  @override
  void sendResetPassword(String password, String cardNo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('sendResetPassword');
    _forgotPasswordModel.postResetPassword(password, prefs.getString('_email')).then((SignUpResponse response) {
      if(response?.msgCode != null) {
        if (response?.msgCode == '021') {
          MyPreferenceHandler helper = MyPreferenceHandler();
          ApiToken.registerApiToken();
          prefs.setString('_password', password);
          helper.destroyUserData();
          _forgotPasswordView.resetPasswordSuccess(response);
        } else {
          _forgotPasswordView.onError(response?.msgDescription, 'reset-p');
        }
      } else {
        String msg = response?.message;
        _forgotPasswordView.onError(msg, 'reset-p');
      }
    });
  }

  @override
  String validateUserName(String username) {
    return Common.validateUserName(username);
  }

  @override
  String validatePassword(String password) {
    return Common.validatePassword(password);
  }

}