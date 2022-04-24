import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxiapp/statemanagment.dart';

Widget circularProgress(String message) => Dialog(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Container(
          height: 100,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(message),
              const SizedBox(
                width: 10,
              ),
              const CircularProgressIndicator()
            ],
          ),
        ),
      ),
    );
Widget showDailognotifuction(
  context,
  String locationstart,
  locationend,
) {
  final prov = Provider.of<StateMangment>(context);
  return Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: SizedBox(
        height: 300,
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Text(prov.titel),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(child: Text("From $locationend")),
                const Icon(
                  Icons.location_on,
                  color: Colors.red,
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    "To $locationstart",
                  ),
                ),
                const Icon(
                  Icons.location_on,
                  color: Colors.green,
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel")),
              ElevatedButton(
                  onPressed: () {
                    prov.updateStatus(context);
                  },
                  child: const Text("Accepte")),
            ])
          ],
        ),
      ),
    ),
  );
}
