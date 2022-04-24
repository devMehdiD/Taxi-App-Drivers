import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxiapp/widget/circularprogress.dart';

import 'fcm.dart';

class StateMangment extends ChangeNotifier {
  Completer<GoogleMapController> controller = Completer();

  String titel = "";
  final auth = FirebaseAuth.instance.currentUser!.uid;
  Set<Marker> marker = {};
  bool serviceEnabled = false;
  LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high, distanceFilter: 1);
  Future<Position> determinePosition() async {
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    notifyListeners();
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    final GoogleMapController mycontroller = await controller.future;
    mycontroller.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)));
    notifyListeners();
    LatLng(position.latitude, position.longitude);
    marker.add(Marker(
        markerId: const MarkerId("user"),
        position: LatLng(position.latitude, position.longitude)));
    notifyListeners();
    return await Geolocator.getCurrentPosition();
  }

  updatepostion() {
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((event) async {
      if (event != null) {
        await FirebaseFirestore.instance
            .collection("drivers")
            .doc(auth)
            .update({"lat": event.latitude, "long": event.longitude});
        updateLatlangInRelationCollection(event.longitude, event.latitude);
        marker.add(Marker(
            markerId: const MarkerId("user"),
            position: LatLng(event.latitude, event.longitude)));
        notifyListeners();
      } else {
        print('null');
      }
    });
  }

  notofication(context) {
    final fcm = Fcm();
    fcm.setNotificationSettings();
    fcm.titlectrl.stream.listen((event) {
      titel = event;
      notifyListeners();
    });
    fcm.bodyctrl.stream.listen((mesage) {
      showDialog(
          context: context,
          builder: (context) => showDailognotifuction(context, titel, mesage));
    });
  }

  listenToStatus() async {
    FirebaseFirestore.instance
        .collection('relation')
        .where('driverId', isEqualTo: auth)
        .snapshots(includeMetadataChanges: true)
        .listen((event) async {
      for (var item in event.docs) {
        if (item.data()['response'] == 'yes') {
          marker.add(Marker(
              markerId: const MarkerId('client'),
              icon: await BitmapDescriptor.fromAssetImage(
                  const ImageConfiguration(), 'assets/client.png')));
          notifyListeners();
        }
      }
    });
  }

  updateStatus(context) async {
    var doc = await FirebaseFirestore.instance
        .collection('relation')
        .where('driverId', isEqualTo: auth)
        .get();
    for (var element in doc.docs) {
      element.reference.update({'response': 'yes'});
      marker.add(Marker(
          markerId: MarkerId('clientd'),
          position: LatLng(element['latClient'], element['longClient']),
          icon: await BitmapDescriptor.fromAssetImage(
              const ImageConfiguration(), 'assets/client.png')));
      notifyListeners();
    }
    Navigator.pop(context);
    notifyListeners();
  }

  updateLatlangInRelationCollection(double longDriver, double latDriver) async {
    var doc = await FirebaseFirestore.instance
        .collection('relation')
        .where('driverId', isEqualTo: auth)
        .get();
    doc.docs.forEach((element) {
      element.reference
          .update({'longDriver': longDriver, 'latDriver': latDriver});
    });
    notifyListeners();
  }
}
