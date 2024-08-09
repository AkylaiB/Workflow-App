import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:KHD_Dokum/LoginPage.dart';
import 'package:KHD_Dokum/AdminPage.dart';
import 'package:KHD_Dokum/UserPage.dart';

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
      theme: ThemeData(primarySwatch: Colors.blue,),
      home: CheckAuthentication(),
    );
  }
}

class CheckAuthentication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //return UserPage();
  final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (user.email == 'planlama@khd.com.tr') {
        return AdminPage();
      } else {
        return UserPage();
      }
    } else {
      return LoginPage();
    }
  }
}
