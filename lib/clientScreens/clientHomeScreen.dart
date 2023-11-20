import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ordonez_vet/clientScreens/clientAppointmentsScreen.dart';
import 'package:ordonez_vet/clientScreens/clientCalendarScreen.dart';
import 'package:ordonez_vet/clientScreens/clientPetsScreen.dart';
import 'package:ordonez_vet/clientScreens/clientProfile.dart';
import 'package:quickalert/quickalert.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordonez Vet Clinic'),
        centerTitle: true,
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
          ),
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(CupertinoPageRoute(
                    builder: (BuildContext context) =>
                        const ClientProfileScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0174BE),
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16), // Adjust the radius as needed
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    size: 70,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Text('My Profile'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(CupertinoPageRoute(
                    builder: (BuildContext context) =>
                        const ClientPetsScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0174BE),
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16), // Adjust the radius as needed
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pets,
                    size: 70,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Text('My Pets'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (BuildContext context) =>
                        const ClientAppointmentsScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0174BE),
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16), // Adjust the radius as needed
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 70,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Text('My Appointments'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (BuildContext context) =>
                        const ClientCalendarScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0174BE),
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16), // Adjust the radius as needed
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_to_queue_sharp,
                    size: 70,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Text('Schedule Appointment'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
