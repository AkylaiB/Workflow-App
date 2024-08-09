import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:KHD_Seramik/UserPage.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:permission_handler/permission_handler.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController _stokController = TextEditingController();
  final TextEditingController _malzemeController = TextEditingController();
  final TextEditingController _isemriController = TextEditingController();
  final TextEditingController _salkimController = TextEditingController();
  final TextEditingController _fireController = TextEditingController();
  String scanned = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const UserPage()));},
          ),
          title: const Text('Malzeme Ekle', style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.black

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width*1/2,
                    child: Column(
                      children: [
                        TextField(
                          controller: _stokController,
                          decoration: const InputDecoration(labelText: 'Stok Kodu'),
                        ),
                        TextField(
                          controller: _isemriController,
                          decoration: const InputDecoration(labelText: 'İş Emri'),
                        ),
                        TextField(
                          controller: _malzemeController,
                          decoration: const InputDecoration(labelText: 'Malzeme'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10,),
                  SizedBox(
                    width: MediaQuery.of(context).size.width*1/2.6,
                    height: 200,
                    child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                      onPressed: () async {
                        await Permission.camera.request();
                        if (await Permission.camera.isGranted) {
                          scanned = (await scanner.scan())!;
                          List<String> splitedData = scanned.split("|");
                          _stokController.text = splitedData[0];
                          _isemriController.text = splitedData[1];
                          _malzemeController.text = splitedData[2];
                        }
                      },
                      child: const Column(
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
              const SizedBox(width: 20,),
              TextField(
                controller: _salkimController,
                decoration: const InputDecoration(labelText: 'Salkım Sayısı'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(width: 20,),
              TextField(
                controller: _fireController,
                decoration: const InputDecoration(labelText: 'Fire Sayısı'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 30,),
              SizedBox(
                width: 100,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0),),
                    backgroundColor: Colors.green[700],
                  ),
                  onPressed: () {
                    final stok = _stokController.text;
                    final malzeme = _malzemeController.text;
                    final isemri = _isemriController.text;
                    final salkim = int.parse(_salkimController.text);
                    final fire = int.parse(_fireController.text);

                    final newItem = Urun(stok, malzeme, isemri, salkim, fire);

                    Navigator.pop(context, newItem);
                  },
                  child: const Text('Ekle',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
