import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';

class Fcm {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final datactrl = StreamController<String>.broadcast();
  final titlectrl = StreamController<String>.broadcast();
  final bodyctrl = StreamController<String>.broadcast();

  setNotificationSettings() async {
    NotificationSettings notificationSettings =
        await firebaseMessaging.requestPermission(
            alert: true, badge: true, sound: true, provisional: false);
    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      print("Permision Granted");
      forGroundNotification();
      backGroundNotification();
      terminatedNotification();
    }
  }

  void terminatedNotification() async {
    RemoteMessage? remoteMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (remoteMessage!.data.isNotEmpty) {
      datactrl.sink.add("event.data");
    }
    if (remoteMessage.notification != null) {
      titlectrl.sink.add(remoteMessage.notification!.title!);
      bodyctrl.sink.add(remoteMessage.notification!.body!);
    }
  }

  void forGroundNotification() {
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      if (event.data.isNotEmpty) {
        datactrl.sink.add("event.data");
      }
      if (event.notification != null) {
        titlectrl.sink.add(event.notification!.title!);
        bodyctrl.sink.add(event.notification!.body!);
      }
    });
  }

  void backGroundNotification() {
    FirebaseMessaging.onMessage.listen((event) {
      if (event.data.isNotEmpty) {
        datactrl.sink.add("event.data");
      }
      if (event.notification != null) {
        titlectrl.sink.add(event.notification!.title!);
        bodyctrl.sink.add(event.notification!.body!);
      }
    });
  }

  @override
  void dispose() {
    datactrl.close();
    titlectrl.close();
    bodyctrl.close();
  }
}
