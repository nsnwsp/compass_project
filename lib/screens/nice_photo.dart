import 'package:flutter/material.dart';

class NicePhoto extends StatefulWidget {
  const NicePhoto({super.key});

  @override
  State<NicePhoto> createState() => _NicePhotoState();
}

class _NicePhotoState extends State<NicePhoto> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/photo1',
              height: 140,
              width: 240,
            ),
            Text("Hey")
          ],
        ),
      ),
    );
  }
}
