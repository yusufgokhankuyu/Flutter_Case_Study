import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hero_game/Services/HobiService.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final userCollection = FirebaseFirestore.instance.collection("users");
  final firebaseAuth = FirebaseAuth.instance;
  final hobiCollection = FirebaseFirestore.instance.collection("hobi");
  TextEditingController hobiController = TextEditingController();
  List<dynamic> hobiler = [];

  String name = "";
  String email = "";
  String birthDay = "";
  String biografi = "";

  Future<void> loadUserData() async {
    try {
      User? user = firebaseAuth.currentUser;
      if (user != null) {
        DocumentSnapshot userSnapshot =
            await userCollection.doc(user.uid).get();

        setState(() {
          name = userSnapshot.get("name");
          email = userSnapshot.get("email");
          birthDay = userSnapshot.get("birthDay");
          biografi = userSnapshot.get("biografi");
        });
      }
    } catch (e) {
      print("Kullanıcı bilgilerini getirme hatası: $e");
    }
  }

  Future<void> loadHobi() async {
    try {
      User? user = firebaseAuth.currentUser;
      if (user != null) {
        QuerySnapshot hobiSnapshot =
            await hobiCollection.where('userId', isEqualTo: user.uid).get();

        setState(() {
          hobiler = hobiSnapshot.docs.map((doc) => doc.get('hobi')).toList();
        });
      }
    } catch (e) {
      print("Kullanıcı bilgilerini getirme hatası: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
    loadHobi();
  }

  Future<void> _showAddHobiDialog(BuildContext context) async {
    TextEditingController hobiTextFieldController = TextEditingController();
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hobi Ekle'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(),
                  ),
                  child: TextFormField(
                    controller: hobiTextFieldController,
                    decoration: const InputDecoration(
                      labelText: 'Hobi',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen bir hobi girin.';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      String hobi = hobiTextFieldController.text;
                      User? user = firebaseAuth.currentUser;
                      HobiService().addHobi(user!.uid, hobi);
                      setState(() {
                        loadHobi();
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Ekle'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Home Page',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListView(shrinkWrap: true, children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text(
                        "Ad Soyad: ",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        name,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text(
                        "E-posta: ",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        email,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text(
                        "Doğum Tarihi: ",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        birthDay,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Biyografi: ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        biografi,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 10.0),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Hobiler:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: hobiler.map((hobi) {
                  return Card(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(hobi),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHobiDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
