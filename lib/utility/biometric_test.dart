/*
  Created by Warren Cedro 8/29/19
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:trust_fall/trust_fall.dart';

class BiometricTest {

  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> checkJailbreak() async {
    bool isJailBroken;
    try {
      isJailBroken = await TrustFall.isJailBroken;
    } on PlatformException catch (e) {
      print(e);
    }

    print('isRooted: $isJailBroken');
    return isJailBroken;

  }

  Future<bool> checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }


    print('canCheckBiometrics: $canCheckBiometrics');
    return canCheckBiometrics;
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }

    print('availableBiometrics: $availableBiometrics');
    return availableBiometrics;
  }

  Future<bool> authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await _auth.authenticateWithBiometrics(
          localizedReason: 'Scan your fingerprint to authenticate',
          useErrorDialogs: true,
          stickyAuth: true);
    } on PlatformException catch (e) {
      print(e);
    }

    print('authenticate: $authenticated');
    return authenticated;
  }
}


void main() => runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen()));

class SplashScreen extends StatefulWidget {

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isJailBroken;
  bool _canCheckBiometrics;
  bool _isAuthorized;
  List<BiometricType> _availableBiometrics;
  bool _isFinished;


  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

    Future.delayed(const Duration(seconds: 4), () {
      Future.wait([
        _checkJailbreak(),
        _checkBiometrics(),
        _getAvailableBiometrics(),
      ]).whenComplete(() {
        print("Futures Finished");
        setState(() {
          print('$_isJailBroken, $_canCheckBiometrics, $_isAuthorized, $_availableBiometrics, $_isFinished');
          Navigator.pushReplacement(context,
            MaterialPageRoute(
                builder: (context) => null
            ),
          );
        });
      });
    });

    //call this function to initialize fingerprint/face unlock
    //_authenticate();
  }


  Future<void> _checkJailbreak() async {
    bool isJailBroken;
    try {
      isJailBroken = await TrustFall.isJailBroken;
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      print('isRooted: $isJailBroken');
      _isJailBroken = isJailBroken;
    });
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      print('canCheckBiometrics: $canCheckBiometrics');
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      print('availableBiometrics: $availableBiometrics');
      _availableBiometrics = availableBiometrics;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: _getSplashScreen(),
    );
  }

  Widget _getSplashScreen() {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: 6.0,
            child: Container(color: Colors.yellowAccent,),
          ),
        ),
        Center(
          child: Image.asset('assets/images/EtiqaLogoColored_SmileApp.png', fit: BoxFit.contain),
        ),
        Align(
            alignment: Alignment.bottomCenter,
            heightFactor: 100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Powered by:'),
                Hero(
                  tag: 'etiqa-logo',
                  child: SizedBox(
                    height: 75,
                    child: Image.asset('assets/images/EtiqaLogoColored_SmileApp.png', fit: BoxFit.contain),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _getSocialMediaIcon('assets/images/FB_SMILE_APP.png'),
                    _getSocialMediaIcon('assets/images/IG_SMILE_APP.png'),
                    _getSocialMediaIcon('assets/images/LinkedIN_SMILE_APP.png'),
                    _getSocialMediaIcon('assets/images/Website_SMILE_APP.png'),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Copyright 2019. Etiqa & General Assurance Philippines, Inc.',
                      style: TextStyle(fontSize: 10.0,)),
                ),
              ],
            )
        ),
      ],
    );
  }

  Widget _getSocialMediaIcon(String image) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: SizedBox(
        height: 30,
        width: 30,
        child: Image.asset(image, fit: BoxFit.fill),
      ),
    );
  }
}
