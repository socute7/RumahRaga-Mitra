import 'package:flutter/material.dart';
import 'package:mitra_rumahraga/history.dart';
import 'package:mitra_rumahraga/splash.dart';
import 'package:mitra_rumahraga/login.dart';
import 'package:provider/provider.dart';
import 'package:mitra_rumahraga/profile.dart';
import 'package:mitra_rumahraga/models/user_provider.dart';
import 'package:mitra_rumahraga/order.dart' as OrderPage;

import 'dashboard.dart';
import 'tambah.dart';
import 'edit.dart';
import 'jam.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        if (settings.name == '/splash') {
          return MaterialPageRoute(builder: (context) => SplashScreen());
        } else if (settings.name == '/login') {
          return MaterialPageRoute(builder: (context) => LoginScreen());
        } else if (settings.name == '/dashboard') {
          int? mitraId =
              Provider.of<UserProvider>(context, listen: false).idMitra;
          return MaterialPageRoute(
            builder: (context) => DashboardScreen(mitraId: mitraId ?? 0),
          );
        } else if (settings.name == '/tambah') {
          return MaterialPageRoute(builder: (context) => TambahScreen());
        } else if (settings.name == '/edit') {
          return MaterialPageRoute(builder: (context) => EditScreen());
        } else if (settings.name == '/order') {
          return MaterialPageRoute(
              builder: (context) => OrderPage.OrderScreen());
        } else if (settings.name == '/history') {
          final args = settings.arguments as Map<String, dynamic>?;
          final String? transactionCode = args?['transactionCode'] as String?;
          return MaterialPageRoute(
            builder: (context) => HistoryScreen(),
          );
        } else if (settings.name == '/profile') {
          return MaterialPageRoute(builder: (context) => ProfileScreen());
        } else if (settings.name == '/jam') {
          return MaterialPageRoute(builder: (context) => JamScreen());
        }
        return null;
      },
      home: LoginScreen(),
    );
  }
}
