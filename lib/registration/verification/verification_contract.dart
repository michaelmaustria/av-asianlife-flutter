
import 'package:av_asian_life/data_manager/resend_code_response.dart';
import 'package:av_asian_life/data_manager/signup_response.dart';
import 'package:av_asian_life/data_manager/verification_request.dart';

import '../../mvp_base.dart';

abstract class IVerificationModel extends IBaseModel{
  Future<SignUpResponse> postVerificationRequest(VerificationRequest request);
  Future<ResendCodeResponse> postResendCode(String cardNo);
  Future<SignUpResponse> postAccountVerification(VerificationRequest request);
}

abstract class IVerificationView extends IBaseView {
  void onSuccess(SignUpResponse response, String sender);
  void onError(String message, String sender);

}

abstract class IVerificationPresenter extends IBasePresenter {
  void sendVerificationRequest(VerificationRequest request);
  void resendVerificationRequest(VerificationRequest request);
  void sendAccountVerification(VerificationRequest request);

}


//registered did not choose where to send code (test001)
//[{msgCode: 014, msgDescription: You have entered an invalid verification code.}]

//registered chosen where to send code, did not proceed (test002)
//[{msgCode: 017, msgDescription: Account not yet verified, cardno: 10101343110165000}]