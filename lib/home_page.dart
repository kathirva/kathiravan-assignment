import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:login_app/login_page.dart';
import 'package:login_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _username = "No Name";
  bool showSpinner = false;

  // Notification Things
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();

    // Notification Stuffs
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print('TERMINATED');
        //remove redirect route here, so the unknownRoute will trigger the default route
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Foreground - triggers when app in foreground
      print("on Message triggered");
      NotificationRemoteMessage notificationRemoteMessage =
          NotificationRemoteMessage.fromRemoteMessage(message);

      // only string allowed in onSelectNotification. Thats why creating it a object, convert to json string and we are passing it
      Map<String, dynamic> messageObject = {
        'route': notificationRemoteMessage.route,
        'routekey': notificationRemoteMessage.routeKey,
        // 'params': data,
      };

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel?.id ?? "",
              channel?.name ?? "",
              channelDescription: channel?.description,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: jsonEncode(messageObject)
              .toString(), //notificationRemoteMessage.route,
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Background - trigger when app in background
      if (message != null) {}
    });

    // Notification Stuffs - Needed by iOS only

    // _firebaseMessaging.requestPermission(const IosNotificationSettings(sound: true, badge: true, alert: true));
    // _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
    // });

    // for iOS
    _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Notification Stuffs

    _firebaseMessaging.setAutoInitEnabled(false);
    _firebaseMessaging.subscribeToTopic("allusers");
    initLocalNotification();
    getToken();
  }

  getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      print("FCM token : " + token.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black87),
          elevation: 0.0,
          backgroundColor: Colors.white,
          actions: <Widget>[
            showSpinner
                ? const Center(
                    child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: CupertinoActivityIndicator(),
                  ))
                : Container()
          ],
        ),
        body: Container(
          padding: EdgeInsets.all(20.0),
          color: Colors.white,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  margin: EdgeInsets.only(top: 20.0, bottom: 30.0),
                  child: Text(
                    "Welcome " + _username,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue),
                  )),
              Text(
                "Activate the SOS feature to send an emergency notification and get immediate assistance. ",
                textAlign: TextAlign.center,
                style: TextStyle(
                    height: 1.5, fontSize: 13.0, fontWeight: FontWeight.w400),
              ),
              Container(
                  margin: EdgeInsets.only(
                    top: 30.0,
                  ),
                  child: Text(
                    "Your safety matters.",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
                  )),
              InkWell(
                onTap: () {
                  if (!showSpinner) {
                    Fluttertoast.showToast(
                        msg: "Notification sent to your friends and family.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey[300],
                        textColor: Colors.black,
                        fontSize: 16.0);
                    // todo Send notification to friend and family tokens which we already saved in the server.
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(top: 40.0, bottom: 40.0),
                  // padding: EdgeInsets.only(left: 60.0, right: 60.0, top: 15.0, bottom : 15.0),
                  width: 100.0,
                  height: 100.0,
                  // color: Colors.blue,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    // border: Border.all(color: Colors.grey[200]),
                    color: Colors.red,
                  ),
                  child: Center(
                      child: Text(
                    "SOS",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 20.0),
                  )),
                ),
              ),
              InkWell(
                onTap: () {
                  if (!showSpinner) {
                    setState(() {
                      showSpinner = true;
                    });
                    _handleLogout();
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(top: 80.0),
                  padding: EdgeInsets.only(
                      left: 60.0, right: 60.0, top: 15.0, bottom: 15.0),
                  // width: 50.0,
                  // height: 20.0,
                  // color: Colors.blue,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    // border: Border.all(color: Colors.grey[200]),
                    color: Colors.blue,
                  ),
                  child: Text(
                    "Logout",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 16.0),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = (prefs.getString('username') ?? "");
    });
  }

  initLocalNotification() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings();

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      // iOS: initializationSettingsIOS,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            onSelectNotification); // only string allowed in onSelectNotification. Thats why creating it a object, convert to json string and we are passing it
  }

  onSelectNotification(var payload) async {
    NotificationRemoteMessage notificationRemoteMessage =
        NotificationRemoteMessage.fromPayload(payload);

    String route = notificationRemoteMessage.route;
    // notificationRemoteMessage.routeKey
  }

  void _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("username");
    prefs.remove("userid");
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
        (Route<dynamic> route) => false);
  }
}

class NotificationRemoteMessage {
  String routeKey = "";
  String route = "";

  // String userKeyFromNotification;

  NotificationRemoteMessage.fromRemoteMessage(RemoteMessage message) {
    final dynamic data = message.data;
    routeKey = data['routekey'];
    route = data['route'];
    // userKeyFromNotification = data['userkey'];
  }

  NotificationRemoteMessage.fromPayload(String message) {
    var data = json.decode(message);
    routeKey = data['routekey'];
    route = data['route'];
  }
}
