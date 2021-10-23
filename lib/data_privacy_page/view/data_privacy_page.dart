import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/member.dart';
import 'package:av_asian_life/data_manager/requests.dart';
import 'package:av_asian_life/data_manager/user.dart';
import 'package:av_asian_life/home_page/session_callback.dart';
import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:intl/intl.dart';

class PrivacyPage extends StatefulWidget {
  static String tag = 'log-page';
  final Member member;

  final IApplicationSession appSessionCallback;

  PrivacyPage({this.member, this.appSessionCallback});   
  @override
  _PrivacyPageState createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> with AutomaticKeepAliveClientMixin<PrivacyPage> {

  @override
  bool get wantKeepAlive => true;

  IApplicationSession _appSessionCallback;

  var cardHeight;
  var barColor;
  var textColor;
  var txtStatus;

  User _mUser;
  bool _checkBoxValue1 = false;
  bool _checkBoxValue2 = false;
  bool _checkBoxValue3 = false;
  bool _validator = false;
  int _checkerInt = 0;

  Matrix4 matrix = Matrix4.identity();
  Matrix4 zerada =  Matrix4.identity();

  @override
  void initState() {
    super.initState();

    _appSessionCallback = widget.appSessionCallback;

  }

  @override
  void onError(String message) {

  }

  @override
  void onSuccess(String message) {

  }

  void _checker(newValue){
    if(newValue == false){
      _checkerInt = _checkerInt - 1;
    }else{
      _checkerInt = _checkerInt + 1;
    }
    _checkValidator();
  
  }
  void _checkValidator(){
    if(_checkerInt == 3){
      _validator = true;
    }else{
      _validator = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
    return Container(
      decoration: myAppBackground(),
    child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text('Data Privacy Consent'),
        centerTitle: true,
      ),
      body: Container(
        child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.only(top: 30.0, left: 40.0, right: 40.0),
              child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          child: Container(
                            child: Text('Collection and Processing of Personal Data. I authorize and give my consent to ETIQA Philippines to collect, store, transmit, use, distribute, disclose, share, retain, dispose, destroy, and process my Personal Data which includes Personal Information and/or Sensitive Personal Information and Privileged Information contained in my customer record that I have answered electronically for any of the following purposes prescribed by the Data Privacy Act of 2012 and its Implementing Rules and Regulations: ',
                              textAlign: TextAlign.justify,),
                          ),
                        )
                    ),
                    // ),
                    // Align(
                    //   alignment: Alignment.topLeft,
                    //   child: Row(
                    //     children: <Widget>[
                    //       Checkbox(
                    //         value: _checkBoxValue1,
                    //         activeColor: mPrimaryColor,
                    //         onChanged: (bool newValue){
                    //           setState(() {
                    //             _checker(newValue);
                    //             _checkBoxValue1 = newValue;
                    //           });
                    //         }
                    //       ),
                    //       Text('I Agree', style: TextStyle(fontSize: 17.0),)
                    //     ]
                    //   )
                    // ),
                    SizedBox(
                        height: 30.0
                    ),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          child: Container(
                            child: Text('Security Measures. I understand that any information provided to ETIQA Philippines is protected. ETIQA Philippines will only collect my Personal Data through secure means and shall ensure confidentiality and privacy in all aspects of processing of my personal data.',
                              textAlign: TextAlign.justify,),
                          ),
                        )
                    ),
                    // Align(
                    //   alignment: Alignment.topLeft,
                    //   child: Row(
                    //     children: <Widget>[
                    //       Checkbox(
                    //         value: _checkBoxValue2,
                    //         activeColor: mPrimaryColor,
                    //         onChanged: (bool newValue){
                    //           setState(() {
                    //             _checker(newValue);
                    //             _checkBoxValue2 = newValue;
                    //           });
                    //         }
                    //       ),
                    //         Text('I Agree', style: TextStyle(fontSize: 17.0))
                    //     ]
                    //   )
                    // ),
                    SizedBox(
                        height: 30.0
                    ),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          child: Container(
                            child: Text('Retention and Destruction. I understand that this authorization/consent shall continue to be in effect throughout the duration of my  insurance policy and/or until expiration of the records retention limit set by ETIQA Philippines and/or relevant laws and regulations and the period set until destruction and/or disposal of my records, unless earlier withdrawn in writing. ',
                              textAlign: TextAlign.justify,),
                          ),
                        )
                    ),
                    SizedBox(
                        height: 30.0
                    ),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          child: Container(
                            child: Text('I have read this form, understood its contents and consent to the processing of my personal data and be bound by all the terms and conditions stated above. I understand that my consent does not preclude the existence of other criteria for lawful processing of personal data, and does not waive any of my rights under the Data Privacy Act of 2012 and other applicable laws.',
                              textAlign: TextAlign.justify,),
                          ),
                        )
                    ),
                    // Align(
                    //   alignment: Alignment.topLeft,
                    //   child: Row(
                    //     children: <Widget>[
                    //       Checkbox(
                    //         value: _checkBoxValue3,
                    //         activeColor: mPrimaryColor,
                    //         onChanged: (bool newValue){
                    //           setState(() {
                    //             _checker(newValue);
                    //             _checkBoxValue3 = newValue;
                    //           });
                    //         }
                    //       ),
                    //       Text('I Agree', style: TextStyle(fontSize: 17.0))
                    //     ]
                    //   )
                    // ),
                    // Container(
                    //       width: width * .5,
                    //       child: RaisedButton(
                    //         padding: EdgeInsets.all(10),
                    //         color: mPrimaryColor,
                    //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    //         child: Text('Continue', style: TextStyle(color: Colors.black87)),
                    //         //onPressed: _isInteractionDisabled ? null : _validateInputs,
                    //         onPressed: _validator ?
                    //             () => Navigator.pop(context, 'granted') : null,
                    //       ),
                    //     ),
                    // SizedBox(height: 25,),
                    // Align(
                    //   alignment: Alignment.bottomCenter,
                    //   child: copyRightText()
                    // ),
                  ]
              ),
            )
        ),
      )
    )
    );
  }

}


// LayoutBuilder(builder: (context, constraint){
//         final height = constraint.maxHeight;
//         final width = constraint.maxWidth;
//         return SingleChildScrollView(
//           child: Container(
//             child: Container(
//               padding: const EdgeInsets.only(top: 30.0, left: 40.0, right: 40.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.max,
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: <Widget>[
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: Container(
//                       child: Expanded(
//                         child: Text('Etiqa Life and General Assurance Philippines Inc. (Etiqa Philippines), formerly AsianLife and General Assurance Corporation, a life and non-life insurance company provides a wide range of products including Group Health and Accident Insurance, Group Life, Individual Insurance, Micro-Insurance Motor, Fire, Travel and Construction All-Risk Insurance Over the years, it has built a solid reputation for fast prompt and reliable service and is now considered a leader in employee benefits insurance insuring executives, employees and dependents of multinational and local corporations nationwide.',
//                         textAlign: TextAlign.justify,),
//                       ),
//                     )
//                   ),
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: Row(
//                       children: <Widget>[
//                         Checkbox(
//                           value: _checkBoxValue1,
//                           activeColor: mPrimaryColor, 
//                           onChanged: (bool newValue){
//                             setState(() {
//                               _checker(newValue);
//                               _checkBoxValue1 = newValue;
//                             });
//                           }
//                         ),
//                         Text('I Agree', style: TextStyle(fontSize: 17.0),)
//                       ]
//                     )
//                   ),
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: Container(
//                       child: Expanded(
//                         child: Text('Etiqa Philippines also offers loans to educators. We at Etiqa Philippines are committed to provide you with the services pursuant to the service/product agreements to which we are parties while implementing safegurads to protect your privacy and keep your personal data safe and secure.',
//                         textAlign: TextAlign.justify,),
//                       ),
//                     )
//                   ),
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: Row(
//                       children: <Widget>[
//                         Checkbox(
//                           value: _checkBoxValue2,
//                           activeColor: mPrimaryColor, 
//                           onChanged: (bool newValue){
//                             setState(() {
//                               _checker(newValue);
//                               _checkBoxValue2 = newValue;
//                             });
//                           }
//                         ),
//                         Text('I Agree', style: TextStyle(fontSize: 17.0))
//                       ]
//                     )
//                   ),
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: Container(
//                       child: Expanded(
//                         child: Text('Processing of Personal Data. The Types of personal data we collect may include, but is not limited to your name, address, other contract details, age, date of birth, occupation, marital status, place of birth, financial references (e.g income, tax particulars, credit history),(information on personal indentifiers (e.g. identity card, passport), professional information (e.g. specialization, clinic schedules), medical conditions and diagnosis and your transaction history.',
//                         textAlign: TextAlign.justify,),
//                       ),
//                     )
//                   ),
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: Row(
//                       children: <Widget>[
//                         Checkbox(
//                           value: _checkBoxValue3,
//                           activeColor: mPrimaryColor, 
//                           onChanged: (bool newValue){
//                             setState(() {
//                               _checker(newValue);
//                               _checkBoxValue3 = newValue;
//                             });
//                           }
//                         ),
//                         Text('I Agree', style: TextStyle(fontSize: 17.0))
//                       ]
//                     )
//                   ),
//                   Container(
//                         width: width * .5,
//                         child: RaisedButton(
//                           padding: EdgeInsets.all(10),
//                           color: mPrimaryColor,
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                           child: Text('Continue', style: TextStyle(color: Colors.black87)),
//                           //onPressed: _isInteractionDisabled ? null : _validateInputs,
//                           onPressed: _validator ?
//                               () => Navigator.pop(context, 'granted') : null,
//                         ),
//                       ),
//                   SizedBox(height: 25,),
//                   Align(
//                     alignment: Alignment.bottomCenter,
//                     child: copyRightText()
//                   ),
//                 ]
//               ),
//             )
//           ),
//         );
//       }),