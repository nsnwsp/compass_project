import 'package:compass1/model/dest_place.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/compass_screen.dart';
import 'screens/destination_screen.dart';
import 'screens/navigation_over.dart';
import 'data/place_playlist.dart';

class Compass extends StatefulWidget {
  const Compass({super.key});

  @override
  State<Compass> createState() => _CompassState();
}

class _CompassState extends State<Compass> {
  bool userReady = false;
  DestPlace? currentPlace = playlist[0];
  //DestCoord currentCoord = currentPlace.coord.latitude;//DestCoord(currentPlace.coord.latitude ?? 41.5852128 ?? 12.6558842);
  List<DestPlace> currentPlaylist = List.from(playlist);
  bool _hasPermissions = false;
  //var currentCoord = (latitude: 41.5852128, longitude: 12.6558842);

  var _activeScreen = 'compass-screen';

/* checks to have location permissions granted, during init*/
  @override
  void initState() {
    super.initState();
    //_fetchPermissionStatus();
  }

  void _switchScreen() {
    _activeScreen == 'compass-screen'
        ? setState(() {
            _activeScreen = 'destination-screen';
          })
        : setState(() {
            _activeScreen = 'compass-screen';
          });
  }

  void _proceedInPlaylist() {
    currentPlaylist.removeAt(0);
    if (currentPlaylist.isEmpty) {
      setState(() {
        _activeScreen = 'navigation-over';
      });
    } else {
      currentPlace = currentPlaylist[0];
      setState(() {
        _activeScreen = 'compass-screen';
      });
    }
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("I need to know where you are to tell where to go next.",
              textAlign: TextAlign.center,
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
    Widget screenWidget = CompassScreen(_switchScreen, currentPlace!.coord);

    if (_activeScreen == "compass-screen") {
      screenWidget = CompassScreen(_switchScreen, currentPlace!.coord);
    }
    if (_activeScreen == "destination-screen") {
      screenWidget = DestinationScreen(
          _proceedInPlaylist, currentPlace!.text, currentPlace!.photo);
    }
    if (_activeScreen == "navigation-over") {
      screenWidget = const NavigatioOver();
    }

    return MaterialApp(
      title: 'Compass Project',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        builder: (context, snapshot) {
          if (_hasPermissions && userReady) {
            return screenWidget;
          } else {
            return SafeArea(
              child: Scaffold(
                backgroundColor: const Color.fromARGB(255, 48, 48, 48),
                body: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/start_back.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/start_logo.png",
                        height: 300,
                      ),
                      const SizedBox(height: 30),
                      const Text(
                          "Benvenuto, quando sei pronto possiamo iniziare.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 24)),
                      const SizedBox(height: 60),
                      OutlinedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 40,
                          ),
                          backgroundColor: Color.fromARGB(132, 0, 0, 0),
                          //foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: const Text(
                          "Sono pronto",
                          style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 30),
                        ),
                        onPressed: () {
                          setState(() {
                            userReady = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
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
