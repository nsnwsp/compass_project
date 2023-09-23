import 'package:flutter/material.dart';
import 'dart:math' as math;

class NiceCompass extends StatelessWidget {
  final Widget stack;

  const NiceCompass({super.key, required this.stack});

  @override
  Widget build(BuildContext context) {
    //double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: screenWidth * 0.94,
      width: screenWidth * 0.94,
      alignment: Alignment.center, // inner container
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 3),
          color: Color.fromARGB(255, 233, 148, 105),
          shape: BoxShape.circle),
      child: Container(
        height: screenWidth * 0.85,
        width: screenWidth * 0.85,
        alignment: Alignment.center, // inner container
        decoration: const BoxDecoration(
            //border: Border.all(width: 15, color: Color.fromARGB(255, 233, 148, 105)),
            color: Colors.white,
            shape: BoxShape.circle),
        child: stack,
      ),
    );
  }
}

class RotatingDirectionMarker extends StatelessWidget {
  final double angle;
  const RotatingDirectionMarker({super.key, required this.angle});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Transform.rotate(
      angle: angle * math.pi / 180,
      child: Container(
        color: Colors.black12,
        height: screenWidth,
        width: 30.0,
        alignment: Alignment.topCenter,
        child: const Icon(
          Icons.circle,
          size: 20.0,
          color: Colors.brown,
        ),
      ),
    );
  }
}

class RoundArrow extends StatelessWidget {
  const RoundArrow({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -7),
      child: Image.asset(
        'assets/images/round_arrow.png',
        height: 70,
        width: 70,
      ),
    );
  }
}

class CardinalDirections extends StatelessWidget {
  const CardinalDirections({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Transform.rotate(
          angle: 0,
          child: Container(
            height: screenWidth,
            width: 30.0,
            //color: Colors.black12,
            alignment: Alignment.topCenter,
            child: const Text(
              'N',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 34),
            ),
          ),
        ),
        Transform.rotate(
          angle: math.pi / 2,
          child: Container(
            height: screenWidth,
            width: 30.0,
            //color: Colors.black12,
            alignment: Alignment.topCenter,
            child: const Text(
              'E',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
            ),
          ),
        ),
        Transform.rotate(
          angle: -math.pi / 2,
          child: Container(
            height: screenWidth,
            width: 30.0,
            //color: Colors.black12,
            alignment: Alignment.topCenter,
            child: const Text(
              'O',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
            ),
          ),
        ),
        Transform.rotate(
          angle: math.pi,
          child: Container(
            height: screenWidth,
            width: 30.0,
            //color: Colors.black12,
            alignment: Alignment.topCenter,
            child: const Text(
              'S',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
            ),
          ),
        )
      ],
    );
  }
}
