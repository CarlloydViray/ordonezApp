import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ordonez_vet/adminScreens/adminAppointmentsScreen.dart';
import 'package:ordonez_vet/adminScreens/adminCalendarScreen.dart';
import 'package:ordonez_vet/adminScreens/adminClientsScreen.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'package:quickalert/quickalert.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
  String? code;

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
        title: const Text('ADMIN'),
        centerTitle: true,
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
                        const AdminClientsScreen()));
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
                    Icons.people,
                    size: 70,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Text('Clients'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
                    context: context,
                    onCode: (code) async {
                      try {
                        // Replace 'appointments' with your actual collection name
                        // Replace 'schedules' with your actual document name
                        var result = await FirebaseFirestore.instance
                            .collection('appointments')
                            .doc('schedules')
                            .get();

                        // Check if the document exists and if the code is in the 'appointments' array
                        if (result.exists &&
                            result.data()?['appointments'] != null) {
                          List<dynamic> appointments =
                              result.data()?['appointments'];

                          int index = appointments.indexOf(code);
                          if (index != -1) {
                            appointments[index]['done'] = true;
                            await FirebaseFirestore.instance
                                .collection('appointments')
                                .doc('schedules')
                                .update({'appointments': appointments});
                          }

                          QuickAlert.show(
                              context: context,
                              type: QuickAlertType.success,
                              title: 'Appointment Successful');
                        } else {
                          QuickAlert.show(
                              context: context,
                              type: QuickAlertType.warning,
                              title: 'Code does not exist in records');
                        }
                      } catch (e) {
                        print('Error checking code: $e');
                        return false;
                      }
                    });
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
                    Icons.qr_code_scanner,
                    size: 70,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Text('Scan QR'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (BuildContext context) =>
                        const AdminAppointmentsScreen(),
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
                    Icons.checklist_rounded,
                    size: 70,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Text('Appointments'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (BuildContext context) =>
                        const AdminCalendarScreen(),
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
                  Text('Appointment Schedule'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
