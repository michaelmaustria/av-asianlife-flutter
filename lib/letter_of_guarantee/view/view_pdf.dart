import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:share/share.dart';


class ViewPdfPage extends StatefulWidget {
final String path;
final String url;
final String fileName;

const ViewPdfPage({Key key, this.path, this.url, this.fileName}) : super(key: key);
@override
_ViewPdfPageState createState() => _ViewPdfPageState();
}

class _ViewPdfPageState extends State<ViewPdfPage> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool pdfReady = false;
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("View LOG Form"),
        elevation: 0,
          flexibleSpace: Image(
            image:  AssetImage('assets/images/appBar_background.png'),
            fit: BoxFit.fill),
        centerTitle: true,
          actions:<Widget>[
            InkWell(
              child: Icon(Icons.download_sharp),
              onTap: () async {
                savePDF();
              },
            ),
            SizedBox(width:10)
            // PopupMenuButton<String>(
            //     padding: EdgeInsets.zero,
            //     icon: Icon(Icons.download_sharp),
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
            //         height: 30.0,
            //         child: InkWell(
            //           splashColor: Colors.yellow,
            //           highlightColor: Colors.blue.withOpacity(0.5),
            //           onTap: () async {
            //             savePDF();
            //           },
            //           child: Text('Download', textAlign: TextAlign.center,),
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
                _totalPages = _pages;
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
      // floatingActionButton: Row(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: <Widget>[
      //     _currentPage > 0
      //         ? FloatingActionButton.extended(
      //       backgroundColor: Colors.red,
      //       label: Text("Go to ${_currentPage - 1}"),
      //       onPressed: () {
      //         _currentPage -= 1;
      //         _pdfViewController.setPage(_currentPage);
      //       },
      //     )
      //         : Offstage(),
      //     _currentPage+1 < _totalPages
      //         ? FloatingActionButton.extended(
      //       backgroundColor: Colors.green,
      //       label: Text("Go to ${_currentPage + 1}"),
      //       onPressed: () {
      //         _currentPage += 1;
      //         _pdfViewController.setPage(_currentPage);
      //       },
      //     )
      //         : Offstage(),
      //   ],
      // ),
    );
  }
}