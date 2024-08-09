import 'package:KHD_Dokum/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: Text(
            "Admin",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30, color: Colors.white),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.auto_delete, color: Colors.white),
            onPressed: () {_cleanDatabaseDialog();},
          ),
          actions: [
            IconButton(
                onPressed: () async{
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                },
                icon: Icon(Icons.logout, color: Colors.white))
          ],
        ),
        body: PersonelPage(),
    );
  }
  void _cleanDatabaseDialog() {
    TextEditingController month_ctrl = TextEditingController();
    TextEditingController year_ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Veritabanı Temizleme:'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints( minHeight: 100.0),
              child: Column(
                children: [
                  TextField(
                    controller: month_ctrl,
                    decoration: InputDecoration(labelText: 'Verisini silmek istediğiniz ay:'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    controller: year_ctrl,
                    decoration: InputDecoration(labelText: 'Verisini silmek istediğiniz yıl:'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20,),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                deleteDocuments(int.parse(month_ctrl.text), int.parse(year_ctrl.text));
                Navigator.pop(context);
              },
              child: Text('Evet'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Hayır'),
            ),
          ],
        );
      },
    );
  }
  Future<void> deleteDocuments(int delMonth, int delYear) async {
    try{
      final CollectionReference personelDokumCollection = FirebaseFirestore.instance.collection('Personel-Dokum');

      QuerySnapshot personelDokumSnapshot = await personelDokumCollection
          .where('Tarih', isGreaterThanOrEqualTo: DateTime(delYear, delMonth, 1))
          .where('Tarih', isLessThan: DateTime(delYear, delMonth + 1, 1))
          .where('excel', isEqualTo: true)
          .get();
      print("****************************************personelDokumSnapshot: ${personelDokumSnapshot.docs}");

      for (QueryDocumentSnapshot personelDokumDoc in personelDokumSnapshot.docs) {
        DocumentReference dokumDocRef = personelDokumDoc['Dokum_ID'];
        await personelDokumDoc.reference.delete();
        await dokumDocRef.delete();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veritabanı başarıyla temizlenmiştir!')),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veritabanı temizlenemedi!')),
      );
      print("*********************Error: $e");
    }
  }
}

class PersonelPage extends StatefulWidget{
  PersonelPage();

  @override
  State<PersonelPage> createState() => _PersonelPageState();
}

class _PersonelPageState extends State<PersonelPage> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: Text('Döküm Personel Listesi', style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(onPressed: (){
            _personelAddDialog();
          },
              icon: Icon(Icons.person_add)),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Personel').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          List<DocumentSnapshot> personelDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: personelDocs.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(personelDocs[index]['Ad']+" "+personelDocs[index]['Soyad']),
                subtitle: Text(personelDocs[index]['Telefon']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _personelUpdateDialog(
                            personelDocs[index].id,
                            personelDocs[index]['Ad'],
                            personelDocs[index]['Soyad'],
                            personelDocs[index]['Telefon']);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _personelDeleteDialog(personelDocs[index].id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
  void _personelUpdateDialog(String documentId, String currentAd, String currentSoyad, String currentTelefon) {
    TextEditingController adController = TextEditingController(text: currentAd);
    TextEditingController soyadController = TextEditingController(text: currentSoyad);
    TextEditingController telefonController = TextEditingController(text: currentTelefon);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Personel Bilgisini Güncelle'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints( minHeight: 100.0),
              child: Column(
                children: [
                  TextField(
                    controller: adController,
                    decoration: InputDecoration(labelText: 'Yeni Ad'),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    controller: soyadController,
                    decoration: InputDecoration(labelText: 'Yeni Soyad'),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    controller: telefonController,
                    decoration: InputDecoration(labelText: 'Yeni Telefon'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async{
                try {
                  await FirebaseFirestore.instance.collection('Personel').doc(documentId).update({
                    'Ad': adController.text,
                  });
                  await FirebaseFirestore.instance.collection('Personel').doc(documentId).update({
                    'Soyad': soyadController.text,
                  });
                  await FirebaseFirestore.instance.collection('Personel').doc(documentId).update({
                    'Telefon': telefonController.text,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Personel bilgisi başarıyla güncellenmiştir!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Personel bilgisi güncellenemedi!')),
                  );
                }
                Navigator.pop(context);
              },
              child: Text('Ok'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Hayır'),
            ),
          ],
        );
      },
    );
  }
  void _personelDeleteDialog(String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Personeli Sil'),
          content: Text('Bu kişiyi silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('Personel').doc(documentId).delete();
                Navigator.pop(context);
              },
              child: Text('Evet'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Hayır'),
            ),
          ],
        );
      },
    );
  }
  void _personelAddDialog() {
    TextEditingController adController = TextEditingController();
    TextEditingController soyadController = TextEditingController();
    TextEditingController telefonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Yeni Personel Ekle'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints( minHeight: 100.0),
              child: Column(
                children: [
                  TextField(
                    controller: adController,
                    decoration: InputDecoration(labelText: 'Ad:'),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    controller: soyadController,
                    decoration: InputDecoration(labelText: 'Soyad:'),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    keyboardType: TextInputType.phone,
                    controller: telefonController,
                    decoration: InputDecoration(
                        labelText: 'Telefon:',
                        hintText: '+90...'
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async{
                try {
                  DocumentReference docRef = FirebaseFirestore.instance.collection('Personel').doc();
                  Map<String, dynamic> newPersonel = {
                    'Ad': adController.text,
                    'Soyad': soyadController.text,
                    'Telefon': telefonController.text,
                  };
                  await docRef.set(newPersonel);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Personel başarıyla eklenmiştir!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Yeni personel eklenemedi!')),
                  );
                }
                Navigator.pop(context);
              },
              child: Text('Ok'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Hayır'),
            ),
          ],
        );
      },
    );
  }
}
