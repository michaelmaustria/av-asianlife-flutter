
import 'package:av_asian_life/data_manager/claim_response.dart';
import 'package:av_asian_life/data_manager/claims.dart';
import 'package:av_asian_life/data_manager/claims_request.dart';
import 'package:av_asian_life/data_manager/member.dart';
import 'package:av_asian_life/data_manager/user.dart';
import 'package:flutter/cupertino.dart';

import '../mvp_base.dart';

abstract class IClaimsModel extends IBaseModel{
  Future<List<Claims>> getClaimsHistory(User user, String claimType);
  Future<ClaimResponse> postClaimRequest(ClaimRequest request, BuildContext context, Member member);
  Future<ClaimResponse> postClaimIpRequest(ClaimRequest request, BuildContext context, Member member);
}

abstract class IClaimsView extends IBaseView {
  void onSuccess(String message);
  void onError(String message);
}

abstract class IClaimsPresenter extends IBasePresenter {
  Future<User> getUserData();
  Future<List<Claims>> initClaimsHistory(User user, String claimType);
  void sendClaimOpRequest(ClaimRequest request, BuildContext context, Member member);
  void sendClaimIpRequest(ClaimRequest request, BuildContext context, Member member);
}