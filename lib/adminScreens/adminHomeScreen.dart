import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              QuickAlert.show(
                context: context,
                type: QuickAlertType.confirm,
                title: 'Sign out?',
                onConfirmBtnTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                },
              );
            },
            icon: const Icon(Icons.logout)),
        title: const Text('ADMIN SCREEN'),
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
