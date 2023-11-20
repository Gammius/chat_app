import 'dart:io';
import 'package:chat_app/widgets/auth/auth_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  void _submitForm(
      String email,
      String password,
      String userName,
      File userImageFile,
      bool isLogin,
      BuildContext ctx,
      ) async {
    late UserCredential userCredential;

    setState(() {
      _isLoading = true;
    });

    try{
    if (isLogin) {
      userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } else {
      userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      final ref = FirebaseStorage.instance.ref()
          .child("users_images")
          .child("${userCredential.user!.uid}.jpg");
      
      await ref.putFile(userImageFile);
      
      final imageUrl = await ref.getDownloadURL();

      FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid)
          .set({"username": userName, "email": email, "imageUrl": imageUrl,
      });
    }
  } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? ""),
          backgroundColor: Theme.of(context).colorScheme.error,
      ),
      );
    }
    setState(() {
      _isLoading  = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: AuthForm(callback: _submitForm, loading: _isLoading),
    );
  }
}