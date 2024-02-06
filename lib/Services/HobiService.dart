import 'package:cloud_firestore/cloud_firestore.dart';

class HobiService {
  final CollectionReference hobiCollection =
      FirebaseFirestore.instance.collection("hobi");

  Future<void> addHobi(String userId, String hobi) async {
    await hobiCollection.add({
      "userId": userId,
      "hobi": hobi,
    });
  }
}
