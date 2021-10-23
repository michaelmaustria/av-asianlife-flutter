import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:flutter/material.dart';

class OfflineApiPage extends StatefulWidget {
  @override
  _OfflineApiPageState createState() => _OfflineApiPageState();
}

class _OfflineApiPageState extends State<OfflineApiPage> {
  TextEditingController controller = TextEditingController();

  double _height, _width;

  bool _codeVis = true, passwordIconVis = false;

  double iconSize = .25;

  String useQuickView;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    _height = MediaQuery.of(context).size.height * .85;
    _width = MediaQuery.of(context).size.width;

    return Container(
      height: _height,
      width: _width,
      decoration: myAppBackground(),
      child: Stack(
        children: <Widget>[
          Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                elevation: 0.0,
              ),
              body: SingleChildScrollView(
                child: Wrap(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              height: _width * iconSize,
                              decoration: myAppLogo(),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                height: _height * .6,
                                child: Column(
                                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Visibility(
                                      visible: _codeVis,
                                      child: Container(
                                        height: _height * .5,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Align(
                                              alignment: Alignment.topCenter,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Text('We\'ll be back soon! \n'
                                                      'We\'re doing maintenance work to\n '
                                                      'improve your experience. You\n'
                                                      'may still reach us via customer support.\n '
                                                      'Thank you!',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14.0),),
                                                ],
                                              ),
                                            ),
                                            // SizedBox(
                                            //   width: _width * .5,
                                            //   child: RaisedButton(
                                            //     padding: EdgeInsets.all(12),
                                            //     color: mPrimaryColor,
                                            //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                            //     child: Text('Close', style: TextStyle(color: Colors.black87)),
                                            //     onPressed: () {
                                            //       Navigator.pop(context);
                                            //     },
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ),


                                  ],
                                ),
                              ),
                            ),
                            Align(
                                alignment: Alignment.bottomCenter,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    SizedBox(
                                      height: 60,
                                      child: Image.asset('assets/images/EtiqaLogoColored_SmileApp.png', fit: BoxFit.contain),
                                    ),
                                    myMultimediaAccounts(),
                                    Padding(
                                        padding: const EdgeInsets.only(top: 10.0),
                                        child: copyRightText()
                                    ),
                                  ],
                                )
                            ),
                          ],
                        ),
                      ),]
                ),
              )
          ),
        ],
      ),
    );
  }
}
