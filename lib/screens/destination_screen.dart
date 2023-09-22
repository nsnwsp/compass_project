import 'package:flutter/material.dart';

class DestinationScreen extends StatefulWidget {
  const DestinationScreen(this.continuePlaylist, this.text, this.photoPath,
      {super.key});
  final String text;
  final String photoPath;

  final void Function() continuePlaylist;

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  String button = "Chiudi";
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
                widget.photoPath,
                width: MediaQuery.of(context).size.width * 0.7,
              ),
              const SizedBox(height: 30),
              Text(widget.text,
                  style: const TextStyle(color: Colors.white, fontSize: 32)),
              const SizedBox(height: 70),
              TextButton(
                child: Text(
                  button,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 233, 148, 105), fontSize: 34),
                ),
                onPressed: () {
                  button = "Solo un secondo...";

                  widget.continuePlaylist();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
