import 'dart:math';
import 'dart:async';
//import 'dart:isolate';
//import 'package:compass1/goal_location.dart';

//<uses-permission android:name="android.permission.VIBRATE"/>    <--- questo da aggiungere al manifest

import 'package:compass1/screens/nice_compass.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
//import 'package:location/location.dart';
//import 'package:flutter_qiblah/flutter_qiblah.dart';

class destCoord {
  //panchina parco musica
  static double latitude = 41.5852128;
  static double longitude = 12.6558842;
}

final _coordController = TextEditingController();

Animation<double>? animation;
AnimationController? _animationController;
double begin = 0.0;
double? direction;
double compassAccuracy = -1;
double?
    accuracy; // RICORDA CHE HAI DIMEZZATO IL TEMPO DI RICALCOLO DELLA POSIZIONE(?) NELLA CLASSE LOCATION
double? latitude;
double? longitude;
double locationHeading = 361;
double distance = -1;
double fakeDistance = 33;
var locationSettings = AndroidSettings(
  accuracy: LocationAccuracy.best,
  //distanceFilter: 1,
  forceLocationManager: false,
  //intervalDuration: const Duration(seconds: 1),
  //(Optional) Set foreground notification config to keep the app alive
  //when going to the background
);
double bearing = 0;
String messageDisplayed = "Welcome";

final Iterable<Duration> longPauses = [
  const Duration(milliseconds: 900),
];
final Iterable<Duration> mediumPauses = [
  const Duration(milliseconds: 600),
];
final Iterable<Duration> shortPauses = [
  const Duration(milliseconds: 200),
];

//double northOffset = 0;
//final Location userLocation = Location();
//final Geolocator location1 = Geolocator();

//final goal = GoalLocation(41.5852758, 12.6563285, 'Parco Lirica');
//final goal1 = GoalLocation(43.6765487, 6.8218989, 'Francia da qualche parte');

class CompassScreen extends StatefulWidget {
  const CompassScreen(this.destinantionReached, {super.key});

  final void Function() destinantionReached;

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen>
    with SingleTickerProviderStateMixin {
  // ^^^^ this thing is for vsynching the animation

  // each animation needs an animation controller, which must be initialized (and configured)
  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    animation = Tween(begin: 0.0, end: 0.0).animate(
        _animationController!); // initialize the animation on dumb values...why??
    _vibrate();
    super.initState();
  }

  static void vibrateDevice(double distance) {
    while (distance < 35 && distance > 0) {
      Vibrate.vibrateWithPauses(longPauses);
    }
    while (distance < 20 && distance > 8) {
      Vibrate.vibrateWithPauses(mediumPauses);
    }
    while (distance < 8 && distance > 0) {
      Vibrate.vibrateWithPauses(shortPauses);
    }
  }

  void _vibrate() async {
    await compute(vibrateDevice, fakeDistance);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 48, 48, 48),
        body: Column(
          children: [
            const SizedBox(height: 40),
            StreamBuilder(
              stream: FlutterCompass
                  .events, // here it needs a direction... not qiblah tho
              builder: (context, snapshot) {
                // heading has error
                if (snapshot.hasError) {
                  return const Text('Error while getting north direction');
                }
                //snapshot not ready yet
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading north direction...');
                }

                direction = snapshot.data!.heading;
                compassAccuracy = snapshot.data!.accuracy ?? -1;

                // if direction is null, propably no sensors
                if (direction == null) {
                  return const Text('Device might not have sensors!');
                }

                // animation settings
                animation = Tween(
                        begin:
                            begin, // fist begin position would be 0.0, so it begins at the start position of the animation just initialized??...when app is executed
                        end: (direction! * (pi / 180) * -1))
                    .animate(_animationController!);
                begin = (direction! *
                    (pi / 180) *
                    -1); // the following begin positions of each animation would be the end position of the one who came before

                _animationController!
                    .forward(from: 0); // implicitly starts the animation??

                return _buildNiceCompass();
              },
            ),
            const SizedBox(height: 30),
            StreamBuilder(
              stream: Geolocator.getPositionStream(
                  locationSettings: locationSettings),
              builder: (context, snapshot) {
                //user coordinates have an error
                if (snapshot.hasError) {
                  return const Text('Error while getting your location');
                }
                //user coordinates are not ready yet
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Finding you on planet Earth...',
                      style: TextStyle(color: Colors.white, fontSize: 24));
                }

                latitude = snapshot.data!.latitude;
                longitude = snapshot.data!.longitude;
                accuracy = snapshot.data!.accuracy;
                locationHeading = snapshot.data!.heading;

                if (latitude == null || longitude == null) {
                  return const Text('Your coordinates are null!');
                }

                bearing = Geolocator.bearingBetween(latitude!, longitude!,
                    destCoord.latitude, destCoord.longitude);
                distance = Geolocator.distanceBetween(latitude!, longitude!,
                    destCoord.latitude, destCoord.longitude);

                // Check if close to DESTINATION
                if (distance < 3.1) {
                  messageDisplayed = "Ci sei quasi...";
                }

                // Check if arrived at DESTINATION
                if (distance < 3) {
                  //messageDisplayed = "Keep steady";
                  // keep steady for 1 second
                  Future.delayed(const Duration(milliseconds: 1200), () {
                    widget.destinantionReached();
                  });
                }

                messageDisplayed = "Cammina verso la meta";

                return Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      messageDisplayed,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 233, 148, 105),
                        fontSize: 28,
                      ),
                    ),
                    Text('${distance.toInt()} m',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 32)),
                    const SizedBox(
                      height: 30,
                    ),
                    Text('gps acc: ${accuracy!.toInt()}m',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18)),
                    const SizedBox(
                      height: 20,
                    ),
                    Text('compass acc: ${compassAccuracy.toInt()}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () {},
              child: const Text(
                "Cambia destinazione",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            )
          ],
        ),
      ),
    );
  }

  void manuallyChangeDestination() {
/*

void _submitExpenseData() {
    final enteredCoord = double.tryParse(_amountController
        .text); // tryParse('Hello') => null, tryParse('1.12') => 1.12
    final amountIsInvalid = enteredAmount == null || enteredAmount <= 0;
    if (_titleController.text.trim().isEmpty ||
        amountIsInvalid ||
        _selectedDate == null) {
      _showDialog();
      return;
    }

    ;
    Navigator.pop(context);
  }


 */
  }

  Widget _buildNiceCompass() {
    // get north direction and offset then calculate their sum
    double? direction360 = direction! < 0 ? (360 + direction!) : direction;

    //double northOffset360 = northOffset < 0 ? (360 + northOffset) : northOffset;
    double bearing360 = (bearing) < 0 ? (360 + (bearing)) : (bearing);
    double goalDirection = direction360! - bearing360;
    if (goalDirection < 0) {
      goalDirection = goalDirection + 360;
    }

    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        /*
        Text(
          "north: ${direction360.toInt()}°",
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
        */
        Text(
          "${goalDirection.toInt()}°",
          style: const TextStyle(color: Colors.brown, fontSize: 40),
        ),
        const SizedBox(
          height: 30,
        ),
        SizedBox(
          child: Stack(alignment: Alignment.center, children: [
            AnimatedBuilder(
              animation: animation!,
              builder: (context, child) {
                return Transform.rotate(
                  angle: animation!.value,
                  child: NiceCompass(
                    stack: Stack(
                      children: [
                        const CardinalDirections(),
                        RotatingDirectionMarker(angle: bearing),
                        //RotatingDirectionMarker(angle: northOffset)
                      ],
                    ),
                  ),
                );
              },
            ),
            Transform.translate(
              offset: const Offset(0, -8),
              child: Image.asset(
                'assets/images/round_arrow.png',
                height: 140,
                width: 140,
              ),
            ),
            Column(
              children: [
                Text('${(distance).toInt()}',
                    //textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 36)),
                const Text('metri',
                    //textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 20)),
              ],
            ),
          ]),
        ),
      ]),
    );
  }
}
