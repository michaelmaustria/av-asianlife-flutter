import 'dart:convert';

import 'package:av_asian_life/data_manager/api_token.dart';
import 'package:av_asian_life/data_manager/member.dart';
import 'package:av_asian_life/home_page/home_page.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:dio/dio.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ViewClaimPdfPage extends StatefulWidget {
  final String path;
  final String url;
  final String fileName;
  final String mode;
  final String reqId;
  final String cardno;
  final String title;
  final Member member;

  const ViewClaimPdfPage({Key key, this.title, this.path, this.url, this.fileName, this.mode, this.reqId, this.member, this.cardno}) : super(key: key);
  @override
  _ViewClaimPdfPageState createState() => _ViewClaimPdfPageState();
}

class _ViewClaimPdfPageState extends State<ViewClaimPdfPage> {

  bool pdfReady = false;
  bool isDelete = false;

  List msgDesc = [];

  String _msgDesc;

  Member _mMember;

  PDFViewController _pdfViewController;
  String path;
  String imgUrl;
  var dio = Dio();
  @override
  void initState() {
    getPermission();
    print(widget?.url);
    print(widget?.path);
    setState(() {
      widget?.mode == 'Delete' ? isDelete = true : isDelete = false;
      imgUrl = widget?.url;
      path = widget?.path;
    });
    // TODO: implement initState
    super.initState();
  }
  void getPermission() async {
    print("getPermission");
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);
  }

  savePDF() async {
    String path;
    //    path = await ExtStorage.getExternalStoragePublicDirectory(
    //     ExtStorage.DIRECTORY_DOWNLOADS);
    path = (await getApplicationDocumentsDirectory()).path;
    String fullPath = "$path/${widget?.fileName}.pdf";
    download2(dio,imgUrl,fullPath);
  }

  void onErrorDialog(){
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
          title: new Text(""),
          content: new Text('The file could not be downloaded',textAlign: TextAlign.center),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ));
  }

  void showMessageDialog(){
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
          title: new Text(""),
          content: new Text('Downloaded successfully',textAlign: TextAlign.center),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ));
  }

  Future download2(Dio dio, String url, String savePath) async {
    //get pdf from link
    try{
      showLoaderDialog(context);
      Response response = await dio.get(
        url,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              if (status >= 200){
                Navigator.pop(context);
              }
              return status < 500;
            }),
      );

      //write in download folder
      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();
      Share.shareFiles([savePath]);
      //showMessageDialog();
    }catch (e){
      print('Error is ');
      print(e);
      onErrorDialog();
    }
  }

  showLoaderDialog(BuildContext context){
    AlertDialog alert=AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 7),child:Text("Loading..." )),
        ],),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }

  void showDownloadProgress(received, total){
    print((received / total * 100).toStringAsFixed(0) + "%");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        _navigateToHomePage(widget?.member.cardno);
      },
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(widget?.title),
            elevation: 0,
            flexibleSpace: Image(
                image:  AssetImage('assets/images/appBar_background.png'),
                fit: BoxFit.fill),
            centerTitle: true,
            actions:<Widget>[
              InkWell(
                child: Icon(Icons.download_sharp),
                onTap: (){
                  savePDF();
                },
              ),
              SizedBox(width:10)
              // PopupMenuButton<String>(
              //     padding: EdgeInsets.zero,
              //     icon: Icon(Icons.more_vert),
              //     elevation: 20,
              //     shape: OutlineInputBorder(
              //         borderSide: BorderSide(
              //             color: Colors.black,
              //             width: .5
              //         )
              //     ),
              //     itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              //       PopupMenuItem<String>(
              //         value: 'Download',
              //         height: 30,
              //         child: InkWell(
              //           splashColor: Colors.yellow,
              //           highlightColor: Colors.blue.withOpacity(0.5),
              //           onTap: () async {
              //             savePDF();
              //           },
              //           child: Text('Download', textAlign: TextAlign.center,),
              //         ),
              //       ),
              //       PopupMenuItem<String>(
              //         value: 'Delete',
              //         height: isDelete == true ? 30.0 : 0,
              //         child: InkWell(
              //           splashColor: Colors.yellow,
              //           highlightColor: Colors.blue.withOpacity(0.5),
              //           onTap: () async {
              //             deleteRecord(widget?.reqId);
              //             print(widget?.reqId);
              //           },
              //           child: isDelete == true ? Text('Delete', textAlign: TextAlign.center,) : Offstage(),
              //         ),
              //       ),
              //       PopupMenuItem<String>(
              //         value: 'Close',
              //         height:isDelete == true ? 30.0 : 0,
              //         child: InkWell(
              //           splashColor: Colors.yellow,
              //           highlightColor: Colors.blue.withOpacity(0.5),
              //           onTap: () async {
              //             _navigateToHomePage(widget?.cardno);
              //             print(widget?.reqId);
              //           },
              //           child: isDelete == true ? Text('Close', textAlign: TextAlign.center,) : Offstage(),
              //         ),
              //       ),
              //     ]
              // )
            ]
        ),
        body: Stack(
          children: <Widget>[
            PDFView(
              filePath: widget.path,
              autoSpacing: true,
              enableSwipe: true,
              pageSnap: true,
              swipeHorizontal: false,
              nightMode: false,
              onError: (e) {
                print(e);
              },
              onRender: (_pages) {
                setState(() {
                  pdfReady = true;
                });
              },
              onViewCreated: (PDFViewController vc) {
                _pdfViewController = vc;
              },
              onPageChanged: (int page, int total) {
                setState(() {});
              },
              onPageError: (page, e) {},
            ),
            !pdfReady
                ? Center(
              child: CircularProgressIndicator(),
            )
                : Offstage()
          ],
        ),
      ),
    );
  }

  void deleteRecord(String reqId){
    Widget yesButton = FlatButton(
      child: Text('YES'),
      onPressed: () {
        deleteClaim(reqId);
      },
    );
    Widget noButton = FlatButton(
      child: Text('NO'),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(""),
      content: Text("Are you sure you want to delete this claim?",textAlign: TextAlign.center),
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

  Future<String> deleteClaim(String reqId) async {
    dynamic data;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();
    var response = await http.post(
      Uri.encodeFull("${_base_url}CancelClaimRequest"),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        "UserAccount": _email
      },
      body: {
        "userid" : _api_user,
        "password" : _api_pass,
        "requestid" : reqId,
        "mode" : "2",
        "appuserid" : "administrator",
      }
    );
    data = json.decode(response.body);
    msgDesc = json.decode(data);
    this._msgDesc = msgDesc[0]['msgDescription'];
    print(_msgDesc);
    successDialog(_msgDesc);
    return "Success!";
  }

  void successDialog(String msgDesc){
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
          title: new Text(""),
          content: new Text(msgDesc, textAlign: TextAlign.center,),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                _navigateToHomePage(widget?.cardno);
              },
            )
          ],
        ));
  }

  Future<Member> _navigateToHomePage(String cardNo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var baseUrl = await ApiHelper.getBaseUrl();
    var apiUser = await ApiHelper.getApiUser();
    var apiPass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();
    String _deviceId = await ImeiPlugin.getImei();

    String url = '${baseUrl}MemberInfo';
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
      _mMember = data[0];
      print(_mMember);
      Navigator.of(context)
          .pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => HomePage(member: _mMember)
          ),
              (Route<dynamic> route) => false
      );
      return data[0];
    } else {
      print('Error Fetching Member Info: $json');
      return null;
    }
  }
}