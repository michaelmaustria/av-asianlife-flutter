
import 'package:av_asian_life/data_manager/resend_code_response.dart';
import 'package:av_asian_life/data_manager/signup_response.dart';
import 'package:av_asian_life/data_manager/verification_request.dart';
import 'package:av_asian_life/mvp_base.dart';
import 'package:av_asian_life/registration/verification/model/verification_model.dart';
import 'package:av_asian_life/registration/verification/verification_contract.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerificationPresenter implements IVerificationPresenter{

  IVerificationView _verificationView;
  IVerificationModel _verificationModel = VerificationModel();

  @override
  void onAttach(IBaseView view) {
    print('onAttach: $view');
    _verificationView = view;
  }

  @override
  void sendVerificationRequest(VerificationRequest request) {
    print('sendVerificationRequest');
    print('send code M: ${request.sendcodethru}');
    String msg = '';
    _verificationModel.postVerificationRequest(request).then((SignUpResponse response) {
      if(response?.msgCode != null) {
        msg = response?.msgDescription;
        print(msg);
        if (response?.msgCode == '018') {
          _verificationView.onSuccess(response, 'request-v');
        } else {
          _verificationView.onError(response?.msgDescription, 'request-v');
        }
      }else{
        msg = 'An error has occurred.';
        _verificationView.onError(msg, 'request-v');
      }
      print('sendVerificationRequest: $msg');
    });

  }


  @override
  void resendVerificationRequest(VerificationRequest request) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('reSendVerificationRequest');
    String msg = '';
    _verificationModel.postResendCode(prefs.getString('_username')).then((ResendCodeResponse res) {
      print('resendCode: ${res.cardno}');
      if(res?.cardno != null) {
        print('send code M: ${request.sendcodethru}');
        _verificationModel.postVerificationRequest(request).then((SignUpResponse response) {

          if(response?.msgCode != null) {
            msg = response?.msgDescription;
            print(msg);
            if (response?.msgCode == '018') {
              _verificationView.onError(response?.msgDescription, 'r-verification');
            }else {
              _verificationView.onSuccess(response, 'r-verification');
            }
          }else{
            msg = 'An error has occurred.';
            _verificationView.onError(msg, 'r-verification' );
          }

          print('reSendVerificationRequest: $msg');
        });
      }else{
        msg = res?.message;
        _verificationView.onError(msg, 'r-verification' );
        print('Error postResendCode');
      }
    });
  }

  @override
  void sendAccountVerification(VerificationRequest request) {
    print('sendAccountVerification');
    _verificationModel.postAccountVerification(request).then((SignUpResponse response){
      String msg = '';
      if(response?.msgCode != null) {
        msg = response?.msgDescription;
        if (response?.msgCode != '014') {
          _verificationView.onSuccess(response, 'account-v');
        } else {
          _verificationView.onError(response?.msgDescription, 'account-v');
        }
      }else{
        msg = response?.message;
        _verificationView.onError(msg, 'account-v');
      }
      print(msg);
    });
  }


}