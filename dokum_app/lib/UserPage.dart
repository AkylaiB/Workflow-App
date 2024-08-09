
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:KHD_Dokum/LoginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:permission_handler/permission_handler.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:excel/excel.dart';
import 'package:share/share.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  TextEditingController kapasite_ctrler = TextEditingController();
  int pota_ctrler = 1;
  int sarj_ctrler = 1;
  TextEditingController stok_kodu_ctrler = TextEditingController();
  TextEditingController is_emri_ctrler = TextEditingController();
  TextEditingController urun_ctrler = TextEditingController();
  TextEditingController salkim_s_ctrler = TextEditingController();
  TextEditingController urun_s_ctrler = TextEditingController();
  TextEditingController fire_ctrler = TextEditingController();
  TextEditingController neden_ctrler = TextEditingController();
  TextEditingController cins_ctrler = TextEditingController();
  String vardiya = "";
  var date = DateTime.now();
  late final personel_id;
  String fullName = "";
  String scanned = "";
  bool isContainerEnabled = false;

  void initState() {
    super.initState();
    getUserInfo();
    date = DateTime.now();
    if(date.hour < 7){vardiya = "Gece";}
    else{vardiya = "Gündüz";}
  }

  void reset_page() {
    setState(() {
      pota_ctrler = 1;
      sarj_ctrler = 1;
      stok_kodu_ctrler.clear();
      is_emri_ctrler.clear();
      urun_ctrler.clear();
      salkim_s_ctrler.clear();
      urun_s_ctrler.clear();
      fire_ctrler.clear();
      neden_ctrler.clear();
      cins_ctrler.clear();
    });
  }
  
  Future<bool> addDoc() async{
    bool saved = false;
    try {
      DocumentReference dokumDocRef = FirebaseFirestore.instance.collection('Dokum').doc();
      await dokumDocRef.set({
        'Pota' : pota_ctrler,
        'Sarj' : sarj_ctrler,
        'Stok_Kodu' : stok_kodu_ctrler.text,
        'Is_Emri' : is_emri_ctrler.text,
        'Urun' : urun_ctrler.text,
        'Salkim_Sayisi' : int.parse(salkim_s_ctrler.text),
        'Urun_Sayisi' : int.parse(urun_s_ctrler.text),
        'Fire_Sayisi' : int.parse(fire_ctrler.text),
        'Fire_Nedeni' : neden_ctrler.text,
        'Cins' : cins_ctrler.text
      });

      print('**************************ID: ${dokumDocRef.id} DokumDoc oluşturuldu.');
      try {
        DocumentReference userRef = FirebaseFirestore.instance.collection('Personel').doc(personel_id);
        DocumentReference docRef = FirebaseFirestore.instance.collection('Personel-Dokum').doc();
        Timestamp date_stamp = Timestamp.fromDate(date);
        await docRef.set({
          'Dokum_ID' : dokumDocRef,
          'Ocak_Kapasitesi' : kapasite_ctrler.text,
          'Personel_ID' : userRef,
          'Tarih' : date_stamp,
          'Vardiya' : vardiya,
          'excel' : false
        });

        print('**************************ID: ${docRef.id} PersonelDokumDoc oluşturuldu.');
        saved = true;
      }catch (e) {
        print('**************************PersonelDokumDoc eklemede bir hata oluştu: $e');
      }
    }catch (e) {
      print('**************************DokumDoc eklemede bir hata oluştu: $e');
    }
    return saved;
  }
  
  void getUserInfo() async {
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
        print('GetUserInfo**************************${error}');
      });
    }
  }

  Future<void> createAndSendExcel(String fullName) async {
    var myexcel = Excel.createExcel();
    var sheet = myexcel['Sheet1'];

    sheet.appendRow([
      'TARİH',
      'VARDİYA',
      'PERSONEL',
      'OCAK KAPASİTESİ',
      'POTA',
      'ŞARJ',
      'MALZEME STOK KODU',
      'İŞ EMRİ',
      'DÖKÜLEN ÜRÜN',
      'SALKIM SAYISI',
      'SALKIMDAKİ ÜRÜN SAYISI',
      'FİRE SAYISI',
      'FİRE NEDENİ',
      'MALZEME CİNSİ']);

    try {
      QuerySnapshot PersonelDokumSnapshot = await FirebaseFirestore.instance.collection('Personel-Dokum').where('excel', isEqualTo: false).get();

      for (QueryDocumentSnapshot PersonelDokumDoc in PersonelDokumSnapshot.docs) {
        DocumentReference PersonelDokumRef = PersonelDokumDoc.reference;
        DocumentSnapshot personelDokumSnapshot = await PersonelDokumRef.get();
        DocumentReference dokumRef = PersonelDokumDoc['Dokum_ID'];
        DocumentSnapshot dokumSnapshot = await dokumRef.get();

        if (dokumSnapshot.exists) {
          Map<String, dynamic> dokumData = dokumSnapshot.data() as Map<String, dynamic>;
          Map<String, dynamic> personelDokumData = personelDokumSnapshot.data() as Map<String, dynamic>;

          Timestamp dateStamp = personelDokumData['Tarih'];
          DateTime tarih = dateStamp.toDate();
          String tarih_str = DateFormat('dd/MM/yyyy').format(tarih);

          sheet.appendRow([
            tarih_str,
            vardiya,
            fullName,
            personelDokumData['Ocak_Kapasitesi'].toString(),
            dokumData['Pota'].toString(),
            dokumData['Sarj'].toString(),
            dokumData['Stok_Kodu'],
            dokumData['Is_Emri'],
            dokumData['Urun'],
            dokumData['Salkim_Sayisi'].toString(),
            dokumData['Urun_Sayisi'].toString(),
            dokumData['Fire_Sayisi'].toString(),
            dokumData['Fire_Nedeni'],
            dokumData['Cins']
          ]);
          PersonelDokumRef.update({'excel':true});
        } else {
          print('************Dokum not found for Personel-Dokum document: ${PersonelDokumDoc.id}');
        }
      }
      Uint8List? excelData = myexcel.save() as Uint8List?;
      final directory = Directory("/storage/emulated/0/Download");
      if(await directory.exists()){
        String file_time = DateTime.now().millisecondsSinceEpoch.toString();
        File file = File('${directory.path}/dokum_takip_formu_$file_time.xlsx');
        try{
          await file.writeAsBytes(excelData!);
          Share.shareFiles(
            [file.path],
            subject: 'Dokum Takip Formu',
            sharePositionOrigin: Rect.fromCenter(center: Offset(0, 0), width: 0, height: 0),
          );
        }catch(e){print("*******************$e");}
      }else{
        print("*******************Directory is null");
      }
    } catch (e) {
      print('************${e}');
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
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
            icon: Icon(Icons.logout, color: Colors.white)),
        actions: <Widget>[
          IconButton(
            icon: Icon(
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
          padding: EdgeInsets.symmetric( vertical: 15.0, horizontal: 3.0),
          child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(5.0)),
                      width: MediaQuery.of(context).size.width/2.1,
                      height: 70,
                      alignment: Alignment.center,
                      child: Text(
                        style: TextStyle(fontSize: 12),
                        "Tarih: "+date.day.toString()+"/"+date.month.toString()+"/"+date.year.toString()
                        +"\nVardiya: "+vardiya+"\nPersonel: "+fullName,
                      ),
                    ),
                    SizedBox(width: 10,),
                    SizedBox(
                      width: MediaQuery.of(context).size.width/2.1,
                      child: TextField(
                        controller: kapasite_ctrler,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 24,
                              horizontal: 15,
                          ),
                          labelText: 'Ocak Kapasitesi',
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black),),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black),),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (value){
                          setState(() { isContainerEnabled = value.isNotEmpty; });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: isContainerEnabled ? Colors.green : Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Padding(
                                  padding: EdgeInsets.all(2.0),
                                  child: Text('Pota')),
                              InputQty(
                                initVal: 1,
                                steps: 1,
                                minVal: 1,
                                onQtyChanged: (val1){
                                },
                                decoration: QtyDecorationProps(width: 25,)
                              ),
                            ],
                          ),
                          SizedBox(width: 10,),
                          Column(
                            children: [
                              Padding(
                                  padding: EdgeInsets.all(2.0),
                                  child: Text('Şarj')),
                              InputQty(
                                initVal: 1,
                                minVal: 1,
                                steps: 1,
                                onQtyChanged: (val2){},
                                decoration: QtyDecorationProps(width: 25,)
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 15,),
                      Row(
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width/2.2,
                                child: TextField(
                                  enabled: isContainerEnabled,
                                  controller: stok_kodu_ctrler,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 20,
                                      horizontal: 15,
                                    ),
                                    labelText: 'Malzeme Stok Kodu',
                                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black),),
                                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black),),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15,),
                              SizedBox(
                                width: MediaQuery.of(context).size.width/2.2,
                                child: TextField(
                                  enabled: isContainerEnabled,
                                  controller: is_emri_ctrler,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 20,
                                      horizontal: 15,
                                    ),
                                    labelText: 'İş Emri Numarası',
                                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black),),
                                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black),),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15,),
                              SizedBox(
                                width: MediaQuery.of(context).size.width/2.2,
                                child: TextField(
                                  enabled: isContainerEnabled,
                                  controller: urun_ctrler,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 20,
                                      horizontal: 15,
                                    ),
                                    labelText: 'Dökülen Ürün',
                                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black),),
                                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black),),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 10,),
                          SizedBox(
                            width: MediaQuery.of(context).size.width/2.2,
                            height: 212,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isContainerEnabled? Colors.deepOrange : Colors.deepOrange[300],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onPressed: isContainerEnabled? () async {
                                await Permission.camera.request();
                                if (await Permission.camera.isGranted) {
                                  scanned = (await scanner.scan())!;
                                  List<String> splited_data = scanned.split("|");
                                  stok_kodu_ctrler.text = splited_data[0];
                                  is_emri_ctrler.text = splited_data[1];
                                  urun_ctrler.text = splited_data[2];
                                }
                              } : null,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.qr_code,
                                    color: Colors.white,
                                    size: 100.0,
                                  ),
                                  SizedBox(
                                    height:10,
                                  ),
                                  Text("QR Okut!", style:TextStyle(fontSize:20, color: Colors.white)),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 15,),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width/2.2,
                            child: TextField(
                              enabled: isContainerEnabled,
                              controller: salkim_s_ctrler,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 12,
                                ),
                                labelText: 'Salkım Sayısı',
                                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black),),
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black),),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                          ),
                          SizedBox(width: 10,),
                          SizedBox(
                            width: MediaQuery.of(context).size.width/2.2,
                            child: TextField(
                              enabled: isContainerEnabled,
                              controller: urun_s_ctrler,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 12,
                                ),
                                labelText: 'Salkımdaki Ürün Sayısı',
                                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black),),
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black),),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15,),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width/2.2,
                            child: TextField(
                              enabled: isContainerEnabled,
                              controller: fire_ctrler,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 12,
                                ),
                                labelText: 'Fire (Adet)',
                                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black),),
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black),),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                          ),
                          SizedBox(width: 10,),
                          SizedBox(
                            width: MediaQuery.of(context).size.width/2.2,
                            child: TextField(
                              enabled: isContainerEnabled,
                              controller: cins_ctrler,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 12,
                                ),
                                labelText: 'Malzeme Cinsi',
                                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black),),
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black),),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15,),
                      TextField(
                        enabled: isContainerEnabled,
                        controller: neden_ctrler,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 12,
                          ),
                          labelText: 'Fire Nedeni',
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black),),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black),),
                        ),
                      ),
                    ],
                 ),
                  ),
                ),
                SizedBox(height: 15,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(170, 40),
                      backgroundColor: Colors.green
                  ),
                  onPressed: () async {
                    if(await addDoc()){
                      reset_page();
                      final snackBar = SnackBar(
                        content: Text('Kaydedildi'),
                        duration: Duration(seconds: 2),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }else{
                      final snackBar = SnackBar(
                        content: Text('Kayıt gerçekleştirilemedi!'),
                        duration: Duration(seconds: 2),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    };
                  },
                  child: Text('Kaydet', style: TextStyle(color: Colors.white)),
                ),
              ]
          )
        )
    );
  }
}

