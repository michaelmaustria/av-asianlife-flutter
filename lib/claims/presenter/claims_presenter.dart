
import 'package:av_asian_life/claims/model/claims_model.dart';
import 'package:av_asian_life/data_manager/claim_response.dart';
import 'package:av_asian_life/data_manager/claims.dart';
import 'package:av_asian_life/data_manager/claims_request.dart';
import 'package:av_asian_life/data_manager/member.dart';
import 'package:av_asian_life/data_manager/user.dart';
import 'package:av_asian_life/mvp_base.dart';
import 'package:av_asian_life/utility/my_preference_helper.dart';
import 'package:flutter/cupertino.dart';

import '../claims_contract.dart';

class ClaimsPresenter implements IClaimsPresenter {

  IClaimsModel _claimsModel = ClaimsModel();
  IClaimsView _claimsView;
  ClaimsModel _cModel;

  @override
  void onAttach(IBaseView view) {
    _claimsView = view;
  }

  @override
  Future<User> getUserData() {
    MyPreferenceHandler _prefHandler = MyPreferenceHandler();
    return _prefHandler.getUserData();
  }

  @override
  Future<List<Claims>> initClaimsHistory(User user, String claimType) {
    print('initClaimsHistory');
    return _claimsModel.getClaimsHistory(user, claimType);
  }

  @override
  void sendClaimOpRequest(ClaimRequest request, BuildContext context, Member member) async {
    await _claimsModel.postClaimRequest(request, context, member);
  }

  @override
  void sendClaimIpRequest(ClaimRequest request, BuildContext context, Member member) async {
    await _claimsModel.postClaimIpRequest(request, context, member);
  }
}