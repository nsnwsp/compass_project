import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

class DestinationScreen extends StatefulWidget {
  const DestinationScreen(this.backToCompass, {super.key});

  final void Function() backToCompass;

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  double distance = 32;
  ReceivePort _port = ReceivePort();
  void _startBackgroundTask() async {
    await Isolate.spawn(_backgroundTask, _port.sendPort);
    _port.listen((message) {
      // Handle background task completion
      print('Background task completed: $message');
    });
  }

  void _backgroundTask(SendPort sendPort) {
    while (distance < 35 && distance > 0) {
      Vibrate.vibrate;
    }
    sendPort.send('Task completed successfully!');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 48, 48, 48),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/photo1.jpg',
                width: MediaQuery.of(context).size.width * 0.9,
              ),
              const SizedBox(height: 30),
              const Text("Hey",
                  style: TextStyle(color: Colors.white, fontSize: 32)),
              const SizedBox(height: 70),
              TextButton(
                child: const Text(
                  'Chiudi',
                  style: TextStyle(
                      color: Color.fromARGB(255, 233, 148, 105), fontSize: 34),
                ),
                onPressed: () {
                  widget.backToCompass();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
