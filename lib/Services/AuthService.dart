import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hero_game/Pages/HomePage.dart';

class AuthService {
  final userCollection = FirebaseFirestore.instance.collection("users");
  final firebaseAuth = FirebaseAuth.instance;

  Future<void> signUp(BuildContext context,
      {required String name,
      required String email,
      required String password,
      required String birthDay,
      required String biografi}) async {
    final navigator = Navigator.of(context);
    try {
      final UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        _registerUser(
            name: name,
            email: email,
            password: password,
            birthDay: birthDay,
            biografi: biografi);

        navigator
            .push(MaterialPageRoute(builder: (context) => const HomePage()));
      }
    } on FirebaseAuthException catch (e) {
      SnackBar(content: Text(e.message!));
    }
  }

  Future<void> signIn(BuildContext context,
      {required String email, required String password}) async {
    final navigator = Navigator.of(context);
    try {
      final UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        navigator
            .push(MaterialPageRoute(builder: (context) => const HomePage()));

        const SnackBar(content: Text("LOGIN SUCCESSFULLY"));
      }
    } on FirebaseAuthException catch (e) {
      SnackBar(content: Text(e.message!));
    }
  }

  Future<void> _registerUser(
      {required String name,
      required String email,
      required String password,
      required String birthDay,
      required String biografi}) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await userCollection.doc(user.uid).set({
          "name": name,
          "email": email,
          "password": password,
          "birthDay": birthDay,
          "biografi": biografi
        });
      } else {
        print("Kullanıcı ID'si bulunamadı.");
      }
    } catch (e) {
      print("Veri ekleme hatası: $e");
    }
  }
}
