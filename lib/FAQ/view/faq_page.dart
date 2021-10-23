import 'dart:convert';
import 'dart:ui';

import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/member.dart';
import 'package:av_asian_life/home_page/session_callback.dart';
import 'package:flutter/material.dart';
import 'package:av_asian_life/FAQ/model/faq_model.dart';
import 'package:av_asian_life/data_manager/faq.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart' as http;


class FaqPage extends StatefulWidget {
  static String tag = 'policy-details';
  final Member member;
  final IApplicationSession appSessionCallback;

  FaqPage({this.member, this.appSessionCallback});

  @override
  _FaqPageState createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  IApplicationSession _appSessionCallback;

  List question = [];
  List questions = [];
  List answer = [];
  List answers = [];
  List questionSuggestions = [];
  List questionQuery = [];
  List answerQuery = [];

  dynamic data;

  String _question;
  String _answer;
  String _selectedQuestion;

  bool isQuestionVisible = false;

  int index = 0;

  var searchBarController = new TextEditingController();

  Future<String> getData() async {
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var response = await http.post(
      Uri.encodeFull('${_base_url}GetFAQs'),
      headers: {
        "Accept": "application/json"
      },
      body: {
        "userid" : _api_user,
        "password" : _api_pass,
      }
    );
    data = json.decode(response.body);
    _question = data;
    _answer = data;
    setState(() {
      question = json.decode(_question);
      answer = json.decode(_answer);
    });
    for(var i = 0; i < question.length; i++){
      this.questions.add(question[i]["question"]);
      this.answers.add(answer[i]["answer"]);
    }
    return "Success!";
  }

  @override
  void initState() {
    super.initState();
    this.getData();
    _appSessionCallback = widget.appSessionCallback;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text('FREQUENTLY ASKED QUESTIONS'),
        flexibleSpace: Image(
          image: AssetImage('assets/images/appBar_background.png'),
          fit: BoxFit.fill,
        ),
      ),
      body: questions.length != 0 ? LayoutBuilder(builder: (context, constraint) {
        final height = constraint.maxHeight;
        final width = constraint.maxWidth;
        final heightBody = height * .89;
        return Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: <Widget>[
                // Card(
                //   color: Colors.white,
                //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0), side: BorderSide(color: Colors.black54)),
                //   borderOnForeground: false,
                //   child: Autocomplete(
                //     optionsBuilder: (TextEditingValue value) {
                //       if (value.text.isEmpty) {
                //         _selectedQuestion = '';
                //         setState(() {
                //           isQuestionVisible = false;
                //         });
                //         return [];
                //       } else {
                //         setState(() {
                //           isQuestionVisible = true;
                //         });
                //       }
                //       return questions.where((suggestion) => suggestion
                //           .toLowerCase()
                //           .contains(value.text.toLowerCase()));
                //     },
                //     onSelected: (value) {
                //       setState(() {
                //         index = questions.indexOf(value);
                //       });
                //     },
                //   ),
                // ),
                Card(
                  // color: Colors.white,
                  // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0), side: BorderSide(color: Colors.black54)),
                  // borderOnForeground: false,
                  child: Focus(
                    child: TextFormField(
                      controller: searchBarController,
                      onChanged: (value){
                        questionSuggestions = questions.where((questionSuggestion) => questionSuggestion
                            .toLowerCase()
                            .contains(value.toLowerCase())).toList();
                        questionQuery = questionSuggestions.toSet().toList();
                        answerQuery.clear();
                        for(int x = 0; x < questionQuery.length; x++){
                          int i = questions.indexOf(questionQuery[x]);
                          print(answers[i]);
                          answerQuery.add(answers[i]);
                        }
                        setState(() {
                          if((value == null) || (value == '')){
                            answerQuery.clear();
                            isQuestionVisible = false;
                          } else {
                            isQuestionVisible = true;
                          }
                        });
                      },
                      decoration: InputDecoration(
                        hintText: " Search",
                        suffix: InkWell(
                          onTap: () {
                            searchBarController.text = '';
                            setState((){
                              isQuestionVisible = false;
                            });
                          } ,
                          child: Container(
                            margin: EdgeInsets.only(left:0.0, top: 0.0,right:10.0,bottom:0.0),
                            child: Icon(
                              Icons.cancel,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onFocusChange: (hasFocus){
                      setState(() {
                        if(hasFocus){
                          answerQuery.clear();
                        } else {
                          for(int x = 0; x < questionQuery.length; x++){
                            int i = questions.indexOf(questionQuery[x]);
                            print(answers[i]);
                            answerQuery.add(answers[i]);
                          }
                        }
                      });
                    },
                  )
                ),
                //getQuestion(index),
                isQuestionVisible == true ? Container(
                  height: heightBody * 0.90,
                  child: ListView.builder(
                      itemCount: this.questionSuggestions.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0), side: BorderSide(color: Colors.black54)),
                            elevation: 1.0,
                            child: ExpansionTile(
                              title: Text(this.questionSuggestions[index]),
                              backgroundColor: Colors.white,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 1.0),
                                  child: Container(
                                    color: mPrimaryColor,
                                    height: 2,
                                  ),
                                ),
                                SizedBox(height: 10,),
                                Container(
                                    alignment: new FractionalOffset(0.0, 1.0),
                                    padding: EdgeInsets.only(left: 10),
                                    child: this.answerQuery.length == 0 ? Text('') : Text(this.answerQuery[index])
                                ),
                                SizedBox(height: 10,),
                              ],
                            ),
                          ),
                        );
                      }),
                ) : Offstage(),
                isQuestionVisible == false ? Container(
                  height: isQuestionVisible == true ? heightBody * 0.70 : heightBody * 0.90,
                  child: ListView.builder(
                    itemCount: this.questions.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0), side: BorderSide(color: Colors.black54)),
                          elevation: 1.0,
                          child: ExpansionTile(
                            title: Text(this.questions[index]),
                            backgroundColor: Colors.white,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 1.0),
                                child: Container(
                                  color: mPrimaryColor,
                                  height: 2,
                                ),
                              ),
                              SizedBox(height: 10,),
                              Container(
                                  alignment: new FractionalOffset(0.0, 1.0),
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(this.answers[index],
                                      textAlign: TextAlign.left)
                              ),
                              SizedBox(height: 10,),
                            ],
                          ),
                        ),
                      );
                    }),
                ) : Offstage(),
                isQuestionVisible == false ? copyRightText() : Offstage()
              ],
          )
        ));
      }) : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:<Widget>[
            Text('Please wait...', textAlign: TextAlign.center)
          ]
      ),
    );
  }

  void showMessageDialog(String message){
    showDialog(
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
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ));
  }

  getQuestion(int index){
    return Visibility(
      visible: isQuestionVisible,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0), side: BorderSide(color: Colors.black54)),
          elevation: 1.0,
          child: ExpansionTile(
            title: Text(this.questions[index]),
            backgroundColor: Colors.white,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 1.0),
                child: Container(
                  color: mPrimaryColor,
                  height: 2,
                ),
              ),
              SizedBox(height: 10,),
              Container(
                  alignment: new FractionalOffset(0.0, 1.0),
                  padding: EdgeInsets.only(left: 10),
                  child: Text(this.answers[index],
                      textAlign: TextAlign.left)
              ),
              SizedBox(height: 10,),
            ],
          ),
        ),
      ),
    );
  }
}
