import 'package:KHD_Dokum/AdminPage.dart';
import 'package:KHD_Dokum/LoginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({Key? key}) : super(key: key);

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> _loginWithEmailPassword(BuildContext context) async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    try {
      UserCredential result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminPage()));
      }
    } catch (e) {
      print('*******************${e}');
      final snackBar = SnackBar(
        content: Text('Mail adresi veya şifre yanlış!'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
        ),
        backgroundColor: Colors.deepOrange[700],
        title: Text(
          "Giriş",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              SizedBox(height: 30,),
              Image(image: AssetImage('imgs/logo_white.png')),
              SizedBox(height: 30,),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: new InputDecoration(
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(30),
                      ),
                    ),
                    filled: true,
                    prefixIcon: Icon(
                      Icons.mail,
                      color: Colors.black,
                    ),
                    hintStyle: new TextStyle(color: Colors.grey),
                    hintText: "planlama@khd.com.tr",
                    fillColor: Colors.white),
              ),
              SizedBox(height: 30,),
              TextField(
                controller: passwordController,
                keyboardType: TextInputType.visiblePassword,
                decoration: new InputDecoration(
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(30),
                      ),
                    ),
                    filled: true,
                    prefixIcon: Icon(
                      Icons.password,
                      color: Colors.black,
                    ),
                    hintStyle: new TextStyle(color: Colors.grey),
                    hintText: "_ _ _ _ _ _ _ _ _",
                    fillColor: Colors.white),
              ),
              SizedBox(height: 30,),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),),
                      fixedSize: const Size(125, 40),
                      backgroundColor: Colors.green[700]
                  ),
                  child: Text("Login", style: TextStyle(fontSize: 20, color: Colors.white)),
                  onPressed: () {
                    _loginWithEmailPassword(context);
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
