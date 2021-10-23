import 'dart:io';

import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/home_page/home_page.dart';
import 'package:av_asian_life/profile_page/profile_page.dart';
import 'package:flutter/material.dart';


class SuccessPage extends StatefulWidget {
  String from;
  SuccessPage({this.from});
  @override
  _SuccessPageState createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {


  @override
  void initState() {
    super.initState();

    print('from : ${widget.from}');
    checkFrom();

  }

  String phrase = 'lkjl';

  void checkFrom() {
    if(widget.from == 'mobile'){
      setState(() {
        phrase = 'Mobile Number Updated';
      });

    }if(widget.from == 'email'){
      setState(() {
        phrase = 'Email Updated';
      });

    }if(widget.from == 'claims'){
      setState(() {
        phrase = 'Your Reimbursement Claim Request has been sent!';
      });

    }
    if(widget.from == 'log'){
      setState(() {
        phrase = 'Your LOG Request has been sent!';
      });

    }
  }


  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Container(
      height: height,
      width: width,
      decoration: myAppBackground(),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Container(
              height: height,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  SizedBox(height: 25.0,),
                  Container(
                    height: width * .40,
                    decoration: myAppLogo(),
                  ),
                  _textFields(height, width),
                  RaisedButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.fromLTRB(60, 10, 60, 10),
                    child: Text('Close', style: TextStyle(fontSize: 20)),
                    color: mPrimaryColor,
                    onPressed: (){
                      Navigator.pop(context);
                    },
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
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
                ],
              ),
            ),
          )
        ),
    );
  }

  Widget _textFields(double height, double width) {
    return Container(
      height: height / 3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text('THANK YOU!', style: TextStyle(fontSize: 40)),
          Text('$phrase', style: TextStyle(fontSize: 20),textAlign: TextAlign.center,),
        ],
      )
    );
  }

  Widget _getLoginOptionIcons(String image, String text){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Image.asset(image,
          fit: BoxFit.contain,
          height: 40,
        ),
        SizedBox(
          height: 10.0,
        ),
        SizedBox(
          child: Text(text, textAlign: TextAlign.center, style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w400,
              fontSize: 10.0
          ),),
        ),
      ],
    );
  }


}

