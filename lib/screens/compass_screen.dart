import 'dart:math';
//import 'dart:async';
import 'package:compass1/model/dest_place.dart';
import 'package:compass1/screens/nice_compass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:compass1/goal_location.dart';
//import 'package:vibration/vibration.dart';
//import 'package:location/location.dart';
/*
late Timer
    backgroundVibration; // the Timer which will keep running until some cond is meet.
bool shouldStop = false; // Add some variable to know , when to stop
*/

final _coordController = TextEditingController();

Animation<double>? animation;
AnimationController? _animationController;
double begin = 0.0;
double? direction;
double compassAccuracy = -1;
double? accuracy;
double? latitude;
double? longitude;
double locationHeading = 361;
double distance = -1;
double fakeDistance = 4;
var locationSettings = AndroidSettings(
  accuracy: LocationAccuracy.best,
  //distanceFilter: 1,
  forceLocationManager: false,
  //intervalDuration: const Duration(seconds: 1),
  //(Optional) Set foreground notification config to keep the app alive
  //when going to the background
);
double bearing = 0;
String messageDisplayed = "Cammina verso la meta";

double northOffset = 0;
//final Location userLocation = Location();
//final Geolocator location1 = Geolocator();

final goal = GoalLocation(41.5852758, 12.6563285, 'Parco Lirica');
//final goal1 = GoalLocation(43.6765487, 6.8218989, 'Francia da qualche parte');

class CompassScreen extends StatefulWidget {
  const CompassScreen(this.destinantionReached, this.destCoord, {super.key});

  final void Function() destinantionReached;

  final DestCoord destCoord;

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
        vsync: this, duration: const Duration(milliseconds: 250));
    animation = Tween(begin: 0.0, end: 0.0).animate(
        _animationController!); // initialize the animation on dumb values...why??
/*
    backgroundVibration =
        Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      shouldVibrate(); // This will check whether to stop or go on. Every 1 sec
});
*/

    super.initState();
  }

  @override
  void dispose() {
    //backgroundVibration.cancel();
    _animationController?.dispose();
    super.dispose();
  }

  void closeCompass() {
    widget.destinantionReached();
  }

/*
  void shouldVibrate() {
    Vibration.cancel();
    if (distance < 35 && distance > 20) {
      Vibration.vibrate(pattern: [0, 50, 1400]);
    }
    /*
    if (distance < 20 && distance > 8) {
      Vibration.vibrate(pattern: [0, 200, 750]);
    }
    */
    if (distance < 8 && distance > 0) {
      Vibration.vibrate(pattern: [0, 500, 200]);
    }
    if (shouldStop) {
      backgroundVibration.cancel();
    }
  }
*/
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 48, 48, 48),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //const SizedBox(height: 40),
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
                //Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

                //user coordinates have an error
                if (snapshot.hasError) {
                  return const Text('Error while getting your location');
                }

                //user coordinates are not ready yet
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Determino la tua posizione sul pianeta...',
                      style: TextStyle(color: Colors.white, fontSize: 24));
                }

                latitude = snapshot.data!.latitude;
                longitude = snapshot.data!.longitude;
                accuracy = snapshot.data!.accuracy;

                if (latitude == null || longitude == null) {
                  return const Text('Your coordinates are null!');
                }

                northOffset = goal.getOffsetFromNorth(latitude!, longitude!,
                    widget.destCoord.latitude, widget.destCoord.longitude);

                // stop updating bearing if user is close to destination
                if (distance < 45) {
                  bearing = Geolocator.bearingBetween(latitude!, longitude!,
                      widget.destCoord.latitude, widget.destCoord.longitude);
                }

                distance = Geolocator.distanceBetween(latitude!, longitude!,
                    widget.destCoord.latitude, widget.destCoord.longitude);

                // Check if arrived at DESTINATION
                if (distance < 6) {
                  messageDisplayed = "Attendi un istante";
                  // keep steady for 1 second
                  //Future.delayed(const Duration(milliseconds: 500), () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    widget.destinantionReached();
                  });

                  //});
                }

                // Check if close to DESTINATION
                if (distance < 35 && distance > 20) {
                  messageDisplayed = "Sei sulla giusta strada";
                }

                // Check if really close to DESTINATION
                if (distance < 13) {
                  messageDisplayed = "Ci sei quasi...";
                }

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
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('gps acc: ${accuracy!.toInt()}m',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18)),
                        const SizedBox(
                          width: 20,
                        ),
                        Text('compass acc: ${compassAccuracy.toInt()}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18)),
                      ],
                    ),
                  ],
                );
              },
            ),
            /*
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                widget.destinantionReached();
              },
              child: const Text(
                "Cambia destinazione",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
            */
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

    double northOffset360 = northOffset < 0 ? (360 + northOffset) : northOffset;
    double bearing360 = (bearing) < 0 ? (360 + (bearing)) : (bearing);
    double goalDirection = direction360! - bearing360;
    if (goalDirection < 0) {
      goalDirection = goalDirection + 360;
    }

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                      RotatingDirectionMarker(angle: bearing360),
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
      const SizedBox(
        height: 15,
      ),
      Text('bearing: ${(bearing).toInt()} / ${bearing360.toInt()}',
          //textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 22)),
      ////
      Text('northoffset: ${(northOffset).toInt()} / ${northOffset360.toInt()}',
          //textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 22)),
    ]);
  }
}
