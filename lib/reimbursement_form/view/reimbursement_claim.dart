import 'dart:io';
import 'dart:typed_data';

import 'package:av_asian_life/claims/presenter/claims_presenter.dart';
import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/user.dart';
import 'package:av_asian_life/home_page/session_callback.dart';
import 'package:av_asian_life/login/view/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_scan/barcode_scan.dart';

import '../../claims/claims_contract.dart';

class ReimbursementClaimPage extends StatefulWidget {
  static String tag = 'claimss-page';
  final IApplicationSession appSessionCallback;

  ReimbursementClaimPage({this.appSessionCallback});

  @override
  _ReimbursementClaimPageState createState() => _ReimbursementClaimPageState();
}

class _ReimbursementClaimPageState extends State<ReimbursementClaimPage> with AutomaticKeepAliveClientMixin<ReimbursementClaimPage> {

  @override
  bool get wantKeepAlive => true;

  IClaimsPresenter _mPresenter = ClaimsPresenter();

  User _mUser;
  IApplicationSession _appSessionCallback;

  @override
  void initState() {
    super.initState();
    _appSessionCallback = widget.appSessionCallback;
  }

  String result = "Hey there !";

  Future _scanQR() async {
    try {
      String qrResult = await BarcodeScanner.scan();
      setState(() {
        result = qrResult;
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          result = "Camera permission was denied";
        });
      } else {
        setState(() {
          result = "Unknown Error $ex";
        });
      }
    } on FormatException {
      setState(() {
        result = "You pressed the back button before scanning anything";
      });
    } catch (ex) {
      setState(() {
        result = "Unknown Error $ex";
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text('Claims'),
        flexibleSpace: Image(
          image:  AssetImage('assets/images/appBar_background.png'),
          fit: BoxFit.fill,),
      ),
      body: DefaultTabController(
          length: 2,
          child: Column(
            children: <Widget>[
              Container(
                constraints: BoxConstraints(maxHeight: 150.0),
                child: Material(
                  color: Colors.transparent,
                  child: TabBar(
                    labelStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
                    indicatorWeight: 5.0,
                    onTap: (_) { _appSessionCallback.pauseAppSession(); },
                    tabs: [
                      Tab(text: 'Out-Patient',),
                      Tab(text: 'In-Patient',),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    GestureDetector(
                      onTap: () { _appSessionCallback.pauseAppSession(); },
                        child: _getReimbursementBody()
                    ),
                    GestureDetector(
                        onTap: () { _appSessionCallback.pauseAppSession(); },
                        child: _getGPBody()
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Widget _getReimbursementBody(){
    return LayoutBuilder(
      builder: (context, constraint) {
        final height = constraint.maxHeight;
        final width = constraint.maxWidth;
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                SizedBox(
                  height: 20.0,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: <Widget>[
                      Text(result,style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400)),
                    ]
                  )
                ),
                SizedBox(
                  height: height *.7,
                  child: QrImage(
                    padding: EdgeInsets.all(90), 
                    data: 'adfads')
                    ,
                  ),
                Align(
                  alignment: AlignmentDirectional.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      RaisedButton(
                        padding: EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                        color: mPrimaryColor,
                        onPressed: (){
                          _scanQR();
                        },
                        child: Text('Scan Now'),
                      ),
                      RaisedButton(
                        padding: EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide(color: mPrimaryColor)),
                        onPressed: (){
                        },
                        child: Text('Upload'),
                      )
                    ]),
                ),
                SizedBox( height: height / 15 ,),
                copyRightText()
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getGPBody(){
    return LayoutBuilder(
      builder: (context, constraint) {
        final height = constraint.maxHeight;
        final width = constraint.maxWidth;
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                SizedBox(
                  height: 10.0,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: <Widget>[
                      Text('In - Patient Reimbursement Form', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500)),
                    ]
                  )
                ),
                SizedBox(height: 20,),
                Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: <Widget>[
                      RaisedButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                        color: mPrimaryColor,
                        onPressed: (){
                        },
                        child: Container(
                          margin: EdgeInsets.all(20),
                          child: Text('Download', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500)),
                        )
                      ),
                    ]
                  )
                ),
                SizedBox(height: 20,),
                Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: <Widget>[
                      Text('Fund Tranfer Subscription Form', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500)),
                    ]
                  )
                ),
                SizedBox(height: 20,),
                Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: <Widget>[
                      RaisedButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                        color: mPrimaryColor,
                        onPressed: (){
                        },
                        child: Container(
                          margin: EdgeInsets.all(20),
                          child: Text('Download', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500)),
                        )
                      ),
                    ]
                  )
                ),
                SizedBox(height: 30),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    child: Text('  Note: ', style: TextStyle(fontSize: 17.0)),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0)), side: BorderSide(color: Colors.black)),
                    child: Container(
                      margin: EdgeInsets.fromLTRB(30, 20, 10, 20),
                      child:  Expanded(
                       //margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                       child: Text("Please upload this form with the ORIGINAL Doctor's Prescription and Official Reciept (BIR Registered).",
                       style: TextStyle(fontSize: 15.0))
                    ),
                    )
                  )
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  
}
