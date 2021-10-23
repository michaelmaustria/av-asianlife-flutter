import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/member.dart';
import 'package:av_asian_life/data_manager/requests.dart';
import 'package:av_asian_life/data_manager/user.dart';
import 'package:av_asian_life/home_page/session_callback.dart';
import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:intl/intl.dart';

class TermsAndConditionsPage extends StatefulWidget {
  static String tag = 'log-page';
  final Member member;

  final IApplicationSession appSessionCallback;

  TermsAndConditionsPage({this.member, this.appSessionCallback});
  @override
  _TermsAndConditionsPageState createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> with AutomaticKeepAliveClientMixin<TermsAndConditionsPage> {

  @override
  bool get wantKeepAlive => true;

  IApplicationSession _appSessionCallback;

  var cardHeight;
  var barColor;
  var textColor;
  var txtStatus;

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
              title: Text('Terms and Conditions of Use'),
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
                            alignment:  Alignment.topLeft,
                            child: Container(
                              child: Text('A.Definition of Terms',style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),),
                            ),
                          ),
                          Align(
                            alignment:  Alignment.topLeft,
                            child: Container(
                              child: Text('\nAs used herein, unless otherwise specified:\n',style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),),
                            ),
                          ),
                          Row(children: <Widget>[
                            Text('1.'),
                            Expanded(child: Text('"Plan Member/s” shall mean any of the following:\n', textAlign: TextAlign.justify))
                          ], crossAxisAlignment: CrossAxisAlignment.start),
                          Row(children: <Widget>[
                            Text('2.'),
                            Expanded(child: Text('the eligible Principal Enrollee enrolled by the Plan Holder and/or\n', textAlign: TextAlign.justify))
                          ], crossAxisAlignment: CrossAxisAlignment.start),
                          Row(children: <Widget>[
                            Text('3.'),
                            Expanded(child: Text('the respective eligible enrolled dependents of Principal Enrollees who are, at the time of registration to use the SmileApp, is of legal age.\n', textAlign: TextAlign.justify))
                          ], crossAxisAlignment: CrossAxisAlignment.start),
                          Row(children: <Widget>[
                            Text('4.'),
                            Expanded(child: Text('“Plan Holder” shall mean the legal entity to which the Plan Members are\n', textAlign: TextAlign.justify))
                          ], crossAxisAlignment: CrossAxisAlignment.start),
                          Row(children: <Widget>[
                            Text('5.'),
                            Expanded(child: Text('“Etiqa” shall mean Etiqa Life and General Assurance Philippines\n', textAlign: TextAlign.justify))
                          ], crossAxisAlignment: CrossAxisAlignment.start),
                          Row(children: <Widget>[
                            Text('6.'),
                            Expanded(child: Text('“Accredited Provider/s” refers to either the hospitals and/or clinics and/or physicians nationwide accredited to Etiqa\n', textAlign: TextAlign.justify))
                          ], crossAxisAlignment: CrossAxisAlignment.start),
                          Row(children: <Widget>[
                            Text('7.'),
                            Expanded(child: Text('“Accredited Dentist/s” and/or “Accredited Dental Clinic/s” refer to the respective dentist/s and/or dental clinic/s that are accredited to Etiqa’s outsourced dental network provider/s\n', textAlign: TextAlign.justify))
                          ], crossAxisAlignment: CrossAxisAlignment.start),
                          Row(children: <Widget>[
                            Text('8.'),
                            Expanded(child: Text('“Dental Network Provider/s” refer to Etiqa’s outsourced provider from where Plan Members can avail, if any, their respective dental benefits\n', textAlign: TextAlign.justify))
                          ], crossAxisAlignment: CrossAxisAlignment.start),
                          Row(children: <Widget>[
                            Text('9.'),
                            Expanded(child: Text('“Mobile device” shall refer to any electronic device such as, but not, at the moment, limited to, smart phones used by the Plan Member in downloading the SmileApp, in registering to use the SmileApp and using the SmileApp.\n', textAlign: TextAlign.justify))
                          ], crossAxisAlignment: CrossAxisAlignment.start),
                          Row(children: <Widget>[
                            Text('10.'),
                            Expanded(child: Text('“use of the SmileApp” shall refer to the use of any or all the current and/or succeeding functions and/or features of the SmileApp\n', textAlign: TextAlign.justify))
                          ], crossAxisAlignment: CrossAxisAlignment.start),
                          Row(children: <Widget>[
                            Text('11.'),
                            Expanded(child: Text('“Schedule of Benefits” refers to and is limited to the Plan Member’s own benefits\n', textAlign: TextAlign.justify))
                          ], crossAxisAlignment: CrossAxisAlignment.start),
                          Row(children: <Widget>[
                            Text('12.'),
                            Expanded(child: Text('“Program” refers to any or all of the in-force Group Insurance and/or Individual Insurance to where the Plan Member is currently enrolled eligibly.\n', textAlign: TextAlign.justify))
                          ], crossAxisAlignment: CrossAxisAlignment.start),
                          Align(
                            alignment:  Alignment.topLeft,
                            child: Container(
                              child: Text('\nB.Grant of License and Applicability of SmileApp Terms and Conditions',style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),),
                            ),
                          ),
                          Align(
                            alignment:  Alignment.topLeft,
                            child: Container(
                                child: Text('\nBeing a Plan Member enrolled on an in-force Program by the Plan Holder, the Plan Member acknowledges that the Plan Member is granted with non-transferable, personal and limited privilege to install and use the SmileApp on a Mobile Device that the Plan Member owns and/or has sole control of use and/or access on.'
                                    'The SmileApp Terms and Conditions shall be in addition to the Data Privacy the Plan Member also signifies acknowledgement, understanding and acceptance of. \n')
                            ),
                          ),
                          Align(
                            alignment:  Alignment.topLeft,
                            child: Container(
                              child: Text('\nC.General Rules',style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),),
                            ),
                          ),
                          Align(
                            alignment:  Alignment.topLeft,
                            child: Container(
                              child: Text('\nThe Plan Member hereby agrees to be bound by, understands, accept and agrees on the following general rules governing the use of the  SmileApp:\n', textAlign: TextAlign.justify),
                            ),
                          ),
                          Row(children: <Widget>[
                            Text('1.'),
                            Expanded(child: Text('the Plan Member will be able to download the SmileApp even if the Plan Member is not enrolled yet or even as the Plan Member’s enrollment is not yet completely processed\n', textAlign: TextAlign.justify))
                          ], crossAxisAlignment: CrossAxisAlignment.start),
                          Row(children: <Widget>[
                            Text('2.'),
                            Expanded(child: Text('in order to register and/or use the SmileApp, the Plan Member must:'
                                '\na. be enrolled'
                                '\nb. has the Plan Member ID number'
                                '\nc. use the complete name and birth date that the Plan Holder sent to Etiqa when the Plan Member was enrolled\n', textAlign: TextAlign.justify))
                          ], crossAxisAlignment: CrossAxisAlignment.start),
                          Row(children: <Widget>[
                            Text('3.'),
                            Expanded(child: Text('Only Plan Members whose respective enrollment is completely processed can gain access to and usage of the SmileApp.\n', textAlign: TextAlign.justify))
                          ], crossAxisAlignment: CrossAxisAlignment.start),
                          Row(children: <Widget>[
                            Text('4.'),
                            Expanded(child: Text('As an individual registers to access and use the SmileApp, the individual attests that the said individual is the same and actual Plan Member who is enrolled on the Program.   The Plan Member shall not hold Etiqa responsible for anyone acting as Plan Member to download and/or access  and/or use the SmileApp.\n', textAlign: TextAlign.justify))
                          ], crossAxisAlignment: CrossAxisAlignment.start),
                          Row(children: <Widget>[
                            Text('5.'),
                            Expanded(child: Text('The Plan Member confirms that the Plan Member has the full responsibility over the security of registration and the succeeding use the SmileApp.\n', textAlign: TextAlign.justify))
                          ], crossAxisAlignment: CrossAxisAlignment.start),
                          Row(children: <Widget>[
                            Text('6.'),
                            Expanded(child: Text('The Plan Member confirms that the Plan Member, at the onset of the registration on the use of the Smile App, is the same person registering as the Plan Member..\n', textAlign: TextAlign.justify))
                          ], crossAxisAlignment: CrossAxisAlignment.start),
                          Row(children: <Widget>[
                            Text('7.'),
                            Expanded(child: Text('The Plan Member also confirms that all inquiry will only be related to the Plan Member’s own Schedule of Benefits and/or Limitations of the Program and/or enrolled eligible dependents (if any), etc.  Any reply to an inquiry that is not particular to the Plan Member does not constitute a confirmation from Etiqa as applicable to the Plan Member.\n', textAlign: TextAlign.justify))
                          ], crossAxisAlignment: CrossAxisAlignment.start),
                          Row(children: <Widget>[
                            Text('8.'),
                            Expanded(child: Text('Etiqa may, at any time and sole volition and without notice to the Plan Member and/or Plan Holder, suspend the downloading of the SmileApp and/or registration and/or access and/or use for reason Etiqa deems necessary.  And, any and/or all features and/or functions of the SmileApp may, at any time, be changed and/or enhanced without prior notice.\n', textAlign: TextAlign.justify))
                          ], crossAxisAlignment: CrossAxisAlignment.start),
                          Row(children: <Widget>[
                            Text('9.'),
                            Expanded(child: Text('To enable Etiqa to aptly attend to matters related to the delivery of service (such as, but not limited to, availments and/or claims and/or enrollment and/or inquiries and/or other matters that are brought to Etiqa’s attention) and/or any needs of the Plan Member, the Plan Member gives Etiqa a continuing authority to send the Plan Member information and/or messages through texts and/or e-mail and/or any other means of communication directly and/or through the authorized representatives (generally referring to, for Plan Members of a corporate account, Plan Holder’s authorized Human Resource persons who transact with any of the Etiqa employees).\n', textAlign: TextAlign.justify))
                          ], crossAxisAlignment: CrossAxisAlignment.start),
                          Align(
                            alignment:  Alignment.topLeft,
                            child: Container(
                              child: Text('\nD.Lost Mobile Device',style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),),
                            ),
                          ),
                          Align(
                              alignment:  Alignment.topLeft,
                              child: Container(
                                child: Text('\nIn the event the Plan Member loses the Mobile Device used in accessing the SmileApp, it is the Plan Member’s sole responsibility to reset the password using another (or, new) Mobile Device.'),
                              )
                          ),
                          Align(
                              alignment:  Alignment.topLeft,
                              child: Container(
                                  child:Text('\nE.Disclaimer\n',style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ))
                              )
                          ),
                          Row(children: <Widget>[
                            Text('1.'),
                            Expanded(child: Text('Etiqa is unable to receive or execute any of the requests from the Plan Member due to reasons beyond the control of Etiqa such as, but not limited to, services that should be rendered by Etiqa’s accredited provider/s.\n', textAlign: TextAlign.justify))
                          ], crossAxisAlignment: CrossAxisAlignment.start),
                          Row(children: <Widget>[
                            Text('2.'),
                            Expanded(child: Text('Possible loss of information during processing or transmission or any unauthorized access by any other person due to reasons beyond the control of Etiqa;\n', textAlign: TextAlign.justify))
                          ], crossAxisAlignment: CrossAxisAlignment.start),
                          Row(children: <Widget>[
                            Text('3.'),
                            Expanded(child: Text('Any loss, cost, or damages as a result of, or caused by any delay in the delivery of service beyond the control of Etiqa;\n', textAlign: TextAlign.justify))
                          ], crossAxisAlignment: CrossAxisAlignment.start),
                          Align(
                              alignment:  Alignment.topLeft,
                              child: Container(
                                  child:Text('\nF. Other Provisions',style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ))
                              )
                          ),
                          Align(
                              alignment:  Alignment.topLeft,
                              child: Container(
                                  child:Text('\nThe exact provisions of the master policy that is in-force shall serve as the sole reference in addressing any matter related to the Plan Member’s Schedule of Benefits, Limitation of the Plans, etc..'
                                      '\nThe SmileApp does not, in any way, replaces any master policy provision.'
                                      '\nEtiqa reserves the right to amend or modify the SmileApp Terms and Conditions at any time by posting on Etiqa’s website and/or social media account/s.\n')
                              )
                          ),
                        ]
                    ),
                  )
              ),
            )
        )
    );
  }
}