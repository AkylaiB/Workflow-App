import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:KHD_Seramik/LogPage.dart';
import 'package:share/share.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'AddItemPage.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

const List<Widget> katlar = <Widget>[
  Text('1', style: TextStyle(fontWeight: FontWeight.bold),),
  Text('2', style: TextStyle(fontWeight: FontWeight.bold),),
  Text('3', style: TextStyle(fontWeight: FontWeight.bold),),
  Text('4', style: TextStyle(fontWeight: FontWeight.bold),),
  Text('5', style: TextStyle(fontWeight: FontWeight.bold),),
  Text('6', style: TextStyle(fontWeight: FontWeight.bold),),
  Text('7', style: TextStyle(fontWeight: FontWeight.bold),)
];

const List<Widget> kazanlar = <Widget>[
  Text('1', style: TextStyle(fontWeight: FontWeight.bold),),
  Text('2', style: TextStyle(fontWeight: FontWeight.bold),),
  Text('3', style: TextStyle(fontWeight: FontWeight.bold),),
  Text('4', style: TextStyle(fontWeight: FontWeight.bold),),
  Text('5', style: TextStyle(fontWeight: FontWeight.bold),),
  Text('6', style: TextStyle(fontWeight: FontWeight.bold),),
  Text('7', style: TextStyle(fontWeight: FontWeight.bold),)
];


class Urun {
  final String Stok_Kodu;
  final String Malzeme_Aciklamasi;
  final String Is_Emri;
  final int Salkim_Sayisi;
  final int Fire_Sayisi;

  Urun(this.Stok_Kodu, this.Malzeme_Aciklamasi, this.Is_Emri, this.Salkim_Sayisi, this.Fire_Sayisi);
}


class _UserPageState extends State<UserPage> {
  List<Urun> items = [];
  late final personel_id;
  String fullName = "";
  TextEditingController ArabaNoCtrlr = TextEditingController();
  late Timestamp baslangic;
  late Timestamp bitis;
  List<String> UrunIDler= [];
  bool startButtonEnabled = true;
  bool finishButtonEnabled= false;
  final List<bool> _secilenKat = <bool>[true,false,false,false,false,false,false];
  late String secilmisKat;
  final List<bool> _secilenKazan = <bool>[true,false,false,false,false,false,false];
  late String secilmisKazan;

  @override
 void initState() {
    super.initState();
    _getUserInfo();
  }

  void reset_page() {
    setState(() {
      ArabaNoCtrlr.clear();
      for (int i = 0; i < _secilenKat.length; i++) {
        if(i==0){
          _secilenKat[i] = true;}
        else{
          _secilenKat[i] = false;}
      }
      for (int i = 0; i < _secilenKazan.length; i++) {
        if(i==0){
          _secilenKazan[i] = true;}
        else{
          _secilenKazan[i] = false;}
      }
      items.clear();
    });
  }

  void _getUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if(user != null){
        FirebaseFirestore.instance.collection('Personel').where('Telefon', isEqualTo: user.phoneNumber).get().then((QuerySnapshot querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          final userData = querySnapshot.docs[0].data() as Map<String, dynamic>;
          final firstName = userData['Ad'];
          final lastName = userData['Soyad'];
          personel_id = querySnapshot.docs[0].id;
          fullName = '$firstName $lastName';
        }
      }).catchError((error) {
          print('**************************$error');
      });
    }
  }

  Future<void> addDocument_Islem_Urun(String islemId) async {
    try {
      for(int i = 0; i < UrunIDler.length; i++) {
        var urunId = UrunIDler[i];
        DocumentReference islemRef = FirebaseFirestore.instance.collection('Islem').doc(islemId);
        DocumentReference urunRef = FirebaseFirestore.instance.collection('Urun').doc(urunId);
        DocumentReference docRef = FirebaseFirestore.instance.collection('Islem-Urun').doc();
        await docRef.set({
          'Islem_ID': islemRef,
          'Urun_ID': urunRef,
          'excel': false,
        });
        print('**************************ID: ${docRef.id} döküman oluşturuldu.');
      }
    } catch (e) {
      print('**************************Döküman eklemede bir hata oluştu: $e');
    }
  }

  Future<bool> addDocument_Islem() async {
    try {
      DocumentReference userRef = FirebaseFirestore.instance.collection('Personel').doc(personel_id);
      DocumentReference docRef = FirebaseFirestore.instance.collection('Islem').doc();
      print("***********Araba in  adding: ${ArabaNoCtrlr.text}");
      await docRef.set({
        'Araba_No': ArabaNoCtrlr.text,
        'Baslangic': baslangic,
        'Bitis': bitis,
        'Gonderen_ID': userRef,
        'Kat_No': int.parse(secilmisKat),
        'Kazan_No': int.parse(secilmisKazan)
      });

      print('**************************ID: ${docRef.id} döküman oluşturuldu.');
      addDocument_Islem_Urun(docRef.id);
      return true;
    } catch (e) {
      print('**************************Döküman eklemede bir hata oluştu: $e');
      return false;
    }
  }

  Future<void> addDocument_Urun(newItem) async {
    try {
      DocumentReference docRef = FirebaseFirestore.instance.collection('Urun').doc();
      Map<String, dynamic> newUrun = {
        'Stok_Kodu': newItem.Stok_Kodu,
        'Malzeme_Aciklamasi': newItem.Malzeme_Aciklamasi,
        'Is_Emri': newItem.Is_Emri,
        'Salkim_Sayisi': newItem.Salkim_Sayisi,
        'Fire_Sayisi': newItem.Fire_Sayisi,
      };
      await docRef.set(newUrun);

      print('**************************ID: ${docRef.id} döküman oluşturuldu.');
      UrunIDler.add(docRef.id);
    } catch (e) {
      print('**************************Döküman eklemede bir hata oluştu: $e');
    }
  }

  Future<void> createAndSendExcel(String fullName) async {
    var myexcel = Excel.createExcel();
    var sheet = myexcel['Sheet1'];

    sheet.appendRow(['KULLANICI',
      'BAŞLAMA ZAMANI',
      'BİTİRME ZAMANI',
      'ARABA NO',
      'STOK KODU',
      'MALZEME',
      'İŞ EMRİ',
      'SALKIM SAYISI',
      'FİRE SAYISI',
      'KAT NO',
      'KAZAN NO'
    ]);

    try {
      QuerySnapshot IslemUrunSnapshot = await FirebaseFirestore.instance.collection('Islem-Urun').where('excel', isEqualTo: false).get();

      for (QueryDocumentSnapshot islemUrunDoc in IslemUrunSnapshot.docs) {
        DocumentReference islemUrunRef = islemUrunDoc.reference;
        DocumentReference islemRef = islemUrunDoc['Islem_ID'];
        DocumentReference urunRef = islemUrunDoc['Urun_ID'];

        DocumentSnapshot urunSnapshot = await urunRef.get();
        if (urunSnapshot.exists) {
          DocumentSnapshot islemSnapshot = await islemRef.get();
          if (islemSnapshot.exists) {

            Map<String, dynamic> islemData = islemSnapshot.data() as Map<String, dynamic>;
            Map<String, dynamic> urunData = urunSnapshot.data() as Map<String, dynamic>;

            Timestamp baststamp = islemData['Baslangic'];
            DateTime basDateTime = baststamp.toDate();
            String BaslangicDateTime = DateFormat('dd/MM/yyyy HH:mm:ss').format(basDateTime);

            Timestamp sontstamp = islemData['Bitis'];
            DateTime sonDateTime = sontstamp.toDate();
            String BitisDateTime = DateFormat('dd/MM/yyyy HH:mm:ss').format(sonDateTime);

            sheet.appendRow([
              fullName,
              BaslangicDateTime,
              BitisDateTime,
              islemData['Araba_No'],
              urunData['Stok_Kodu'],
              urunData['Malzeme_Aciklamasi'],
              urunData['Is_Emri'],
              urunData['Salkim_Sayisi'].toString(),
              urunData['Fire_Sayisi'].toString(),
              islemData['Kat_No'],
              islemData['Kazan_No'],
            ]);
            islemUrunRef.update({'excel':true});

          } else {
            print('************Islem not found for Islem-Urun document: ${islemUrunDoc.id}');
          }
        } else {
          print('************Urun not found for Islem-Urun document: ${islemUrunDoc.id}');
        }
      }
      Uint8List? excelData = myexcel.save() as Uint8List?;
      final directory = Directory("/storage/emulated/0/Download");
      if(await directory.exists()){
        String file_time = DateTime.now().millisecondsSinceEpoch.toString();
        File file = File('${directory.path}/Seramik_Takip_Formu_$file_time.xlsx');
        try{
          await file.writeAsBytes(excelData!);
          Share.shareFiles(
            [file.path],
            subject: 'Seramik Takip Formu',
            sharePositionOrigin: Rect.fromCenter(center: const Offset(0, 0), width: 0, height: 0),
          );
        }catch(e){
          print("*******************$e");
        }
      }else{
        print("*******************Directory is null");
      }
    } catch (e) {
      print('************$e');
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: FlexibleSpaceBar(
          background: Image.asset(
            'imgs/logo_white.png',
            fit: BoxFit.contain,
          ),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
            onPressed: () async{
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LogPage()));
            },
            icon: const Icon(Icons.logout, color: Colors.white,)),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.mail,
              color: Colors.white,
            ),
            onPressed: () {
              createAndSendExcel(fullName);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric( vertical: 0, horizontal: 3.0),
    child: Column(
    children: [
      Container(
        decoration: BoxDecoration(
          color: Colors.deepOrange,
          border: Border.all(color: Colors.black, width: 1.8),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(50.0),
            bottomRight: Radius.circular(50.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, color: Colors.white),
            Text(fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
          ],
        ),
      ),
      const SizedBox(height: 10,),
      Row(
        children: [
          const Text("Araba No:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
          const SizedBox(width: 10,),
          SizedBox(
            width: 280,
            height: 50,
            child: TextFormField(
              controller: ArabaNoCtrlr,
              decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  )
              ),
            ),
          )
        ],
      ),
      const SizedBox(height: 10,),
      Row(
        children: [
          const Text("Kazan seç:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 5,),
          ToggleButtons(
            direction: Axis.horizontal,
            onPressed: (int index) {
              setState(() {
                for (int i = 0; i < _secilenKazan.length; i++) {
                  _secilenKazan[i] = i == index;
                }
                secilmisKazan = (kazanlar[_secilenKazan.indexOf(true)] as Text).data!;
              });
            },
            borderColor: Colors.black,
            borderRadius: BorderRadius.circular(5),
            selectedBorderColor: Colors.black,
            selectedColor: Colors.white,
            fillColor: Colors.orange,
            color: Colors.orange,
            constraints: const BoxConstraints(
              minHeight: 45.0,
              minWidth: 35.0,
            ),
            isSelected: _secilenKazan,
            children: kazanlar,
          ),
        ],
      ),
      const SizedBox(height: 10,),
      Row(
        children: [
          const Text("Kat seç:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 23,),
          ToggleButtons(
            direction: Axis.horizontal,
            onPressed: (int index) {
              setState(() {
                for (int i = 0; i < _secilenKat.length; i++) {
                  _secilenKat[i] = i == index;
                }
                secilmisKat = (katlar[_secilenKat.indexOf(true)] as Text).data!;
              });
            },
            borderColor: Colors.black,
            borderRadius: BorderRadius.circular(5),
            selectedBorderColor: Colors.black,
            selectedColor: Colors.white,
            fillColor: Colors.deepOrange,
            color: Colors.deepOrange,
            constraints: const BoxConstraints(
              minHeight: 45.0,
              minWidth: 35.0,
            ),
            isSelected: _secilenKat,
            children: katlar,
          ),
        ],
      ),
      const SizedBox(height: 10,),
      Container(
        height: MediaQuery.of (context).size.height*1/2,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1.0),
            borderRadius: BorderRadius.circular(5)
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.black,
              alignment: Alignment.center,
              child: const Text("Malzemeler", style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10.0),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    child: Column(
                      children: [
                        Text('Stok kodu: ${item.Stok_Kodu}'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(100, 40),
            backgroundColor: Colors.green[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
              side: const BorderSide(
                color: Colors.black,
                width: 1.0,
              ),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddItemPage(),
              ),
            ).then((newItem) {
              if (newItem != null) {
                setState(() {
                  items.add(newItem);
                  addDocument_Urun(newItem);
                });
              }
            });
          },
          child: const Text('Ekle', style: TextStyle(color: Colors.white,)),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: const BorderSide(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                  minimumSize: const Size(170, 40),
                  backgroundColor: startButtonEnabled? Colors.orange : Colors.orange[300]
              ),
              onPressed: startButtonEnabled ? (){
                setState(() {
                  startButtonEnabled = false;
                  finishButtonEnabled = true;
                });
                baslangic = Timestamp.now();
                const snackBar = SnackBar(
                  content: Text('İşlem başlatıldı!'),
                  duration: Duration(seconds: 2),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }:null,
              child: const Text('Başla', style: TextStyle(color: Colors.white,)),
            ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: const BorderSide(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                  minimumSize: const Size(170, 40),
                  backgroundColor: finishButtonEnabled? Colors.deepOrange: Colors.deepOrange[300]
              ),
              onPressed: finishButtonEnabled?
                  () {
                setState(() {
                  finishButtonEnabled = false;
                  startButtonEnabled = true;
                });
                bitis = Timestamp.now();

                const snackBar = SnackBar(
                  content: Text('İşlem bitirildi!'),
                  duration: Duration(seconds: 2),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                print("***********Araba: ${ArabaNoCtrlr.text}");
                if(addDocument_Islem() != false){
                  reset_page();
                  const snackBar = SnackBar(
                    content: Text('Kaydedildi'),
                    duration: Duration(seconds: 2),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }else{
                  const snackBar = SnackBar(
                    content: Text('Kayıt gerçekleştirilemedi!'),
                    duration: Duration(seconds: 2),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              }
                  :() {
                const snackBar = SnackBar(
                  content: Text('İşlem başlatılmadan bitirilemez!'),
                  duration: Duration(seconds: 2),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: const Text('Bitir', style: TextStyle(color: Colors.white,)),
            ),
        ],
      )
    ]
    )
      )
    );
  }
}



