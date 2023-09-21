import 'package:flutter/material.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/compass_screen.dart';
import 'screens/destination_screen.dart';

class Compass extends StatefulWidget {
  const Compass({super.key});

  @override
  State<Compass> createState() => _CompassState();
}

class _CompassState extends State<Compass> {
  bool _hasPermissions = false;
  //late Geolocator userPosition;

  var _activeScreen = 'destination-screen';

  void _switchScreen() {
    _activeScreen == 'compass-screen'
        ? setState(() {
            _activeScreen = 'destination-screen';
          })
        : setState(() {
            _activeScreen = 'compass-screen';
          });
  }

  /* checks to have location permissions granted, during init*/
  @override
  void initState() {
    super.initState();
    //_fetchPermissionStatus();
  }

  // check and get the location service started///////////////////////////////////////////////////////////////////////////////

  // check and get permissions directly
  Future getPermission() async {
    if (await Permission.location.serviceStatus.isEnabled) {
      var status = await Permission.location.status;
      if (status.isGranted) {
        _hasPermissions = true;
      } else {
        Permission.location.request().then((value) {
          setState(() {
            _hasPermissions = (value == PermissionStatus.granted);
          });
        });
      }
    }
  }

  // if not woking, user will be prompt to give permissions
  Widget _buildPermissionSheet() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("I need to know where you are to tell where to go next.",
              style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 30),
          ElevatedButton(
            child: const Text('Request Permissions'),
            onPressed: () {
              Permission.locationWhenInUse.request().then((status) {
                setState(() {
                  _hasPermissions = (status == PermissionStatus.granted);
                });
              });
            },
          ),
        ],
      ),
    );
  }

  // main app widget
  @override
  Widget build(BuildContext context) {
    Widget screenWidget = CompassScreen(_switchScreen);

    if (_activeScreen == "compass-screen") {
      screenWidget = CompassScreen(_switchScreen);
    }
    if (_activeScreen == "destination-screen") {
      screenWidget = DestinationScreen(_switchScreen);
    }

    return MaterialApp(
      title: 'CompassAmor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        builder: (context, snapshot) {
          if (_hasPermissions) {
            return screenWidget;
          } else {
            return Scaffold(
              backgroundColor: const Color.fromARGB(255, 48, 48, 48),
              body: _buildPermissionSheet(),
            );
          }
        },
        future: getPermission(),
      ),
    );
  }
}

/*

MANUAL CHECK PERMISSION STATUS (FROM GEOLOCATOR DEV) 


  Future<Position> _startGeolocator() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

//////OLD STUFF (but gold?)


  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then(
      (status) {
        if (mounted) {
          setState(
            () {
              _hasPermissions = (status == PermissionStatus.granted);
            },
          );
        }
      },
    );
  }

// main widget while building nice compass
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          backgroundColor: Colors.blueGrey,
          body: const SafeArea(
            child: Align(alignment: Alignment.center, child: NiceCompass()),
          ),
        ));
  }
}
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            if (_hasPermissions) {
              return _directionProvider();
            } else {
              return _buildPermissionSheet();
            }
          },
        ),
      ),
    );
  }
*/
