import 'package:flutter/material.dart';
import 'package:mitra_rumahraga/login.dart'; // Sesuaikan dengan lokasi file login.dart

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });

    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/rumahraga.png',
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
