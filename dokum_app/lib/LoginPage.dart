import 'package:KHD_Dokum/AdminLoginPage.dart';
import 'package:KHD_Dokum/UserLoginPage.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange[700],
        title: Text(
          "Giriş",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 30),
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
                child: Column(
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
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserLoginPage())),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),),
                    fixedSize: const Size(200, 200),
                    backgroundColor: Colors.green
                ),
              ),
              SizedBox(height: 30,),
              ElevatedButton(
                child: Column(
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
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminLoginPage())),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),),
                    fixedSize: const Size(200, 200),
                    backgroundColor: Colors.green[800]
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
