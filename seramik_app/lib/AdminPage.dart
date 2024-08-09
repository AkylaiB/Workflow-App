import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'LogPage.dart';

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
        title: const Text(
          "Admin",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 30, color: Colors.white,),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.auto_delete, color: Colors.white,),
          onPressed: () {_cleanDatabaseDialog();},
        ),
        actions: [
          IconButton(
              onPressed: () async{
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LogPage()));
              },
              icon: const Icon(Icons.logout, color: Colors.white,))
        ],
      ),
      body: PersonelPage()
    );
  }
  void _cleanDatabaseDialog() {
    TextEditingController monthCtrl = TextEditingController();
    TextEditingController yearCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Veritabanı Temizleme:'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints( minHeight: 100.0),
              child: Column(
                children: [
                  TextField(
                    controller: monthCtrl,
                    decoration: const InputDecoration(labelText: 'Verisini silmek istediğiniz ay:'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20,),
                  TextField(
                    controller: yearCtrl,
                    decoration: const InputDecoration(labelText: 'Verisini silmek istediğiniz yıl:'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20,),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                deleteDocuments(int.parse(monthCtrl.text), int.parse(yearCtrl.text));
                Navigator.pop(context);
              },
              child: const Text('Evet'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hayır'),
            ),
          ],
        );
      },
    );
  }
  Future<void> deleteDocuments(int delMonth, int delYear) async {
    try{
    final CollectionReference islemCollection = FirebaseFirestore.instance.collection('Islem');
    final CollectionReference islemUrunCollection = FirebaseFirestore.instance.collection('Islem-Urun');

    QuerySnapshot islemSnapshot = await islemCollection
        .where('Bitis', isGreaterThanOrEqualTo: DateTime(delYear, delMonth, 1))
        .where('Bitis', isLessThan: DateTime(delYear, delMonth + 1, 1))
        .get();

    for (QueryDocumentSnapshot islemDoc in islemSnapshot.docs) {
      QuerySnapshot islemUrunQuerySnapshot =
      await islemUrunCollection.where('Islem_ID', isEqualTo: islemDoc.reference).where('excel', isEqualTo: true).get();

      for (QueryDocumentSnapshot islemUrunDoc in islemUrunQuerySnapshot.docs) {
        DocumentReference urunRef = islemUrunDoc['Urun_ID'];
        await islemUrunDoc.reference.delete();
        await urunRef.delete();
      }

      await islemDoc.reference.delete();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Veritabanı başarıyla temizlenmiştir!')),
    );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veritabanı temizlenemedi!')),
      );
      print("*********************Error: $e");
    }
  }
}

class PersonelPage extends StatefulWidget{
  const PersonelPage({super.key});

  @override
  State<PersonelPage> createState() => _PersonelPageState();
}

class _PersonelPageState extends State<PersonelPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Seramik Personel Listesi', style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(onPressed: (){
            _personelAddDialog();
            },
            icon: const Icon(Icons.person_add, color: Colors.white,)),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Personel').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
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
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _personelUpdateDialog(
                            personelDocs[index].id,
                            personelDocs[index]['Ad'],
                            personelDocs[index]['Soyad'],
                            personelDocs[index]['Telefon']);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
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
          title: const Text('Personel Bilgisini Güncelle'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints( minHeight: 100.0),
              child: Column(
                children: [
                  TextField(
                    controller: adController,
                    decoration: const InputDecoration(labelText: 'Yeni Ad'),
                  ),
                  const SizedBox(height: 20,),
                  TextField(
                    controller: soyadController,
                    decoration: const InputDecoration(labelText: 'Yeni Soyad'),
                  ),
                  const SizedBox(height: 20,),
                  TextField(
                    controller: telefonController,
                    decoration: const InputDecoration(labelText: 'Yeni Telefon'),
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
                    const SnackBar(content: Text('Personel bilgisi başarıyla güncellenmiştir!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Personel bilgisi güncellenemedi!')),
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('Ok'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hayır'),
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
          title: const Text('Personeli Sil'),
          content: const Text('Bu kişiyi silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('Personel').doc(documentId).delete();
                Navigator.pop(context);
              },
              child: const Text('Evet'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hayır'),
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
          title: const Text('Yeni Personel Ekle'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints( minHeight: 100.0),
              child: Column(
                children: [
                  TextField(
                    controller: adController,
                    decoration: const InputDecoration(labelText: 'Ad:'),
                  ),
                  const SizedBox(height: 20,),
                  TextField(
                    controller: soyadController,
                    decoration: const InputDecoration(labelText: 'Soyad:'),
                  ),
                  const SizedBox(height: 20,),
                  TextField(
                    keyboardType: TextInputType.phone,
                    controller: telefonController,
                    decoration: const InputDecoration(
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
                    const SnackBar(content: Text('Personel başarıyla eklenmiştir!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Yeni personel eklenemedi!')),
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('Ok'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hayır'),
            ),
          ],
        );
      },
    );
  }
}
