import 'dart:convert';
import 'dart:io';

import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/api_token.dart';
import 'package:av_asian_life/data_manager/member.dart';
import 'package:av_asian_life/data_manager/user.dart';
import 'package:av_asian_life/home_page/session_callback.dart';
import 'package:av_asian_life/login/model/login_model.dart';
import 'package:av_asian_life/login/view/login_page.dart';
import 'package:av_asian_life/profile_page/forgot_email.dart';
import 'package:av_asian_life/profile_page/forgot_mobile.dart';
import 'package:av_asian_life/profile_page/quickview_page.dart';
import 'package:av_asian_life/profile_page/verify_change_password.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:av_asian_life/utility/common.dart';
import 'package:av_asian_life/utility/my_preference_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:av_asian_life/login/view/new_login_page.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ssh/ssh.dart';

import '../data_manager/offline_page.dart';

class ProfilePage extends StatefulWidget {
  static String tag = 'profile-page';
  final String cardNo;
  final String displayPic;
  final String username;
  final Member member;
  final IApplicationSession applicationSession;
  ProfilePage({this.cardNo, this.displayPic, this.applicationSession, this.username, this.member});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  IApplicationSession _applicationSession;
  LoginModel loginModel = new LoginModel();

  AlertDialog _loadingDialog;

  String _mobile, _email;
  String email;
  String mobile;
  String _username;
  String username;

  Future<Member> member;

  Member _mMember;



  double _uploadProgress = 0;
  int _downloadProgress = 0;
  File _image;
  File _imagePathFromSFTP;
  BuildContext mContext;

  int _imgDownloadAttempts = 0;

  String useQuickView;
  String _isLogEnabled;
  String _isClaimEnabled;

  bool _imageUpdated = false;
  bool _autoValidate = false;
  bool _isInteractionDisabled = true;
  bool _isUploading = false;
  bool isSelected = false;
  bool isLogEnabled = false;
  bool isClaimEnabled = false;
  bool isMember = true;
  bool allowFileClaim = false;
  bool allowRequestLog = false;

  @override
  void initState() {
    super.initState();
    getUsername();
    getPersonalSettings();

    if(widget.applicationSession != null)
      _applicationSession = widget.applicationSession;

    if(widget.displayPic != null)
      //_getImageFromCache(widget.displayPic);
      _getImageFromSFTP();

    setState(() {
      member = getMemberInfo(widget?.cardNo);
      if(widget?.cardNo.substring(14,17) != '000'){
        isMember = false;
      } else {
        isMember = true;
      }
    });

    if( _username == null )_getUsername();

    _getQuickView();
  }

  void getUsername() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      this.username = prefs.getString('_username');
    });
  }

  Future getPersonalSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    dynamic data;
    dynamic settings = [];
    String _username;

    _username = prefs.getString('_username')??('');

    var response = await http.post(
      Uri.encodeFull('${_base_url}GetPersonalSettings'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        "UserAccount": _email
      },
      body: {
        "userid" : _api_user,
        "password" : _api_pass,
        "appuserid" : _username,
      }
    );
    data = json.decode(response.body);
    settings = json.decode(data);

    setState((){
      if(settings[0]['value'] != 1){
        isClaimEnabled = false;
      } else {
        isClaimEnabled = true;
      }
      if(settings[1]['value'] != 1){
        isLogEnabled = false;
      } else {
        isLogEnabled = true;
      }
    });
    return "Success!";
  }

  Future updateRequestLogSetting(String setting, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    dynamic data;
    dynamic settings = [];

    String _username;

    _username = prefs.getString('_username')??('');

    var response = await http.post(
      Uri.encodeFull('${_base_url}UpdateRequestLOGSetting'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        "UserAccount": _email
      },
      body: {
        "userid" : _api_user,
        "password" : _api_pass,
        "appuserid" : _username,
        "value" : setting
      }
    );
    data = json.decode(response.body);
    settings = json.decode(data);
    setState((){
      if((settings[0]['msgDescription'] != '')||(settings[0]['msgDescription'] != null)){
        Navigator.pop(context);
      }
    });
    showMessageDialog(settings[0]['msgDescription'], context);
    return "Success!";
  }

  Future updateClaimFilingSetting(String setting, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    dynamic data;
    dynamic settings = [];

    String _username;

    _username = prefs.getString('_username')??('');

    var response = await http.post(
      Uri.encodeFull('${_base_url}UpdateClaimFilingSetting'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        "UserAccount": _email
      },
      body: {
        "userid" : _api_user,
        "password" : _api_pass,
        "appuserid" : _username,
        "value" : setting,
      }
    );
    data = json.decode(response.body);
    settings = json.decode(data);
    setState((){
      if((settings[0]['msgDescription'] != '')||(settings[0]['msgDescription'] != null)){
        Navigator.pop(context);
      }
    });
    showMessageDialog(settings[0]['msgDescription'], context);
    return "Success!";
  }

  void showConfirmClaimDialog(String setting, BuildContext context, String message){
    Widget yesButton = FlatButton(
      child: Text('Continue'),
      onPressed: () {
        Navigator.pop(context);
        _showLoadingDialog();
        updateClaimFilingSetting(setting, context);
      },
    );
    Widget noButton = FlatButton(
      child: Text('Cancel'),
      onPressed: () {
        getPersonalSettings();
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))
      ),
      title: Text(""),
      content: Text(message,textAlign: TextAlign.center),
      actions: [
        yesButton,
        noButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showConfirmLogDialog(String setting, BuildContext context, String message){
    Widget yesButton = FlatButton(
      child: Text('Continue'),
      onPressed: () {
        Navigator.pop(context);
        _showLoadingDialog();
        updateRequestLogSetting(setting, context);
      },
    );
    Widget noButton = FlatButton(
      child: Text('Cancel'),
      onPressed: () {
        getPersonalSettings();
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))
      ),
      title: Text(""),
      content: Text(message,textAlign: TextAlign.center),
      actions: [
        yesButton,
        noButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showMessageDialog(String message, BuildContext context){
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => new AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))
          ),
          title: new Text(""),
          content: new Text(message,textAlign: TextAlign.center),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () async {
                Navigator.pop(context);
              },
            )
          ],
        ));
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
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _loadingDialog;
      },
    );

  }

  void _getUsername() async{
    print('username is null');
    MyPreferenceHandler myPreferenceHandler = MyPreferenceHandler();
    bool hasAuthData = await myPreferenceHandler.hasUserAuthData();

    if(hasAuthData){
      User user = await myPreferenceHandler.getAuthData();
      print("User: ${user.username}");

      _username = user.username;

    }
  }

  void _setQuickView(bool quik) async{
    print("setting quickview");
    String setter;
    if(quik == true){ setter = 'yes'; }
    if(quik == false){ setter = 'no'; }
    MyPreferenceHandler myPreferenceHandler = MyPreferenceHandler();
    await myPreferenceHandler.setQuickView(setter);
  }

  void _getQuickView() async{
    MyPreferenceHandler myPreferenceHandler = MyPreferenceHandler();
    useQuickView = await myPreferenceHandler.getQuickView();
    if(useQuickView.toString() == 'yes'){ isSelected = true; }
    if(useQuickView.toString() == 'no'){ isSelected = false; }
  }

  @override
  void dispose() {
    super.dispose();
    print('dispose called in ProfilePage');
    String displayPic = '';
    if(_image?.path != null)
      displayPic = basename(_image.path);

    _applicationSession.onExitProfilePage(_imageUpdated, displayPic);
  }

  Future<Member> getMemberInfo(String cardNo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var baseUrl = await ApiHelper.getBaseUrl();
    var apiUser = await ApiHelper.getApiUser();
    var apiPass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();
    String _deviceId = await ImeiPlugin.getImei();

    String url = '${baseUrl}MemberInfo';
    try {
      var res = await http.post(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          "UserAccount": _email,
          "DeviceID": _deviceId
        },
        body : {
          "userid" : apiUser,
          "password" : apiPass,
          "cardno" : cardNo,
          "frommain" : "0"
        }
      );
      var json = jsonDecode(jsonDecode(res.body));

      List<Member> data = [];
      json.forEach((entity) {
        data.add(Member.fromJson(entity));
      });

      if (data[0].cardno != null) {
        print(json);
        _mMember = data[0];
        email = _mMember.email;
        mobile = _mMember.mobileno;
        print('mobile no: $email');
        return data[0];
      } else {
        print('Error Fetching Member Info: $json');
        return null;
      }
    } catch(e) {
      print(e);
      return null;
    }finally{
      print('displaypic: ${_mMember?.displaypic}');
      if(_mMember?.displaypic != null)
        _downloadImage();
    }
  }

  void _initUpdateProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var baseUrl = await ApiHelper.getBaseUrl();
    var apiUser = await ApiHelper.getApiUser();
    var apiPass = await ApiHelper.getApiPass();

    var token = await ApiToken.getApiToken();

    String imageName = '';
    print('image?.path: ${_image?.path}');
    print('_mMember?.displaypic: ${_mMember?.displaypic}');

    if(_imageUpdated)
      imageName = basename(_image.path);
    else
      imageName = _mMember.displaypic;

    print('mobile: $_mobile');
    print('email: $_email');
    print('imageName: $imageName');

    if(_mobile == null)
      _mobile = _mMember.mobileno;
    if(_email == null)
      _email = _mMember.email;
    setState(() {
      _uploadProgress = 0.7;
    });
    String url = '${baseUrl}UpdateMemberContactInfo';
    print(url);

    setState(() {
      _uploadProgress = 0.8;
    });

    try {
      var res = await http.post(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          "UserAccount": _email
        },
        body: {
          "userid" : apiUser,
          "password" : apiPass,
          "cardno" : widget.cardNo,
          "mobileno" : _mobile,
          "emailadd" : _email,
          "displaypic" : imageName,
        }
      );
      var json = jsonDecode(jsonDecode(res.body));
      print(json);

      setState(() {
        _uploadProgress = 1.0;
      });
      //_shouldFetchMemberData = true;
      _showAlertDialog(true, 'Update Success');
    }catch (e) {
      print(e);
      var res = await http.post(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          "UserAccount": _email
        },
        body: {
          "userid" : apiUser,
          "password" : apiPass,
          "cardno" : widget.cardNo,
          "mobileno" : _mobile,
          "emailadd" : _email,
          "displaypic" : imageName,
        }
      );
      var json = jsonDecode(res.body);
      String msg;
      print(json);

      setState(() {
        _uploadProgress = 0.9;
      });

      if(json['Message'] != null)
        msg = json['Message'];
      else msg = 'Connection Error occured.';
      //_shouldFetchMemberData = false;

      setState(() {
        _uploadProgress = 0;
        _isUploading = false;
      });

      _showAlertDialog(false, msg);
    }
  }

  void _showAlertDialog(bool isSuccess, String text) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(isSuccess ? "Success" : "Warning"),
      content: Text(isSuccess ? "Changes Saved" : text == '' ? "Saving Failed" : text, textAlign: TextAlign.center),
      actions: <Widget>[
        FlatButton(
          child: Text("OK"),
          onPressed: () {
            setState(() {
              _isInteractionDisabled = true;
              Navigator.of(this.context).pop('dialog');
              //Redirect UI to another page i.e. HomePage
            });
          },
        )
      ],
    );

    if(isSuccess) {
      setState(() {
        _isUploading = false;
      });
    }

    // show the dialog
    showDialog(
      context: this.context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future _uploadImage() async {
    if(_image != null) {
      setState(() {
        _isUploading = true;
        print('is Uploading');
      });
    }

    SSHClient client;

    var host = await ApiHelper.getSFTPHost();
    var port = await ApiHelper.getSFTPPort();
    var user = await ApiHelper.getSFTPUser();
    var pass = await ApiHelper.getSFTPPass();

    try{

      if(_image != null) {
        client = new SSHClient(
          host: host,
          port: port,
          username: user,
          passwordOrKey: pass,
        );

        var clientResult = await client.connect();

        if (clientResult == 'session_connected') {
          var sftpResult = await client.connectSFTP();

          if(sftpResult == 'sftp_connected') {

            print('sftp connected');
            var result;
            result = await client.sftpUpload(
              path: _image.path,
              toPath: '/data/MyProfile',
              callback: (progress) async {
                print('Uploading: $progress%'); // read upload progress
                setState(() {
                  _uploadProgress = progress /2 * .01;
                  _applicationSession.pauseAppSession();
                });
              },
            );

            print('Result: $result');
            if(result == 'upload_success') {
              _imageUpdated = true;
              _initUpdateProfile();
            }
            _uploadProgress = 0;
            _imagePathFromSFTP = null;
            await client.disconnectSFTP();
          }
          client.disconnect();
        }
      }
    } catch (e) {
      print(e);
      //  print('Closing Clients on catch');
      //  client?.disconnectSFTP();
      //  client?.disconnect();
    }
  }

  void _getImageFromCache(String displayPic) async {
    print('_getImageFromCache');
    try {
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;

      File file = File('$tempPath/$displayPic');
      if (file.existsSync()) {
        print('file does exist from cache.');
        setState(() {
          _imagePathFromSFTP = file;
          print(_imagePathFromSFTP);
        });
      } else {
        print('file does not exist from cache.');
        _getImageFromSFTP();
      }
    } catch (e) {
      print(e);
    }
  }

  void _getImageFromSFTP() async {
    print('_downloadImage');
    _imgDownloadAttempts++;
    SSHClient client;

    var host = await ApiHelper.getSFTPHost();
    var port = await ApiHelper.getSFTPPort();
    var user = await ApiHelper.getSFTPUser();
    var pass = await ApiHelper.getSFTPPass();

    try{
      client = SSHClient(
        host: host,
        port: port,
        username: user,
        passwordOrKey: pass,
      );

      var clientResult = await client.connect();

      if (clientResult == 'session_connected') {
        var sftpResult = await client.connectSFTP();

        if(sftpResult == 'sftp_connected') {
          Directory tempDir = await getTemporaryDirectory();
          String tempPath = tempDir.path;

          if(_mMember?.displaypic != null || _mMember?.displaypic != '') {

            var filePath = await client.sftpDownload(
              path: '/data/MyProfile/${_mMember?.displaypic}',
              toPath: tempPath,
              callback: (progress) async {
                print('Downloading: $progress%'); // read download progress
                _downloadProgress = progress;
              },
            );

            print('_downloadProgress: $_downloadProgress');

            if(_downloadProgress >= 95) {
              if(filePath != null) {
                setState(() {
                  _imagePathFromSFTP = File(filePath);
                  print(_imagePathFromSFTP);
                });
              }
            } else if(_downloadProgress == 0) {
              print('_downloadImage: Download Failed');
            }

          } else{
            print('_downloadImage: No Image found in SFTP');
          }
          await client?.disconnectSFTP();
        }
        client?.disconnect();
      }

    } catch(e) {
      print('Download Exception occurred.');
      print(e);
      if(e?.code != 'connection_failure') {
        if (_imgDownloadAttempts < 5 && _imagePathFromSFTP != null)
          _downloadImage();
      }

//      print('Closing Clients on catch');
//      client?.disconnectSFTP();
//      client?.disconnect();
    }
  }

  void _downloadImage() async {
    if(_mMember.displaypic == widget.displayPic)
      _getImageFromCache(widget.displayPic);
    else
      _getImageFromSFTP();
  }

  @override
  Widget build(BuildContext context) {
    mContext = context;
    return Container(
      decoration: myAppBackground(),
      child: Stack(
        children: <Widget>[
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              actions: <Widget>[
                GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: Icon(Icons.exit_to_app),
                    ),
                    onTap: () {
                      //Clear Login Data here...
                      _applicationSession.pauseAppSession();
                      _showLogoutDialog();
                    }),
              ],
            ),
            body: LayoutBuilder(
                builder: (context, constraint){
                  final height = constraint.maxHeight;
                  final width = constraint.maxWidth;
                  return _gradientBG(height, width);
                }),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Message'),
      content: Text('Are you sure you want to exit the App?'),
      actions: <Widget>[
        FlatButton(
          child: Text("Cancel", style: TextStyle(color: Colors.black45),),
          onPressed: () {
            setState(() {
              Navigator.of(this.context).pop('dialog');
              //Redirect UI to another page i.e. HomePage
            });
          },
        ),
        FlatButton(
          child: Text("Confirm"),
          onPressed: () async {
            await loginModel.LogOut();
            setState(() {
              prefs.remove('token');
              // MyPreferenceHandler myPreferenceHandler = MyPreferenceHandler();
              // myPreferenceHandler.destroyUserData().then((bool isDone) {
              //   //Remove all Routes/Page then redirect to LoginPage
              //   Navigator.of(this.context)
              //       .pushNamedAndRemoveUntil(
              //       LoginPage.tag, (Route<dynamic> route) => false
              //   );
              // });
              MyPreferenceHandler myPreferenceHandler = MyPreferenceHandler();
              myPreferenceHandler.releaseUserData();
              Navigator.of(this.context).pushNamedAndRemoveUntil(
                  NewLoginPage.tag, (Route<dynamic> route) => false);
            });
          },
        ),
      ],
    );


    // show the dialog
    showDialog(
      context: this.context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget _textFields(double height, double width, Member member, BuildContext context) {
    return Form(
      key: _formKey,
      autovalidate: _autoValidate,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        child: Column(
          children: <Widget>[
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 10.0),
            //   child: SizedBox(
            //     child: TextFormField(
            //       initialValue: _username,
            //       keyboardType: TextInputType.emailAddress,
            //       enabled: false,
            //       decoration: InputDecoration(
            //         border: UnderlineInputBorder(),
            //         hintText: "Username",
            //         labelText: "User Name",
            //       ),
            //       validator: null,
            //       onSaved: (String val) {

            //       },
            //     ),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: SizedBox(
                child: TextFormField(
                  initialValue: member.lastName,
                  keyboardType: TextInputType.emailAddress,
                  enabled: false,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: "Last Name",
                    labelText: "Last Name",
                  ),
                  validator: null,
                  onSaved: (String val) {

                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: SizedBox(
                child: TextFormField(
                  initialValue: member.firstName,
                  keyboardType: TextInputType.emailAddress,
                  enabled: false,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: "First Name",
                    labelText: "First Name",
                  ),
                  validator: null,
                  onSaved: (String val) {

                  },
                ),
              ),
            ),
            Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: SizedBox(
                    child: TextFormField(
                      initialValue: member.mobileno,
                      keyboardType: TextInputType.emailAddress,
                      enabled: false,
                      onTap: () { _applicationSession.pauseAppSession(); },
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        hintText: "e.g. 09123456789",
                        labelText: "Mobile No.",
                      ),
                      validator: _phoneNumberValidator,
                      onSaved: (String val) {
                        _mobile = '';
                        _mobile = val;
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: EdgeInsets.only(top: 35),
                    child: InkWell(
                      onTap: (){
                        //pauseAppSession();
                        Navigator.push(context,
                            MaterialPageRoute(
                                builder: (context) => ForgotMobilePage(sendEmailPass: new SendEmailPass(email,mobile,widget.cardNo))));
                      },
                      child: Icon(Icons.edit),
                    ),
                  ),
                )
              ],
            ),
            Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: SizedBox(
                    child: TextFormField(
                      initialValue: member.email,
                      keyboardType: TextInputType.emailAddress,
                      enabled: false,
                      onTap: () { _applicationSession.pauseAppSession(); },
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        hintText: "Email",
                        labelText: "Email",
                      ),
                      validator: _validateEmail,
                      onSaved: (String val) {
                        _email = '';
                        _email = val;
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: EdgeInsets.only(top: 35),
                    child: InkWell(
                      onTap: (){
                        Navigator.push(context,
                            MaterialPageRoute(
                                builder: (context) => ForgotEmailPage(sendEmailPass: new SendEmailPass(email,mobile,widget.cardNo))));
                      },
                      child: Icon(Icons.edit),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: SizedBox(
                child: TextFormField(
                  initialValue: member.dob,
                  keyboardType: TextInputType.emailAddress,
                  enabled: false,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: "Date of Birth",
                    labelText: "Date of Birth ",
                  ),
                  validator: null,
                  onSaved: (String val) {

                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: SizedBox(
                child: TextFormField(
                  initialValue: this.username,
                  keyboardType: TextInputType.emailAddress,
                  enabled: false,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: "Username",
                    labelText: "Username",
                  ),
                  validator: null,
                  onSaved: (String val) {

                  },
                ),
              ),
            ),
            Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: SizedBox(
                    child: Text("Quick View"),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                      child: Switch(
                        value: isSelected, onChanged: (bool newValue){
                          setState(() {
                            // _setQuickView(newValue);
                            if(newValue == true){
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => QuickViewPage()));
                            } else if(newValue == false){
                              setState((){
                                _setQuickView(false);
                              });
                            }
                            isSelected = newValue;
                          });
                      })
                  ),
                )
              ],
            ),
            isMember == true ? Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: SizedBox(
                    child: Text("Enable dependent to request LOG"),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                      child: Switch(
                          value: isLogEnabled, onChanged: (bool newValue){
                            String _logMsg;
                            setState(() {
                              if(newValue == true){
                                _isLogEnabled = '1';
                                _logMsg = 'Allowing your dependents to request LOG on their own also give them liberty to provide any information known to them.';
                              } else if(newValue == false){
                                _isLogEnabled = '0';
                                _logMsg = 'Disabling this feature will restrict your dependents from requesting LOG on their own.';
                              }
                              isLogEnabled = newValue;
                              showConfirmLogDialog(_isLogEnabled, context, _logMsg);
                              //updateRequestLogSetting(_isLogEnabled, context);
                          });
                      })
                  ),
                )
              ],
            ) : Offstage(),
            isMember == true ? Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: SizedBox(
                    child: Text("Enable dependent to file claim"),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                      child: Switch(
                          value: isClaimEnabled, onChanged: (bool newValue){
                            String _claimMsg;
                            setState(() {
                              if(newValue == true){
                                _isClaimEnabled = '1';
                                _claimMsg = 'Allowing your dependents to file claims on their own also give them liberty to provide any information known to them including the fund transfer details.';
                              } else if(newValue == false){
                                _isClaimEnabled = '0';
                                _claimMsg = 'Disabling this feature will restrict your dependents from filing claim on their own.';
                              }
                              isClaimEnabled = newValue;
                              showConfirmClaimDialog(_isClaimEnabled, context, _claimMsg);
                              //updateClaimFilingSetting(_isClaimEnabled, context);
                            });
                      })
                  ),
                )
              ],
            ) : Offstage(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25.0),
              child: SizedBox(
                width: width,
                child: RaisedButton(
                  padding: EdgeInsets.all(12),
                  color: mPrimaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  child: Text('Change password', style: TextStyle(color: Colors.black54)),
                  onPressed: (){
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context) => VerifyChangePasswordPage(member: widget?.member)));
                  }
                ),
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget _gradientBG(double height, double width){
    return Container(
      height: height,
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Hero(
                      tag: 'profile-pic',
                      child: Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: ClipOval(
                          child: Container(
                              height: 125,
                              width: 125,
                              child: GestureDetector(
                                child: _image == null ?
                                CircleAvatar(backgroundImage: _imagePathFromSFTP != null ? FileImage(_imagePathFromSFTP) : AssetImage('assets/images/default_profile_img.png'), radius: 200.0, backgroundColor: Colors.transparent,):
                                CircleAvatar(backgroundImage: FileImage(_image), radius: 200.0,),
                                onTap: _isInteractionDisabled ? null : _showFileDialog,
                              )
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                        onTap: () {
                          _applicationSession.pauseAppSession();
                          setState(() {
                            _isInteractionDisabled = false;
                          });
                          _showFileDialog();
                        },
                        child: Icon(Icons.camera_alt)
                    )
                  ],
                ),

                Visibility(
                  visible: _isUploading,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 135.0, top: 15.0),
                    child: LinearPercentIndicator(
                      width: 150.0,
                      lineHeight: 25.0,
                      percent: _uploadProgress,
                      center: Text('${(_uploadProgress * 100).toInt()}%', style: TextStyle(color: Colors.white),),
                      backgroundColor: Colors.white,
                      progressColor:  mPrimaryColor,
                    ),
                  ),
                ),

//                Visibility(
//                  visible: !_isUploading,
//                  child: Padding(
//                    padding: const EdgeInsets.only(left: 5.0, top: 10.0),
//                    child: RaisedButton(
//                      padding: EdgeInsets.all(12),
//                      color: mPrimaryColor,
//                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                      child: Text('Choose Photo', style: TextStyle(color: Colors.black87)),
//                      onPressed: _isInteractionDisabled ? null : _showFileDialog,
//                    ),
//                  ),
//                ),
              ],
            ),
          ),
          Container(
            child: FutureBuilder<Member>(
              future: member,
              builder: (BuildContext context, AsyncSnapshot<Member> snapshot){
                if(!snapshot.hasData)
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 200),
                    child: myLoadingIcon(height: (height * .5) * .25),
                  );
                else {

                  if(snapshot.data != null)
                    return _textFields(height, width, snapshot.data, context);
                  else
                    return Container(child: Text('Connection error occured'),);
                }
              },
            ),
          ),
          SizedBox(height: 90.0,),
          Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(
                    height: 60,
                    child: Image.asset('assets/images/smile_app_icon_sm.png', fit: BoxFit.contain),
                  ),
                  SizedBox(height: 10.0,),
                  copyRightText()
                ],
              )
          ),
        ],
      ),
    );
  }

  void _validateInputs() {
    setState(() {
      if (_formKey.currentState.validate()) {
        _isInteractionDisabled = true;
        //If all data are correct then init onSave function in each TextFormField
        _formKey.currentState.save();

        if(_image != null) {
          print('init Upload');
          _uploadImage();
        }else {
          print('no upload');
          _initUpdateProfile();
        }


      } else {
        //If all data are not valid then start auto validation.
        setState(() {
          _autoValidate = true;
        });
      }

    });
  }

  String _validateEmail(String email) {
    return Common.validateEmail(email);
  }

  String _phoneNumberValidator(String phone) {
    return Common.phoneNumberValidator(phone);
  }

  Future getImage(ImageSource source) async {

    ImagePicker.pickImage(source: source).then((File image) async {
      Directory tempDir = await getTemporaryDirectory();

      String newName = '${widget?.cardNo}.${extension(image.path)}';

      File newImage = await image.copy('${tempDir.path}/$newName');

      print('${newImage.path}');

      setState(() {
        _image = newImage;
        _uploadImage();
      });
    });

  }

  void _showFileDialog() {
    // set up the AlertDialog
    _applicationSession.pauseAppSession();
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
                  _applicationSession.pauseAppSession();
                  getImage(ImageSource.camera);
                  Navigator.of(context).pop('dialog');
                },
              ),
              FlatButton(
                child: Text('Gallery'),
                onPressed: () {
                  _applicationSession.pauseAppSession();
                  getImage(ImageSource.gallery);
                  Navigator.of(context).pop('dialog');
                },
              ),
              // FlatButton(
              //   child: Text('Revert'),
              //   onPressed: () {
              //     _applicationSession.pauseAppSession();
              //     setState(() {
              //       _image = null;
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

}

class SendEmailPass {
  final String email;
  final String mobile;
  final String cardno;

  SendEmailPass(this.email, this.mobile, this.cardno);
}
