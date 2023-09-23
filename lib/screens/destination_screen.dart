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
            mainAxisSize: MainAxisSize.max,
            children: [
              Center(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    background: Paint()
                      ..color = Color.fromARGB(255, 0, 0, 0)
                      ..strokeJoin = StrokeJoin.round
                      ..strokeCap = StrokeCap.round
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 34.0,
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 3),
                  ),
                  child: Image.asset(
                    widget.photoPath,
                    width: MediaQuery.of(context).size.width * 0.85,
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
                child: Text(
                  button,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255), fontSize: 30),
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
