import 'dart:async';
import 'dart:io';

import 'package:av_asian_life/FAQ/view/faq_page.dart';
import 'package:av_asian_life/claims/view/claims_page.dart';
import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/member.dart';
import 'package:av_asian_life/data_manager/principal_info.dart';
import 'package:av_asian_life/find_doctor/find_doctor_page.dart';
import 'package:av_asian_life/find_provider/find_provider_page.dart';
import 'package:av_asian_life/home_page/session_callback.dart';
import 'package:av_asian_life/inquiries/inquiries_page.dart';
import 'package:av_asian_life/letter_of_guarantee/view/letter_of_guarantee_page.dart';
import 'package:av_asian_life/login/login_contract.dart';
import 'package:av_asian_life/login/model/login_model.dart';
import 'package:av_asian_life/login/presenter/login_presenter.dart';
import 'package:av_asian_life/login/view/init_login.dart';
//import 'package:av_asian_life/login/view/login_page.dart';
import 'package:av_asian_life/login/view/new_login_page.dart';
import 'package:av_asian_life/policy_details/policy_details_page.dart';
import 'package:av_asian_life/profile_page/profile_page.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:av_asian_life/utility/my_preference_helper.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ssh/ssh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';


class HomePage extends StatefulWidget {
  static String tag = 'home-page';
  final Member member;

  HomePage({this.member});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver implements IApplicationSession {
  MyPreferenceHandler _myPreferenceHandler = MyPreferenceHandler();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  LoginModel loginModel = new LoginModel();

  Member _member;

  BuildContext _mContext;

  int _downloadProgress = 0;
  int _imgDownloadAttempts = 0;
  int _sessionTime = 5; //Minutes
  int _idleCounter = 20; //Seconds
  int _notificationCount = 0;

  Timer _sessionTimer, _idleCountdown;

  bool _notifcations = false;
  bool dataLoaded = false;
  bool _didUpdate = false;


  String imageData;
  String _displayPic;
  String inProgress;

  File savedImage;
  File _imagePathFromSFTP;


  Future<List<PrincipalInfo>> principalInfo;

  String _capWords(String text) =>
      toBeginningOfSentenceCase(text.toLowerCase());

  String _formatCardNo(String str) =>
      str.substring(0, 3) +
          " " +
          str.substring(3, 8) +
          " " +
          str.substring(
            8,
            14,
          ) +
          " " +
          str.substring(14, str.length);

  Widget _generateQRCode(double size) {
    return QrImage(
      data: _member.qrcode,
      version: QrVersions.auto,
      size: size,
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    initApplicationSession();
    getImei();
    //secureScreen();

    setCardNo();

    _member = widget?.member;
    _displayPic = _member?.displaypic;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('displaypic: $_displayPic');
      if (_displayPic != null) {
        _downloadImage();
        setState(() {
          inProgress = 'downloading Image';
        });
      }
    });
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true)
    );
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic>message) async {
          print("onMessage: $message");
          setState(() {
            _notifcations = true;
            _notificationCount = _notificationCount + 1;
          });
        },
        onLaunch: (Map<String, dynamic>message) async {
          print("onLaunch: $message");
        },
        onResume: (Map<String, dynamic>message) async {
          print("onResume: $message");
        }
    );

  }

  getImei() async {
    var deviceid = await _getId();
    print('Device ID: $deviceid');
  }

  Future<String> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  setCardNo() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('_Cardno',_member.cardno);
    prefs.setString('mobileno',_member.mobileno);
    prefs.setString('_email',_member.email);
  }

  @override
  initApplicationSession() {
    print('App Session Started');
    _sessionTimer = Timer(Duration(minutes: _sessionTime), () {
      //Logout user..
      _showSessionExpiredDialog();
      print('App Session Ended');

    });
  }

  @override
  pauseAppSession() {
    _sessionTimer?.cancel();
    print('_sessionTimer canceled');
    _idleCountdown?.cancel();
    print('_idleCountdown canceled');

    print('_idleCountdown re-initialize');
    _idleCountdown = Timer(Duration(seconds: _idleCounter), () {
      print('initApplicationSession re-initialize by _idleCountdown');
      initApplicationSession();
    });
  }

  @override
  onExitProfilePage(bool didUpdate, String displayPic) {
    print('onExitProfilePage: didUpdateImage = $didUpdate');
    _didUpdate = didUpdate;
    if (_didUpdate) {
      _displayPic = displayPic;
      _imgDownloadAttempts = 0;
      _downloadImage();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state = $state');

    //This test will take effect in splash_screen_page.dart
    if (state == AppLifecycleState.paused) {
      //Set a destroyData flag to true in Preference for attempt clear.
      //When flag is true in initial run, it possibly meant that
      //the app was destroyed and didn't resumed.
      //In that case clear user data before showing SplashScreenPage.
      _myPreferenceHandler.setDestroyFlag(true);
      _myPreferenceHandler.getDestroyFlag().then((bool isDestroy) {
        print('destroy flag: $isDestroy');
      });
    } else if (state == AppLifecycleState.resumed) {
      //Set the destroyData flag to false in Preference
      //since the user went back into the app.
      //No clearing of data should happen before showing SplashScreenPage.
      _myPreferenceHandler.setDestroyFlag(false);
      _myPreferenceHandler.getDestroyFlag().then((bool isDestroy) {
        print('destroy flag: $isDestroy');
      });
    } else if (state == AppLifecycleState.detached) {
      //Set the destroyData flag to false in Preference
      //since the user went back into the app.
      //No clearing of data should happen before showing SplashScreenPage.
      print('app closed');
    }
  }

  // Future<void> secureScreen() async {
  //   await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  // }

  void _asyncMethod() async {
    print('downloading profile Picture!');
    //comment out the next two lines to prevent the device from getting
    // the image from the web in order to prove that the picture is
    // coming from the device instead of the web.
    final File image = _imagePathFromSFTP;
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = documentDirectory.path + "/images";
    var filePathAndName = documentDirectory.path + '/images/pic.jpg';
    //comment out the next three lines to prevent the image from being saved
    //to the device to show that it's coming from the internet
    await Directory(firstPath).create(recursive: true); // <-- 1
    final File newImage = await image.copy('$firstPath/pic.jpg');
    print(newImage);

    setState(() {
      savedImage = newImage;
      imageData = filePathAndName;
      dataLoaded = true;
    });
  }

  void _getImageFromCache() async {
    setState(() {
      inProgress = 'get image from cache';
    });
    print('_getImageFromCache');
    try {
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;

      File file = File('$tempPath/$_displayPic');

      if (file.existsSync()) {
        print('file does exist from cache.');
        setState(() {
          _imagePathFromSFTP = file;
          print(_imagePathFromSFTP);
          _asyncMethod();
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
    print('_getImageFromSFTP');
    SSHClient client;
    _imgDownloadAttempts++;

    var host = await ApiHelper.getSFTPHost();
    var port = await ApiHelper.getSFTPPort();
    var user = await ApiHelper.getSFTPUser();
    var pass = await ApiHelper.getSFTPPass();

    try {
      client = SSHClient(
        host: host,
        port: port,
        username: user,
        passwordOrKey: pass,
      );

      var clientResult = await client.connect();
      print('clientResult: $clientResult');
      if (clientResult == 'session_connected') {
        var sftpResult = await client.connectSFTP();
        print('sftpResult: $sftpResult');
        if (sftpResult == 'sftp_connected') {
          print('_downloadImage: Attempt #$_imgDownloadAttempts');

          Directory tempDir = await getTemporaryDirectory();
          String tempPath = tempDir.path;

          if (_displayPic != null || _displayPic != '') {
            print('tempPath: $tempPath');

            print('displaypic: ${_member?.displaypic}');

            var filePath = await client.sftpDownload(
              path: '/data/MyProfile/$_displayPic',
              toPath: tempPath,
              callback: (progress) {
                print('Downloading: $progress%'); // read download progress
                _downloadProgress = progress;
                setState(() {
                  _downloadProgress = progress;
                });
              },
            );

            print('filePath: $filePath');

            if (_downloadProgress >= 95) {
              if (filePath != null) {
                setState(() {
                  _imagePathFromSFTP = File(filePath);
                  print(_imagePathFromSFTP);
                  inProgress = 'image downloaded';
                  _asyncMethod();
                });
              }
            } else if (_downloadProgress == 0) {
              print('_downloadImage: Download Failed');
            }
          } else {
            print('_downloadImage: No Image found in SFTP');
          }

          await client.disconnectSFTP();
        }
        client?.disconnect();
      }
    } catch (e) {
      print('Download Exception occurred.');
      print(e);
      if (e?.code != 'connection_failure') {
        if (_imgDownloadAttempts < 5 && _imagePathFromSFTP != null)
          _downloadImage();
      }
//      print('Closing Clients on catch');
//      client?.disconnectSFTP();
//      client?.disconnect();
    }
  }

  void _downloadImage() async {
    if (_displayPic != null)
      _getImageFromCache();
    else
      _getImageFromSFTP();
  }

  @override
  Widget build(BuildContext context) {
    _mContext = context;

    String name = _member.firstName;

    String formattedName = _capWords(name.split(' ')[0]);
    return Container(
      decoration: myAppBackground(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(builder: (context, constraint) {
          final height = constraint.maxHeight;
          final width = constraint.maxWidth;
          return Stack(
            children: <Widget>[
              Container(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(
                        bottom: 10.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.only(
                                bottom: 10.0,
                                top: 10.0,
                                left: 25.0,
                                right: 25.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Hi $formattedName,',
                                  style: TextStyle(fontSize: 25.0),
                                ),
                                InkWell(
                                    onTap: () {
                                      pauseAppSession();
                                      Navigator.of(context).push(PageRouteBuilder(
                                          pageBuilder: (context, _, __) => _questionMark(context), opaque: false));
                                    },
                                    child: Hero(
                                        tag: 'profile-pic',
                                        child: CircleAvatar(
                                          backgroundImage: _imagePathFromSFTP !=
                                              null
                                              ? FileImage(_imagePathFromSFTP)
                                              : AssetImage(
                                              'assets/images/default_profile_img.png'),
                                          radius: 20.0,
                                          backgroundColor: Colors.transparent,
                                        ))),
                              ],
                            ),
                          ),
                          Container(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 20.0),
                            child: _virtualIDCard(height, width),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          InkWell(
                              onTap: () {
                                pauseAppSession();
                                setState(() {
                                  _notifcations = false;
                                  _notificationCount = 0;
                                  print('notification close');
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          LetterOfGuaranteePage(
                                            member: _member,
                                            appSessionCallback: this,
                                          )),
                                );
                              },
                              child: Stack(
                                children: <Widget>[
                                  _getHomePageButtons(
                                      'assets/images/GLRequest_v1.png',
                                      'Letter of\nGuarantee'),
                                  _notifcations == true ?
                                  Padding(
                                    padding: EdgeInsets.only(left: 35),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.red,
                                      radius: 10,
                                      child: Text('$_notificationCount', style: TextStyle(color: Colors.white, fontSize: 10),),
                                    ),
                                  )
                                      : Offstage()
                                ],
                              )
                          ),
                          InkWell(
                              onTap: () {
                                pauseAppSession();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FindProviderPage(
                                          appSessionCallback: this)),
                                );
                              },
                              child: _getHomePageButtons(
                                  'assets/images/FindHospitals_v1.png',
                                  'Find\nProvider')),
                          InkWell(
                              onTap: () {
                                pauseAppSession();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FindDoctorPage(
                                          appSessionCallback: this)),
                                );
                              },
                              child: _getHomePageButtons(
                                  'assets/images/FindDoctors_v1.png',
                                  'Find\nDoctor')),
                          InkWell(
                              onTap: () {
                                pauseAppSession();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => InquiriesPage(
                                          appSessionCallback: this)),
                                );
                              },
                              child: _getHomePageButtons(
                                  'assets/images/Inquiries_v1.png',
                                  'Inquiries')),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          RaisedButton(
                            padding: EdgeInsets.only(
                                top: 8, bottom: 8, left: 20, right: 10),
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                            child: _getHomePageOptionButtons('Policy Details'),
                            onPressed: () {
                              pauseAppSession();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PolicyDetailsPage(
                                      member: _member,
                                      appSessionCallback: this,
                                    )),
                              );
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          RaisedButton(
                            padding: EdgeInsets.only(
                                top: 8, bottom: 8, left: 20, right: 10),
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                            child: _getHomePageOptionButtons('Claims'),
                            onPressed: () {
                              pauseAppSession();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ClaimsPage(
                                      member: _member,
                                      appSessionCallback: this,
                                    )),
                              );
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          RaisedButton(
                            padding: EdgeInsets.only(
                                top: 8, bottom: 8, left: 20, right: 10),
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                            child: _getHomePageOptionButtons(
                                'FAQ'),
                            onPressed: () {
                              pauseAppSession();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FaqPage(
                                      member: _member,
                                      appSessionCallback: this,
                                    )),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                // SizedBox(
                                //   width: 50.0,
                                // ),
                                Center(
                                  child: SizedBox(
                                    height: 60,
                                    child: Image.asset(
                                        'assets/images/smile_app_icon_sm.png',
                                        fit: BoxFit.contain),
                                  ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.only(right: 15.0),
                                //   child: InkWell(
                                //       child: Icon(Icons.exit_to_app),
                                //       onTap: () {
                                //         pauseAppSession();
                                //         //Clear Login Data here...
                                //         _showLogoutDialog();
                                //       }),
                                // ),
                              ],
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            copyRightText(),
                          ],
                        )),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _showLogoutDialog() {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Message'),
      content: Text('Are you sure you want to exit the App?'),
      actions: <Widget>[
        FlatButton(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.black45),
          ),
          onPressed: () {
            pauseAppSession();
            setState(() {
              Navigator.of(this.context).pop('dialog');
              //Redirect UI to another page i.e. HomePage
            });
          },
        ),
        FlatButton(
          child: Text("Confirm"),
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await loginModel.LogOut();
            pauseAppSession();
            setState(() {
              // _myPreferenceHandler = MyPreferenceHandler();
              // _myPreferenceHandler.destroyUserData().then((bool isDone) {
              //   //Remove all Routes/Page then redirect to LoginPage
              //   Navigator.of(context).pushNamedAndRemoveUntil(
              //       LoginPage.tag, (Route<dynamic> route) => false);
              // });
              prefs.remove('token');
              _myPreferenceHandler = MyPreferenceHandler();
              _myPreferenceHandler.releaseUserData();
              //Remove all Routes/Page then redirect to LoginPage
              // Navigator.push(context,
              //    MaterialPageRoute(builder: (context) => InitLogin(
              //       displayPic: _displayPic,
              //     ),
              //  ));
              Navigator.of(context)
                  .pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => NewLoginPage()
                  ),
                      (Route<dynamic> route) => false
              );
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

  void _showSessionExpiredDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Message'),
      content: Text('Application Session expired, please login again.'),
      actions: <Widget>[
        FlatButton(
          child: Text("Confirm"),
          onPressed: () async {
            await loginModel.LogOut();
            pauseAppSession();
            setState(() {
              _myPreferenceHandler = MyPreferenceHandler();
              prefs.remove('token');
              //_myPreferenceHandler.releaseUserData();
              //Remove all Routes/Page then redirect to LoginPage
              Navigator.of(context)
                  .pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => NewLoginPage()
                  ),
                      (Route<dynamic> route) => false
              );
            });
          },
        ),
      ],
    );

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: _mContext,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget _getHomePageOptionButtons(String text) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(text, style: TextStyle(fontSize: 18.0, color: Colors.black54)),
          Icon(
            Icons.chevron_right,
            size: 35.0,
            color: mPrimaryColor,
          ),
        ],
      ),
    );
  }

  Widget _getHomePageButtons(String image, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          image,
          fit: BoxFit.contain,
          height: 45,
        ),
        SizedBox(
          height: 5.0,
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w500,
            fontSize: 12.0,
          ),
        ),
      ],
    );
  }

  Widget _fullScreenQRCode(BuildContext context, String qrCode) {
    return GestureDetector(
      onTap: () {
        pauseAppSession();
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
        color: Colors.black.withOpacity(0.7),
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  child: FloatingActionButton(
                      elevation: 3.0,
                      backgroundColor: Colors.teal,
                      onPressed: () {
                        pauseAppSession();
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                      )),
                ),
              ),
              Center(
                child: Hero(
                  tag: _member.qrcode,
                  child: Container(
                    height: 350,
                    color: Colors.white,
                    child: _generateQRCode(350),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _virtualIDCard(double height, double width) {
    return InkWell(
      onTap: () {
        pauseAppSession();
        Navigator.of(context).push(PageRouteBuilder(
            opaque: false,
            barrierDismissible: true,
            pageBuilder: (BuildContext context, _, __) {
              return _fullScreenQRCode(
                  context, 'assets/images/qrcode_placeholder.png');
            }));
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          child: Container(
            height: height / 3.3,
            width: width,
            color: mPrimaryColor,
            child: Stack(
              children: <Widget>[
                Positioned(
                    bottom: (height / 4.4) * .9,
                    child: _topLogo(height / 4.5, width / 4.5)),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: width * .25,
                    //color: Colors.white60,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Hero(
                          tag: _member.qrcode,
                          child: _generateQRCode(90),
                        ),
                        // Text(
                        //   'Scan QR Code',
                        //   style: TextStyle(
                        //       fontSize: 12, fontStyle: FontStyle.italic),
                        // ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: (height / 5) * .50,
                  child: Container(
                    width: width,
                    height: (height / 3.5) * .7,
                    //color: Colors.white54,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          SizedBox(
                            width: width * .65,
                            child: Text(
                                _member.firstName + ' ' + _member.lastName,
                                style: TextStyle(
                                    fontSize: height <= 600 ? 12.0 : 17.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Abel'
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                          ),
                          Text('${_formatCardNo(_member.cardno)}',
                              style: TextStyle(fontFamily: 'Abel', fontSize: height <= 600 ? 12.0 :17.0, letterSpacing: 4.0)),
                          // SizedBox(
                          //   height: .65,
                          // ),
                          Text(_member.policyholder,
                              style: TextStyle(fontFamily: 'Abel', fontSize: height <= 600 ? 12.0 :15.0,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(
                            height: 3.0,
                          ),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Stack(children: <Widget>[
                                  Text('MAX BENEFIT LIMIT',
                                      style: TextStyle(fontFamily: 'Abel', fontSize: height <= 600 ? 9.0 : 11.0)),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                            margin: EdgeInsets.fromLTRB(0, 15, 10, 0),
                                            child: Text(
                                                _member.limit, style: TextStyle(fontFamily: 'Abel', fontWeight: FontWeight.bold, fontSize: height <= 600 ? 9.0 : 13.0)))
                                      ],
                                    ),
                                  ),
                                ]),
                                SizedBox(width: 15),
                                Stack(children: <Widget>[
                                  Text('VALIDITY PERIOD',
                                      style: TextStyle(fontFamily: 'Abel', fontSize: height <= 600 ? 9.0 : 11)),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                            margin: EdgeInsets.fromLTRB(0, 15, 10, 0),
                                            child: Text(
                                                _member.coverstartdt + ' - ' + _member.coverenddt, style: TextStyle(fontFamily: 'Abel', fontWeight: FontWeight.bold, fontSize: height <= 600 ? 9.0 : 13.0)))
                                      ],
                                    ),
                                  ),
                                ]),
                              ]),
                          SizedBox(height: 3),
                          Text(
                            'ROOM & BOARD UNIT',
                            style: TextStyle(fontFamily: 'Abel', fontSize: height <= 600 ? 9.0 : 11.0),
                          ),
                          SizedBox(
                            width: width * .75,
                            child: Text(_member.roomnboard,
                                style: TextStyle(
                                    fontFamily: 'Abel',
                                    fontSize: height <= 600 ? 9.0 : 13.0,
                                    fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.only(left: 25),
                          //   child: Text('  ** For further details, Please scan QR Code.',
                          //     style: TextStyle(fontSize: 12.0),
                          //     maxLines: 2,
                          //     overflow: TextOverflow.ellipsis,),
                          // ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topLogo(double height, double width) {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Container(
          height: height,
          width: height,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: 160,
              child: Image.asset('assets/images/EtiqaLogoColored_SmileApp.png',
                  fit: BoxFit.contain),
            ),
          ),
        ),
      ],
    );
  }

  Widget _questionMark(BuildContext context,) {
    final _height = MediaQuery.of(context).size.height;
    context = this.context;
    return Container(
        color: Colors.grey[600].withOpacity(.8),
        padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
        child: Container(
          child: Stack(children: <Widget>[
            Align(
                alignment: Alignment.topCenter,
                child: Column(children: <Widget>[
                  SizedBox(height: _height <= 669 ? _height * .7  : _height * .73),
                  Container(
                      child:Card(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0)
                          ),
                          color: Colors.white,
                          child: Stack(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                          alignment: AlignmentDirectional.topStart,
                                          margin: EdgeInsets.fromLTRB(15, 10, 10, 10),
                                          child: Material(
                                            color: Colors.white,
                                            child: InkWell(
                                              child: Row(
                                                children: <Widget>[
                                                  Icon(Icons.person),
                                                  Text("My Profile")
                                                ],
                                              ),
                                              onTap: (){
                                                Navigator.push(context,
                                                    MaterialPageRoute(builder: (context) => ProfilePage(member: _member, cardNo: _member.cardno,displayPic: _displayPic,applicationSession: this,))
                                                );
                                              },
                                            ),
                                          )
                                      ),
                                      Container(
                                        color: Colors.black,
                                        height: 1,
                                      ),
                                      Container(
                                          alignment: AlignmentDirectional.topStart,
                                          margin: EdgeInsets.fromLTRB(15, 10, 10, 10),
                                          child: Material(
                                            color: Colors.white,
                                            child: InkWell(
                                              child: Row(
                                                children: <Widget>[
                                                  Icon(Icons.exit_to_app),
                                                  Text("Logout")
                                                ],
                                              ),
                                              onTap: (){
                                                _showLogoutDialog();
                                              },
                                            ),
                                          )
                                      ),
                                    ],
                                  ),
                                ),
                              ]
                          )
                      )
                  ),
                  Container(
                    height: 40,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.close, color: Colors.white, size: 40,),
                      ),
                    ),
                  )
                ],
                )
            ),
          ],
          ),
        )
    );
  }
}
