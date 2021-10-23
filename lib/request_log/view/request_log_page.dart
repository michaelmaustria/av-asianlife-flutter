import 'dart:io';

import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/availment.dart';
import 'package:av_asian_life/data_manager/dependent.dart';
import 'package:av_asian_life/data_manager/doctor.dart';
import 'package:av_asian_life/data_manager/log_request.dart';
import 'package:av_asian_life/data_manager/member.dart';
import 'package:av_asian_life/data_manager/procedure.dart';
import 'package:av_asian_life/data_manager/provider.dart';
import 'package:av_asian_life/data_manager/user.dart';
import 'package:av_asian_life/find_doctor/find_doctor_page.dart';
import 'package:av_asian_life/find_provider/find_provider_page.dart';
import 'package:av_asian_life/home_page/session_callback.dart';
import 'package:av_asian_life/letter_of_guarantee/view/letter_of_guarantee_page.dart';
import 'package:av_asian_life/request_log/presenter/requet_log_presenter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:menu_button/menu_button.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:av_asian_life/request_log/view/verify_request_log_page.dart';

import '../request_log_contract.dart';

class RequestLogPage extends StatefulWidget {
  static String cardno_patient;
  final String availType;
  final Member member;

  final IApplicationSession appSessionCallback;

  RequestLogPage({this.availType, this.member, this.appSessionCallback});

  @override
  _RequestLogPageState createState() => _RequestLogPageState();
}

class _RequestLogPageState extends State<RequestLogPage> implements IRequestLogView {
  //String cardno_patient;
  DateTime selectedDate = DateTime.now();
  bool isSelected = false;
  String selectedDateText = '';

  IApplicationSession _appSessionCallback;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _isInteractionDisabled = false;
  bool _isRemoveDocVis = false;
  bool _availVis = true;
  bool _isAttachmentRequired = false;
  List<String> isTappedd = [];

  var _complaintController = new TextEditingController();

  //MyPreferenceHandler _prefHandler = MyPreferenceHandler();

  IRequestLogPresenter _mPresenter = RequestLogPresenter();

  String _selectedAvailment, _selectedPatient, _selectedProcedure;
  String _selectedProvider = 'Select your Provider';
  String _selectedDoctor = 'Select your Doctor';
  String _availment, _provider, _complaints, _availDate, _patient;
  String _contactNo = '', _doctor = '', _fileName = '', _procedures = ''; //_file;
  String _coverenddt = '';
  String _coverstartdt = '';

  bool procVis = true;
  bool docVis = true;
  File _document;
  List<File> _fileList = [];
  List<String> _fileListStr = [];
  List<String> _selectedProceduresList =[];
  

  Future<List<Availment>> _mAvailment;
  Future<List<Dependent>> _mDependent;
  Future<List<Procedure>> _mProcedure;
  User _mUser;

  List<String>picks = []; //for procedures display

  AlertDialog _loadingDialog;
  BuildContext mContext;

  double _width;

  @override
  void initState() {
    super.initState();
    _mPresenter.onAttach(this);
    _appSessionCallback = widget.appSessionCallback;
    setState(() {
      _contactNo = widget.member.mobileno;
    });

    _getUser().then((_){
      setState(() {
        if (widget.availType == '2'){
          _availVis = false;
          _availment = '21';
        } else {
          _availVis = true;
        }
        _mAvailment = _mPresenter.initAvailmentType(widget.availType);
        _mDependent = _mPresenter.initDependentsInfo(_mUser.cardNo);
      });
    });
  }

  Future<Null> _getUser() async {
    _mUser = await _mPresenter.getUserData();
   print('User: ${_mUser.cardNo}');
  }

  @override
  void onSuccess(String message) {
    _appSessionCallback.pauseAppSession();
    print('success');
    _closeAlert();
    _showAlertDialog(true, message);
  }

  @override
  void onError(String message) {
    _appSessionCallback.pauseAppSession();
    _closeAlert();

    var errMsg = '';

    if(message == 'An error has occurred.') {
      if(_availDate == null)
        errMsg += '\nPlease provide an Availment Date.';
      if(_provider == null)
        errMsg += '\nPlease select a Provider.';
      if(_availment == null)
        errMsg += '\nPlease select a Type of Availment.';
      if(_patient == null)
        errMsg += '\nPlease choose a Patient Name.';
    } else if(message == 'File error occurred.')
      errMsg = 'An error occured while uploading the file. Please try again.';

    _showAlertDialog(false, errMsg);
  }

  void _showAlertDialog(bool isSuccess, String text) {
    // set up the AlertDialog
    showDialog(
      context: mContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isSuccess ? "Success" : "Warning"),
          content: Text(text),
          actions: <Widget>[
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                if(isSuccess) {
                  _appSessionCallback.pauseAppSession();
                  Navigator.of(context).pop('alert');
                  Navigator.pushReplacement(context,
                    MaterialPageRoute(
                        builder: (context) => LetterOfGuaranteePage(member: widget.member,)),
                  );
                }else{
                  setState(() {
                    _isInteractionDisabled = false;
                  });
                  Navigator.of(context).pop('alert');
                }
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    mContext = context;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text('LOG Request'),
        flexibleSpace: Image(
          image:  AssetImage('assets/images/appBar_background.png'),
          fit: BoxFit.fill,),
      ),
      body: LayoutBuilder(builder: (context, constraint) {
        final height = constraint.maxHeight;
        final width = constraint.maxWidth;
        _width = constraint.maxWidth;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                height: height * .97,
                child: Form(
                  key: _formKey,
                  autovalidate: _autoValidate,
                  child: ListView(
                    children: <Widget>[
                      Visibility(
                        visible: _availVis,
                        child: SizedBox(
                          height: height * .06,
                          child: RaisedButton(
                            elevation: 1.0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                            onPressed: () { _appSessionCallback.pauseAppSession(); },
                            child: FutureBuilder<List<Availment>>(
                              future: _mAvailment,
                              builder: (BuildContext context, AsyncSnapshot<List<Availment>> snapshot){
                                if(!snapshot.hasData)
                                  return _dropDownDisabledHolder('Type of Availment');
                                else
                                  return _getAvailmentDropdown(snapshot.data);
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      SizedBox(
                        height: height * .06,
                        child: RaisedButton(
                          elevation: 1.0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                          onPressed: () {
                            _waitForProvider(context);
                            _appSessionCallback.pauseAppSession();
                          },
                          child: SizedBox(
                              width: double.infinity,
                              child: Text(_selectedProvider, textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black54,
                                      fontSize: 16)
                              )
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Row(children: <Widget>[Text('*',style: TextStyle(color: Colors.red)),Text(' Patient')]),
                      SizedBox(
                        height: height * .06,
                        child: RaisedButton(
                          elevation: 1.0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                          onPressed: () {  },
                          child: FutureBuilder<List<Dependent>>(
                            future: _mDependent,
                            builder: (BuildContext context, AsyncSnapshot<List<Dependent>> snapshot){
                              if(!snapshot.hasData) {
                                print('dependents: ${snapshot.data}');
                                return _dropDownDisabledHolder('Choose Patient Name');
                              }else {
                                print('dependents: ${snapshot.data[0].message}');
                                if(snapshot.data[0].message != 'No Dependent')
                                  return _getPatientDropdown(snapshot.data, true);
                                else
                                  return _getPatientDropdown(snapshot.data, false);
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Row(children: <Widget>[Text('*',style: TextStyle(color: Colors.red)),Text(' Availment Date')]),
                      RaisedButton(
                        elevation: 1.0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                        onPressed: () {
                          _datePicker(context);
                          _appSessionCallback.pauseAppSession();
                        },
                        child: Container(
                          width: double.infinity,
                          height: 45,
                          alignment: Alignment.centerLeft,
                          child: Text(selectedDateText == '' ? 'Availment Date' : 'Availment Date:  $selectedDateText',
                            style: TextStyle(fontSize: 16.0,),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      _getChiefComplaintText(),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.phone,
                        validator: _mPresenter.validatePhoneNumber,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Contact No.",
                          labelText: "Contact No.",
                        ),
                        initialValue: _contactNo,
                        onTap: () { _appSessionCallback.pauseAppSession(); },
                        onSaved: (String val) {
                          _contactNo = val;
                        },
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Visibility(
                        visible: docVis,
                        child: Text('Preferred Doctor', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Visibility(
                        visible: docVis,
                        child: SizedBox(
                          height: height * .06,
                          child: RaisedButton(
                            elevation: 1.0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                            onPressed: () {
                              _waitForDoctor(context);
                              _appSessionCallback.pauseAppSession();
                            },
                            child: SizedBox(
                                width: double.infinity,
                                child: Text(_selectedDoctor, textAlign: TextAlign.start, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 16))
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: _isRemoveDocVis,
                        child: SizedBox(
                          child: FlatButton(
                              onPressed: () {
                                setState(() {
                                  _appSessionCallback.pauseAppSession();
                                  _selectedDoctor = 'Select your Doctor';
                                  _doctor = null;
                                  _isRemoveDocVis = false;
                                });
                          }, child: Text('Remove Doctor')),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Visibility(
                        visible: procVis,
                        child: SizedBox(
                          height: height * .06,
                          child: RaisedButton(
                            elevation: 1.0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                            onPressed: () { _appSessionCallback.pauseAppSession(); },
                            child: FutureBuilder<List<Procedure>>(
                              future: _mProcedure,
                              builder: (BuildContext context, AsyncSnapshot<List<Procedure>> snapshot){
                                if(!snapshot.hasData)
                                  return _dropDownDisabledHolder('Procedures');
                                else if(picks.length == 3){
                                  return _dropDownDisabledHolder('You Already selected 3 Procedures');
                                }
                                else
                                  return _getProceduresDropdown(snapshot.data);
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      picks.length >= 1 ? Container(
                        padding: EdgeInsets.fromLTRB(0, 4, 0, 6),
                        child: Stack(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Card(
                                shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                                child: Container(
                                  width: width * .8,
                                  padding: EdgeInsets.only(left: 10),
                                  child: Column(
                                    children: <Widget>[
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text('${picks[0]}'),
                                      ),
                                      SizedBox(height: 10,)
                                    ],
                                  )
                                )
                              )
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: EdgeInsets.all(.3),
                                child: InkWell(
                                  child: CircleAvatar(
                                    backgroundColor: Colors.red,
                                    radius: 10,
                                    child: Icon(Icons.close, size: 20, color: Colors.white)
                                  ),
                                  onTap: (){
                                    setState(() {
                                      this.picks.removeWhere((item) => item == picks[0]);
                                      this._selectedProceduresList.removeWhere((item) => item == _selectedProceduresList[0]);
                                      print(_selectedProceduresList);
                                      print(picks);
                                    });
                                  }
                                )
                              ),
                            )
                          ],
                        ),
                      ) : Offstage(),
                      picks.length >= 2 ? Container(
                        padding: EdgeInsets.fromLTRB(0, 4, 0, 6),
                        child: Stack(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Card(
                                shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                                child: Container(
                                  width: width * .8,
                                  padding: EdgeInsets.only(left: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text('${picks[1]}'),
                                      ),
                                      SizedBox(height: 10,)
                                    ],
                                  )
                                )
                              )
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: EdgeInsets.all(.3),
                                child: InkWell(
                                  child: CircleAvatar(
                                    backgroundColor: Colors.red,
                                    radius: 10,
                                    child: Icon(Icons.close, size: 20, color: Colors.white)
                                  ),
                                  onTap: (){
                                    setState(() {
                                      this.picks.removeWhere((item) => item == picks[1]);
                                      this._selectedProceduresList.removeWhere((item) => item == _selectedProceduresList[1]);
                                      print(_selectedProceduresList);
                                      print(picks);
                                    });
                                  }
                                )
                              ),
                            )
                          ],
                        ),
                      ) : Offstage(),
                      picks.length == 3 ? Container(
                        padding: EdgeInsets.fromLTRB(0, 4, 0, 6),
                        child: Stack(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Card(
                                shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                                child: Container(
                                  width: width * .8,
                                  padding: EdgeInsets.only(left: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text('${picks[2]}'),
                                      ),
                                      SizedBox(height: 10,)
                                    ],
                                  )
                                )
                              )
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: EdgeInsets.all(.3),
                                child: InkWell(
                                  child: CircleAvatar(
                                    backgroundColor: Colors.red,
                                    radius: 10,
                                    child: Icon(Icons.close, size: 20, color: Colors.white)
                                  ),
                                  onTap: (){
                                    setState(() {
                                      this.picks.removeWhere((item) => item == picks[2]);
                                      this._selectedProceduresList.removeWhere((item) => item == _selectedProceduresList[2]);
                                      print(_selectedProceduresList);
                                      print(picks);
                                    });
                                  }
                                )
                              ),
                            )
                          ],
                        ),
                      ) : Offstage(),
                      // SizedBox(
                      //   height: picks.length == 0 ? 4 : height * .2 / 1.5,
                      //     child: ListView.builder(
                      //       itemCount: picks.length,
                      //       itemBuilder: (BuildContext context, int index){
                      //         return Container(
                      //           padding: EdgeInsets.fromLTRB(0, 4, 0, 6),
                      //           child: Stack(
                      //             children: <Widget>[
                      //               Align(
                      //                 alignment: Alignment.centerLeft,
                      //                 child: Card(
                      //                   shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                      //                   child: Container(
                      //                     width: width * .8,
                      //                     child: Text('   ${picks[index]}')
                      //                   )
                      //                 )
                      //               ),
                      //               Align(
                      //                 alignment: Alignment.centerRight,
                      //                 child: Container(
                      //                   padding: EdgeInsets.all(.3),
                      //                   child: InkWell(
                      //                     child: CircleAvatar(
                      //                       backgroundColor: Colors.red,
                      //                       radius: 10,
                      //                       child: Icon(Icons.close, size: 20, color: Colors.white)
                      //                     ),
                      //                     onTap: (){
                      //                       print(picks[index]);
                      //                       setState(() {
                      //                         this.picks.removeWhere((item) => item == picks[index]);
                      //                         this._selectedProceduresList.removeWhere((item) => item == _selectedProceduresList[index]);
                      //                       });
                      //                     }
                      //                   )
                      //                 ),
                      //               )
                      //             ],
                      //           )
                      //         );
                      //     } 
                      //   )
                      // ),
                      Visibility(
                          visible: procVis,
                          child: _getBrowseButton()
                      ),
                      _fileList.length >= 1 ? Container(
                        padding: EdgeInsets.fromLTRB(0, 4, 0, 6),
                        child: Stack(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Card(
                                shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                                child: Container(
                                  width: width * .8,
                                  padding: EdgeInsets.only(left: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text('${_fileListStr[0]}'),
                                      SizedBox(height: 10,)
                                    ],
                                  )
                                )
                              )
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: EdgeInsets.all(.3),
                                child: InkWell(
                                  child: CircleAvatar(
                                    backgroundColor: Colors.red,
                                    radius: 10,
                                    child: Icon(Icons.close, size: 20, color: Colors.white)
                                  ),
                                  onTap: (){
                                    setState(() {
                                      this._fileList.removeWhere((item) => item == _fileList[0]);
                                      this._fileListStr.removeWhere((item) => item == _fileListStr[0]);
                                      print(_fileList);
                                      print(_fileListStr);
                                    });
                                  }
                                )
                              ),
                            )
                          ],
                        ),
                      ) : Offstage(),
                      _fileList.length >= 2 ? Container(
                        padding: EdgeInsets.fromLTRB(0, 4, 0, 6),
                        child: Stack(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Card(
                                shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                                child: Container(
                                  width: width * .8,
                                  padding: EdgeInsets.only(left: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text('${_fileListStr[1]}'),
                                      SizedBox(height: 10,)
                                    ],
                                  )
                                )
                              )
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: EdgeInsets.all(.3),
                                child: InkWell(
                                  child: CircleAvatar(
                                    backgroundColor: Colors.red,
                                    radius: 10,
                                    child: Icon(Icons.close, size: 20, color: Colors.white)
                                  ),
                                  onTap: (){
                                    setState(() {
                                      this._fileListStr.removeWhere((item) => item == _fileListStr[1]);
                                      this._fileList.removeWhere((item) => item == _fileList[1]);
                                      print(_fileList);
                                      print(_fileListStr);
                                    });
                                  }
                                )
                              ),
                            )
                          ],
                        ),
                      ) : Offstage(),
                      _fileListStr.length == 3 ? Container(
                        padding: EdgeInsets.fromLTRB(0, 4, 0, 6),
                        child: Stack(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Card(
                                shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                                child: Container(
                                  width: width * .8,
                                  padding: EdgeInsets.only(left: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text('${_fileListStr[2]}'),
                                      SizedBox(height: 10,)
                                    ],
                                  )
                                )
                              )
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: EdgeInsets.all(.3),
                                child: InkWell(
                                  child: CircleAvatar(
                                    backgroundColor: Colors.red,
                                    radius: 10,
                                    child: Icon(Icons.close, size: 20, color: Colors.white)
                                  ),
                                  onTap: (){
                                    setState(() {
                                      this._fileListStr.removeWhere((item) => item == _fileListStr[2]);
                                      this._fileList.removeWhere((item) => item == _fileList[2]);
                                      print(_fileList);
                                      print(_fileListStr);
                                    });
                                  }
                                )
                              ),
                            )
                          ],
                        ),
                      ) : Offstage(),
                      // SizedBox(
                      //   height: _fileList.length == 0 ? 4 : height * .2 / 1.5,
                      //     child: ListView.builder(
                      //       itemCount: _fileListStr.length,
                      //       itemBuilder: (BuildContext context, int index){
                      //         return Container(
                      //           padding: EdgeInsets.fromLTRB(0, 4, 0, 6),
                      //           child: Stack(
                      //             children: <Widget>[
                      //               Align(
                      //                 alignment: Alignment.topLeft,
                      //                 child: Icon(Icons.folder_special, color: mPrimaryColor)
                      //               ),
                      //               Align(
                      //                 alignment: Alignment.center,
                      //                 child: Card(
                      //                   shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                      //                   child: Container(
                      //                     width: width * .8,
                      //                     padding: EdgeInsets.only(left: 10),
                      //                     child: Text('${_fileListStr[index]}')
                      //                   )
                      //                 )
                      //               ),
                      //               Align(
                      //                 alignment: Alignment.centerRight,
                      //                 child: Container(
                      //                   padding: EdgeInsets.all(.3),
                      //                   child: InkWell(
                      //                     child: Icon(Icons.close, size: 20, color: Colors.black),
                      //                     onTap: (){
                      //                       print(_fileList);
                      //                       setState(() {
                      //                         this._fileList.removeWhere((item) => item == _fileList[index]);
                      //                         this._fileListStr.removeWhere((item) => item == _fileListStr[index]);
                      //                       });
                      //                     }
                      //                   )
                      //                 ),
                      //               )
                      //             ],
                      //           )
                      //         );
                      //     } 
                      //   )
                      // ),
                      SizedBox(
                        height: 25.0,
                      ),
                      RaisedButton(
                        padding: EdgeInsets.all(12),
                        color: mPrimaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        child: Container(
                            alignment: Alignment.center,
                            width: width * .5,
                            child: Text('Submit', style: TextStyle(color: Colors.black))
                        ),
                        onPressed: (){
                            var errMsg = '';
                            if(widget.availType == '1'){
                              if((_isAttachmentRequired == true)&&((_selectedProcedure == null || _selectedProcedure == '')||(_availDate == null || _availDate == '')||(_provider == null || _provider == '')||(_availment == null || _availment == '')||(_patient == null || _patient == '')||(_complaintController.text == '' || _complaintController.text == null)||(_fileList.length == 0))){
                                if(_availDate == null || _availDate == ''){
                                  errMsg += '\nPlease provide an Availment Date.';
                                }

                                if(_provider == null || _provider == ''){
                                  errMsg += '\nPlease select a Provider.';
                                }

                                if(_availment == null || _availment == ''){
                                  errMsg += '\nPlease select a Type of Availment.';
                                }

                                if(_patient == null || _patient == ''){
                                  errMsg += '\nPlease choose a Patient Name.';
                                }

                                if(_complaintController.text == '' || _complaintController.text == null){
                                  errMsg += '\nPlease provide your complaint.';
                                }

                                if(_fileList.length == 0){
                                  errMsg += '\nPlease attach doctor\'s request form.';
                                }

                                if(_selectedProcedure == null || _selectedProcedure == ''){
                                  errMsg += '\nPlease select a procedure.';
                                }

                                _showAlertDialog(false, errMsg);
                              }

                              else if((_isAttachmentRequired == false)&&((_availDate == null || _availDate == '')||(_provider == null || _provider == '')||(_availment == null || _availment == '')||(_patient == null || _patient == '')||(_complaintController.text == '' || _complaintController.text == null))){
                                if(_availDate == null || _availDate == ''){
                                  errMsg += '\nPlease provide an Availment Date.';
                                }

                                if(_provider == null || _provider == ''){
                                  errMsg += '\nPlease select a Provider.';
                                }

                                if(_availment == null || _availment == ''){
                                  errMsg += '\nPlease select a Type of Availment.';
                                }

                                if(_patient == null || _patient == ''){
                                  errMsg += '\nPlease choose a Patient Name.';
                                }

                                if(_complaintController.text == '' || _complaintController.text == null){
                                  errMsg += '\nPlease provide your complaint.';
                                }

                                _showAlertDialog(false, errMsg);
                              }

                              else if((_isAttachmentRequired == false)&&(_availDate == null || _availDate == '')||(_provider == null || _provider == '')||(_availment == null || _availment == '')||(_patient == null || _patient == '')||(_complaintController.text == '' || _complaintController.text == null)){

                                if(_availDate == null || _availDate == ''){
                                  errMsg += '\nPlease provide an Availment Date.';
                                }

                                if(_provider == null || _provider == ''){
                                  errMsg += '\nPlease select a Provider.';
                                }

                                if(_availment == null || _availment == ''){
                                  errMsg += '\nPlease select a Type of Availment.';
                                }

                                if(_patient == null || _patient == ''){
                                  errMsg += '\nPlease choose a Patient Name.';
                                }

                                if(_complaintController.text == '' || _complaintController.text == null){
                                  errMsg += '\nPlease provide your complaint.';
                                }

                                _showAlertDialog(false, errMsg);
                              }

                              else if((_availDate != null || _availDate != '')||(_provider != null || _provider != '')||(_availment != null || _availment != '')||(_patient != null || _patient != '')||(_complaintController.text != '' || _complaintController.text != null)){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VerifyRequestLogPage(
                                          availment: _availment,
                                          availDate: _availDate,
                                          username: _mUser.username,
                                          cardNo: _mUser.cardNo,
                                          provider: _provider,
                                          patient: _patient,
                                          complaints: _complaintController.text,
                                          contactNo: _contactNo,
                                          doctor: _doctor,
                                          fileList: _fileList,
                                          selectedProceduresList: _selectedProceduresList),
                                    )
                                );
                              }
                            }

                            else if(widget.availType == '2'){
                              if((_selectedProcedure == null || _selectedProcedure == '')||(_availDate == null || _availDate == '')||(_provider == null || _provider == '')||(_availment == null || _availment == '')||(_patient == null || _patient == '')||(_complaintController.text == '' || _complaintController.text == null)||(_fileList.length == 0)){
                                if(_availDate == null || _availDate == ''){
                                  errMsg += '\nPlease provide an Availment Date.';
                                }

                                if(_provider == null || _provider == ''){
                                  errMsg += '\nPlease select a Provider.';
                                }

                                if(_availment == null || _availment == ''){
                                  errMsg += '\nPlease select a Type of Availment.';
                                }

                                if(_patient == null || _patient == ''){
                                  errMsg += '\nPlease choose a Patient Name.';
                                }

                                if(_complaintController.text == '' || _complaintController.text == null){
                                  errMsg += '\nPlease provide your complaint.';
                                }

                                if(_isAttachmentRequired == true){
                                  errMsg += '\nPlease attach doctor\'s request form.';
                                }

                                if(_selectedProcedure == null || _selectedProcedure == ''){
                                  errMsg += '\nPlease select a procedure.';
                                }

                                if(_fileList.length == 0){
                                  errMsg += '\nPlease attach doctor\'s request form.';
                                }

                                _showAlertDialog(false, errMsg);
                              }

                              else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VerifyRequestLogPage(
                                          availment: _availment,
                                          availDate: _availDate,
                                          username: _mUser.username,
                                          cardNo: _mUser.cardNo,
                                          provider: _provider,
                                          patient: _patient,
                                          complaints: _complaintController.text,
                                          contactNo: _contactNo,
                                          doctor: _doctor,
                                          fileList: _fileList,
                                          selectedProceduresList: _selectedProceduresList),
                                    )
                                );
                              }
                            }
                        }
                      ),
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 50.0),
                            child: copyRightText()
                          )
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _dropDownDisabledHolder(String text) {
    return SizedBox(
        width: double.infinity,
        child: Text(text, textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.grey),)
    );
  }

  void _datePicker(BuildContext context) {
    List months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

    // int startdate = int.parse(this._coverstartdt.substring(0,2));
    // int startmonth = months.indexOf(this._coverstartdt.substring(3,6))+1;
    // int startyear = int.parse(this._coverstartdt.substring(7,11));

    DateTime now = new DateTime.now();

    int enddate = int.parse(this._coverenddt.substring(0,2));
    int endmonth = months.indexOf(this._coverenddt.substring(3,6))+1;
    int endyear = int.parse(this._coverenddt.substring(7,11));
    
    DatePicker
        .showDatePicker(context,
        minTime: DateTime(now.year,now.month,now.day),
        maxTime: DateTime(endyear,endmonth,enddate),
        showTitleActions: true,
        onChanged: (date) { print('change ${date.month}'); },
        onConfirm: (date) {
          print('confirm ${date.month} ${date.day} ${date.year}');
          setState(() {
            var month = date.month.toString().length == 1 ? '0${date.month}' : '${date.month}';
            var day = date.day.toString().length == 1 ? '0${date.day}' : '${date.day}';
            _availDate = '${date.year}$month$day';
            print(_availDate);
            selectedDateText = '${date.month}/${date.day}/${date.year}';
          });
        },
        currentTime: DateTime.now(), locale: LocaleType.en);
  }

  Future getImage(ImageSource source) async {
    try{
      ImagePicker.pickImage(source: source).then((File file) async {

        Directory tempDir = await getTemporaryDirectory();

        String newName = '${widget.member.cardno}_${DateTime.now().millisecondsSinceEpoch}.${extension(file.path)}';

        File newFile = await file.copy('${tempDir.path}/$newName');

        print('${newFile.path}');

        setState(() {
          if(file != null) {
            _document = newFile;
            _fileName = basename(file.path);
            _fileList.add(_document);
            _fileListStr.add(_fileName);
          }
        });
      });
    }catch (e){
      print('Compressing of PNG is not supported');
    }
  }

  Future getFile(FileType type) async {
    FilePicker.getFilePath(type: type, allowCompression: true).then((String path) async {

      Directory tempDir = await getTemporaryDirectory();

      File file = File(path);

      String newName = '${widget.member.cardno}_${DateTime.now().millisecondsSinceEpoch}${extension(file.path)}';

      File newFile = await File(path).copy('${tempDir.path}/$newName');

      print('${newFile.path}');

      setState(() {
        if(path != null) {
          print(newFile);
          _document = newFile;
          _fileName = basename(path);
          
          _fileList.add(_document);
          _fileListStr.add(_fileName);
        }
      });
    });
  }

  void _showFileDialog() {
    // set up the AlertDialog
    showDialog(
      context: mContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upload file from...'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              FlatButton(
                child: Text('Camera'),
                onPressed: () {
                  getImage(ImageSource.camera);
                  _appSessionCallback.pauseAppSession();
                  Navigator.of(context).pop('dialog');
                },
              ),
              FlatButton(
                child: Text('Gallery'),
                onPressed: () {
                  getImage(ImageSource.gallery);
                  _appSessionCallback.pauseAppSession();
                  Navigator.of(context).pop('dialog');
                },
              ),
              // FlatButton(
              //   child: Text('File Explorer'),
              //   onPressed: () {
              //     getFile(FileType.image);
              //     _appSessionCallback.pauseAppSession();
              //     Navigator.of(context).pop('dialog');
              //   },
              // ),
              // FlatButton(
              //   child: Text('Clear'),
              //   onPressed: () {
              //     _appSessionCallback.pauseAppSession();
              //     setState(() {
              //       _document = null;
              //       _fileName = null;
              //     });
              //     Navigator.of(context).pop('dialog');
              //   },
              // ),
            ],
          ),

        );
      },
    );
  }

  Widget _getBrowseButton() {
    return Column(
      children: <Widget>[
        Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text('Attach Doctor\'s Request Form (.png/.jpg)')
        ),
        _fileList.length < 3 ? RaisedButton(
          elevation: 1.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)),
          onPressed: () {
            //Open Camera, File handler...
            _showFileDialog();
            _appSessionCallback.pauseAppSession();
          },
          child: Container(
            width: double.infinity,
            height: 45,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: _getBrowseText(),
                ),
                Icon(Icons.attach_file)
              ],
            ),
          ),
        ) : Card(
          elevation: 1.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)),
          child: Container(
            width: double.infinity,
            height: 45,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text('    You already selected 3 images', style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold)),
                ),
                Icon(Icons.attach_file)
              ],
            ),
          ),
        )
      ],
    );
  }

  Text _getBrowseText() {

    bool isFileEmpty = _document == null ? true : false;

    String text = isFileEmpty ? 'Browse' : 'Browse';
    TextStyle style = isFileEmpty ? TextStyle(fontSize: 16.0) : TextStyle(fontSize: 12.0);

    return Text(text, style: style, maxLines: 2, overflow: TextOverflow.ellipsis,);
  }

  Widget _getChiefComplaintText() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(bottom: 5.0),
              child: Text('Chief Complaints', style: TextStyle(fontSize: 16.0,))
          ),
          TextFormField(
            controller: _complaintController,
            keyboardType: TextInputType.multiline,
            maxLines: 6,
            enabled: !_isInteractionDisabled,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black87)
              ),
            ),
            validator: _mPresenter.validateComplaintText,
            onTap: () { _appSessionCallback.pauseAppSession(); },
            onSaved: (String val) {
              setState((){
                _complaints = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _getAvailmentDropdown(List<Availment> availments){
    List<String> dropDownItems = [];
    availments.forEach((cat) {
      dropDownItems.add(cat.description);
    });

    final Widget button = SizedBox(
         width: _width,
         height: 40,
         child: Padding(
           padding: const EdgeInsets.only(right: 0),
           child: Stack(
             //mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: <Widget>[
               Align(
                 alignment: Alignment.centerLeft,
                 child: Container(
                 child: Text(_selectedAvailment == null ? 'Type of Availment' :'$_selectedAvailment', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 16.5)
              ),
             )
           ),
           Align(
             alignment: Alignment.centerRight,
             child: Container(
               child: Icon(
                 Icons.keyboard_arrow_down,
                 color: Colors.black,)
             )
           )
         ],
       ),
     ),
   );


    return MenuButton(
      child: button,
      items: dropDownItems,
      topDivider: true,
      crossTheEdge: true,
      scrollPhysics: AlwaysScrollableScrollPhysics(),
      dontShowTheSameItemSelected: false,
      // Use edge margin when you want the menu button don't touch in the edges
      edgeMargin: 30,
      itemBuilder: (value) => Container(
        height: 40,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(left: 10),
        child: Align(
          alignment: Alignment.centerLeft,
            child: Container(
              child: Text(value, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600)
              ),
            )
        ),
      ),
      toggledChild: Container(
        color: Colors.white,
        child: button,
      ),
      divider: Container(
        height: 1,
        color: Colors.white,
      ),
      onItemSelected: (newValue) {
         setState(() {
              _selectedAvailment = newValue;
              _provider = '';
              _patient = '';
              _availDate = '';
              _complaintController.clear();
              _selectedDoctor = 'Select your Doctor';
              _procedures = '';
              _fileList.clear();
              if(_selectedAvailment == 'CONSULTATION'){
                procVis = false;
                docVis = true;
                _isAttachmentRequired = false;
              } else {
                procVis = true;
                docVis = false;
                _isAttachmentRequired = true;
              }
              availments.forEach((cat) {
                if(cat.description == _selectedAvailment)
                  _availment = cat.code;
              });
            });
            _appSessionCallback.pauseAppSession();
      },
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent),
        borderRadius: const BorderRadius.all(
          Radius.circular(3.0),
        ),
        color: Colors.white),
      onMenuButtonToggle: (isToggle) {
        print(isToggle);
      },
     );

    // return SizedBox(
    //   width: double.infinity,
    //   child: DropdownButtonHideUnderline(
    //     child: DropdownButton(
    //       hint: SizedBox(
    //           width: double.infinity,
    //           child: Text('Type of Availment', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.w600),)
    //       ),
    //       icon: Icon(Icons.keyboard_arrow_down),
    //       isExpanded: true,
    //       value: _selectedAvailment,
    //       onChanged: (newValue) {
    //         setState(() {
    //           _selectedAvailment = newValue;
    //           availments.forEach((cat) {
    //             if(cat.description == _selectedAvailment)
    //               _availment = cat.code;
    //             print(_availment);
    //           });
    //         });
    //         _appSessionCallback.pauseAppSession();
    //       },
    //       items: dropDownItems.map((value) => DropdownMenuItem(
    //         child: SizedBox(
    //           width: double.infinity, // for example
    //           child: Text(value, textAlign: TextAlign.start, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0, color: Colors.black54),),
    //         ),
    //         value: value,
    //       )).toList(),
    //     ),
    //   ),
    // );

  }

  Widget _getPatientDropdown(List<Dependent> dependents, bool hasDependent){
    List<String> dropDownItems = [];
    dropDownItems.add('${widget.member.firstName} ${widget.member.lastName}');
    if(hasDependent) {
      dependents.forEach((dep) {
        String name = '${dep.firstName} ${dep.lastName}';
        dropDownItems.add((name));
      });
    }
     final Widget button = SizedBox(
         width: _width,
         height: 40,
         child: Padding(
           padding: const EdgeInsets.only(right: 0),
           child: Stack(
             //mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: <Widget>[
               Align(
                 alignment: Alignment.centerLeft,
                 child: Container(
                 child: Text(_selectedPatient == null ? 'Choose patient name' :'$_selectedPatient', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 16.5)
              ),
             )
           ),
           Align(
             alignment: Alignment.centerRight,
             child: Container(
               child: Icon(
                 Icons.keyboard_arrow_down,
                 color: Colors.black,)
             )
           )
         ],
       ),
     ),
   );


    return MenuButton(
      child: button,
      items: dropDownItems,
      topDivider: true,
      crossTheEdge: true,
      scrollPhysics: AlwaysScrollableScrollPhysics(),
      dontShowTheSameItemSelected: false,
      // Use edge margin when you want the menu button don't touch in the edges
      edgeMargin: 30,
      itemBuilder: (value) => Container(
        height: 40,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(left: 10),
        child: Align(
          alignment: Alignment.centerLeft,
            child: Container(
              child: Text(value, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600)
              ),
            )
        ),
      ),
      toggledChild: Container(
        color: Colors.white,
        child: button,
      ),
      divider: Container(
        height: 1,
        color: Colors.white,
      ),
      onItemSelected: (newValue) {
         setState(() {
              _selectedPatient = newValue;
              String member = '${widget.member.firstName} ${widget.member.lastName}';

              if (_selectedPatient == member){
                _patient = widget?.member.cardno;
                this._coverstartdt = widget?.member.coverstartdt;
                this._coverenddt = widget?.member.coverenddt;
                RequestLogPage.cardno_patient = widget.member.cardno;
                print(RequestLogPage.cardno_patient);
              } else {
                dependents.forEach((prov) {
                  String name = '${prov.firstName} ${prov.lastName}';
                  if(name == _selectedPatient){
                    _patient = prov.cardno;
                    this._coverstartdt = prov.coverstartdt;
                    this._coverenddt = prov.coverenddt;
                    RequestLogPage.cardno_patient = _patient;
                    print(RequestLogPage.cardno_patient);
                  }
                });
              }
            });
            _appSessionCallback.pauseAppSession();
      },
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent),
        borderRadius: const BorderRadius.all(
          Radius.circular(3.0),
        ),
        color: Colors.white),
      onMenuButtonToggle: (isToggle) {
        print(isToggle);
      },
     );

    
    // return SizedBox(
    //   width: double.infinity,
    //   child: DropdownButtonHideUnderline(
    //     child: DropdownButton(
    //       hint: SizedBox(
    //           width: double.infinity,
    //           child: Text('Choose Patient Name', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.w600),)
    //       ),
    //       icon: Icon(Icons.keyboard_arrow_down),
    //       isExpanded: true,
    //       value: _selectedPatient,
    //       onChanged: (newValue) {
    //         setState(() {
    //           _selectedPatient = newValue;
    //           dependents.forEach((prov) {
    //             String name = '${prov.firstName} ${prov.lastName}';
    //             if(name == _selectedPatient)
    //               _patient = prov.cardno;
    //             else if(name == '${widget.member.firstName} ${widget.member.lastName}')
    //               _patient = widget.member.cardno;
    //           });
    //           print(_patient);
    //         });
    //         _appSessionCallback.pauseAppSession();
    //       },
    //       items: dropDownItems.map((value) => DropdownMenuItem(
    //         child: SizedBox(
    //           width: double.infinity, // for example
    //           child: Text(value, textAlign: TextAlign.start, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0, color: Colors.black54),),
    //         ),
    //         value: value,
    //       )).toList(),
    //     ),
    //   ),
    // );

  }

  Widget _getProceduresDropdown(List<Procedure> procedures){
    List<String> dropDownItems = [];
    procedures.forEach((dep) {
      dropDownItems.add((dep.procDesc));
    });

  //   final Widget button = SizedBox(
  //        width: double.infinity,
  //        height: 40,
  //        child: Padding(
  //          padding: const EdgeInsets.only(right: 16),
  //          child: Stack(
  //            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //            children: <Widget>[
  //              Align(
  //                alignment: Alignment.center,
  //                child: Container(
  //                child: Text('Procedures', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)
  //             ),
  //            )
  //          ),
  //          Align(
  //            alignment: Alignment.centerRight,
  //            child: Container(
  //              child: Icon(
  //                Icons.keyboard_arrow_down,
  //                color: Colors.black,)
  //            )
  //          )
  //        ],
  //      ),
  //    ),
  //  );


  //   return MenuButton(
  //     child: button,
  //     items: dropDownItems,
  //     topDivider: true,
  //     crossTheEdge: true,
  //     scrollPhysics: AlwaysScrollableScrollPhysics(),
  //     dontShowTheSameItemSelected: false,
  //     // Use edge margin when you want the menu button don't touch in the edges
  //     edgeMargin: 12,
  //     itemBuilder: (value) => Container(
  //       height: 40,
  //       alignment: Alignment.centerLeft,
  //       padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16),
  //       child: Align(
  //         alignment: Alignment.center,
  //           child: Container(
  //             child: Text(value, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600)
  //             ),
  //           )
  //       ),
  //     ),
  //     toggledChild: Container(
  //       color: Colors.white,
  //       child: button,
  //     ),
  //     divider: Container(
  //       height: 1,
  //       color: Colors.white,
  //     ),
  //     onItemSelected: (newValue) {
  //        setState(() {
  //             _selectedProcedure = newValue;
  //             picks.add(newValue);
  //           });
  //           procedures.forEach((prov) {
  //             if(prov?.procDesc == _selectedProcedure)
  //               _procedures = prov?.procCode;
  //           });
  //           print(_procedures);
  //           _selectedProceduresList.add(_procedures);
  //           print(_selectedProceduresList);
  //           _appSessionCallback.pauseAppSession();
  //     },
  //     decoration: BoxDecoration(
  //       border: Border.all(color: Colors.transparent),
  //       borderRadius: const BorderRadius.all(
  //         Radius.circular(3.0),
  //       ),
  //       color: Colors.white),
  //     onMenuButtonToggle: (isToggle) {
  //       print(isToggle);
  //     },
  //    );

    return SizedBox(
      width: double.infinity,
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          hint: SizedBox(
              width: double.infinity,
              child: Text('Procedures', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.w600),)
          ),
          icon: Icon(Icons.add, color: Colors.green ),
          isExpanded: true,
          //value: _selectedProcedure,
          onChanged: (newValue) {
            setState(() {
              _selectedProcedure = newValue;
              picks.add(newValue);
            });
            procedures.forEach((prov) {
              if(prov?.procDesc == _selectedProcedure)
                _procedures = prov?.procCode;
            });
            print(_procedures);
            _selectedProceduresList.add(_procedures);
            print(_selectedProceduresList);
            _appSessionCallback.pauseAppSession();
          },
          items: dropDownItems.map((value) => DropdownMenuItem(
            child: SizedBox(
              width: double.infinity, // for example
              child: Text(value, textAlign: TextAlign.start, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0, color: Colors.black54),),
            ),
            value: value,
          )).toList(),
        ),
      )
    );
  }

  void _showLoadingDialog() {
    // set up the AlertDialog
    _loadingDialog = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))
      ),
      contentPadding: EdgeInsets.all(0.0),
      content: myLoadingIcon(height: 125, width: 20),
    );

    // show the dialog
    showDialog(
      context: mContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _loadingDialog;
      },
    );

  }

  void _closeAlert() {
    Navigator.pop(mContext);//it will close last route in your navigator
  }

  void _validateInputs() {
    setState(() {
      if (_formKey.currentState.validate()) {
        //_showLoadingDialog();
        _isInteractionDisabled = true;
        //If all data are correct then init onSave function in each TextFormField
        _formKey.currentState.save();
        print('success');
        // LogRequest request = LogRequest(
        //   availType: _availment,
        //   availDate: _availDate,
        //   username: _mUser.username,
        //   cardNo: _mUser.cardNo,
        //   providerCode: _provider,
        //   patient: _patient,
        //   complaint: _complaints,
        //   contactNo: _contactNo,
        //   doctors: _doctor,
        //   attachments: _fileList,
        //   procedures: _selectedProceduresList,
        // );
        // _mPresenter.sendLogRequest(request);
      } else {
        print('failed');
        //If all data are not valid then start auto validation.
        setState(() {
          _autoValidate = true;
        });
      }
    });
    _appSessionCallback.pauseAppSession();
  }

  _waitForProvider(BuildContext context) async {
    print('_waitForProvider');
    Provider result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FindProviderPage(isNeedingProviderFromRequestLog: true, appSessionCallback: _appSessionCallback,),
        ));

    if(result?.hospitalId != null) {
      setState(() {
        _selectedProvider = result.hospitalName;
        _provider = result.hospitalId;

        _mProcedure = _mPresenter.initProcedures(_mUser.cardNo, _provider);

        print('Provider: $_provider, $_selectedProvider ');
      });
    }
  }

  _waitForDoctor(BuildContext context) async {
    Doctor result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FindDoctorPage(isNeedingDoctorFromRequestLog: true, provider: _provider, appSessionCallback: _appSessionCallback,),
        ));

    if(result?.docId != null) {
      setState(() {
        _selectedDoctor = 'Dr. ${result.doctor}';
        _doctor = result.docId;
        _isRemoveDocVis = true;
        print('Provider: $_doctor, $_selectedDoctor');
      });
    }
  }

}
