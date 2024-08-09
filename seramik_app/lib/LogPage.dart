import 'package:flutter/material.dart';
import 'AdminLoginPage.dart';
import 'LoginPage.dart';

class LogPage extends StatelessWidget {
  const LogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange[700],
        title: const Text(
          "Giriş",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(50),
          child: Column(
            children: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage())),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),),
                    fixedSize: const Size(200, 200),
                    backgroundColor: Colors.green
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 100.0,
                    ),
                    SizedBox(
                      height:10,
                    ),
                    Text("Kullanıcı", style:TextStyle(fontSize:20, color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(height: 30,),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminLoginPage())),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),),
                    fixedSize: const Size(200, 200),
                    backgroundColor: Colors.green[800]
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.manage_accounts,
                      color: Colors.white,
                      size: 100.0,
                    ),
                    SizedBox(
                      height:10,
                    ),
                    Text("Admin", style:TextStyle(fontSize:20, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
