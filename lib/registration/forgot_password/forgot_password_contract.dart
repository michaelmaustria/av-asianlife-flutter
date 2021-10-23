
import 'package:av_asian_life/data_manager/choose_where_to_send_code_response.dart';
import 'package:av_asian_life/data_manager/forgot_password_response.dart';
import 'package:av_asian_life/data_manager/signup_response.dart';
import 'package:av_asian_life/data_manager/verification_request.dart';

import '../../mvp_base.dart';

abstract class IForgotPasswordModel extends IBaseModel{
  Future<ForgotPasswordResponse> postForgotPasswordRequest(String username);
  Future<SignUpResponse> postVerificationRequest(VerificationRequest request);
  Future<SignUpResponse> postAccountVerification(VerificationRequest request);
  Future<ChooseWhereToSendCodeResponse> postChooseWhereToSendCode(String cardNo);
  Future<ForgotPasswordResponse> postResendCode(String cardNo);
  Future<SignUpResponse> postResetPassword(String password, String cardNo);

}

abstract class IForgotPasswordView extends IBaseView {
  void onSuccess(SignUpResponse response, String sender);
  void onError(String message, String sender);

  void forgotPasswordRequestSuccess(ChooseWhereToSendCodeResponse response, String cardNo);
  void accountVerificationSuccess(SignUpResponse response);
  void resetPasswordSuccess(SignUpResponse response);

}

abstract class IForgotPasswordPresenter extends IBasePresenter {
  void sendForgotPasswordRequest(String username);
  void sendVerificationRequest(VerificationRequest request);
  void reSendVerificationRequest(VerificationRequest request);
  void sendAccountVerification(VerificationRequest request);
  void sendResetPassword(String password, String cardNo);


  String validateUserName(String username);
  String validatePassword(String password);

}