import 'package:flutter/material.dart';

class NavigatioOver extends StatelessWidget {
  const NavigatioOver({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              radius: 2,
              colors: [
                Color.fromARGB(255, 30, 148, 97),
                Color.fromARGB(255, 41, 41, 41),
                //Color.fromARGB(255, 104, 105, 143)
              ],
            ),
          ),
          child: Center(
            child: Text(
              "Navigazione terminata!",
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
        ),
      ),
    );
  }
}
