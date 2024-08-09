import 'package:KHD_Dokum/LoginPage.dart';
import 'package:KHD_Dokum/UserPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserLoginPage extends StatefulWidget {
  const UserLoginPage({Key? key}) : super(key: key);

  @override
  State<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController otpCodeController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  String receivedVerificationID = "";
  bool otpCodeVisible = false;
  bool user_type = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
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
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: new InputDecoration(
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(30),
                      ),
                    ),
                    filled: true,
                    prefixIcon: Icon(
                      Icons.phone,
                      color: Colors.black,
                    ),
                    hintStyle: new TextStyle(color: Colors.grey),
                    hintText: "+905556661122",
                    fillColor: Colors.white),
              ),
              SizedBox(height: 20,),
              Visibility(
                visible: otpCodeVisible,
                child: TextField(
                  controller: otpCodeController,
                  keyboardType: TextInputType.phone,
                  decoration: new InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(const Radius.circular(30),),
                      ),
                      filled: true,
                      prefixIcon: Icon(
                        Icons.password,
                        color: Colors.black,
                      ),
                      hintStyle: new TextStyle(color: Colors.grey[800]),
                      hintText: "_ _ _ _ _ _",
                      fillColor: Colors.white),
                ),
              ),
              SizedBox(height: 30,),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0),),
                      fixedSize: const Size(125, 40),
                      backgroundColor: Colors.green[700]
                  ),
                  child: Text(otpCodeVisible? "Login":"Doğrula", style: TextStyle(fontSize: 20, color: Colors.white)),
                  onPressed: () {
                    if (phoneController.text.length==13) {
                      final snackBar = SnackBar(
                        content: Text('Bekleyiniz...'),
                        duration: Duration(seconds: 2),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      if(otpCodeVisible){
                        verifyCode();
                      }
                      else {
                        isUser();
                      }
                    }else{
                      final snackBar = SnackBar(
                        content: Text('Numaranızı +905556661122 formatında yazınız!'),
                        duration: Duration(seconds: 2),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> verifyNumber() async{
    await auth.verifyPhoneNumber(
        phoneNumber: phoneController.text,
        verificationCompleted: (PhoneAuthCredential credential){
          auth.signInWithCredential(credential).then((value) =>
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => UserPage())));
        },
        verificationFailed: (FirebaseAuthException exception){
          print("********************************$exception.message");
        },
        codeSent: (String verificationID, int? resendToken){
          setState(() {
            receivedVerificationID = verificationID;
            otpCodeVisible = true;
          });
        },
        codeAutoRetrievalTimeout: (String verificationID){
          setState(() {
            receivedVerificationID = verificationID;
            otpCodeVisible = true;
          });
        }
    );
  }

  void verifyCode() async{
    PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: receivedVerificationID, smsCode: otpCodeController.text);
    await auth.signInWithCredential(credential).then((value){
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => UserPage()));
    });
  }

  void isUser() async{
    final CollectionReference collection = FirebaseFirestore.instance.collection('Personel'); // Replace with your actual collection name.

    final QuerySnapshot querySnapshot = await collection
        .where('Telefon', isEqualTo: phoneController.text)
        .get();

    if(querySnapshot.docs.isNotEmpty){
      verifyNumber();
    }
    else{
      print("********************************Kullanıcı tanımlı değil!");
    }
  }
}
