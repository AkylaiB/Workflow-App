import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:KHD_Seramik/LogPage.dart';
import 'package:KHD_Seramik/UserPage.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LogPage()));},
        ),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 30,),
              const Image(image: AssetImage('imgs/logo_white.png')),
              const SizedBox(height: 30,),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                    ),
                    filled: true,
                    prefixIcon: Icon(
                      Icons.phone,
                      color: Colors.black,
                    ),
                    hintStyle: TextStyle(color: Colors.grey),
                    hintText: "+905556661122",
                    fillColor: Colors.white),
              ),
              const SizedBox(height: 20,),
              Visibility(
                visible: otpCodeVisible,
                child: TextField(
                  controller: otpCodeController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30),),
                      ),
                      filled: true,
                      prefixIcon: const Icon(
                        Icons.password,
                        color: Colors.black,
                      ),
                      hintStyle: TextStyle(color: Colors.grey[800]),
                      hintText: "_ _ _ _ _ _",
                      fillColor: Colors.white),
                ),
              ),
              const SizedBox(height: 30,),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0),),
                      fixedSize: const Size(125, 40),
                      backgroundColor: Colors.green[700]
                  ),
                  child: Text(otpCodeVisible? "Login":"Doğrula", style: const TextStyle(fontSize: 20, color: Colors.white)),
                  onPressed: () {
                    if (phoneController.text.length==13) {
                      const snackBar = SnackBar(
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
                    }
                    else{
                      const snackBar = SnackBar(
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
                  builder: (context) => const UserPage())));
          },
        verificationFailed: (FirebaseAuthException exception){
          print("********************$exception.message");
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
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)
        => const UserPage()));
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
      print("***************************Kullanıcı tanımlı değil!");
    }
  }
}
