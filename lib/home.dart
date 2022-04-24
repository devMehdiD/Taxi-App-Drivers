import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taxiapp/statemanagment.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      final StateMangment stateMangment =
          Provider.of<StateMangment>(context, listen: false);
      stateMangment.determinePosition();
      stateMangment.updatepostion();
      stateMangment.notofication(context);
      stateMangment.listenToStatus();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<StateMangment>(context);
    CameraPosition cameraPosition = const CameraPosition(
        target: LatLng(
          37.42796133580664,
          -122.085749655962,
        ),
        zoom: 19);
    return Scaffold(
      body: Stack(children: [
        Positioned.fill(
            child: Center(
          child: prov.serviceEnabled
              ? GoogleMap(
                  myLocationButtonEnabled: true,
                  initialCameraPosition: cameraPosition,
                  mapType: MapType.normal,
                  markers: prov.marker,
                  onMapCreated: (GoogleMapController controller) {
                    prov.controller.complete(controller);
                  },
                )
              : Center(
                  child: TextButton(
                      onPressed: () {
                        prov.determinePosition();
                      },
                      child: const Text("Pleaz Enable Your Location")),
                ),
        )),
        Positioned(
            top: 30,
            left: 20,
            child: Builder(builder: (context) {
              return IconButton(
                  onPressed: () async {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: const Icon(Icons.menu));
            }))
      ]),
      drawer: const Drawer(),
    );
  }
}
