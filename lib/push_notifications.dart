// import 'package:av_asian_life/data_manager/message.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';

// class MessagingPage extends StatefulWidget{
//   @override
//   _MessagingPageState createState() => _MessagingPageState();

// }

// class _MessagingPageState extends State<MessagingPage> {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
//   final List<Message> messages = [];

//   void initState(){ 
//     super.initState();
//     _firebaseMessaging.configure(
//       onMessage: (Map<String, dynamic>message) async {
//         print("onMessage: $message");
//         final notification = message['notification'];
//         setState(() {
//           messages.add(Message(title: notification['title'], body: notification['body']));
//         });
//       },
//       onLaunch: (Map<String, dynamic>message) async {
//         print("onLaunch: $message");
//       },
//       onResume: (Map<String, dynamic>message) async {
//         print("onResume: $message");
//       }
//     );
//     _firebaseMessaging.requestNotificationPermissions(
//       const IosNotificationSettings(sound: true, badge: true, alert: true)
//     );
//   }

//   @override
//   Widget build(BuildContext context) => ListView(children: messages.map(buildMessage).toList(),);
  
//   Widget buildMessage(Message message) => ListTile(title: Text(message.title),subtitle: Text(message.body),);
// }