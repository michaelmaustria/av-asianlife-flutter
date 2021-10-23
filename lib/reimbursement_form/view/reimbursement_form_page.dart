//import 'dart:html';
import 'dart:convert';
import 'dart:io';

import 'package:av_asian_life/claims/view/verify_file_claim_ip.dart';
import 'package:av_asian_life/claims/view/verify_file_claim_op.dart';
import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/api_token.dart';
import 'package:av_asian_life/data_manager/claims.dart';
import 'package:av_asian_life/data_manager/claims_request.dart';
import 'package:av_asian_life/data_manager/dependent.dart';
import 'package:av_asian_life/data_manager/member.dart';
import 'package:av_asian_life/data_manager/user.dart';
import 'package:av_asian_life/home_page/session_callback.dart';
import 'package:av_asian_life/reimbursement_form/presenter/reimbursement_claim_presenter.dart';
import 'package:av_asian_life/reimbursement_form/reimbursement_claim_contract.dart';
import 'package:av_asian_life/success_screen/succes_screen_page.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:menu_button/menu_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ReimbursementPage extends StatefulWidget {
  static String tag = 'claims-page';
  final Member member;
  final IApplicationSession appSessionCallback;

  ReimbursementPage({this.member, this.appSessionCallback});

  @override
  _ReimbursementPageState createState() => _ReimbursementPageState();
}

class _ReimbursementPageState extends State<ReimbursementPage> with AutomaticKeepAliveClientMixin<ReimbursementPage>
    implements IReimburseView {

  @override
  bool get wantKeepAlive => true;

  IReimbursePresenter _mPresenter = ReimbursePresenter();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyIn = GlobalKey<FormState>();
  final GlobalKey<FormState> _employedKey = GlobalKey<FormState>();
  final GlobalKey<FormState>  _consultedKey = GlobalKey<FormState>();
  final GlobalKey<FormState>  _injuryKey = GlobalKey<FormState>();
  final GlobalKey<FormState>  _insuranceKey = GlobalKey<FormState>();

  final GlobalKey<FormState> _gcashFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _remittanceFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _bankFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _bankFormKeyIn = GlobalKey<FormState>();

  Future<List<Claims>> _mReimbursement, _mGP;
  Future<List<Dependent>> _mDependent;

  List<File> _outfileList =[];
  List<File> _outClaimFormList =[];
  List<File>  _inClaimFormList =[];
  List<File> _inDoctorStatementsList = [];
  List<File> _inChargeSlipsList = [];
  List<File> _inOfficialRecieptsList = [];

  List<String> _outfileListStr = [];
  List<String>  _inClaimFormListStr =[];
  List<String> _outClaimFormListStr = [];
  List<String> _inChargeSlipsListStr = [];
  List<String> _inOfficialRecieptsListStr = [];
  List<String> _inDoctorStatementsListStr = [];
  List getBank;
  List getHospital;
  List getBankCodeStoreList = [''];
  List getBankNameStoreList = [''];
  List getPrincipalData = [];
  List patientInfo = [''];
  List hospName = [''];
  List hospCode = [''];
  List checkedItems = [''];
  List modeName = [''];
  List defaultBankCode = [''];
  List blockId = [''];

  BuildContext mContext;

  User _mUser;
  IApplicationSession _appSessionCallback;

  File outDoctorPrescriptionsAndReciepts, outClaimForm, inClaimForm, inDoctorStatements, inChargeSlips, inOfficialReciepts;

  String _fileName = ''; //_file;
  String urlPdfPath = "";
  String _employee, _patient;
  String _selectedEmployee, _selectedPatient;
  String _receiptAmount;
  String _birthday;
  String _injuryDate;
  String _consultationDate;
  String _age;
  String _complaints;
  String _examination;
  String _prescribedMedicines;
  String _finalDiagnosis;
  String  _acctNo;
  String _bank;
  String _bankName;
  String _selectedBankCode;
  String _selectedBlockId;
  String _selectedBankName;
  String _getBank;
  String _address;
  String _acctName;
  String _getPrincipalData;
  String _consultation;
  String _telephoneNo;
  String _mobileNo;
  String _email;
  String _claimantName;
  String _employer;
  String _occupation;
  String gender;
  String age;
  String empName;
  String _physicianIP;
  String _physicianAddressIP;
  String _previousDiagnosisIP;
  String _diagnosisIP;
  String _consultationDateIP;
  String _insuranceCompany;
  String _symptomsOccur;
  String _cardnoPatient = '';
  String _injuryDateIP;
  String _injuryWhatHappened;
  String _howHappened;
  String _patientInfo;
  String _certificateNo;
  String _dobPatient;
  String _relation;
  String _getHospital;
  String _selectedHospCode;
  String _selectedHospName;
  String _civilStatus;
  String _genderIP;
  String _attendingPhysicianIP;
  String _otherHosp;
  String _outMed;
  String _outLab;
  String _selectedPaymentMethod;

  bool outIsMale = false;
  bool outIsFemale = false;
  bool inIsMale = false;
  bool inIsFemale = false;
  bool isMarried = false;
  bool resideWithEnsuredIndividuals = false;
  bool insuredHospitalized = false;
  bool isEmployed = false;
  bool hasConsulted = false;
  bool _outFundAccDetails = false;
  bool _inFundAccDetails = false;
  bool patientCoveredByAnotherInsurance = false;
  bool injuryCheckbox = false;
  bool isHospOthers = false;
  bool outLabNotEmpty = false;
  bool outMedNotEmpty = false;
  bool isBankSelected = false;
  bool isMobileWalletVisible = false;
  bool isRemittanceVisible = false;
  bool certifyStatements = false;
  bool awareSubmitRecords = false;
  bool authorizePhysician = false;
  bool notBeenPaid = false;
  bool copiesTrue = false;
  bool copiesTrueIn = false;
  bool isEnabled = false;
  bool isEnabledIn = false;
  bool isUpper10k = false;
  bool isLower10k = true;
  bool certifyStatementsIn = false;
  bool awareSubmitRecordsIn = false;
  bool authorizePhysicianIn = false;
  bool notBeenPaidIn = false;
  bool isUpper10kIn = false;
  bool isLower10kIn = true;
  bool isFirst = true;

  int validatedItems = 0;
  int itemsChecked = 0;

  var cdTextController = new TextEditingController();
  var dobTextController = new TextEditingController();
  var injTextController = new TextEditingController();
  var ageController = new TextEditingController();
  var empNameController = new TextEditingController();
  var employerController = new TextEditingController();
  var occupationController = new TextEditingController();
  var consultationController = new TextEditingController();
  var diagnosisController = new TextEditingController();
  var physicianNameController = new TextEditingController();
  var physicianAddressController = new TextEditingController();
  var insuranceCompanyController = new TextEditingController();
  var symptomsOccurController = new TextEditingController();
  var certNoController = new TextEditingController();
  var relationController = new TextEditingController();
  var injuryDateController = new TextEditingController();
  var civilStatusController = new TextEditingController();
  var otherHospController = new TextEditingController();
  var outMedAmountController  = new TextEditingController();
  var outLabController  = new TextEditingController();
  var mobileWalletController = new TextEditingController();
  var mobileWalletNameController = new TextEditingController();
  var remittanceContactNoController = new TextEditingController();
  var remittanceNameController = new TextEditingController();
  var remittanceAddressController = new TextEditingController();
  var acctnoController = new TextEditingController();
  var acctnameController = new TextEditingController();
  var acctaddressController = new TextEditingController();
  var addAmountControllerOut = new TextEditingController();
  var addAmountControllerIn = new TextEditingController();

  String selectedDateText = '';
  DateTime _date;

  double _width;

  @override
  void initState() {
    super.initState();
    getBanks();
    getHospitals();
    getPaymentTypes();
    _mPresenter.onAttach(this);
    _appSessionCallback = widget.appSessionCallback;

    _getUser().then((_){
      setState(() {
        _mDependent = _mPresenter.initDependentsInfo(_mUser.cardNo);
      });
    });

  }

  Future getHospitals() async {
    dynamic data = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    var response = await http.post(
      Uri.encodeFull('${_base_url}GetProviderList'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        "UserAccount": _email
      },
      body: {
        "userid" : _api_user,
        "password" : _api_pass
      }
    );
    data = json.decode(response.body);
    _getHospital = data;
    setState((){
      getHospital = json.decode(_getHospital);
    });

    for(var i = 0; i < getHospital.length; i++){
      hospCode.add(getHospital[i]['hospcode']);
      hospName.add(getHospital[i]['hospname']);
    }
    return data;
  }

  Future getBanks() async {
    dynamic data = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    var response = await http.post(
      Uri.encodeFull('${_base_url}GetBanks'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        "UserAccount": _email
      },
      body: {
        "userid" : _api_user,
        "password" : _api_pass
      }
    );

    data = json.decode(response.body);
    _getBank = data;
    setState(() {
      getBank = json.decode(_getBank);
    });
    for(var i = 0; i < getBank.length; i++){
      getBankCodeStoreList.add(getBank[i]['bnkcode']);
      getBankNameStoreList.add(getBank[i]['bnkname']);
    }
    return data;
  }

  Future getPaymentTypes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    String _modename;
    String _defaultbankcode;
    String _blockid;

    var response = await http.post(
      Uri.encodeFull('${_base_url}GetPaymentTypes'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        "UserAccount": _email
      },
      body: {
        "userid" : _api_user,
        "password" : _api_pass
      }
    );

    var json = jsonDecode(jsonDecode(response.body));

    json.forEach((entity) {
      _modename = entity['modename'];
      _defaultbankcode = entity['defaultbankcode'];
      _blockid = entity['blockid'].toString();

      modeName.add(_modename);
      defaultBankCode.add(_defaultbankcode);
      blockId.add(_blockid);
    });
  }

  Future<Null> _getUser() async {
    _mUser = await _mPresenter.getUserData();
    print('User: ${_mUser.cardNo}');
  }

  void showMessageDialog(BuildContext context, String errMsg){
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        elevation: 5,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))
        ),
        title: new Text(""),
        content: new Text(errMsg,textAlign: TextAlign.center),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      )
    );
  }

  @override
  void onError(String message) {
    // TODO: implement onError
  }

  @override
  void onSuccess(String message) {
    // TODO: implement onSuccess
  }

  Future<File> getFileFromUrl (String url) async {
    try{
      var data = await http.get(url);
      var bytes = data.bodyBytes;
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/mypdfonline.pdf");

      File urlFile = await file.writeAsBytes(bytes);
      return urlFile;
    }catch(e){
      throw Exception("Error getting the pdf from the url");
    }
  }

  Future outGetImage(ImageSource source) async {
    ImagePicker.pickImage(source: source, imageQuality: 85).then((File file) async {

      Directory tempDir = await getTemporaryDirectory();

      String newName = '${widget.member.cardno}_${DateTime.now().millisecondsSinceEpoch}.${extension(file.path)}';

      File newFile = await file.copy('${tempDir.path}/$newName');

      print('${newFile.path}');

      setState(() {
        if(file != null) {
          outDoctorPrescriptionsAndReciepts = newFile;
          _fileName = basename(file.path);

          _outfileList.add(outDoctorPrescriptionsAndReciepts);
          _outfileListStr.add(_fileName);
        }
      });
    });

  }

  Future outGetClaimFormImage(ImageSource source) async {
    ImagePicker.pickImage(source: source, imageQuality: 85).then((File file) async {

      Directory tempDir = await getTemporaryDirectory();

      String newName = '${widget.member.cardno}_${DateTime.now().millisecondsSinceEpoch}.${extension(file.path)}';

      File newFile = await file.copy('${tempDir.path}/$newName');

      print('${newFile.path}');

      setState(() {
        if(file != null) {
          outClaimForm = newFile;
          _fileName = basename(file.path);

          _outClaimFormList.add(outClaimForm);
          _outClaimFormListStr.add(_fileName);
        }
      });
    });

  }

  Future outGetFile(FileType type) async {
    FilePicker.getFilePath(type: type).then((String path) async {

      Directory tempDir = await getTemporaryDirectory();

      File file = File(path);

      String newName = '${widget.member.cardno}_${DateTime.now().millisecondsSinceEpoch}${extension(file.path)}';

      File newFile = await File(path).copy('${tempDir.path}/$newName');

      print('${newFile.path}');

      setState(() {
        if(path != null) {
          print(newFile);
          outDoctorPrescriptionsAndReciepts = newFile;
          _fileName = basename(path);

          _outfileList.add(outDoctorPrescriptionsAndReciepts);
          _outfileListStr.add(_fileName);
        }
      });
    });
  }

  Future outGetClaimFormFile(FileType type) async {
    FilePicker.getFilePath(type: type).then((String path) async {

      Directory tempDir = await getTemporaryDirectory();

      File file = File(path);

      String newName = '${widget.member.cardno}_${DateTime.now().millisecondsSinceEpoch}${extension(file.path)}';

      File newFile = await File(path).copy('${tempDir.path}/$newName');

      print('${newFile.path}');

      setState(() {
        if(path != null) {
          print(newFile);
          outClaimForm = newFile;
          _fileName = basename(path);

          _outClaimFormList.add(outClaimForm);
          _outClaimFormListStr.add(_fileName);
        }
      });
    });
  }

  Future inGetImage(ImageSource source, String uploadTo) async {
    ImagePicker.pickImage(source: source, imageQuality: 85).then((File file) async {

      Directory tempDir = await getTemporaryDirectory();

      String newName = '${widget.member.cardno}_${DateTime.now().millisecondsSinceEpoch}.${extension(file.path)}';

      File newFile = await file.copy('${tempDir.path}/$newName');

      print('${newFile.path}');

      setState(() {
        if(file != null) {

          if(uploadTo == 'doctorStatements'){

            inDoctorStatements = newFile;
            _fileName = basename(file.path);

            _inDoctorStatementsList.add(inDoctorStatements);
            _inDoctorStatementsListStr.add(_fileName);

          }else if(uploadTo == 'chargeSlips'){

            inChargeSlips = newFile;
            _fileName = basename(file.path);

            _inChargeSlipsList.add(inChargeSlips);
            _inChargeSlipsListStr.add(_fileName);

          }else if(uploadTo == 'claimForm'){

            inClaimForm = newFile;
            _fileName = basename(file.path);

            _inClaimFormList.add(inClaimForm);
            _inClaimFormListStr.add(_fileName);

          }else{
            inOfficialReciepts = newFile;
            _fileName = basename(file.path);

            _inOfficialRecieptsList.add(inOfficialReciepts);
            _inOfficialRecieptsListStr.add(_fileName);
          }
        }
      });
    });

  }

  Future inGetFile(FileType type, String uploadT0) async {
    FilePicker.getFilePath(type: type).then((String path) async {

      Directory tempDir = await getTemporaryDirectory();

      File file = File(path);

      String newName = '${DateTime.now().millisecondsSinceEpoch}${extension(file.path)}';

      File newFile = await File(path).copy('${tempDir.path}/$newName');

      print('${newFile.path}');

      setState(() {
        if(path != null) {

          if(uploadT0 == 'doctorStatements'){

            inDoctorStatements = newFile;
            _fileName = basename(path);

            _inDoctorStatementsList.add(inDoctorStatements);
            _inDoctorStatementsListStr.add(_fileName);

          }else if(uploadT0 == 'chargeSlips'){

            inChargeSlips = newFile;
            _fileName = basename(path);

            _inChargeSlipsList.add(inChargeSlips);
            _inChargeSlipsListStr.add(_fileName);

          }else if(uploadT0 == 'claimForm'){

            inClaimForm = newFile;
            _fileName = basename(file.path);

            _inClaimFormList.add(inClaimForm);
            _inClaimFormListStr.add(_fileName);

          }else{
            inOfficialReciepts = newFile;
            _fileName = basename(path);

            _inOfficialRecieptsList.add(inOfficialReciepts);
            _inOfficialRecieptsListStr.add(_fileName);
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    mContext = context;
    final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text('Claims'),
        flexibleSpace: Image(
          image:  AssetImage('assets/images/appBar_background.png'),
          fit: BoxFit.fill,),
        centerTitle: true,
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
                    _getOUTReimbursementBody(),
                    _getINReimbursementBody()
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Widget _getOUTReimbursementBody(){
    return LayoutBuilder(
      builder: (context, constraint) {
        final height = constraint.maxHeight;
        final width = constraint.maxWidth;
        _width = constraint.maxWidth;
        return Column(
            children: <Widget>[
              Container(
                    height: height * 9 / 9.5,
                    child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 15),
                            Form(
                              key: _formKey,
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(height: 15),
                                    Container(
                                        width: width * .9,
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: <Widget>[
                                              Row(children:<Widget>[Text('*',style:TextStyle(color: Colors.red), textAlign: TextAlign.left),Text('Name Of The Patient:', textAlign: TextAlign.left)]),
                                              SizedBox(height: 5),
                                              Card(
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(side: BorderSide(color: Colors.black38)),
                                                  child: Container(
                                                    padding: EdgeInsets.only(left: 10),
                                                    child: FutureBuilder<List<Dependent>>(
                                                      future: _mDependent,
                                                      builder: (BuildContext context, AsyncSnapshot<List<Dependent>> snapshot){
                                                        if(!snapshot.hasData) {
                                                          //print('dependents: ${snapshot.data}');
                                                          return _dropDownDisabledHolder('Choose Patient Name');
                                                        }else{
                                                          //print('dependents: ${snapshot.data[0].message}');
                                                          if(snapshot.data[0].message != 'No Dependent')
                                                            return _getPatientDropdown(snapshot.data, true);
                                                          else
                                                            return _getPatientDropdown(snapshot.data, false);
                                                        }
                                                      },
                                                    ),
                                                  )
                                              ),
                                            ]
                                        )
                                    ),
                                    SizedBox(height: 15),
                                    Container(
                                      width: width * .9,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: <Widget>[
                                          Row(
                                              children:<Widget>[
                                                Text('*',style: TextStyle(color: Colors.redAccent)),
                                                Text('Clinic/Hospital: ', textAlign: TextAlign.left)
                                              ]
                                          ),
                                          SizedBox(height: 5),
                                          Card(
                                            elevation: 1,
                                            borderOnForeground: false,
                                            child: Autocomplete(
                                              optionsBuilder: (TextEditingValue value) {
                                                if (value.text.isEmpty) {
                                                  _selectedHospCode = '';
                                                  return [];
                                                }
                                                return hospName.where((suggestion) => suggestion
                                                    .toLowerCase()
                                                    .contains(value.text.toLowerCase()));
                                              },
                                              onSelected: (value) {
                                                setState(() {
                                                  int index = hospName.indexOf(value);
                                                  _selectedHospCode = hospCode[index].toString();
                                                  _selectedHospCode == 'OTH' ? isHospOthers = true : isHospOthers = false ;
                                                  isHospOthers == false ? otherHospController.clear() : otherHospController.text = otherHospController.text;
                                                  _selectedHospName = value;
                                                });
                                              },
                                            ),
                                          ),
                                        ]
                                      ),
                                    ),
                                    // SizedBox(height: 15),
                                    // Container(
                                    //     width: width * .9,
                                    //     child: Column(
                                    //         crossAxisAlignment: CrossAxisAlignment.stretch,
                                    //         children: <Widget>[
                                    //           Text('Name of the Hospital', textAlign: TextAlign.left),
                                    //           SizedBox(height: 5),
                                    //           Card(
                                    //               elevation: 3,
                                    //               child: Container(
                                    //                 padding: EdgeInsets.only(left: 10),
                                    //                 child: DropdownButtonHideUnderline(
                                    //                   child: new DropdownButton<String>(
                                    //                       isExpanded: true,
                                    //                       hint: new Text('--Select Hospital--'),
                                    //                       value: _selectedHospCode,
                                    //                       onChanged: (String newValue) {
                                    //                         setState(() {
                                    //                           _selectedHospCode = newValue;
                                    //                           _selectedHospCode == 'OTH' ? isHospOthers = true : isHospOthers = false ;
                                    //                           isHospOthers == false ? otherHospController.clear() : otherHospController.text = otherHospController.text;
                                    //                         });
                                    //                         print (_selectedHospCode);
                                    //                       },
                                    //                       items: hospCode.map((bankCode){
                                    //                         int index = hospCode.indexOf(bankCode);
                                    //                         index == 0 ? hospName[index] = '--Select Hospital--' : index = index;
                                    //                         return new DropdownMenuItem<String>(
                                    //                             value: bankCode.toString(),
                                    //                             child: Text(hospName[index])
                                    //                         );
                                    //                       }).toList()
                                    //                   ),
                                    //                 ),
                                    //               )
                                    //           )
                                    //         ]
                                    //     )
                                    // ),
                                    Visibility(
                                      visible: isHospOthers,
                                      child: Container(
                                          width: width * .9,
                                          child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: <Widget>[
                                                SizedBox(height: 15),
                                                Row(
                                                    children:<Widget>[
                                                      Text('*',style: TextStyle(color: Colors.redAccent)),
                                                      Text('Name of the Unlisted Hospital:', textAlign: TextAlign.left)
                                                    ]
                                                ),
                                                SizedBox(height: 5),
                                                Card(
                                                  elevation: 0,
                                                  child: TextFormField(
                                                    controller: otherHospController,
                                                    enabled: isHospOthers,
                                                    keyboardType: TextInputType.text,
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(),
                                                    ),
                                                    validator:(val){
                                                      if((val.isEmpty)&&((_selectedHospCode == 'OTH'))){
                                                        return "Please provide hospital";
                                                      }
                                                    },
                                                    onTap: () { _appSessionCallback.pauseAppSession(); },
                                                    onChanged: (String val) {
                                                      _otherHosp = val;
                                                    },
                                                  ),
                                                )
                                              ]
                                          )
                                      ),
                                    ),
                                    // SizedBox(height: 15),
                                    // Container(
                                    //     width: width * .9,
                                    //     child: Column(
                                    //         crossAxisAlignment: CrossAxisAlignment.stretch,
                                    //         children: <Widget>[
                                    //           SizedBox(height: 5),
                                    //           Row(
                                    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //             children: <Widget>[
                                    //               Text('Sex:', textAlign: TextAlign.left),
                                    //               Row(
                                    //                   children: <Widget>[
                                    //                     Stack(
                                    //                         children: <Widget>[
                                    //                           Container(
                                    //                             child: InkWell(
                                    //                               onTap: (){
                                    //                                 setState(() {
                                    //                                   // outIsMale = true;
                                    //                                   // if(outIsFemale = true){
                                    //                                   //   outIsFemale = false;
                                    //                                   // }
                                    //                                 });
                                    //                               },
                                    //                               child: CircleAvatar(
                                    //                                 radius: 15,
                                    //                                 backgroundColor: outIsMale == true ? mPrimaryColor : Colors.grey,
                                    //                                 child: CircleAvatar(
                                    //                                   radius: 13,
                                    //                                   backgroundColor:Colors.white,
                                    //                                   child: CircleAvatar(
                                    //                                       radius: 10,
                                    //                                       backgroundColor: outIsMale == true ? mPrimaryColor : Colors.grey),
                                    //                                 ),
                                    //                               ),
                                    //                             ),
                                    //                           ),
                                    //                         ]
                                    //                     ),
                                    //                     Text('  Male')
                                    //                   ]
                                    //               ),
                                    //               Row(
                                    //                   children: <Widget>[
                                    //                     Stack(
                                    //                         children: <Widget>[
                                    //                           Container(
                                    //                             child: InkWell(
                                    //                               onTap: (){
                                    //                                 setState(() {
                                    //                                   // outIsFemale = true;
                                    //                                   // if(outIsMale = true){
                                    //                                   //   outIsMale = false;
                                    //                                   // }
                                    //                                 });
                                    //                               },
                                    //                               child: CircleAvatar(
                                    //                                 radius: 15,
                                    //                                 backgroundColor: outIsFemale == true ? mPrimaryColor : Colors.grey,
                                    //                                 child: CircleAvatar(
                                    //                                   radius: 13,
                                    //                                   backgroundColor:Colors.white,
                                    //                                   child: CircleAvatar(
                                    //                                       radius: 10,
                                    //                                       backgroundColor: outIsFemale == true ? mPrimaryColor : Colors.grey),
                                    //                                 ),
                                    //                               ),
                                    //                             ),
                                    //                           ),
                                    //                         ]
                                    //                     ),
                                    //                     Text('  Female')
                                    //                   ]
                                    //               ),
                                    //               Text('  ')
                                    //             ],
                                    //           )
                                    //         ]
                                    //     )
                                    // ),
                                    // SizedBox(height: 15),
                                    // Container(
                                    //     width: width * .9,
                                    //     child: Column(
                                    //         crossAxisAlignment: CrossAxisAlignment.stretch,
                                    //         children: <Widget>[
                                    //           Text('Age:', textAlign: TextAlign.left),
                                    //           SizedBox(height: 5),
                                    //           Card(
                                    //             elevation: 0,
                                    //             child: TextFormField(
                                    //               enabled:false,
                                    //               controller: ageController,
                                    //               keyboardType: TextInputType.phone,
                                    //               decoration: InputDecoration(
                                    //                 border: OutlineInputBorder(),
                                    //               ),
                                    //               onTap: () { _appSessionCallback.pauseAppSession(); },
                                    //               onChanged: (String val) {
                                    //                 _age = val;
                                    //               },
                                    //             ),
                                    //           )
                                    //         ]
                                    //     )
                                    // ),
                                    SizedBox(height: 15),
                                    Container(
                                        width: width * .9,
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: <Widget>[
                                              Row(children:<Widget>[Text('*',style:TextStyle(color: Colors.red), textAlign: TextAlign.left),Text('Consultation/Availment Date:', textAlign: TextAlign.left)]),
                                              SizedBox(height: 5),
                                              Card(
                                                elevation: 0,
                                                child: TextFormField(
                                                  validator: (val){
                                                    if(val.isEmpty){
                                                      return "Please provide date";
                                                    }
                                                  },
                                                  keyboardType: TextInputType.text,
                                                  controller: cdTextController,
                                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[]'))],
                                                  decoration: InputDecoration(
                                                      border: OutlineInputBorder()
                                                  ),
                                                  //validator: _mPresenter.validateInputLength,
                                                  onChanged: (String val) {
                                                    var month = '${_date.month}'.length == 1 ? '0${_date.month}' : '${_date.month}';
                                                    var day = '${_date.day}'.length == 1 ? '0${_date.day}' : '${_date.day}';
                                                    _consultationDate = '${_date.year}$month$day';
                                                    cdTextController.text = selectedDateText;
                                                  },
                                                  onTap: (){
                                                    _datePicker(context,'consult');
                                                  },
                                                ),
                                              )
                                            ]
                                        )
                                    ),
                                    SizedBox(height: 15),
                                    Container(
                                        width: width * .9,
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: <Widget>[
                                              Row(children:<Widget>[Text('*',style:TextStyle(color: Colors.red), textAlign: TextAlign.left),Text('Total Amount Of Official Receipts:', textAlign: TextAlign.left)]),
                                              SizedBox(height: 5),
                                              Card(
                                                elevation: 0,
                                                child: Focus(
                                                  child: TextFormField(
                                                    controller: addAmountControllerOut,
                                                    keyboardType: TextInputType.number,
                                                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                                    //validator: _mPresenter.validatePhoneNumber,
                                                    decoration: InputDecoration(
                                                        border: OutlineInputBorder(),
                                                        hintText: 'PHP 0.00'
                                                    ),
                                                    onTap: () { _appSessionCallback.pauseAppSession(); },
                                                    validator: (val){
                                                      if(val.isEmpty){
                                                        return "Please provide receipt amount";
                                                      }
                                                    },
                                                    onChanged: (String value) {
                                                      String newValue = value.replaceAll(',', '').replaceAll('.', '');
                                                      if (value.isEmpty || newValue == '00') {
                                                        addAmountControllerOut.clear();
                                                        isFirst = true;
                                                        return;
                                                      }
                                                      double value1 = double.parse(newValue);
                                                      if (!isFirst) value1 = value1 * 100;
                                                      value = NumberFormat.currency(customPattern: '###,###.##').format(value1 / 100);
                                                      addAmountControllerOut.value = TextEditingValue(
                                                        text: value,
                                                        selection: TextSelection.collapsed(offset: value.length),
                                                      );
                                                      _receiptAmount = value;
                                                      double.parse(_receiptAmount.replaceAll(',', '')) > 10000.00 ? isUpper10k = true : isUpper10k = false;
                                                      double.parse(_receiptAmount.replaceAll(',', '')) <= 10000.00 ? isLower10k = true : isLower10k = false;
                                                    },
                                                  ),
                                                ),
                                              )
                                            ]
                                        )
                                    ),
                                    SizedBox(height: 15),
                                    // Container(
                                    //   width: width * .9,
                                    //   child: Column(
                                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //     children: <Widget>[
                                    //       Container(
                                    //           alignment: Alignment.centerLeft,
                                    //           padding: EdgeInsets.only(bottom: 5.0),
                                    //           child: Text('Complaints:', textAlign: TextAlign.left),
                                    //       ),
                                    //       Card(
                                    //         elevation: 0,
                                    //         child: TextFormField(
                                    //           // validator: (val){
                                    //           //   if(val.isEmpty){
                                    //           //     return "Please state your complaint";
                                    //           //   }
                                    //           // },
                                    //           keyboardType: TextInputType.multiline,
                                    //           maxLines: 6,
                                    //           decoration: InputDecoration(
                                    //             hintText: "....",
                                    //             border: OutlineInputBorder(
                                    //                 borderSide: BorderSide(color: Colors.black87)
                                    //             ),
                                    //           ),
                                    //           onTap: () { _appSessionCallback.pauseAppSession(); },
                                    //           onChanged: (String val) {
                                    //             _complaints = val;
                                    //           },
                                    //         ),
                                    //       )
                                    //     ],
                                    //   ),
                                    // ),
                                    // // SizedBox(height: 15),
                                    // // Container(
                                    // //     width: width * .9,
                                    // //     child: Column(
                                    // //         crossAxisAlignment: CrossAxisAlignment.stretch,
                                    // //         children: <Widget>[
                                    // //           Row(children:<Widget>[Text('*',style:TextStyle(color: Colors.red), textAlign: TextAlign.left),Text('Consultation:', textAlign: TextAlign.left)]),
                                    // //           SizedBox(height: 5),
                                    // //           Card(
                                    // //             elevation: 0,
                                    // //             child: TextFormField(
                                    // //               validator: (val){
                                    // //                 if((val.isEmpty) && ((_prescribedMedicines == null)||(_prescribedMedicines == '')) && ((_examination == null)||(_examination == ''))){
                                    // //                   return "Please provide consultation";
                                    // //                 }
                                    // //               },
                                    // //               keyboardType: TextInputType.text,
                                    // //               decoration: InputDecoration(
                                    // //                 border: OutlineInputBorder(),
                                    // //               ),
                                    // //               onTap: () { _appSessionCallback.pauseAppSession(); },
                                    // //               onChanged: (String val) {
                                    // //                 _consultation = val;
                                    // //               },
                                    // //             ),
                                    // //           )
                                    // //         ]
                                    // //     )
                                    // // ),
                                    // SizedBox(height: 15),
                                    // Container(
                                    //     width: width * .9,
                                    //     child: Column(
                                    //         crossAxisAlignment: CrossAxisAlignment.stretch,
                                    //         children: <Widget>[
                                    //           Row(
                                    //               children:<Widget>[
                                    //                 outMedNotEmpty == false ? Text('*',style:TextStyle(color: Colors.red), textAlign: TextAlign.left) : Text(''),
                                    //                 Text('Laboratory Examination:', textAlign: TextAlign.left),
                                    //                 SizedBox(width:width * .22),
                                    //                 outLabNotEmpty == true ? Text('*',style:TextStyle(color: Colors.red)):Text(''),
                                    //                 Text('Amount:')]),
                                    //           SizedBox(height: 5),
                                    //           Row(
                                    //             children: <Widget>[
                                    //               SizedBox(
                                    //                 width: width * .6,
                                    //                 child: Card(
                                    //                   elevation: 0,
                                    //                   child: TextFormField(
                                    //                     validator: (val){
                                    //                       if((val.isEmpty) && ((_prescribedMedicines == null)||(_prescribedMedicines == ''))){
                                    //                         return "Please provide laboratory examination";
                                    //                       }
                                    //                       // if((!val.isEmpty)&&(_outLab.isEmpty)){
                                    //                       //   return " ";
                                    //                       // }
                                    //                     },
                                    //                     keyboardType: TextInputType.text,
                                    //                     decoration: InputDecoration(
                                    //                       border: OutlineInputBorder(),
                                    //                     ),
                                    //                     onTap: () { _appSessionCallback.pauseAppSession(); },
                                    //                     onChanged: (String val) {
                                    //                       _examination = val;
                                    //                       setState((){
                                    //                         if(_examination.isEmpty){
                                    //                           outLabNotEmpty = false;
                                    //                           outLabController.clear();
                                    //                         } else {
                                    //                           outLabNotEmpty = true;
                                    //                         }
                                    //                       });
                                    //                     },
                                    //                   ),
                                    //                 ),
                                    //               ),
                                    //               SizedBox(
                                    //                 width: width * .3,
                                    //                 child: Card(
                                    //                   elevation: 0,
                                    //                   child: TextFormField(
                                    //                     enabled: outLabNotEmpty,
                                    //                     controller: outLabController,
                                    //                     validator: (val){
                                    //                       if(val.isEmpty && !_examination.isEmpty){
                                    //                         return "Amount";
                                    //                       }
                                    //                       // if(_examination.isEmpty){
                                    //                       //   return " ";
                                    //                       // }
                                    //                     },
                                    //                     inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                                    //                     keyboardType: TextInputType.phone,
                                    //                     decoration: InputDecoration(
                                    //                       border: OutlineInputBorder(),
                                    //                     ),
                                    //                     onTap: () { _appSessionCallback.pauseAppSession(); },
                                    //                     onChanged: (String val) {
                                    //                       _outLab = val;
                                    //                     },
                                    //                   ),
                                    //                 ),
                                    //               ),
                                    //             ],
                                    //           )
                                    //         ]
                                    //     )
                                    // ),
                                    // SizedBox(height: 15),
                                    // Container(
                                    //     width: width * .9,
                                    //     child: Column(
                                    //         crossAxisAlignment: CrossAxisAlignment.stretch,
                                    //         children: <Widget>[
                                    //           Row(
                                    //               children:<Widget>[
                                    //                 outLabNotEmpty == false ? Text('*',style:TextStyle(color: Colors.red), textAlign: TextAlign.left) : Text(''),
                                    //                 Text('Prescribed Medicine/s (If Applicable):', textAlign: TextAlign.left),
                                    //                 SizedBox(width:width * .02),
                                    //                 outMedNotEmpty == true ? Text('*',style:TextStyle(color: Colors.red), textAlign: TextAlign.left) : Text(''),
                                    //                 Text('Amount:')]),
                                    //           SizedBox(height: 5),
                                    //           Row(
                                    //             children: <Widget>[
                                    //               SizedBox(
                                    //                 width: width * .6,
                                    //                 child: Card(
                                    //                   elevation: 0,
                                    //                   child: TextFormField(
                                    //                     validator: (val){
                                    //                       if((val.isEmpty) && ((_examination == null)||(_examination == ''))){
                                    //                         return "Please provide prescribed medicines";
                                    //                       }
                                    //                       // if((!val.isEmpty)&&(_outMed.isEmpty)){
                                    //                       //   return " ";
                                    //                       // }
                                    //                     },
                                    //                     keyboardType: TextInputType.text,
                                    //                     decoration: InputDecoration(
                                    //                       border: OutlineInputBorder(),
                                    //                     ),
                                    //                     onTap: () { _appSessionCallback.pauseAppSession(); },
                                    //                     onChanged: (String val) {
                                    //                       _prescribedMedicines = val;
                                    //                       setState((){
                                    //                         if(_prescribedMedicines.isEmpty){
                                    //                           outMedNotEmpty = false;
                                    //                           outMedAmountController.clear();
                                    //                         } else {
                                    //                           outMedNotEmpty = true;
                                    //                         }
                                    //                       });
                                    //                     },
                                    //                   ),
                                    //                 )
                                    //               ),
                                    //               SizedBox(
                                    //                   width: width * .3,
                                    //                   child: Card(
                                    //                     elevation: 0,
                                    //                     child: TextFormField(
                                    //                       enabled: outMedNotEmpty,
                                    //                       controller: outMedAmountController,
                                    //                       validator: (val){
                                    //                         if(!_prescribedMedicines.isEmpty && val.isEmpty){
                                    //                           return "Amount";
                                    //                         }
                                    //                         // if(_prescribedMedicines.isEmpty){
                                    //                         //   return " ";
                                    //                         // }
                                    //                       },
                                    //                       inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                                    //                       keyboardType: TextInputType.phone,
                                    //                       decoration: InputDecoration(
                                    //                         border: OutlineInputBorder(),
                                    //                       ),
                                    //                       onTap: () { _appSessionCallback.pauseAppSession(); },
                                    //                       onChanged: (String val) {
                                    //                         _outMed = val;
                                    //                       },
                                    //                     ),
                                    //                   )
                                    //               ),
                                    //             ]
                                    //           ),
                                    //
                                    //         ]
                                    //     )
                                    // ),
                                    // SizedBox(height: 15),
                                    // Container(
                                    //   width: width * .9,
                                    //   child: Column(
                                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //     children: <Widget>[
                                    //       Container(
                                    //           alignment: Alignment.centerLeft,
                                    //           padding: EdgeInsets.only(bottom: 5.0),
                                    //           child: Row(children:<Widget>[Text('*',style:TextStyle(color: Colors.red), textAlign: TextAlign.left),Text('Final Diagnosis:', textAlign: TextAlign.left)]),
                                    //       ),
                                    //       Card(
                                    //         elevation: 0,
                                    //         child: TextFormField(
                                    //           validator:(val){
                                    //             if(val.isEmpty){
                                    //               return "Please provide final diagnosis";
                                    //             }
                                    //           },
                                    //           keyboardType: TextInputType.multiline,
                                    //           maxLines: 3,
                                    //           decoration: InputDecoration(
                                    //             border: OutlineInputBorder(
                                    //                 borderSide: BorderSide(color: Colors.black87)
                                    //             ),
                                    //           ),
                                    //           onTap: () { _appSessionCallback.pauseAppSession(); },
                                    //           onChanged: (String val) {
                                    //             _finalDiagnosis = val;
                                    //           },
                                    //         ),
                                    //       )
                                    //     ],
                                    //   ),
                                    // ),
                                  ],
                                )
                            ),
                            SizedBox(height: 15),
                            Container(
                              width: width * .9,
                              child: Text("Original Doctor's Prescriptions and Official Receipt (BIR registered)", textAlign: TextAlign.center, style: TextStyle(fontSize: 17),),
                            ),
                            SizedBox(height: 15),
                            Container(
                                width: width * .9,
                                child: _outfileList.length < 3 ? _outGetBrowseButton() : _disableBrowseButton()
                            ),
                            SizedBox(height: 10,),
                            _outfileList.length >= 1 ? Container(
                              width: width * .9,
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
                                                  Text('${_outfileListStr[0]}'),
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
                                                this._outfileList.removeWhere((item) => item == _outfileList[0]);
                                                this._outfileListStr.removeWhere((item) => item == _outfileListStr[0]);
                                                print(_outfileList);
                                                print(_outfileListStr);
                                              }
                                              );
                                            }
                                        )
                                    ),
                                  )
                                ],
                              ),
                            ) : Offstage(),
                            _outfileList.length >= 2 ? Container(
                              width: width * .9,
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
                                                  Text('${_outfileListStr[1]}'),
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
                                                this._outfileList.removeWhere((item) => item == _outfileList[1]);
                                                this._outfileListStr.removeWhere((item) => item == _outfileListStr[1]);
                                                print(_outfileList);
                                                print(_outfileListStr);
                                              }
                                              );
                                            }
                                        )
                                    ),
                                  )
                                ],
                              ),
                            ) : Offstage(),
                            _outfileListStr.length == 3 ? Container(
                              width: width * .9,
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
                                                  Text('${_outfileListStr[2]}'),
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
                                                this._outfileList.removeWhere((item) => item == _outfileList[2]);
                                                this._outfileListStr.removeWhere((item) => item == _outfileListStr[2]);
                                                print(_outfileList);
                                                print(_outfileListStr);
                                              }
                                              );
                                            }
                                        )
                                    ),
                                  )
                                ],
                              ),
                            ) : Offstage(),
                            SizedBox( height: 15),
                            Container(
                              width: width * .9,
                              child: Text("Signed Claim Form", textAlign: TextAlign.center, style: TextStyle(fontSize: 17),),
                            ),
                            SizedBox( height: 10),
                            Container(
                                width: width * .9,
                                child: _outClaimFormList.length < 3 ? _outGetBrowseClaimFormButton() : _disableBrowseButton()
                            ),
                            SizedBox(height: 10,),
                            _outClaimFormList.length >= 1 ? Container(
                              width: width * .9,
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
                                                  Text('${_outClaimFormListStr[0]}'),
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
                                                this._outClaimFormList.removeWhere((item) => item == _outClaimFormList[0]);
                                                this._outClaimFormListStr.removeWhere((item) => item == _outClaimFormListStr[0]);
                                                print(_outClaimFormList);
                                                print(_outClaimFormListStr);
                                              }
                                              );
                                            }
                                        )
                                    ),
                                  )
                                ],
                              ),
                            ) : Offstage(),
                            _outClaimFormList.length >= 2 ? Container(
                              width: width * .9,
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
                                                  Text('${_outClaimFormListStr[1]}'),
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
                                                this._outClaimFormList.removeWhere((item) => item == _outClaimFormList[1]);
                                                this._outClaimFormListStr.removeWhere((item) => item == _outClaimFormListStr[1]);
                                                print(_outClaimFormList);
                                                print(_outClaimFormListStr);
                                              }
                                              );
                                            }
                                        )
                                    ),
                                  )
                                ],
                              ),
                            ) : Offstage(),
                            _outClaimFormListStr.length == 3 ? Container(
                              width: width * .9,
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
                                                  Text('${_outClaimFormListStr[2]}'),
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
                                                this._outClaimFormList.removeWhere((item) => item == _outClaimFormList[2]);
                                                this._outClaimFormListStr.removeWhere((item) => item == _outClaimFormListStr[2]);
                                                print(_outClaimFormList);
                                                print(_outClaimFormListStr);
                                              }
                                              );
                                            }
                                        )
                                    ),
                                  )
                                ],
                              ),
                            ) : Offstage(),
                            SizedBox( height: 15),
                            Container(
                                width: width * .9,
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Row(children:<Widget>[Text('*',style:TextStyle(color: Colors.red), textAlign: TextAlign.left),Text('Payment Method:', textAlign: TextAlign.left)]),
                                      SizedBox(height: 5),
                                      Card(
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(side: BorderSide(color: Colors.black38)),
                                          child: Container(
                                              padding: EdgeInsets.fromLTRB(10, 0, 15, 0),
                                              child: DropdownButtonHideUnderline(
                                                child: new DropdownButton<String>(
                                                    isExpanded: true,
                                                    hint: new Text('--Select Payment Method--'),
                                                    value: _selectedPaymentMethod,
                                                    onChanged: (String newValue) {
                                                      setState(() {
                                                        _selectedPaymentMethod = newValue;
                                                        _selectedBlockId = blockId[modeName.indexOf(newValue)];
                                                        _selectedBankCode = defaultBankCode[modeName.indexOf(newValue)];

                                                        if(_selectedBlockId == '1'){
                                                          isBankSelected = true;
                                                          _outFundAccDetails = true;
                                                          mobileWalletController.clear();
                                                          mobileWalletNameController.clear();
                                                          remittanceNameController.clear();
                                                          remittanceAddressController.clear();
                                                          remittanceContactNoController.clear();
                                                        } else {
                                                          isBankSelected = false;
                                                          _outFundAccDetails = false;
                                                          mobileWalletController.clear();
                                                          mobileWalletNameController.clear();
                                                          remittanceNameController.clear();
                                                          remittanceAddressController.clear();
                                                          remittanceContactNoController.clear();
                                                        }

                                                        if(_selectedBlockId == '2'){
                                                          isMobileWalletVisible = true;
                                                          acctnoController.clear();
                                                          acctnameController.clear();
                                                          acctaddressController.clear();
                                                          remittanceNameController.clear();
                                                          remittanceAddressController.clear();
                                                          remittanceContactNoController.clear();
                                                        } else {
                                                          isMobileWalletVisible = false;
                                                          acctnoController.clear();
                                                          acctnameController.clear();
                                                          acctaddressController.clear();
                                                          remittanceNameController.clear();
                                                          remittanceAddressController.clear();
                                                          remittanceContactNoController.clear();
                                                        }

                                                        if(_selectedBlockId == '3'){
                                                          isRemittanceVisible = true;
                                                          acctnoController.clear();
                                                          acctnameController.clear();
                                                          acctaddressController.clear();
                                                          mobileWalletController.clear();
                                                          mobileWalletNameController.clear();
                                                        } else {
                                                          isRemittanceVisible = false;
                                                          acctnoController.clear();
                                                          acctnameController.clear();
                                                          acctaddressController.clear();
                                                          mobileWalletController.clear();
                                                          mobileWalletNameController.clear();
                                                          remittanceNameController.clear();
                                                          remittanceAddressController.clear();
                                                          remittanceContactNoController.clear();
                                                        }
                                                      });
                                                    },
                                                    items: modeName.map((pMethod){
                                                      return new DropdownMenuItem<String>(
                                                          value: pMethod.toString(),
                                                          child: Text(pMethod)
                                                      );
                                                    }).toList()
                                                ),
                                              )
                                          )
                                      ),
                                    ]
                                )
                            ),
                            SizedBox( height: isRemittanceVisible == true ? 15 : 0),
                            Container(
                                width: width * .9,
                                child: isRemittanceVisible == true ? Form(
                                  key: _remittanceFormKey,
                                  child: Column(
                                      children: <Widget>[
                                        Row(children:<Widget>[Text('*',style:TextStyle(color: Colors.red), textAlign: TextAlign.left),Text('Name:', textAlign: TextAlign.left)]),
                                        SizedBox(height: 5),
                                        Card(
                                          elevation: 0,
                                          child: TextFormField(
                                            validator: (val){
                                              if(val.isEmpty){
                                                return "Please provide your name.";
                                              }
                                            },
                                            keyboardType: TextInputType.text,
                                              controller: remittanceNameController,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                            ),
                                            onTap: () { _appSessionCallback.pauseAppSession(); },
                                            onChanged: (String val) {
                                              _acctName = val;
                                            },
                                          ),
                                        ),
                                        Row(children:<Widget>[Text('*',style:TextStyle(color: Colors.red), textAlign: TextAlign.left),Text('Address:', textAlign: TextAlign.left)]),
                                        SizedBox(height: 5),
                                        Card(
                                          elevation: 0,
                                          child: TextFormField(
                                            validator: (val){
                                              if(val.isEmpty){
                                                return "Please provide your address.";
                                              }
                                            },
                                            keyboardType: TextInputType.text,
                                            controller: remittanceAddressController,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                            ),
                                            onTap: () { _appSessionCallback.pauseAppSession(); },
                                            onChanged: (String val) {
                                              _address = val;
                                            },
                                          ),
                                        ),
                                        Row(children:<Widget>[Text('*',style:TextStyle(color: Colors.red), textAlign: TextAlign.left),Text('Contact Number:', textAlign: TextAlign.left)]),
                                        SizedBox(height: 5),
                                        Card(
                                          elevation: 0,
                                          child: TextFormField(
                                            validator: (val){
                                              if(val.isEmpty){
                                                return "Please provide your contact no.";
                                              }
                                            },
                                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                            keyboardType: TextInputType.phone,
                                            controller: remittanceContactNoController,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                            ),
                                            onTap: () { _appSessionCallback.pauseAppSession(); },
                                            onChanged: (String val) {
                                              _acctNo = val;
                                            },
                                          ),
                                        )
                                      ]
                                  ),
                                ) : Offstage()
                            ) ,
                            SizedBox( height: isMobileWalletVisible == true ? 15 : 0),
                            Container(
                                width: width * .9,
                                  child: isMobileWalletVisible == true ? Form(
                                    key: _gcashFormKey,
                                    child: Column(
                                        children: <Widget>[
                                            Row(children:<Widget>[Text('*',style:TextStyle(color: Colors.red), textAlign: TextAlign.left),Text('Account Name:', textAlign: TextAlign.left)]),
                                            SizedBox(height: 5),
                                            Card(
                                              elevation: 0,
                                              child: TextFormField(
                                                validator: (val){
                                                  if(val.isEmpty){
                                                    return "Please provide your account name.";
                                                  }
                                                },
                                                keyboardType: TextInputType.text,
                                                controller: mobileWalletNameController,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                ),
                                                onTap: () { _appSessionCallback.pauseAppSession(); },
                                                onChanged: (String val) {
                                                  _acctName = val;
                                                },
                                              ),
                                            ),
                                            Row(children:<Widget>[Text('*',style:TextStyle(color: Colors.red), textAlign: TextAlign.left),Text('Account Number:', textAlign: TextAlign.left)]),
                                            SizedBox(height: 5),
                                            Card(
                                              elevation: 0,
                                              child: TextFormField(
                                                validator: (val){
                                                  if(val.isEmpty){
                                                    return "Please provide your account no.";
                                                  }
                                                },
                                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                                keyboardType: TextInputType.phone,
                                                controller: mobileWalletController,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                ),
                                                onTap: () { _appSessionCallback.pauseAppSession(); },
                                                onChanged: (String val) {
                                                  _acctNo = val;
                                                },
                                              ),
                                            )
                                        ]
                                    ),
                                  ) : Offstage()
                            ) ,
                            SizedBox( height: isBankSelected == true ? 15 : 0),
                            Container(
                                width: width * .9,
                                child: isBankSelected == true ? Card(
                                    elevation: 2,
                                    child: Form(
                                      key: _bankFormKey,
                                      child: Column(
                                          children: <Widget>[
                                            // Row(
                                            //     children: <Widget>[
                                            //       Checkbox(
                                            //           value: _outFundAccDetails,
                                            //           activeColor: Colors.black,
                                            //           onChanged: (bool newValue){
                                            //             setState(() {
                                            //               _outFundAccDetails = newValue;
                                            //             });
                                            //           }
                                            //       ),
                                            //       Text('Add fund transfer account details'),
                                            //     ]
                                            // ),
                                            SizedBox( height: 15),
                                            Container(
                                                width: width * .8,
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    children: <Widget>[
                                                      Row(children:<Widget>[Text('*',style:TextStyle(color: Colors.red), textAlign: TextAlign.left),Text('Bank Account Number:', textAlign: TextAlign.left)]),
                                                      SizedBox(height: 5),
                                                      Card(
                                                        elevation: 0,
                                                        child: TextFormField(
                                                          validator: (val){
                                                            if(val.isEmpty){
                                                              return "Please provide your account no.";
                                                            }
                                                          },
                                                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                                          keyboardType: TextInputType.phone,
                                                          controller: acctnoController,
                                                          decoration: InputDecoration(
                                                            border: OutlineInputBorder(),
                                                          ),
                                                          onTap: () { _appSessionCallback.pauseAppSession(); },
                                                          onChanged: (String val) {
                                                            _acctNo = val;
                                                          },
                                                        ),
                                                      )
                                                    ]
                                                )
                                            ),
                                            SizedBox( height: 15),
                                            Container(
                                                width: width * .8,
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    children: <Widget>[
                                                      Row(children:<Widget>[Text('*',style:TextStyle(color: Colors.red), textAlign: TextAlign.left),Text('Account Name:', textAlign: TextAlign.left)]),
                                                      SizedBox(height: 5),
                                                      Card(
                                                        elevation: 0,
                                                        child: TextFormField(
                                                          validator: (val){
                                                            if(val.isEmpty){
                                                              return "Please provide your account name";
                                                            }
                                                          },
                                                          keyboardType: TextInputType.text,
                                                          controller: acctnameController,
                                                          decoration: InputDecoration(
                                                            border: OutlineInputBorder(),
                                                          ),
                                                          onTap: () { _appSessionCallback.pauseAppSession(); },
                                                          onChanged: (String val) {
                                                            _acctName = val;
                                                          },
                                                        ),
                                                      )
                                                    ]
                                                )
                                            ),
                                            SizedBox( height: 15),
                                            Container(
                                                width: width * .8,
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    children: <Widget>[
                                                      Row(children:<Widget>[Text('*',style:TextStyle(color: Colors.red), textAlign: TextAlign.left),Text('Bank Branch Address:', textAlign: TextAlign.left)]),
                                                      SizedBox(height: 5),
                                                      Card(
                                                        elevation: 0,
                                                        child: TextFormField(
                                                          validator: (val){
                                                            if(val.isEmpty){
                                                              return "Please provide your address";
                                                            }
                                                          },
                                                          keyboardType: TextInputType.text,
                                                          controller: acctaddressController,
                                                          decoration: InputDecoration(
                                                            border: OutlineInputBorder(),
                                                          ),
                                                          onTap: () { _appSessionCallback.pauseAppSession(); },
                                                          onChanged: (String val) {
                                                            _address = val;
                                                          },
                                                        ),
                                                      )
                                                    ]
                                                )
                                            ),
                                            SizedBox(height: 15),
                                            Container(
                                              width: width * .8,
                                              child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                                  children: <Widget>[
                                                    Row(
                                                        children:<Widget>[
                                                          Text('*',style: TextStyle(color: Colors.redAccent)),
                                                          Text('Bank:', textAlign: TextAlign.left)
                                                        ]
                                                    ),
                                                    SizedBox(height: 5),
                                                    Card(
                                                      elevation: 1,
                                                      borderOnForeground: false,
                                                      child: Autocomplete(
                                                        optionsBuilder: (TextEditingValue value) {
                                                          if (value.text.isEmpty) {
                                                            return [];
                                                          }
                                                          return getBankNameStoreList.where((suggestion) => suggestion
                                                              .toLowerCase()
                                                              .contains(value.text.toLowerCase()));
                                                        },
                                                        onSelected: (value) {
                                                          setState(() {
                                                            int index = getBankNameStoreList.indexOf(value);
                                                            _selectedBankCode = getBankCodeStoreList[index].toString();
                                                            _selectedBankName = value;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ]
                                              ),
                                            ),
                                            SizedBox( height: 15),
                                          ]
                                      ),
                                    )
                                ) : Offstage()
                            ),
                            SizedBox( height: 15,),
                            Container(
                              width: width *.9,
                              child: Card(
                                  elevation: 0,
                                  shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0), side: BorderSide(color: Colors.black)),
                                  child: Container(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Checkbox(
                                                value: certifyStatements,
                                                activeColor: Colors.black,
                                                onChanged: (bool value) {
                                                  setState(() {
                                                    certifyStatements = value;
                                                    if(copiesTrue == true && certifyStatements == true && awareSubmitRecords == true && authorizePhysician == true && notBeenPaid == true){
                                                      isEnabled = true;
                                                    } else {
                                                      isEnabled = false;
                                                    }
                                                  });
                                                },
                                              ),
                                              Flexible(child: Text('I hereby certify that foregoing statements, including any accompanying statements are, to the best of my knowledge and belief, true correct, and complete.')),
                                            ]
                                          ),
                                          SizedBox(height: 10.0),
                                          Visibility(
                                            visible: isUpper10k,
                                            child: Row(
                                                children: <Widget>[
                                                  Checkbox(
                                                    value: awareSubmitRecords,
                                                    activeColor: Colors.black,
                                                    onChanged: (bool value) {
                                                      setState(() {
                                                        awareSubmitRecords = value;
                                                        if(copiesTrue == true && certifyStatements == true && awareSubmitRecords == true && authorizePhysician == true && notBeenPaid == true){
                                                          isEnabled = true;
                                                        } else {
                                                          isEnabled = false;
                                                        }
                                                      });
                                                    },
                                                  ),
                                                  Flexible(child: Text('I am aware that I am required to submit all records, original receipts, and other supporting documents to Etiqa’s Head Office within 30 days.')),
                                                ]
                                            ),
                                          ),
                                          Visibility(
                                            visible: isLower10k,
                                            child: Row(
                                                children: <Widget>[
                                                  Checkbox(
                                                    value: awareSubmitRecords,
                                                    activeColor: Colors.black,
                                                    onChanged: (bool value) {
                                                      setState(() {
                                                        awareSubmitRecords = value;
                                                        if(copiesTrue == true && certifyStatements == true && awareSubmitRecords == true && authorizePhysician == true && notBeenPaid == true){
                                                          isEnabled = true;
                                                        } else {
                                                          isEnabled = false;
                                                        }
                                                      });
                                                    },
                                                  ),
                                                  Flexible(child: Text('I am aware that I am required to keep all records, original receipts, and other supporting documents in relation to this claim for a period of ten (10) years.')),
                                                ]
                                            ),
                                          ),
                                          SizedBox(height: 10.0),
                                          Row(
                                              children: <Widget>[
                                                Checkbox(
                                                  value: authorizePhysician,
                                                  activeColor: Colors.black,
                                                  onChanged: (bool value) {
                                                    setState(() {
                                                      authorizePhysician = value;
                                                      if(copiesTrue == true && certifyStatements == true && awareSubmitRecords == true && authorizePhysician == true && notBeenPaid == true){
                                                        isEnabled = true;
                                                      } else {
                                                        isEnabled = false;
                                                      }
                                                    });
                                                  },
                                                ),
                                                Flexible(child: Text('I hereby authorize any physician to furnish and disclose all known facts concerning this disability to Etiqa Philippines or to its authorized representative.')),
                                              ]
                                          ),
                                          SizedBox(height: 10.0),
                                          Row(
                                              children: <Widget>[
                                                Checkbox(
                                                  value: notBeenPaid,
                                                  activeColor: Colors.black,
                                                  onChanged: (bool value) {
                                                    setState(() {
                                                      notBeenPaid = value;
                                                      if(copiesTrue == true && certifyStatements == true && awareSubmitRecords == true && authorizePhysician == true && notBeenPaid == true){
                                                        isEnabled = true;
                                                      } else {
                                                        isEnabled = false;
                                                      }
                                                    });
                                                  },
                                                ),
                                                Flexible(child: Text('I certify that I have not been paid by or filed these claims with other health care providers.')),
                                              ]
                                          ),
                                          Row(
                                              children: <Widget>[
                                                Checkbox(
                                                  value: copiesTrue,
                                                  activeColor: Colors.black,
                                                  onChanged: (bool value) {
                                                    setState(() {
                                                      copiesTrue = value;
                                                      if(copiesTrue == true && certifyStatements == true && awareSubmitRecords == true && authorizePhysician == true && notBeenPaid == true){
                                                        isEnabled = true;
                                                      } else {
                                                        isEnabled = false;
                                                      }
                                                    });
                                                  },
                                                ),
                                                Flexible(child: Text('I certify that the scan copies are true and perfect copy of the original documents.')),
                                              ]
                                          )
                                        ],
                                    )
                                  )
                                ),
                              ),
                            SizedBox( height: 15),
                            RaisedButton(
                              color: mPrimaryColor,
                              padding: EdgeInsets.fromLTRB(40, 15, 40, 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: BorderSide(color: isEnabled == true ? mPrimaryColor : Colors.grey)),
                              onPressed: isEnabled == true ? () async {
                                SharedPreferences prefs = await SharedPreferences.getInstance();

                                var _errMsg = '';
                                var _username = prefs.getString('_username')??('');
                                var _fundTransfer;

                                _complaints = '-';
                                _examination = '-';
                                _outLab = '0';
                                _prescribedMedicines = '-';
                                _outMed = '0';
                                _finalDiagnosis = '-';


                                if(_outFundAccDetails == true)
                                  _fundTransfer = '1';
                                else
                                  _fundTransfer = '0';

                                ClaimRequest request = ClaimRequest(
                                    appUserId: _username == null ? _username = '' : _username = _username,
                                    cardNo: _patient == null ? _patient = '' : _patient = _patient,
                                    hospCode: _selectedHospCode == null ? _selectedHospCode = '' : _selectedHospCode = _selectedHospCode,
                                    otherHosp: _otherHosp == null ? _otherHosp = '' : _otherHosp = _otherHosp,
                                    claimAmount: _receiptAmount == null ? _receiptAmount = '' : _receiptAmount = _receiptAmount,
                                    availmentDate: selectedDateText == null ? selectedDateText = '' : selectedDateText = selectedDateText,
                                    complaints: _complaints == null ? _complaints = '' : _complaints = _complaints,
                                    remarksConsult: _consultation == null ? _consultation = '' : _consultation = _consultation,
                                    remarksLab: _examination == null ? _examination = '' : _examination = _examination,
                                    remarksMed: _prescribedMedicines == null ? _prescribedMedicines = '' : _prescribedMedicines = _prescribedMedicines,
                                    diagnosis: _finalDiagnosis == null ? _finalDiagnosis = '' : _finalDiagnosis = _finalDiagnosis,
                                    fundTransfer: _fundTransfer == null ? _fundTransfer = '' : _fundTransfer = _fundTransfer,
                                    bnkCode: _selectedBankCode == null ? _selectedBankCode = '' : _selectedBankCode = _selectedBankCode,
                                    acctNo: _acctNo == null ? _acctNo = '' : _acctNo = _acctNo,
                                    acctName: _acctName == null ? _acctName = '' : _acctName = _acctName,
                                    acctAddress: _address == null ? _address = '' : _address = _address,
                                    amountLab: _outLab == null ? _outLab = '' : _outLab = _outLab,
                                    amountMed:_outMed == null? _outMed = '' : _outMed = _outMed,
                                    attachments: _outfileList,
                                    claimForm: _outClaimFormList
                                );

                                if((_selectedPaymentMethod == '')||(_selectedPaymentMethod == null)){
                                  _errMsg += "\nPlease select payment method";
                                  showMessageDialog(context,_errMsg);
                                } else {
                                  if(_selectedBlockId == '1'){
                                    if(((_selectedHospCode == '')||(_selectedHospCode == null))||(_selectedBankCode == null )|| (_selectedBankCode == '')||
                                        (_outfileList.length == 0)||(_selectedPatient == null)||(_outClaimFormList.length == 0)){

                                      if(_outfileList.length == 0)
                                        _errMsg += "\nPlease attach original doctor\'s prescriptions and receipt";

                                      if(_outClaimFormList.length == 0)
                                        _errMsg += "\nPlease attach signed claim form.";

                                      if((_selectedBankCode == null)||(_selectedBankCode == ''))
                                        _errMsg += "\nPlease select your bank.";

                                      if((_selectedPatient == null)||(_selectedPatient == ''))
                                        _errMsg += "\nPlease select a patient.";

                                      if((_selectedHospCode == '')||(_selectedHospCode == null))
                                        _errMsg += "\nPlease provide hospital.";

                                      _bankFormKey.currentState.validate() & _formKey.currentState.validate();
                                      showMessageDialog(context,_errMsg);
                                    } else {
                                      _bankFormKey.currentState.validate() & _formKey.currentState.validate() ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => VerifyClaimsOpPage(
                                                request: request,
                                                member: widget?.member,
                                            ),
                                          )
                                      ) : Scaffold.of(context).showSnackBar(SnackBar(content: Text('Please fill all the required fields.')));
                                    }
                                  } else if(_selectedBlockId == '2'){
                                    if((_outClaimFormList.length == 0)||(_outfileList.length == 0)||((_selectedPatient == null)||(_selectedPatient == ''))){

                                      if(_outfileList.length == 0)
                                        _errMsg += "\nPlease attach original doctor\'s prescriptions and receipt.";

                                      if(_outClaimFormList.length == 0)
                                        _errMsg += "\nPlease attach signed claim form.";

                                      if((_selectedPatient == null)||(_selectedPatient == ''))
                                        _errMsg += "\nPlease select a patient.";

                                      _formKey.currentState.validate();
                                      _gcashFormKey.currentState.validate();
                                      showMessageDialog(context,_errMsg);
                                    } else {
                                      _gcashFormKey.currentState.validate() & _formKey.currentState.validate() ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => VerifyClaimsOpPage(
                                                member: widget?.member,
                                                request: request
                                            ),
                                          )
                                      ) : Scaffold.of(context).showSnackBar(SnackBar(content: Text('Please fill all the required fields')));

                                    }
                                  } else {
                                    if((_outClaimFormList.length == 0)||(_outfileList.length == 0)||((_selectedPatient == null)||(_selectedPatient == ''))){

                                      if(_outfileList.length == 0)
                                        _errMsg += "\nPlease attach original doctor\'s prescriptions and receipt.";

                                      if(_outClaimFormList.length == 0)
                                        _errMsg += "\nPlease attach signed claim form.";

                                      if((_selectedPatient == null)||(_selectedPatient == ''))
                                        _errMsg += "\nPlease select a patient.";

                                      _formKey.currentState.validate();
                                      _remittanceFormKey.currentState.validate();
                                      showMessageDialog(context,_errMsg);
                                    } else {
                                      _remittanceFormKey.currentState.validate() & _formKey.currentState.validate() ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => VerifyClaimsOpPage(
                                                member: widget?.member,
                                                request: request
                                            ),
                                          )
                                      ) : Scaffold.of(context).showSnackBar(SnackBar(content: Text('Please fill all the required fields')));

                                    }
                                  }
                                }
                              } : null,
                              child: Text('Submit', style: TextStyle(fontSize: 17)),
                            ),
                            SizedBox( height: 30,),
                            copyRightText(),
                          ],
                        )
                    )
                ),
            ]
        );
      },
    );
  }

  Widget _getINReimbursementBody(){
    final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
    return GestureDetector(
      onDoubleTap: (){
        setState(() {
          notifier.value = Matrix4.identity();
        });
      },
      child: MatrixGestureDetector(
        onMatrixUpdate: (m, tm, sm ,rm){
          setState(() {
            notifier.value = m;
          });
        },
        child: AnimatedBuilder(
          animation: notifier,
          builder: (ctx, child){
            return Transform(
              transform: notifier.value,
              child: LayoutBuilder(
                builder: (context, constraint) {
                  final height = constraint.maxHeight;
                  final width = constraint.maxWidth;
                  return Column(
                      children: <Widget>[
                        Container(
                            height: height * 9 / 9.5,
                            child: SingleChildScrollView(
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(height: 15),
                                    Form(
                                      key:_formKeyIn,
                                      child: Column(
                                          children: <Widget>[
                                            Container(
                                                width: width * .9,
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    children: <Widget>[
                                                      SizedBox(height: 15),
                                                      Row(children:<Widget>[Text('*',style:TextStyle(color: Colors.red), textAlign: TextAlign.left),Text('Name Of The Patient:', textAlign: TextAlign.left)]),
                                                      SizedBox(height: 5),
                                                      Card(
                                                          elevation: 0,
                                                          shape: RoundedRectangleBorder(side: BorderSide(color: Colors.black38)),
                                                          child: Container(
                                                            padding: EdgeInsets.only(left: 10),
                                                            child: FutureBuilder<List<Dependent>>(
                                                              future: _mDependent,
                                                              builder: (BuildContext context, AsyncSnapshot<List<Dependent>> snapshot){
                                                                if(!snapshot.hasData) {
                                                                  print('dependents: ${snapshot.data}');
                                                                  return _dropDownDisabledHolder('Choose Patient Name');
                                                                }else{
                                                                  print('dependents: ${snapshot.data[0].message}');
                                                                  if(snapshot.data[0].message != 'No Dependent')
                                                                    return _getPatientDropdown(snapshot.data, true);
                                                                  else
                                                                    return _getPatientDropdown(snapshot.data, false);
                                                                }
                                                              },
                                                            ),
                                                          )
                                                      ),
                                                    ]
                                                )
                                            ),
                                            // Container(
                                            //   width: width * .9,
                                            //   child: Row(
                                            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            //       children: <Widget>[
                                            //         Text('  Resides With Insured Individuals?', textAlign: TextAlign.left),
                                            //         Switch(
                                            //           value: resideWithEnsuredIndividuals,
                                            //           onChanged: (value){
                                            //             setState(() {
                                            //               resideWithEnsuredIndividuals=value;
                                            //             });
                                            //           },
                                            //           activeTrackColor: mPrimaryColor,
                                            //         ),
                                            //       ]
                                            //   ),
                                            // ),
                                            // Container(
                                            //   width: width * .9,
                                            //   child: Row(
                                            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            //       children: <Widget>[
                                            //         Text('  Was The Insured Person Hospitalized?', textAlign: TextAlign.left),
                                            //         Switch(
                                            //           value: insuredHospitalized,
                                            //           onChanged: (value){
                                            //             setState(() {
                                            //               insuredHospitalized=value;
                                            //               print(insuredHospitalized);
                                            //             });
                                            //           },
                                            //           activeTrackColor: mPrimaryColor,
                                            //         ),
                                            //       ]
                                            //   ),
                                            // ),
                                            // SizedBox(height: 10),
                                            // Container(
                                            //     width: width * .9,
                                            //     child: Column(
                                            //         crossAxisAlignment: CrossAxisAlignment.stretch,
                                            //         children: <Widget>[
                                            //           Text('  When Was The Symptom Noticed?', textAlign: TextAlign.left),
                                            //           SizedBox(height: 5),
                                            //           Card(
                                            //             elevation: 0,
                                            //             child: TextFormField(
                                            //               // validator: (val){
                                            //               //   if(val.isEmpty){
                                            //               //     return 'Please provide symptoms occurence date.';
                                            //               //   }
                                            //               // },
                                            //               inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[]'))],
                                            //               controller: symptomsOccurController,
                                            //               decoration: InputDecoration(
                                            //                 border: OutlineInputBorder(),
                                            //               ),
                                            //               onChanged: (String val) {
                                            //                 var month = '${_date.month}'.length == 1 ? '0${_date.month}' : '${_date.month}';
                                            //                 var day = '${_date.day}'.length == 1 ? '0${_date.day}' : '${_date.day}';
                                            //                 _symptomsOccur = '${_date.year}$month$day';
                                            //                 symptomsOccurController.text = selectedDateText;
                                            //               },
                                            //               onTap: (){
                                            //                 _appSessionCallback.pauseAppSession();
                                            //                 _datePicker(context, 'symptomsOccur');
                                            //               },
                                            //             ),
                                            //           )
                                            //         ]
                                            //     )
                                            // ),
                                            // Container(
                                            //     width: width * .9,
                                            //     child: Column(
                                            //         crossAxisAlignment: CrossAxisAlignment.stretch,
                                            //         children: <Widget>[
                                            //           Text('Name of the Hospital', textAlign: TextAlign.left),
                                            //           SizedBox(height: 5),
                                            //           Card(
                                            //               elevation: 3,
                                            //               child: Container(
                                            //                 padding: EdgeInsets.only(left: 10),
                                            //                 child: DropdownButtonHideUnderline(
                                            //                   child: new DropdownButton<String>(
                                            //                       isExpanded: true,
                                            //                       hint: new Text('--Select Hospital--'),
                                            //                       value: _selectedHospCode,
                                            //                       onChanged: (String newValue) {
                                            //                         setState(() {
                                            //                           _selectedHospCode = newValue;
                                            //                           _selectedHospCode == 'OTH' ? isHospOthers = true : isHospOthers = false ;
                                            //                           isHospOthers == false ? otherHospController.clear() : otherHospController.text = otherHospController.text;
                                            //                         });
                                            //                         print (_selectedHospCode);
                                            //                       },
                                            //                       items: hospCode.map((bankCode){
                                            //                         int index = hospCode.indexOf(bankCode);
                                            //                         index == 0 ? hospName[index] = '--Select Hospital--' : index = index;
                                            //                         return new DropdownMenuItem<String>(
                                            //                             value: bankCode.toString(),
                                            //                             child: Text(hospName[index])
                                            //                         );
                                            //                       }).toList()
                                            //                   ),
                                            //                 ),
                                            //               )
                                            //           )
                                            //         ]
                                            //     )
                                            // ),
                                            SizedBox(height: 15),
                                            Container(
                                              width: width * .9,
                                              child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                                  children: <Widget>[
                                                    Row(
                                                        children:<Widget>[
                                                          Text('*',style: TextStyle(color: Colors.redAccent)),
                                                          Text('Hospital/Clinic:', textAlign: TextAlign.left)
                                                        ]
                                                    ),
                                                    SizedBox(height: 5),
                                                    Card(
                                                      elevation: 1,
                                                      borderOnForeground: false,
                                                      child: Autocomplete(
                                                        optionsBuilder: (TextEditingValue value) {
                                                          if (value.text.isEmpty) {
                                                            return [];
                                                          }
                                                          return hospName.where((suggestion) => suggestion
                                                              .toLowerCase()
                                                              .contains(value.text.toLowerCase()));
                                                        },
                                                        onSelected: (value) {
                                                          setState(() {
                                                            int index = hospName.indexOf(value);
                                                            _selectedHospCode = hospCode[index].toString();
                                                            _selectedHospCode == 'OTH' ? isHospOthers = true : isHospOthers = false ;
                                                            isHospOthers == false ? otherHospController.clear() : otherHospController.text = otherHospController.text;
                                                            _selectedHospName = value;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ]
                                              ),
                                            ),
                                            Visibility(
                                              visible: isHospOthers,
                                              child: Container(
                                                  width: width * .9,
                                                  child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                                      children: <Widget>[
                                                        SizedBox(height: 15),
                                                        Row(
                                                            children:<Widget>[
                                                              Text('*',style: TextStyle(color: Colors.redAccent)),
                                                              Text('Name of The Unlisted Hospital:', textAlign: TextAlign.left)
                                                            ]
                                                        ),
                                                        Card(
                                                          elevation: 0,
                                                          child: TextFormField(
                                                            controller: otherHospController,
                                                            enabled: isHospOthers,
                                                            keyboardType: TextInputType.text,
                                                            decoration: InputDecoration(
                                                              border: OutlineInputBorder(),
                                                            ),
                                                            validator:(val){
                                                              if((val.isEmpty)&&((_selectedHospCode == 'OTH'))){
                                                                return "Please provide hospital";
                                                              }
                                                            },
                                                            onTap: () { _appSessionCallback.pauseAppSession(); },
                                                            onChanged: (String val) {
                                                              _otherHosp = val;
                                                            },
                                                          ),
                                                        )
                                                      ]
                                                  )
                                              ),
                                            ),
                                            // SizedBox(height: 15),
                                            // Container(
                                            //     width: width * .9,
                                            //     child: Column(
                                            //         crossAxisAlignment: CrossAxisAlignment.stretch,
                                            //         children: <Widget>[
                                            //           Row(
                                            //               children:<Widget>[
                                            //                 Text('*',style: TextStyle(color: Colors.redAccent)),
                                            //                 Text('Name Of Attending Physician:', textAlign: TextAlign.left)
                                            //               ]
                                            //           ),
                                            //           SizedBox(height: 5),
                                            //           Card(
                                            //             elevation: 0,
                                            //             child: TextFormField(
                                            //               keyboardType: TextInputType.text,
                                            //               decoration: InputDecoration(
                                            //                 border: OutlineInputBorder(),
                                            //               ),
                                            //               validator:(val){
                                            //                 if(val.isEmpty){
                                            //                   return "Please provide physician";
                                            //                 }
                                            //               },
                                            //               onTap: () { _appSessionCallback.pauseAppSession(); },
                                            //               onChanged: (String val) {
                                            //                 _attendingPhysicianIP = val;
                                            //               },
                                            //             ),
                                            //           )
                                            //         ]
                                            //     )
                                            // ),
                                            SizedBox(height: 15),
                                            Container(
                                                width: width * .9,
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    children: <Widget>[
                                                      Row(
                                                          children:<Widget>[
                                                            Text('*',style: TextStyle(color: Colors.redAccent)),
                                                            Text('Date Of Injury:', textAlign: TextAlign.left)
                                                          ]
                                                      ),
                                                      SizedBox(height: 5),
                                                      Card(
                                                        elevation: 0,
                                                        child: TextFormField(
                                                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[]'))],
                                                          controller: injTextController,
                                                          decoration: InputDecoration(
                                                              border: OutlineInputBorder()
                                                          ),
                                                          validator:(val){
                                                            if(val.isEmpty){
                                                              return "Please provide injury date";
                                                            }
                                                          },
                                                          onSaved: (String val) {
                                                            var month = '${_date.month}'.length == 1 ? '0${_date.month}' : '${_date.month}';
                                                            var day = '${_date.day}'.length == 1 ? '0${_date.day}' : '${_date.day}';
                                                            _injuryDate = '${_date.year}$month$day';
                                                            injTextController.text = selectedDateText;
                                                          },
                                                          onTap: (){
                                                            _datePicker(context,'injury');
                                                          },
                                                        ),
                                                      )
                                                    ]
                                                )
                                            ),
                                            // SizedBox(height: 15),
                                            // Container(
                                            //     width: width * .9,
                                            //     child: Column(
                                            //         crossAxisAlignment: CrossAxisAlignment.stretch,
                                            //         children: <Widget>[
                                            //           Row(
                                            //               children:<Widget>[
                                            //                 Text('*',style: TextStyle(color: Colors.redAccent)),
                                            //                 Text('Diagnosis:', textAlign: TextAlign.left)
                                            //               ]
                                            //           ),
                                            //           SizedBox(height: 5),
                                            //           Card(
                                            //             elevation: 0,
                                            //             child: TextFormField(
                                            //               validator:(val){
                                            //                 if(val.isEmpty){
                                            //                   return 'Please provide diagnosis.';
                                            //                 }
                                            //               },
                                            //               keyboardType: TextInputType.text,
                                            //               decoration: InputDecoration(
                                            //                 border: OutlineInputBorder(),
                                            //               ),
                                            //               onTap: () { _appSessionCallback.pauseAppSession(); },
                                            //               onChanged: (String val) {
                                            //                 _previousDiagnosisIP = val;
                                            //               },
                                            //             ),
                                            //           )
                                            //         ]
                                            //     )
                                            // ),
                                            SizedBox(height: 15),
                                            Container(
                                                width: width * .9,
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    children: <Widget>[
                                                      Row(
                                                          children:<Widget>[
                                                            Text('*',style: TextStyle(color: Colors.redAccent)),
                                                            Text('Total Amount Of Receipt/s:', textAlign: TextAlign.left)
                                                          ]
                                                      ),
                                                      SizedBox(height: 5),
                                                      Card(
                                                        elevation: 0,
                                                        child: TextFormField(
                                                          controller: addAmountControllerIn,
                                                          keyboardType: TextInputType.number,
                                                          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                                          decoration: InputDecoration(
                                                              border: OutlineInputBorder(),
                                                              hintText: 'PHP 0.00'
                                                          ),
                                                          validator:(val){
                                                            if(val.isEmpty){
                                                              return "Please provide amount of receipt.";
                                                            }
                                                          },
                                                          onTap: () { _appSessionCallback.pauseAppSession(); },
                                                          onChanged: (String value) {
                                                            String newValue = value.replaceAll(',', '').replaceAll('.', '');
                                                            if (value.isEmpty || newValue == '00') {
                                                              addAmountControllerIn.clear();
                                                              isFirst = true;
                                                              return;
                                                            }
                                                            double value1 = double.parse(newValue);
                                                            if (!isFirst) value1 = value1 * 100;
                                                            value = NumberFormat.currency(customPattern: '###,###.##').format(value1 / 100);
                                                            addAmountControllerIn.value = TextEditingValue(
                                                              text: value,
                                                              selection: TextSelection.collapsed(offset: value.length),
                                                            );
                                                            _receiptAmount = value;
                                                            double.parse(_receiptAmount.replaceAll(',', '')) > 10000.00 ? isUpper10kIn = true : isUpper10kIn = false;
                                                            double.parse(_receiptAmount.replaceAll(',', '')) <= 10000.00 ? isLower10kIn = true : isLower10kIn = false;
                                                          },
                                                        ),
                                                      )
                                                    ]
                                                )
                                            ),
                                          ]
                                      ),
                                    ),
                                    // Form(
                                    //   key: _employedKey,
                                    //   child: Column(
                                    //     children: <Widget>[
                                    //       SizedBox(height: 15),
                                    //       Container(
                                    //           width: width * .9,
                                    //           child: Card(
                                    //             color: mPrimaryColor,
                                    //             elevation: 5,
                                    //             shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0), side: BorderSide(color: Colors.black38)),
                                    //             child: Row(
                                    //                 children: <Widget>[
                                    //                   Checkbox(
                                    //                       value: isEmployed,
                                    //                       activeColor: Colors.black,
                                    //                       onChanged: (bool newValue){
                                    //                         setState(() {
                                    //                           isEmployed = newValue;
                                    //                           if(isEmployed == false){
                                    //                             employerController.clear();
                                    //                             occupationController.clear();
                                    //                             checkedItems.remove(checkedItems[1]);
                                    //                           } else {
                                    //                             checkedItems.add('');
                                    //                           }
                                    //                         });
                                    //                       }
                                    //                   ),
                                    //                   //SizedBox(width: 20,),
                                    //                   Text('EMPLOYMENT')
                                    //                 ]),
                                    //           )
                                    //       ),
                                    //       SizedBox(height: isEmployed == true ? 10 : 0),
                                    //       Container(
                                    //           width: width * .9,
                                    //           child: isEmployed == true ? Column(
                                    //               crossAxisAlignment: CrossAxisAlignment.stretch,
                                    //               children: <Widget>[
                                    //                 Row(
                                    //                     children:<Widget>[
                                    //                       Text('*',style: TextStyle(color: Colors.redAccent)),
                                    //                       Text('Employer:', textAlign: TextAlign.left)
                                    //                     ]
                                    //                 ),
                                    //                 SizedBox(height: 5),
                                    //                 Card(
                                    //                   elevation: 0,
                                    //                   child: TextFormField(
                                    //                     validator:(val){
                                    //                       if((val.isEmpty)&&(isEmployed == true)){
                                    //                         return "Please provide employer";
                                    //                       }
                                    //                     },
                                    //                     controller: employerController,
                                    //                     enabled: isEmployed,
                                    //                     keyboardType: TextInputType.text,
                                    //                     decoration: InputDecoration(
                                    //                       border: OutlineInputBorder(),
                                    //                     ),
                                    //                     onTap: () { _appSessionCallback.pauseAppSession(); },
                                    //                     onSaved: (String val) {
                                    //                       _employer = val;
                                    //                     },
                                    //                   ),
                                    //                 )
                                    //               ]
                                    //           ) : Offstage()
                                    //       ),
                                    //       SizedBox(height: isEmployed == true ? 15 : 0),
                                    //       Container(
                                    //           width: width * .9,
                                    //           child: isEmployed == true ? Column(
                                    //               crossAxisAlignment: CrossAxisAlignment.stretch,
                                    //               children: <Widget>[
                                    //                 Row(
                                    //                     children:<Widget>[
                                    //                       Text('*',style: TextStyle(color: Colors.redAccent)),
                                    //                       Text('Occupation/Position:', textAlign: TextAlign.left)
                                    //                     ]
                                    //                 ),
                                    //                 SizedBox(height: 5),
                                    //                 Card(
                                    //                   elevation: 0,
                                    //                   child: TextFormField(
                                    //                     validator:(val){
                                    //                       if((val.isEmpty)&&(isEmployed == true)){
                                    //                         return "Please provide occupation";
                                    //                       }
                                    //                     },
                                    //                     controller: occupationController,
                                    //                     enabled: isEmployed,
                                    //                     keyboardType: TextInputType.text,
                                    //                     decoration: InputDecoration(
                                    //                       border: OutlineInputBorder(),
                                    //                     ),
                                    //                     onTap: () { _appSessionCallback.pauseAppSession(); },
                                    //                     onSaved: (String val) {
                                    //                       _occupation = val;
                                    //                     },
                                    //                   ),
                                    //                 )
                                    //               ]
                                    //           ) : Offstage()
                                    //       ),
                                    //     ],
                                    //   )
                                    // ),
                                    // Form(
                                    //   key: _consultedKey,
                                    //   child: Column(
                                    //     //add form here
                                    //       children:<Widget>[
                                    //         SizedBox(height: 15),
                                    //         Container(
                                    //             width: width * .9,
                                    //             child: Card(
                                    //               color: mPrimaryColor,
                                    //               elevation: 5,
                                    //               shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0), side: BorderSide(color: Colors.black38)),
                                    //               child: Row(
                                    //                   children: <Widget>[
                                    //                     Checkbox(
                                    //                         value: hasConsulted,
                                    //                         activeColor: Colors.black,
                                    //                         onChanged: (bool newValue){
                                    //                           setState(() {
                                    //                             hasConsulted = newValue;
                                    //                             if(hasConsulted == false){
                                    //                               consultationController.clear();
                                    //                               diagnosisController.clear();
                                    //                               physicianNameController.clear();
                                    //                               physicianAddressController.clear();
                                    //                               checkedItems.remove(checkedItems[1]);
                                    //                             } else {
                                    //                               checkedItems.add('');
                                    //                             }
                                    //                           });
                                    //                         }
                                    //                     ),
                                    //                     //SizedBox(width: 20,),
                                    //                     Text('PREVIOUS CONSULTATION')
                                    //                   ]),
                                    //             )
                                    //         ),
                                    //         SizedBox(height:15),
                                    //         Container(
                                    //             width: width * .9,
                                    //             child: hasConsulted == true ? Column(
                                    //                 crossAxisAlignment: CrossAxisAlignment.stretch,
                                    //                 children: <Widget>[
                                    //                   Row(
                                    //                       children:<Widget>[
                                    //                         Text('*',style: TextStyle(color: Colors.redAccent)),
                                    //                         Text('Consultation/Availment Date:', textAlign: TextAlign.left)
                                    //                       ]
                                    //                   ),
                                    //                   SizedBox(height: 5),
                                    //                   Card(
                                    //                     elevation: 0,
                                    //                     child: TextFormField(
                                    //                       validator: (val){
                                    //                         if((hasConsulted == true)&&((consultationController.text == null)||(consultationController.text == ''))){
                                    //                           return 'Please provide consultation date.';
                                    //                         }
                                    //                       },
                                    //                       inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[]'))],
                                    //                       controller: consultationController,
                                    //                       enabled: hasConsulted,
                                    //                       keyboardType: TextInputType.phone,
                                    //                       decoration: InputDecoration(
                                    //                         border: OutlineInputBorder(),
                                    //                       ),
                                    //                       onChanged: (String val) {
                                    //                         var month = '${_date.month}'.length == 1 ? '0${_date.month}' : '${_date.month}';
                                    //                         var day = '${_date.day}'.length == 1 ? '0${_date.day}' : '${_date.day}';
                                    //                         _consultationDateIP = '${_date.year}$month$day';
                                    //                         consultationController.text = selectedDateText;
                                    //                       },
                                    //                       onTap: (){
                                    //                         _appSessionCallback.pauseAppSession();
                                    //                         _datePicker(context, 'consultationDay');
                                    //                       },
                                    //                     ),
                                    //                   )
                                    //                 ]
                                    //             ) : Offstage()
                                    //         ),
                                    //         SizedBox(height: hasConsulted == true ? 15 : 0),
                                    //         Container(
                                    //             width: width * .9,
                                    //             child: hasConsulted == true ? Column(
                                    //                 crossAxisAlignment: CrossAxisAlignment.stretch,
                                    //                 children: <Widget>[
                                    //                   Row(
                                    //                       children:<Widget>[
                                    //                         Text('*',style: TextStyle(color: Colors.redAccent)),
                                    //                         Text('What Were The Findings/Diagnosis?', textAlign: TextAlign.left)
                                    //                       ]
                                    //                   ),
                                    //                   SizedBox(height: 5),
                                    //                   Card(
                                    //                     elevation: 0,
                                    //                     child: TextFormField(
                                    //                       validator:(val){
                                    //                         if((hasConsulted == true)&&(val.isEmpty)){
                                    //                           return 'Please provide diagnosis.';
                                    //                         }
                                    //                       },
                                    //                       controller: diagnosisController,
                                    //                       enabled: hasConsulted,
                                    //                       keyboardType: TextInputType.text,
                                    //                       decoration: InputDecoration(
                                    //                         border: OutlineInputBorder(),
                                    //                       ),
                                    //                       onTap: () { _appSessionCallback.pauseAppSession(); },
                                    //                       onChanged: (String val) {
                                    //                         _diagnosisIP = val;
                                    //                       },
                                    //                     ),
                                    //                   )
                                    //                 ]
                                    //             ) : Offstage()
                                    //         ),
                                    //         SizedBox(height: hasConsulted == true ? 15 : 0),
                                    //         Container(
                                    //             width: width * .9,
                                    //             child: hasConsulted == true ? Column(
                                    //                 crossAxisAlignment: CrossAxisAlignment.stretch,
                                    //                 children: <Widget>[
                                    //                   Row(
                                    //                       children:<Widget>[
                                    //                         Text('*',style: TextStyle(color: Colors.redAccent)),
                                    //                         Flexible(child: Text('Name Of The Physician/s You/Patient Have Consulted Prior To This Confinement:', maxLines: 2, textAlign: TextAlign.left))
                                    //                       ]
                                    //                   ),
                                    //                   SizedBox(height: 5),
                                    //                   Card(
                                    //                     elevation: 0,
                                    //                     child: TextFormField(
                                    //                       validator:(val){
                                    //                         if((hasConsulted == true)&&(val.isEmpty)){
                                    //                           return 'Please provide name of physician.';
                                    //                         }
                                    //                       },
                                    //                       controller: physicianNameController,
                                    //                       enabled: hasConsulted,
                                    //                       keyboardType: TextInputType.text,
                                    //                       decoration: InputDecoration(
                                    //                         border: OutlineInputBorder(),
                                    //                       ),
                                    //                       onTap: () { _appSessionCallback.pauseAppSession(); },
                                    //                       onChanged: (String val) {
                                    //                         _physicianIP = val;
                                    //                       },
                                    //                     ),
                                    //                   )
                                    //                 ]
                                    //             ) : Offstage()
                                    //         ),
                                    //         SizedBox(height: hasConsulted == true ?  15 : 0),
                                    //         Container(
                                    //             width: width * .9,
                                    //             child: hasConsulted == true ? Column(
                                    //                 crossAxisAlignment: CrossAxisAlignment.stretch,
                                    //                 children: <Widget>[
                                    //                   Row(
                                    //                       children:<Widget>[
                                    //                         Text('*',style: TextStyle(color: Colors.redAccent)),
                                    //                         Flexible(child: Text('Address Of The Physician You/Patient Has Consulted:', maxLines: 2, textAlign: TextAlign.left))
                                    //                       ]
                                    //                   ),
                                    //                   SizedBox(height: 5),
                                    //                   Card(
                                    //                     elevation: 0,
                                    //                     child: TextFormField(
                                    //                       validator:(val){
                                    //                         if((hasConsulted == true)&&(val.isEmpty)){
                                    //                           return 'Please provide physician\'s address.';
                                    //                         }
                                    //                       },
                                    //                       controller: physicianAddressController,
                                    //                       enabled: hasConsulted,
                                    //                       keyboardType: TextInputType.text,
                                    //                       decoration: InputDecoration(
                                    //                         border: OutlineInputBorder(),
                                    //                       ),
                                    //                       onTap: () { _appSessionCallback.pauseAppSession(); },
                                    //                       onSaved: (String val) {
                                    //                         _physicianAddressIP = val;
                                    //                       },
                                    //                     ),
                                    //                   )
                                    //                 ]
                                    //             ) : Offstage()
                                    //         ),
                                    //         SizedBox(height: hasConsulted == true ?  15 : 0),
                                    //       ]
                                    //   ),
                                    // ),
                                    // Form(
                                    //   key: _injuryKey,
                                    //   child: Column(
                                    //     children: [
                                    //       Container(
                                    //           width: width * .9,
                                    //           child: Card(
                                    //             color: mPrimaryColor,
                                    //             elevation: 5,
                                    //             shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0), side: BorderSide(color: Colors.black38)),
                                    //             child: Row(
                                    //                 children: <Widget>[
                                    //                   Checkbox(
                                    //                       value: injuryCheckbox,
                                    //                       activeColor: Colors.black,
                                    //                       onChanged: (bool newValue){
                                    //                         setState(() {
                                    //                           injuryCheckbox = newValue;
                                    //                           if(injuryCheckbox == true){
                                    //                             checkedItems.add('');
                                    //                           } else {
                                    //                             injuryDateController.clear();
                                    //                             checkedItems.remove(checkedItems[1]);
                                    //                           }
                                    //                         });
                                    //                       }
                                    //                   ),
                                    //                   //SizedBox(width: 20,),
                                    //                   Text('INJURY DUE TO ACCIDENT')
                                    //                 ]),
                                    //           )
                                    //       ),
                                    //       SizedBox(height: 15),
                                    //       Container(
                                    //           width: width * .9,
                                    //           child: injuryCheckbox == true ?Column(
                                    //               crossAxisAlignment: CrossAxisAlignment.stretch,
                                    //               children: <Widget>[
                                    //                 Row(
                                    //                     children:<Widget>[
                                    //                       Text('*',style: TextStyle(color: Colors.redAccent)),
                                    //                       Text('When And Where Did This Accident Happen?', textAlign: TextAlign.left)
                                    //                     ]
                                    //                 ),
                                    //                 Text('  Please Indicate Time:', textAlign: TextAlign.left),
                                    //                 SizedBox(height: 5),
                                    //                 Card(
                                    //                   elevation: 0,
                                    //                   child: TextFormField(
                                    //                     validator:(val){
                                    //                       if((val.isEmpty)&&(injuryCheckbox == true)){
                                    //                         return "Please state the date of injury";
                                    //                       }
                                    //                     },
                                    //                     inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[]'))],
                                    //                     decoration: InputDecoration(
                                    //                       border: OutlineInputBorder(),
                                    //                     ),
                                    //                     controller: injuryDateController,
                                    //                     onChanged: (String val) {
                                    //                       var month = '${_date.month}'.length == 1 ? '0${_date.month}' : '${_date.month}';
                                    //                       var day = '${_date.day}'.length == 1 ? '0${_date.day}' : '${_date.day}';
                                    //                       _injuryDateIP = '${_date.year}$month$day';
                                    //                       injuryDateController.text = selectedDateText;
                                    //                     },
                                    //                     onTap: () {
                                    //                       _appSessionCallback.pauseAppSession();
                                    //                       _datePicker(context, 'injuryDate');
                                    //                     },
                                    //                   ),
                                    //                 )
                                    //               ]
                                    //           ) : Offstage()
                                    //       ),
                                    //       SizedBox(height: injuryCheckbox == true ? 15 : 0),
                                    //       Container(
                                    //           width: width * .9,
                                    //           child: injuryCheckbox == true ? Column (
                                    //               crossAxisAlignment: CrossAxisAlignment.stretch,
                                    //               children: <Widget>[
                                    //                 Row(
                                    //                     children:<Widget>[
                                    //                       Text('*',style: TextStyle(color: Colors.redAccent)),
                                    //                       Flexible(child: Text('What Was The Insured Person Doing When It Happened?', maxLines: 2, textAlign: TextAlign.left))
                                    //                     ]
                                    //                 ),
                                    //                 SizedBox(height: 5),
                                    //                 Card(
                                    //                   elevation: 0,
                                    //                   child: TextFormField(
                                    //                     validator: (val){
                                    //                       if((val.isEmpty)&&(injuryCheckbox == true)){
                                    //                         return "Please state what happened";
                                    //                       }
                                    //                     },
                                    //                     keyboardType: TextInputType.text,
                                    //                     decoration: InputDecoration(
                                    //                       border: OutlineInputBorder(),
                                    //                     ),
                                    //                     onTap: () { _appSessionCallback.pauseAppSession(); },
                                    //                     onChanged: (String val) {
                                    //                       _injuryWhatHappened = val;
                                    //                     },
                                    //                   ),
                                    //                 )
                                    //               ]
                                    //           ) : Offstage()
                                    //       ),
                                    //       SizedBox(height: injuryCheckbox == true ? 15 : 0),
                                    //       Container(
                                    //           width: width * .9,
                                    //           child: Container(
                                    //             child: injuryCheckbox == true ? Column(
                                    //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //               children: <Widget>[
                                    //                 Row(
                                    //                     children:<Widget>[
                                    //                       Text('*',style: TextStyle(color: Colors.redAccent)),
                                    //                       Text('State How It Happened:', textAlign: TextAlign.left)
                                    //                     ]
                                    //                 ),
                                    //                 Card(
                                    //                   elevation: 0,
                                    //                   child: TextFormField(
                                    //                     validator:(val){
                                    //                       if((val.isEmpty)&&(injuryCheckbox == true)){
                                    //                         return "Please state how it happened:";
                                    //                       }
                                    //                     },
                                    //                     keyboardType: TextInputType.multiline,
                                    //                     maxLines: 3,
                                    //                     decoration: InputDecoration(
                                    //                       border: OutlineInputBorder(
                                    //                           borderSide: BorderSide(color: Colors.black87)
                                    //                       ),
                                    //                     ),
                                    //                     onTap: () { _appSessionCallback.pauseAppSession(); },
                                    //                     onChanged: (String val) {
                                    //                       _howHappened = val;
                                    //                     },
                                    //                   ),
                                    //                 )
                                    //               ],
                                    //             ) : Offstage(),
                                    //           )
                                    //       ),
                                    //       SizedBox(height: injuryCheckbox == true ? 15 : 0),
                                    //     ],
                                    //   ),
                                    // ),
                                    // Form(
                                    //   key: _insuranceKey,
                                    //   child: Column(
                                    //     children: <Widget>[
                                    //       Container(
                                    //           width: width * .9,
                                    //           child: Card(
                                    //             color: mPrimaryColor,
                                    //             elevation: 5,
                                    //             shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0), side: BorderSide(color: Colors.black38)),
                                    //             child: Row(
                                    //                 children: <Widget>[
                                    //                   Checkbox(
                                    //                       value: patientCoveredByAnotherInsurance,
                                    //                       activeColor: Colors.black,
                                    //                       onChanged: (bool newValue){
                                    //                         setState(() {
                                    //                           patientCoveredByAnotherInsurance = newValue;
                                    //                           if(patientCoveredByAnotherInsurance == false){
                                    //                             insuranceCompanyController.clear();
                                    //                             checkedItems.remove(checkedItems[1]);
                                    //                           } else {
                                    //                             checkedItems.add('');
                                    //                           }
                                    //                         });
                                    //                       }
                                    //                   ),
                                    //                   //SizedBox(width: 20,),
                                    //                   Flexible(child: Text('COVERED BY ANOTHER GROUP INSURANCE PLAN', maxLines: 2, overflow: TextOverflow.ellipsis,textAlign: TextAlign.left,style: TextStyle(fontSize: 13)))
                                    //                 ]),
                                    //           )
                                    //       ),
                                    //       SizedBox(height: patientCoveredByAnotherInsurance == true ? 15 : 0),
                                    //       Container(
                                    //           width: width * .9,
                                    //           child: patientCoveredByAnotherInsurance == true ? Column(
                                    //               crossAxisAlignment: CrossAxisAlignment.stretch,
                                    //               children: <Widget>[
                                    //                 Row(
                                    //                     children:<Widget>[
                                    //                       Text('*',style: TextStyle(color: Colors.redAccent)),
                                    //                       Text('Insurance Company:', textAlign: TextAlign.left)
                                    //                     ]
                                    //                 ),
                                    //                 SizedBox(height: 5),
                                    //                 Card(
                                    //                   elevation: 0,
                                    //                   child: TextFormField(
                                    //                     validator:(val){
                                    //                       if((val.isEmpty)&&(patientCoveredByAnotherInsurance == true)){
                                    //                         return "Please state the insurance company";
                                    //                       }
                                    //                     },
                                    //                     controller: insuranceCompanyController,
                                    //                     enabled: patientCoveredByAnotherInsurance,
                                    //                     keyboardType: TextInputType.text,
                                    //                     decoration: InputDecoration(
                                    //                       border: OutlineInputBorder(),
                                    //                     ),
                                    //                     onTap: () { _appSessionCallback.pauseAppSession(); },
                                    //                     onChanged: (String val) {
                                    //                       _insuranceCompany = val;
                                    //                     },
                                    //                   ),
                                    //                 )
                                    //               ]
                                    //           ) : Offstage()
                                    //       ) ,
                                    //     ]
                                    //   )
                                    // ),
                                    SizedBox(height: 15),
                                    Container(
                                      width: width * .9,
                                      child: Text("Hospital's and Doctor's Statements", textAlign: TextAlign.center, maxLines: 2, style: TextStyle(fontSize: 17),),
                                    ),
                                    SizedBox(height: 15),
                                    Container(
                                        width: width * .9,
                                        child: _inDoctorStatementsList.length < 3 ? _inGetBrowseButton('doctorStatements') : _disableBrowseButton()
                                    ),
                                    SizedBox(height: 10,),
                                    _inDoctorStatementsList.length >= 1 ? Container(
                                      width: width * .9,
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
                                                          Text('${_inDoctorStatementsListStr[0]}'),
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
                                                        this._inDoctorStatementsList.removeWhere((item) => item == _inDoctorStatementsList[0]);
                                                        this._inDoctorStatementsListStr.removeWhere((item) => item == _inDoctorStatementsListStr[0]);
                                                        print(_inDoctorStatementsList);
                                                        print(_inDoctorStatementsListStr);
                                                      }
                                                      );
                                                    }
                                                )
                                            ),
                                          )
                                        ],
                                      ),
                                    ) : Offstage(),
                                    _inDoctorStatementsList.length >= 2 ? Container(
                                      width: width * .9,
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
                                                          Text('${_inDoctorStatementsListStr[1]}'),
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
                                                        this._inDoctorStatementsList.removeWhere((item) => item == _inDoctorStatementsList[1]);
                                                        this._inDoctorStatementsListStr.removeWhere((item) => item == _inDoctorStatementsListStr[1]);
                                                        print(_inDoctorStatementsList);
                                                        print(_inDoctorStatementsListStr);
                                                      }
                                                      );
                                                    }
                                                )
                                            ),
                                          )
                                        ],
                                      ),
                                    ) : Offstage(),
                                    _inDoctorStatementsListStr.length == 3 ? Container(
                                      width: width * .9,
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
                                                          Text('${_inDoctorStatementsListStr[2]}'),
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
                                                        this._inDoctorStatementsList.removeWhere((item) => item == _inDoctorStatementsList[2]);
                                                        this._inDoctorStatementsListStr.removeWhere((item) => item == _inDoctorStatementsListStr[2]);
                                                        print(_inDoctorStatementsList);
                                                        print(_inDoctorStatementsListStr);
                                                      }
                                                      );
                                                    }
                                                )
                                            ),
                                          )
                                        ],
                                      ),
                                    ) : Offstage(),
                                    SizedBox(height: 15),
                                    Container(
                                      width: width * .9,
                                      child: Text("Statement of Account/Charge slips", textAlign: TextAlign.center, style: TextStyle(fontSize: 17),),
                                    ),
                                    SizedBox(height: 15),
                                    Container(
                                        width: width * .9,
                                        child: _inChargeSlipsList.length <3 ? _inGetBrowseButton('chargeSlips') : _disableBrowseButton()
                                    ),
                                    SizedBox(height: 10,),
                                    _inChargeSlipsListStr.length >= 1 ? Container(
                                      width: width * .9,
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
                                                          Text('${_inChargeSlipsListStr[0]}'),
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
                                                        this._inChargeSlipsList.removeWhere((item) => item == _inChargeSlipsList[0]);
                                                        this._inChargeSlipsListStr.removeWhere((item) => item == _inChargeSlipsListStr[0]);
                                                        print(_inChargeSlipsList);
                                                        print(_inChargeSlipsListStr);
                                                      }
                                                      );
                                                    }
                                                )
                                            ),
                                          )
                                        ],
                                      ),
                                    ) : Offstage(),
                                    _inChargeSlipsListStr.length >= 2 ? Container(
                                      width: width * .9,
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
                                                          Text('${_inChargeSlipsListStr[1]}'),
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
                                                        this._inChargeSlipsList.removeWhere((item) => item == _inChargeSlipsList[1]);
                                                        this._inChargeSlipsListStr.removeWhere((item) => item == _inChargeSlipsListStr[1]);
                                                        print(_inChargeSlipsList);
                                                        print(_inChargeSlipsListStr);
                                                      }
                                                      );
                                                    }
                                                )
                                            ),
                                          )
                                        ],
                                      ),
                                    ) : Offstage(),
                                    _inChargeSlipsListStr.length == 3 ? Container(
                                      width: width * .9,
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
                                                          Text('${_inChargeSlipsListStr[2]}'),
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
                                                        this._inChargeSlipsList.removeWhere((item) => item == _inChargeSlipsList[2]);
                                                        this._inChargeSlipsListStr.removeWhere((item) => item == _inChargeSlipsListStr[2]);
                                                        print(_inChargeSlipsList);
                                                        print(_inChargeSlipsListStr);
                                                      }
                                                      );
                                                    }
                                                )
                                            ),
                                          )
                                        ],
                                      ),
                                    ) : Offstage(),
                                    SizedBox(height: 15),
                                    Container(
                                      width: width * .9,
                                      child: Text("Official Receipt (BIR Registered)", textAlign: TextAlign.center, style: TextStyle(fontSize: 17),),
                                    ),
                                    SizedBox(height: 15),
                                    Container(
                                        width: width * .9,
                                        child: _inOfficialRecieptsList.length < 3 ? _inGetBrowseButton('officialReceipts') : _disableBrowseButton()
                                    ),
                                    SizedBox(height: 10,),
                                    _inOfficialRecieptsListStr.length >= 1 ? Container(
                                      width: width * .9,
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
                                                          Text('${_inOfficialRecieptsListStr[0]}'),
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
                                                        this._inOfficialRecieptsList.removeWhere((item) => item == _inOfficialRecieptsList[0]);
                                                        this._inOfficialRecieptsListStr.removeWhere((item) => item == _inOfficialRecieptsListStr[0]);
                                                        print(_inOfficialRecieptsList);
                                                        print(_inOfficialRecieptsListStr);
                                                      }
                                                      );
                                                    }
                                                )
                                            ),
                                          )
                                        ],
                                      ),
                                    ) : Offstage(),
                                    _inOfficialRecieptsListStr.length >= 2 ? Container(
                                      width: width * .9,
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
                                                          Text('${_inOfficialRecieptsListStr[1]}'),
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
                                                        this._inOfficialRecieptsList.removeWhere((item) => item == _inOfficialRecieptsList[1]);
                                                        this._inOfficialRecieptsListStr.removeWhere((item) => item == _inOfficialRecieptsListStr[1]);
                                                        print(_inOfficialRecieptsList);
                                                        print(_inOfficialRecieptsListStr);
                                                      }
                                                      );
                                                    }
                                                )
                                            ),
                                          )
                                        ],
                                      ),
                                    ) : Offstage(),
                                    _inOfficialRecieptsListStr.length == 3 ? Container(
                                      width: width * .9,
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
                                                          Text('${_inOfficialRecieptsListStr[2]}'),
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
                                                        this._inOfficialRecieptsList.removeWhere((item) => item == _inOfficialRecieptsList[2]);
                                                        this._inOfficialRecieptsListStr.removeWhere((item) => item == _inOfficialRecieptsListStr[2]);
                                                        print(_inOfficialRecieptsList);
                                                        print(_inOfficialRecieptsListStr);
                                                      });
                                                    }
                                                )
                                            ),
                                          )
                                        ],
                                      ),
                                    ) : Offstage(),
                                    SizedBox(height: 15),
                                    Container(
                                      width: width * .9,
                                      child: Text("Signed Claim Form", textAlign: TextAlign.center, style: TextStyle(fontSize: 17),),
                                    ),
                                    SizedBox(height: 15),
                                    Container(
                                        width: width * .9,
                                        child: _inClaimFormList.length < 3 ? _inGetBrowseButton('claimForm') : _disableBrowseButton()
                                    ),
                                    SizedBox(height: 10,),
                                    _inClaimFormListStr.length >= 1 ? Container(
                                      width: width * .9,
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
                                                          Text('${_inClaimFormListStr[0]}'),
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
                                                        this._inClaimFormList.removeWhere((item) => item == _inClaimFormList[0]);
                                                        this._inClaimFormListStr.removeWhere((item) => item == _inClaimFormListStr[0]);
                                                        print(_inClaimFormList);
                                                        print(_inClaimFormListStr);
                                                      }
                                                      );
                                                    }
                                                )
                                            ),
                                          )
                                        ],
                                      ),
                                    ) : Offstage(),
                                    _inClaimFormListStr.length >= 2 ? Container(
                                      width: width * .9,
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
                                                          Text('${_inClaimFormListStr[1]}'),
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
                                                        this._inClaimFormList.removeWhere((item) => item == _inClaimFormList[1]);
                                                        this._inClaimFormListStr.removeWhere((item) => item == _inClaimFormListStr[1]);
                                                        print(_inClaimFormList);
                                                        print(_inClaimFormListStr);
                                                      }
                                                      );
                                                    }
                                                )
                                            ),
                                          )
                                        ],
                                      ),
                                    ) : Offstage(),
                                    _inClaimFormListStr.length == 3 ? Container(
                                      width: width * .9,
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
                                                          Text('${_inClaimFormListStr[2]}'),
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
                                                        this._inClaimFormList.removeWhere((item) => item == _inClaimFormList[2]);
                                                        this._inClaimFormListStr.removeWhere((item) => item == _inClaimFormListStr[2]);
                                                        print(_inClaimFormList);
                                                        print(_inClaimFormListStr);
                                                      });
                                                    }
                                                )
                                            ),
                                          )
                                        ],
                                      ),
                                    ) : Offstage(),
                                    SizedBox( height: 15),
                                    Container(
                                        width: width * .9,
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: <Widget>[
                                              Row(children:<Widget>[Text('*',style:TextStyle(color: Colors.red), textAlign: TextAlign.left),Text('Payment Method:', textAlign: TextAlign.left)]),
                                              SizedBox(height: 5),
                                              Card(
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(side: BorderSide(color: Colors.black38)),
                                                  child: Container(
                                                      padding: EdgeInsets.only(left: 10),
                                                      child: DropdownButtonHideUnderline(
                                                        child: new DropdownButton<String>(
                                                            isExpanded: true,
                                                            hint: new Text('--Select Payment Method--'),
                                                            value: _selectedPaymentMethod,
                                                            onChanged: (String newValue) {
                                                              setState(() {
                                                                _selectedPaymentMethod = newValue;
                                                                _selectedBlockId = blockId[modeName.indexOf(newValue)];
                                                                _selectedBankCode = defaultBankCode[modeName.indexOf(newValue)];

                                                                if(_selectedBlockId == '1'){
                                                                  isBankSelected = true;
                                                                  _inFundAccDetails = true;
                                                                  mobileWalletController.clear();
                                                                  mobileWalletNameController.clear();
                                                                  remittanceNameController.clear();
                                                                  remittanceAddressController.clear();
                                                                  remittanceContactNoController.clear();
                                                                } else {
                                                                  isBankSelected = false;
                                                                  _inFundAccDetails = false;
                                                                  mobileWalletController.clear();
                                                                  mobileWalletNameController.clear();
                                                                  remittanceNameController.clear();
                                                                  remittanceAddressController.clear();
                                                                  remittanceContactNoController.clear();
                                                                }

                                                                if(_selectedBlockId == '2'){
                                                                  isMobileWalletVisible = true;
                                                                  acctnoController.clear();
                                                                  acctnameController.clear();
                                                                  acctaddressController.clear();
                                                                  remittanceNameController.clear();
                                                                  remittanceAddressController.clear();
                                                                  remittanceContactNoController.clear();
                                                                } else {
                                                                  isMobileWalletVisible = false;
                                                                  acctnoController.clear();
                                                                  acctnameController.clear();
                                                                  acctaddressController.clear();
                                                                  remittanceNameController.clear();
                                                                  remittanceAddressController.clear();
                                                                  remittanceContactNoController.clear();
                                                                }

                                                                if(_selectedBlockId == '3'){
                                                                  isRemittanceVisible = true;
                                                                  acctnoController.clear();
                                                                  acctnameController.clear();
                                                                  acctaddressController.clear();
                                                                  mobileWalletController.clear();
                                                                  mobileWalletNameController.clear();
                                                                } else {
                                                                  isRemittanceVisible = false;
                                                                  acctnoController.clear();
                                                                  acctnameController.clear();
                                                                  acctaddressController.clear();
                                                                  mobileWalletController.clear();
                                                                  mobileWalletNameController.clear();
                                                                  remittanceNameController.clear();
                                                                  remittanceAddressController.clear();
                                                                  remittanceContactNoController.clear();
                                                                }
                                                              });
                                                            },
                                                            items: modeName.map((pMethod){
                                                              return new DropdownMenuItem<String>(
                                                                  value: pMethod.toString(),
                                                                  child: Text(pMethod)
                                                              );
                                                            }).toList()
                                                        ),
                                                      )
                                                  )
                                              ),
                                            ]
                                        )
                                    ),
                                    SizedBox( height: isRemittanceVisible == true ? 15 : 0),
                                    Container(
                                        width: width * .9,
                                        child: isRemittanceVisible == true ? Form(
                                          key: _remittanceFormKey,
                                          child: Column(
                                              children: <Widget>[
                                                Row(children:<Widget>[Text('*',style:TextStyle(color: Colors.red), textAlign: TextAlign.left),Text('Name:', textAlign: TextAlign.left)]),
                                                SizedBox(height: 5),
                                                Card(
                                                  elevation: 0,
                                                  child: TextFormField(
                                                    validator: (val){
                                                      if(val.isEmpty){
                                                        return "Please provide your name.";
                                                      }
                                                    },
                                                    keyboardType: TextInputType.text,
                                                    controller: remittanceNameController,
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(),
                                                    ),
                                                    onTap: () { _appSessionCallback.pauseAppSession(); },
                                                    onChanged: (String val) {
                                                      _acctName = val;
                                                    },
                                                  ),
                                                ),
                                                Row(children:<Widget>[Text('*',style:TextStyle(color: Colors.red), textAlign: TextAlign.left),Text('Address:', textAlign: TextAlign.left)]),
                                                SizedBox(height: 5),
                                                Card(
                                                  elevation: 0,
                                                  child: TextFormField(
                                                    validator: (val){
                                                      if(val.isEmpty){
                                                        return "Please provide your address.";
                                                      }
                                                    },
                                                    keyboardType: TextInputType.text,
                                                    controller: remittanceAddressController,
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(),
                                                    ),
                                                    onTap: () { _appSessionCallback.pauseAppSession(); },
                                                    onChanged: (String val) {
                                                      _address = val;
                                                    },
                                                  ),
                                                ),
                                                Row(children:<Widget>[Text('*',style:TextStyle(color: Colors.red), textAlign: TextAlign.left),Text('Contact Number:', textAlign: TextAlign.left)]),
                                                SizedBox(height: 5),
                                                Card(
                                                  elevation: 0,
                                                  child: TextFormField(
                                                    validator: (val){
                                                      if(val.isEmpty){
                                                        return "Please provide your contact no.";
                                                      }
                                                    },
                                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                                    keyboardType: TextInputType.phone,
                                                    controller: remittanceContactNoController,
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(),
                                                    ),
                                                    onTap: () { _appSessionCallback.pauseAppSession(); },
                                                    onChanged: (String val) {
                                                      _acctNo = val;
                                                    },
                                                  ),
                                                )
                                              ]
                                          ),
                                        ) : Offstage()
                                    ) ,
                                    SizedBox( height: isMobileWalletVisible == true ? 15 : 0),
                                    Container(
                                        width: width * .9,
                                        child: isMobileWalletVisible == true ? Form(
                                          key: _gcashFormKey,
                                          child: Column(
                                              children: <Widget>[
                                                Row(children:<Widget>[Text('*',style:TextStyle(color: Colors.red), textAlign: TextAlign.left),Text('Account Name:', textAlign: TextAlign.left)]),
                                                SizedBox(height: 5),
                                                Card(
                                                  elevation: 0,
                                                  child: TextFormField(
                                                    validator: (val){
                                                      if(val.isEmpty){
                                                        return "Please provide your account name.";
                                                      }
                                                    },
                                                    keyboardType: TextInputType.name,
                                                    controller: mobileWalletNameController,
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(),
                                                    ),
                                                    onTap: () { _appSessionCallback.pauseAppSession(); },
                                                    onChanged: (String val) {
                                                      _acctName = val;
                                                    },
                                                  ),
                                                ),
                                                Row(children:<Widget>[Text('*',style:TextStyle(color: Colors.red), textAlign: TextAlign.left),Text('Account Number:', textAlign: TextAlign.left)]),
                                                SizedBox(height: 5),
                                                Card(
                                                  elevation: 0,
                                                  child: TextFormField(
                                                    validator: (val){
                                                      if(val.isEmpty){
                                                        return "Please provide your account no.";
                                                      }
                                                    },
                                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                                    keyboardType: TextInputType.phone,
                                                    controller: mobileWalletController,
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(),
                                                    ),
                                                    onTap: () { _appSessionCallback.pauseAppSession(); },
                                                    onChanged: (String val) {
                                                      _acctNo = val;
                                                    },
                                                  ),
                                                )
                                              ]
                                          ),
                                        ) : Offstage()
                                    ) ,
                                    SizedBox( height: isBankSelected == true ? 15 : 0),
                                    Container(
                                        width: width * .9,
                                        child: isBankSelected == true ? Card(
                                            elevation: 5,
                                            child: Form(
                                              key: _bankFormKeyIn,
                                              child: Column(
                                                  //crossAxisAlignment: CrossAxisAlignment.stretch,
                                                  children: <Widget>[
                                                    // Row(
                                                    //     children: <Widget>[
                                                    //       Checkbox(
                                                    //           value: _inFundAccDetails,
                                                    //           activeColor: Colors.black,
                                                    //           onChanged: (bool newValue){
                                                    //             setState(() {
                                                    //               _inFundAccDetails = newValue;
                                                    //               if(_inFundAccDetails == true){
                                                    //                 checkedItems.add('');
                                                    //               } else {
                                                    //                 checkedItems.remove(checkedItems[1]);
                                                    //               }
                                                    //             });
                                                    //           }
                                                    //       ),
                                                    //       Text('Add fund transfer account details'),
                                                    //     ]
                                                    // ),
                                                    SizedBox( height: 15),
                                                    Container(
                                                        width: width * .8,
                                                        child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                                            children: <Widget>[
                                                              Row(children:<Widget>[Text('*',style:TextStyle(color: Colors.red), textAlign: TextAlign.left),Text('Bank Account Number:', textAlign: TextAlign.left)]),
                                                              SizedBox(height: 5),
                                                              Card(
                                                                elevation: 0,
                                                                child: TextFormField(
                                                                  validator: (val){
                                                                    if(val.isEmpty){
                                                                      return "Please provide your account no.";
                                                                    }
                                                                  },
                                                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                                                  keyboardType: TextInputType.phone,
                                                                  controller : acctnoController,
                                                                  decoration: InputDecoration(
                                                                    border: OutlineInputBorder(),
                                                                  ),
                                                                  onTap: () { _appSessionCallback.pauseAppSession(); },
                                                                  onChanged: (String val) {
                                                                    _acctNo = val;
                                                                  },
                                                                ),
                                                              )
                                                            ]
                                                        )
                                                    ),
                                                    SizedBox( height: 15),
                                                    Container(
                                                        width: width * .8,
                                                        child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                                            children: <Widget>[
                                                              Row(children:<Widget>[Text('*',style:TextStyle(color: Colors.red), textAlign: TextAlign.left),Text('Account Name:', textAlign: TextAlign.left)]),
                                                              SizedBox(height: 5),
                                                              Card(
                                                                elevation: 0,
                                                                child: TextFormField(
                                                                  validator: (val){
                                                                    if(val.isEmpty){
                                                                      return "Please provide your account name";
                                                                    }
                                                                  },
                                                                  keyboardType: TextInputType.text,
                                                                  controller: acctnameController,
                                                                  decoration: InputDecoration(
                                                                    border: OutlineInputBorder(),
                                                                  ),
                                                                  onTap: () { _appSessionCallback.pauseAppSession(); },
                                                                  onChanged: (String val) {
                                                                    _acctName = val;
                                                                  },
                                                                ),
                                                              )
                                                            ]
                                                        )
                                                    ),
                                                    SizedBox( height: 15),
                                                    Container(
                                                        width: width * .8,
                                                        child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                                            children: <Widget>[
                                                              Row(children:<Widget>[Text('*',style:TextStyle(color: Colors.red), textAlign: TextAlign.left),Text('Bank Branch Address:', textAlign: TextAlign.left)]),
                                                              SizedBox(height: 5),
                                                              Card(
                                                                elevation: 0,
                                                                child: TextFormField(
                                                                  validator: (val){
                                                                    if(val.isEmpty){
                                                                      return "Please provide your address";
                                                                    }
                                                                  },
                                                                  keyboardType: TextInputType.text,
                                                                  controller: acctaddressController,
                                                                  decoration: InputDecoration(
                                                                    border: OutlineInputBorder(),
                                                                  ),
                                                                  onTap: () { _appSessionCallback.pauseAppSession(); },
                                                                  onChanged: (String val) {
                                                                    _address = val;
                                                                  },
                                                                ),
                                                              )
                                                            ]
                                                        )
                                                    ),
                                                    SizedBox(height: 15),
                                                    Container(
                                                      width: width * .8,
                                                      child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                                          children: <Widget>[
                                                            Row(
                                                                children:<Widget>[
                                                                  Text('*',style: TextStyle(color: Colors.redAccent)),
                                                                  Text('Bank:', textAlign: TextAlign.left)
                                                                ]
                                                            ),
                                                            SizedBox(height: 5),
                                                            Card(
                                                              elevation: 1,
                                                              borderOnForeground: false,
                                                              child: Autocomplete(
                                                                optionsBuilder: (TextEditingValue value) {
                                                                  if (value.text.isEmpty) {
                                                                    return [];
                                                                  }
                                                                  return getBankNameStoreList.where((suggestion) => suggestion
                                                                      .toLowerCase()
                                                                      .contains(value.text.toLowerCase()));
                                                                },
                                                                onSelected: (value) {
                                                                  setState(() {
                                                                    int index = getBankNameStoreList.indexOf(value);
                                                                    _selectedBankCode = getBankCodeStoreList[index].toString();
                                                                    _selectedBankName = value;
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                          ]
                                                      ),
                                                    ),
                                                    SizedBox( height: 15),
                                                  ]
                                              ),
                                            )
                                        ) : Offstage()
                                    ),
                                    SizedBox( height: 15,),
                                    Container(
                                      width: width *.9,
                                      child: Card(
                                          elevation: 0,
                                          shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0), side: BorderSide(color: Colors.black)),
                                          child: Container(
                                              padding: EdgeInsets.all(10),
                                              child: Column(
                                                children: <Widget>[
                                                  Row(
                                                      children: <Widget>[
                                                        Checkbox(
                                                          value: certifyStatementsIn,
                                                          activeColor: Colors.black,
                                                          onChanged: (bool value) {
                                                            setState(() {
                                                              certifyStatementsIn = value;
                                                              if(copiesTrueIn == true && certifyStatementsIn == true && awareSubmitRecordsIn == true && authorizePhysicianIn == true && notBeenPaidIn == true){
                                                                isEnabledIn = true;
                                                              } else {
                                                                isEnabledIn = false;
                                                              }
                                                            });
                                                          },
                                                        ),
                                                        Flexible(child: Text('I hereby certify that foregoing statements, including any accompanying statements are, to the best of my knowledge and belief, true correct, and complete.')),
                                                      ]
                                                  ),
                                                  SizedBox(height: 10.0),
                                                  Visibility(
                                                    visible: isUpper10kIn,
                                                    child: Row(
                                                        children: <Widget>[
                                                          Checkbox(
                                                            value: awareSubmitRecordsIn,
                                                            activeColor: Colors.black,
                                                            onChanged: (bool value) {
                                                              setState(() {
                                                                awareSubmitRecordsIn = value;
                                                                if(copiesTrueIn == true && certifyStatementsIn == true && awareSubmitRecordsIn == true && authorizePhysicianIn == true && notBeenPaidIn == true){
                                                                  isEnabledIn = true;
                                                                } else {
                                                                  isEnabledIn = false;
                                                                }
                                                              });
                                                            },
                                                          ),
                                                          Flexible(child: Text('I am aware that I am required to submit all records, original receipts, and other supporting documents to Etiqa’s Head Office within 30 days.')),
                                                        ]
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible: isLower10kIn,
                                                    child: Row(
                                                        children: <Widget>[
                                                          Checkbox(
                                                            value: awareSubmitRecordsIn,
                                                            activeColor: Colors.black,
                                                            onChanged: (bool value) {
                                                              setState(() {
                                                                awareSubmitRecordsIn = value;
                                                                if(copiesTrueIn == true && certifyStatementsIn == true && awareSubmitRecordsIn == true && authorizePhysicianIn == true && notBeenPaidIn == true){
                                                                  isEnabledIn = true;
                                                                } else {
                                                                  isEnabledIn = false;
                                                                }
                                                              });
                                                            },
                                                          ),
                                                          Flexible(child: Text('I am aware that I am required to keep all records, original receipts, and other supporting documents in relation to this claim for a period of ten (10) years.')),
                                                        ]
                                                    ),
                                                  ),
                                                  SizedBox(height: 10.0),
                                                  Row(
                                                      children: <Widget>[
                                                        Checkbox(
                                                          value: authorizePhysicianIn,
                                                          activeColor: Colors.black,
                                                          onChanged: (bool value) {
                                                            setState(() {
                                                              authorizePhysicianIn = value;
                                                              if(copiesTrueIn == true && certifyStatementsIn == true && awareSubmitRecordsIn == true && authorizePhysicianIn == true && notBeenPaidIn == true){
                                                                isEnabledIn = true;
                                                              } else {
                                                                isEnabledIn = false;
                                                              }
                                                            });
                                                          },
                                                        ),
                                                        Flexible(child: Text('I hereby authorize any physician to furnish and disclose all known facts concerning this disability to Etiqa Philippines or to its authorized representative.')),
                                                      ]
                                                  ),
                                                  SizedBox(height: 10.0),
                                                  Row(
                                                      children: <Widget>[
                                                        Checkbox(
                                                          value: notBeenPaidIn,
                                                          activeColor: Colors.black,
                                                          onChanged: (bool value) {
                                                            setState(() {
                                                              notBeenPaidIn = value;
                                                              if(copiesTrueIn == true && certifyStatementsIn == true && awareSubmitRecordsIn == true && authorizePhysicianIn == true && notBeenPaidIn == true){
                                                                isEnabledIn = true;
                                                              } else {
                                                                isEnabledIn = false;
                                                              }
                                                            });
                                                          },
                                                        ),
                                                        Flexible(child: Text('I certify that I have not been paid by or filed these claims with other health care providers.')),
                                                      ]
                                                  ),
                                                  Row(
                                                      children: <Widget>[
                                                        Checkbox(
                                                          value: copiesTrueIn,
                                                          activeColor: Colors.black,
                                                          onChanged: (bool value) {
                                                            setState(() {
                                                              copiesTrueIn = value;
                                                              if(copiesTrueIn == true && certifyStatementsIn == true && awareSubmitRecordsIn == true && authorizePhysicianIn == true && notBeenPaidIn == true){
                                                                isEnabledIn = true;
                                                              } else {
                                                                isEnabledIn = false;
                                                              }
                                                            });
                                                          },
                                                        ),
                                                        Flexible(child: Text('I certify that the scan copies are true and perfect copy of the original documents.')),
                                                      ]
                                                  )
                                                ],
                                              )
                                          )
                                      ),
                                    ),
                                    SizedBox( height: 15),
                                    RaisedButton(
                                        color: mPrimaryColor,
                                        padding: EdgeInsets.fromLTRB(40, 15, 40, 15),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                            side: BorderSide(color: isEnabledIn == true ? mPrimaryColor : Colors.grey)),
                                        onPressed: isEnabledIn == true ? () async {
                                          SharedPreferences prefs = await SharedPreferences.getInstance();
                                          var errMsg = '';
                                          itemsChecked = checkedItems.length - 1;

                                          String _infundTransfer;
                                          String _username;
                                          String _resideWithEnsured;
                                          String _isEmployed;
                                          String _hasConsulted;
                                          String _dueToInjury;
                                          String _coveredByOtherInsurance;
                                          String _insuredHospitalized;

                                          _username = prefs.getString('_username')??('');

                                          _inFundAccDetails == true ? _infundTransfer = '1': _infundTransfer = '0';
                                          insuredHospitalized == true ? _insuredHospitalized = '1' : _insuredHospitalized = '0';
                                          resideWithEnsuredIndividuals == true ? _resideWithEnsured = '1': _resideWithEnsured = '0';

                                          ClaimRequest request = ClaimRequest(
                                              cardNo: _cardnoPatient == null ? _cardnoPatient = '' : _cardnoPatient = _cardnoPatient,
                                              claimAmount: _receiptAmount == null ? _receiptAmount = '' : _receiptAmount = _receiptAmount,
                                              availmentDate: injTextController.text == null ? injTextController.text = '' : injTextController.text = injTextController.text,
                                              diagnosis: _previousDiagnosisIP == null ? _previousDiagnosisIP = '' : _previousDiagnosisIP =_previousDiagnosisIP,
                                              fundTransfer: _infundTransfer == null ? _infundTransfer = '' : _infundTransfer = _infundTransfer,
                                              bnkCode: _selectedBankCode == null ? _selectedBankCode = '' : _selectedBankCode =_selectedBankCode,
                                              acctNo: _acctNo == null ? _acctNo = '' : _acctNo = _acctNo,
                                              acctName: _acctName == null ? _acctName = '' : _acctName = _acctName,
                                              acctAddress: _address == null ? _address = '' : _address = _address,
                                              appUserId: _username == null ? _username = '' : _username =_username,
                                              resideWithEnsured: _resideWithEnsured == null ? _resideWithEnsured = '' : _resideWithEnsured = _resideWithEnsured,
                                              isEmployed: _isEmployed == null ? _isEmployed = '' : _isEmployed = _isEmployed,
                                              employer: _employer  == null ? _employer = '' : _employer = _employer,
                                              patientDesignation: _occupation == null ? _occupation = '' : _occupation = _occupation,
                                              symptomNoticed: symptomsOccurController.text == null ? symptomsOccurController.text = '' : symptomsOccurController.text = symptomsOccurController.text,
                                              consultedDoc: _hasConsulted == null ? _hasConsulted = '' : _hasConsulted = _hasConsulted,
                                              consultedDocDate: consultationController.text == null ? consultationController.text = '' : consultationController.text = consultationController.text,
                                              findings: _diagnosisIP == null ? _diagnosisIP = '' : _diagnosisIP =_diagnosisIP,
                                              physicianName: _physicianIP == null ? _physicianIP = '' : _physicianIP =_physicianIP,
                                              physicianAddress: _physicianAddressIP == null ? _physicianAddressIP = '' : _physicianAddressIP = _physicianAddressIP,
                                              dueToInjury: _dueToInjury == null ? _dueToInjury = '' : _dueToInjury = _dueToInjury,
                                              whenWhereHappened: _injuryDateIP == null ? _injuryDateIP = '' : _injuryDateIP = _injuryDateIP,
                                              injuryWhatHappened: _injuryWhatHappened == null ? _injuryWhatHappened = '' : _injuryWhatHappened =_injuryWhatHappened,
                                              injuryHowHappened: _howHappened == null ? _howHappened = '' : _howHappened = _howHappened,
                                              withOtherInsurance: _coveredByOtherInsurance == null ? _coveredByOtherInsurance = '' : _coveredByOtherInsurance = _coveredByOtherInsurance,
                                              insuranceCompany: _insuranceCompany == null ? _insuranceCompany = '' : _insuranceCompany = _insuranceCompany,
                                              hospCode: _selectedHospCode == null ? _selectedHospCode = '' : _selectedHospCode = _selectedHospCode,
                                              attendingPhysician: _attendingPhysicianIP == null ? _attendingPhysicianIP = '' : _attendingPhysicianIP = _attendingPhysicianIP,
                                              otherHosp: _otherHosp == null ? _otherHosp = '' : _otherHosp = _otherHosp,
                                              doctorStatementList: _inDoctorStatementsList,
                                              chargeSlipList: _inChargeSlipsList,
                                              officialReceiptList: _inOfficialRecieptsList,
                                              insuredHospitalized: _insuredHospitalized,
                                              claimForm: _inClaimFormList
                                          );

                                          if((_selectedPaymentMethod == '')||(_selectedPaymentMethod == null)){
                                          // errMsg += '\nPlease select a payment method';
                                          // showMessageDialog(context, errMsg);
                                          } else {
                                            if(_selectedBlockId == '1'){
                                              _bankFormKeyIn.currentState.validate() ? validatedItems += 1 : print('please complete all fields');
                                            } else if(_selectedBlockId == '2'){
                                              _gcashFormKey.currentState.validate() ? validatedItems += 1 : print('please complete all fields');
                                            } else if(_selectedBlockId == '3'){
                                              _remittanceFormKey.currentState.validate() ? validatedItems += 1 : print('please complete all fields');
                                            }
                                          }
                                          _formKeyIn.currentState.validate() ? validatedItems += 1 : print('please complete all fields');

                                          if(isEmployed == true){
                                            _isEmployed = '1';
                                            _employedKey.currentState.validate() ? validatedItems += 1 : print('please complete all fields');
                                          } else {
                                            _isEmployed = '0';
                                            // if(validatedItems > 1)
                                            //   validatedItems -= 1;
                                          }

                                          if(hasConsulted == true){
                                            _hasConsulted = '1';
                                            _consultedKey.currentState.validate() ? validatedItems += 1 : print('please complete all fields');
                                          } else {
                                            _hasConsulted = '0';
                                            // if(validatedItems > 1)
                                            //   validatedItems -= 1;
                                          }

                                          if(injuryCheckbox == true){
                                            _dueToInjury = '1';
                                            _injuryKey.currentState.validate() ? validatedItems += 1 : print('please complete all fields');
                                          } else {
                                            _dueToInjury = '0';
                                            // if(validatedItems > 1)
                                            //   validatedItems -= 1;
                                          }

                                          if(patientCoveredByAnotherInsurance == true){
                                            _coveredByOtherInsurance = '1';
                                            _insuranceKey.currentState.validate()  ? validatedItems += 1 : print('please complete all fields');
                                          } else {
                                            _coveredByOtherInsurance = '0';
                                          }
                                          if((_selectedPaymentMethod == '')||(_selectedPaymentMethod == null)){
                                            errMsg += '\nPlease select a payment method';
                                            showMessageDialog(context, errMsg);
                                          } else {
                                            if((_selectedBlockId == '1')&&(((_selectedBankCode == null)||(_selectedBankCode == ''))||((_selectedHospCode == '')||(_selectedHospCode == null))||(_cardnoPatient.isEmpty)||(_inDoctorStatementsList.length == 0)||
                                                (_inClaimFormList.length == 0)||(_inChargeSlipsList.length == 0)||(_inOfficialRecieptsList.length == 0)||((_selectedHospCode == 'OTH')&&((_otherHosp == null)||(_otherHosp == ''))))){

                                              if(((_selectedHospCode == null)||(_selectedHospCode == ''))||((_selectedHospCode == 'OTH')&&((_otherHosp == null)||(_otherHosp == ''))))
                                                errMsg += '\nPlease provide hospital';

                                              if(_inDoctorStatementsList.length == 0)
                                                errMsg += '\nPlease attach hospital\'s and doctor\s statements';

                                              if(_inChargeSlipsList.length == 0)
                                                errMsg += '\nPlease attach charge slips';

                                              if(_inOfficialRecieptsList.length == 0)
                                                errMsg += '\nPlease attach official BIR receipt';

                                              if(_inClaimFormList.length == 0)
                                                errMsg += '\nPlease attach signed claim form';

                                              if(_cardnoPatient.isEmpty)
                                                errMsg += '\nPlease select a patient';

                                              if((_selectedBankCode == null)||(_selectedBankCode == ''))
                                                errMsg += '\nPlease select a bank';

                                              showMessageDialog(context, errMsg);

                                              _bankFormKeyIn.currentState.validate() ? print('validated') : Scaffold.of(context).showSnackBar(SnackBar(content: Text('Please fill all the required fields')));
                                              _employedKey.currentState.validate() ? print('validated') : Scaffold.of(context).showSnackBar(SnackBar(content: Text('Please fill all the required fields')));
                                              _consultedKey.currentState.validate() ? print('validated') : Scaffold.of(context).showSnackBar(SnackBar(content: Text('Please fill all the required fields')));
                                              _injuryKey.currentState.validate() ? print('validated') : Scaffold.of(context).showSnackBar(SnackBar(content: Text('Please fill all the required fields')));
                                              _insuranceKey.currentState.validate() ? print('validated') : Scaffold.of(context).showSnackBar(SnackBar(content: Text('Please fill all the required fields')));

                                            } else {
                                              if((((_selectedBankCode == null)||(_selectedBankCode == ''))||((_selectedHospCode == '')||(_selectedHospCode == null))||(_cardnoPatient.isEmpty)||(_inDoctorStatementsList.length == 0)||
                                                  (_inClaimFormList.length == 0)||(_inChargeSlipsList.length == 0)||(_inOfficialRecieptsList.length == 0)||((_selectedHospCode == 'OTH')&&((_otherHosp == null)||(_otherHosp == ''))))){

                                                if(((_selectedHospCode == null)||(_selectedHospCode == ''))||((_selectedHospCode == 'OTH')&&((_otherHosp == null)||(_otherHosp == ''))))
                                                  errMsg += '\nPlease provide hospital';

                                                if(_inDoctorStatementsList.length == 0)
                                                  errMsg += '\nPlease attach hospital\'s and doctor\s statements';

                                                if(_inChargeSlipsList.length == 0)
                                                  errMsg += '\nPlease attach charge slips';

                                                if(_inOfficialRecieptsList.length == 0)
                                                  errMsg += '\nPlease attach official BIR receipt';

                                                if(_inClaimFormList.length == 0)
                                                  errMsg += '\nPlease attach signed claim form';

                                                if(_cardnoPatient.isEmpty)
                                                  errMsg += '\nPlease select a patient';

                                                showMessageDialog(context, errMsg);

                                                _bankFormKeyIn.currentState.validate() ? print('validated') : Scaffold.of(context).showSnackBar(SnackBar(content: Text('Please fill all the required fields')));
                                                _employedKey.currentState.validate() ? print('validated') : Scaffold.of(context).showSnackBar(SnackBar(content: Text('Please fill all the required fields')));
                                                _consultedKey.currentState.validate() ? print('validated') : Scaffold.of(context).showSnackBar(SnackBar(content: Text('Please fill all the required fields')));
                                                _injuryKey.currentState.validate() ? print('validated') : Scaffold.of(context).showSnackBar(SnackBar(content: Text('Please fill all the required fields')));
                                                _insuranceKey.currentState.validate() ? print('validated') : Scaffold.of(context).showSnackBar(SnackBar(content: Text('Please fill all the required fields')));

                                              } else {
                                                if(itemsChecked == 0){
                                                  if(_selectedBlockId == '1'){
                                                    _bankFormKeyIn.currentState.validate() & _formKeyIn.currentState.validate() ?
                                                    verifyClaimIp(context,request, widget?.member) : Scaffold.of(context).showSnackBar(SnackBar(content: Text('Please fill all the required fields')));
                                                  } else if(_selectedBlockId == '2'){
                                                    _gcashFormKey.currentState.validate() & _formKeyIn.currentState.validate() ?
                                                    verifyClaimIp(context,request, widget?.member) : Scaffold.of(context).showSnackBar(SnackBar(content: Text('Please fill all the required fields')));
                                                  } else if(_selectedBlockId == '3'){
                                                    _remittanceFormKey.currentState.validate() & _formKeyIn.currentState.validate() ?
                                                    verifyClaimIp(context,request, widget?.member) : Scaffold.of(context).showSnackBar(SnackBar(content: Text('Please fill all the required fields')));
                                                  }
                                                } else {
                                                  itemsChecked == (validatedItems-2) ?
                                                  verifyClaimIp(context,request, widget?.member) : Scaffold.of(context).showSnackBar(SnackBar(content: Text('Please fill all the required fields')));
                                                }
                                              }
                                            }
                                          }
                                          validatedItems = 0;
                                          itemsChecked = 0;
                                        } : null,
                                        child: Text('Submit')
                                    ),
                                    SizedBox( height: 30,),
                                    copyRightText(),
                                  ],
                                )
                            )
                        )
                      ]
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _dropDownDisabledHolder(String text) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Text(
                text,
                style: TextStyle(color: Colors.black54),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getEmployeeDropdown(List<Dependent> dependents, bool hasDependent){
    List<String> dropDownItems = [];
    dropDownItems.add('${widget.member.firstName} ${widget.member.lastName}');
    if(hasDependent) {
      dependents.forEach((dep) {
        String name = '${dep.firstName} ${dep.lastName}';
        dropDownItems.add((name));
      });
    }

    final Widget button = SizedBox(
      width: double.infinity,
      height: 50,
      child: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Text(
                _selectedEmployee == null ? 'Choose Employee Names' : _selectedEmployee,
                style: TextStyle(color: _selectedEmployee == null ? Colors.black54: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,)
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
          _selectedEmployee = newValue;
          dependents.forEach((prov) {
            String name = '${prov.firstName} ${prov.lastName}';
            if(name == _selectedEmployee)
              _employee = prov.cardno;
            else if(name == '${widget.member.firstName} ${widget.member.lastName}')
              _employee = widget.member.cardno;
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
    //           child: Text('Choose Employee Name', textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.w600),)
    //       ),
    //       icon: Icon(Icons.keyboard_arrow_down),
    //       isExpanded: true,
    //       value: _selectedEmployee,
    //       onChanged: (newValue) {
    //         setState(() {
    //           _selectedEmployee = newValue;
    //           dependents.forEach((prov) {
    //             String name = '${prov.firstName} ${prov.lastName}';
    //             if(name == _selectedEmployee)
    //               _employee = prov.cardno;
    //             else if(name == '${widget.member.firstName} ${widget.member.lastName}')
    //               _employee = widget.member.cardno;
    //           });
    //           print(_employee);
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
            setState((){
              _patient = widget?.member.cardno;
              _cardnoPatient = _patient;
            });
          } else {
            dependents.forEach((prov) {
              String name = '${prov.firstName} ${prov.lastName}';
              if(name == _selectedPatient){
                setState((){
                  _patient = prov.cardno;
                  _cardnoPatient = _patient;
                });
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
  }

  Widget _getPresentAddress() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(bottom: 5.0),
              child: Text('Present Addresss', style: TextStyle(fontSize: 14.0,))
          ),
          Card(
            elevation: 5,
            child: TextFormField(
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87)
                ),
              ),
              onTap: () { _appSessionCallback.pauseAppSession(); },
              onSaved: (String val) {
                //_complaints = val;
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _getSignature() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(bottom: 5.0),
              child: Text('Signature', style: TextStyle(fontSize: 14.0,))
          ),
          Card(
            elevation: 5,
            child: TextFormField(
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87)
                ),
              ),
              onTap: () { _appSessionCallback.pauseAppSession(); },
              onSaved: (String val) {
                //_complaints = val;
              },
            ),
          )
        ],
      ),
    );
  }

  void verifyClaimIp(BuildContext context, ClaimRequest request, Member member){
    Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VerifyClaimsIpPage(
                    member: member,
                    request: request,
                  ),
                )
            );
  }

  void _outShowFileDialog() {
    // set up the AlertDialog
    showDialog(
      context: mContext,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))
          ),
          title: Text('Upload file from...', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              FlatButton(
                child: Text('Camera'),
                onPressed: () {
                  outGetImage(ImageSource.camera);
                  _appSessionCallback.pauseAppSession();
                  Navigator.of(context).pop('dialog');
                },
              ),
              FlatButton(
                child: Text('Gallery'),
                onPressed: () {
                  outGetImage(ImageSource.gallery);
                  _appSessionCallback.pauseAppSession();
                  Navigator.of(context).pop('dialog');
                },
              ),
              // FlatButton(
              //   child: Text('File Explorer'),
              //   onPressed: () {
              //     outGetFile(FileType.image);
              //     _appSessionCallback.pauseAppSession();
              //     Navigator.of(context).pop('dialog');
              //   },
              // ),
            ],
          ),

        );
      },
    );
  }

  void _outShowClaimFormFileDialog() {
    // set up the AlertDialog
    showDialog(
      context: mContext,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))
          ),
          title: Text('Upload file from...', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              FlatButton(
                child: Text('Camera'),
                onPressed: () {
                  outGetClaimFormImage(ImageSource.camera);
                  _appSessionCallback.pauseAppSession();
                  Navigator.of(context).pop('dialog');
                },
              ),
              FlatButton(
                child: Text('Gallery'),
                onPressed: () {
                  outGetClaimFormImage(ImageSource.gallery);
                  _appSessionCallback.pauseAppSession();
                  Navigator.of(context).pop('dialog');
                },
              ),
              // FlatButton(
              //   child: Text('File Explorer'),
              //   onPressed: () {
              //     outGetClaimFormFile(FileType.image);
              //     _appSessionCallback.pauseAppSession();
              //     Navigator.of(context).pop('dialog');
              //   },
              // ),
            ],
          ),

        );
      },
    );
  }

  Widget _disableBrowseButton() {
    return Column(
      children: <Widget>[
        RaisedButton(
          elevation: 5,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: mPrimaryColor)),
          onPressed: () {
          },
          child: Container(
            width: double.infinity,
            height: 75,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('You have selected 3 images', style: TextStyle(fontSize: 15)),
                SizedBox(width: 30,),
                Icon(Icons.cloud_upload, size: 40,)
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _outGetBrowseButton() {
    return Column(
      children: <Widget>[
        RaisedButton(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: mPrimaryColor)),
          onPressed: () {
            //Open Camera, File handler...
            _outShowFileDialog();
            _appSessionCallback.pauseAppSession();
          },
          child: Container(
            width: double.infinity,
            height: 75,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Add file', style: TextStyle(fontSize: 15)),
                SizedBox(width: 30,),
                Icon(Icons.cloud_upload, size: 40,)
              ],
            ),
          ),
        ),
      ],
    );
  }
  Widget _outGetBrowseClaimFormButton() {
    return Column(
      children: <Widget>[
        RaisedButton(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: mPrimaryColor)),
          onPressed: () {
            //Open Camera, File handler...
            _outShowClaimFormFileDialog();
            _appSessionCallback.pauseAppSession();
          },
          child: Container(
            width: double.infinity,
            height: 75,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Add file', style: TextStyle(fontSize: 15)),
                SizedBox(width: 30,),
                Icon(Icons.cloud_upload, size: 40,)
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _inShowFileDialog(String uploadTO) {
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
                  inGetImage(ImageSource.camera, uploadTO);
                  _appSessionCallback.pauseAppSession();
                  Navigator.of(context).pop('dialog');
                },
              ),
              FlatButton(
                child: Text('Gallery'),
                onPressed: () {
                  inGetImage(ImageSource.gallery, uploadTO);
                  _appSessionCallback.pauseAppSession();
                  Navigator.of(context).pop('dialog');
                },
              ),
              // FlatButton(
              //   child: Text('File Explorer'),
              //   onPressed: () {
              //     inGetFile(FileType.image, uploadTO);
              //     _appSessionCallback.pauseAppSession();
              //     Navigator.of(context).pop('dialog');
              //   },
              // ),
            ],
          ),

        );
      },
    );
  }

  Widget _inGetBrowseButton(String uploadTo) {
    return Column(
      children: <Widget>[
        RaisedButton(
          elevation: 5,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: mPrimaryColor)),
          onPressed: () {
            //Open Camera, File handler...
            _inShowFileDialog(uploadTo);
            _appSessionCallback.pauseAppSession();
          },
          child: Container(
            width: double.infinity,
            height: 75,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Add File', style: TextStyle(fontSize: 15)),
                SizedBox(width: 30,),
                Icon(Icons.cloud_upload, size: 40,)
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _datePicker(context, String dateFor) {
    DatePicker
        .showDatePicker(
        context,
        showTitleActions: true,
        minTime: DateTime(1800, 1, 1),
        maxTime: DateTime.now(),
        onChanged: (date) { print('change ${date.month}'); },
        onConfirm: (date) {
          setState(() {
            selectedDateText = '${date.month}/${date.day}/${date.year}';
            _date = date;
            if(dateFor == 'birthday'){
              dobTextController.text = selectedDateText;
            }else if(dateFor == 'injury'){
              injTextController.text = selectedDateText;
            }else if(dateFor == 'consultationDay'){
              consultationController.text = selectedDateText;
            }else if(dateFor == 'injuryDate'){
              injuryDateController.text = selectedDateText;
            }else if(dateFor == 'symptomsOccur'){
              symptomsOccurController.text = selectedDateText;
            }else{
              cdTextController.text = selectedDateText;
            }
          });
        },
        currentTime: DateTime.now(), locale: LocaleType.en);
  }

  static String formatCurrency(num value,{int fractionDigits = 2}) {
    ArgumentError.checkNotNull(value, 'value');

    // convert cents into hundreds.
    value = value / 100;

    return NumberFormat.currency(
        customPattern: '###,###.##',
        // using Netherlands because this country also
        // uses the comma for thousands and dot for decimal separators.
        locale: 'nl_NL'
    ).format(value);
  }

}


class PdfViewPage extends StatefulWidget {
  final String path;
  final double maxHeight;
  final double maxWidth;

  const PdfViewPage({Key key, this.path, this.maxHeight, this.maxWidth}) : super(key: key);

  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  bool pdfReady = false;
  int _totalPages = 0;
  int _currentPage = 0;
  PDFViewController _pdfViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text('Claims', textAlign: TextAlign.center),
        flexibleSpace: Image(
          image:  AssetImage('assets/images/appBar_background.png'),
          fit: BoxFit.fill,),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(bottom: widget.maxHeight /2),
            child: PDFView(
              filePath: widget.path,
              autoSpacing: true,
              enableSwipe: true,
              pageSnap: true,
              swipeHorizontal: true,
              onRender: (_pages){
                setState(() {
                  _totalPages = _pages;
                  pdfReady = true;
                });
              },
              onViewCreated: (PDFViewController vc){
                _pdfViewController = vc;
              },
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: 55,
              child: Image.asset('assets/images/EtiqaLogoColored_SmileApp.png', fit: BoxFit.contain),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    RaisedButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.fromLTRB(60, 10, 60, 10),
                      child: Text('Submit', style: TextStyle(fontSize: 20)),
                      color: mPrimaryColor,
                      onPressed: (){
                        Navigator.pop(context);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => SuccessPage(from: 'claims')));
                      },
                    ),
                    SizedBox(height: 30,),
                    Text('Powered by:', style: TextStyle(color: Colors.black87, fontSize: 12.0)),
                    SizedBox(
                      height: 55,
                      child: Image.asset('assets/images/EtiqaLogoColored_SmileApp.png', fit: BoxFit.contain),
                    ),
                    myMultimediaAccounts(),
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: copyRightText()
                    ),
                  ],
                )
            ),
          ),

          !pdfReady?Center(child: CircularProgressIndicator(),):Offstage()
        ],
      ),
    );
  }
}
