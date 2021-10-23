import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/splash_screen/splash_screen_page.dart';
import 'package:av_asian_life/utility/my_preference_helper.dart';
import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';

class IntroSliderPage extends StatefulWidget {
  @override
  _IntroSliderPageState createState() => _IntroSliderPageState();
}

class _IntroSliderPageState extends State<IntroSliderPage> {
  List<Slide> slides = new List();
  MyPreferenceHandler myPreferenceHandler = MyPreferenceHandler();

  BuildContext _mContext;
  
  @override
  void initState() {
    super.initState();
    slides.add(
      Slide(
        title: '',
        styleTitle: TextStyle(color: Colors.white),
        description: 'Request a Letter of Guarantee (LOG)',
        styleDescription: TextStyle(
            color: Colors.black87,
            fontSize: 20.0,
            fontWeight: FontWeight.w600
        ),
        pathImage: 'assets/images/req_log.png',
        heightImage: 300.0,
        backgroundColor: Colors.white,

      ),
    );
    slides.add(
      Slide(
        title: '',
        styleTitle: TextStyle(color: Colors.white),
        description: 'Search for the nearest doctors, hospitals and clinics.',
        styleDescription: TextStyle(
            color: Colors.black87,
            fontSize: 20.0,
            fontWeight: FontWeight.w600),
        pathImage: 'assets/images/search.png',
        heightImage: 300.0,
        backgroundColor: Colors.white,

      ),
    );
    slides.add(
      Slide(
        title: '',
        styleTitle: TextStyle(color: Colors.white),
        description: 'View your account and claim status.',
        styleDescription: TextStyle(
            color: Colors.black87,
            fontSize: 20.0,
            fontWeight: FontWeight.w600
        ),
        pathImage: 'assets/images/intro_view_account.png',
        heightImage: 300.0,
        backgroundColor: Colors.white,

      ),
    );
  }


  _initEndSlider() {
    myPreferenceHandler.setInstallData(false);

    Navigator.of(_mContext).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => SplashScreenPage(hasData: 2,)),
          (Route<dynamic> route) => false,);

  }


  @override
  Widget build(BuildContext context) {

    _mContext = context;

    return IntroSlider(
      slides: slides,
      onDonePress: _initEndSlider,
      onSkipPress: _initEndSlider,

      colorSkipBtn: Colors.white,
      styleNameSkipBtn: TextStyle(color: Colors.black54),
      highlightColorSkipBtn: Colors.white,

      colorDoneBtn: mPrimaryColor,
      styleNameDoneBtn: TextStyle(color: Colors.black54),
      highlightColorDoneBtn: mAccentColor,

      colorDot: Color(0x33D02090),
      colorActiveDot: mPrimaryColor,
    );
  }
}
