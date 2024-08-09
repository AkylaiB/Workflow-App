
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:KHD_Seramik/UserPage.dart';
import 'LogPage.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:KHD_Seramik/AdminPage.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CheckAuthentication(),
    );
  }
}

class CheckAuthentication extends StatelessWidget {
  const CheckAuthentication({super.key});

  @override
  Widget build(BuildContext context) {
    //return UserPage();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (user.email == 'planlama@khd.com.tr') {
        return const AdminPage();
      } else {
        return const UserPage();
      }
    } else {
      return const LogPage();
    }
  }
}

