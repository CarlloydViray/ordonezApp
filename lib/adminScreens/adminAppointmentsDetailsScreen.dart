import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminAppointmentsDetailsScreen extends StatefulWidget {
  const AdminAppointmentsDetailsScreen({super.key, required this.id});

  final id;
  @override
  State<AdminAppointmentsDetailsScreen> createState() =>
      _AdminAppointmentsDetailsScreenState();
}

class _AdminAppointmentsDetailsScreenState
    extends State<AdminAppointmentsDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Appointment Details'),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .doc(
                'schedules') // Assuming 'schedules' is the document you are interested in
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data == null ||
              !snapshot.data!.exists) {
            return const Center(
              child: Text('No data available.'),
            );
          }

          // Access the 'appointments' array within the 'schedules' document
          List<dynamic> appointments = snapshot.data!.get('appointments');

          if (appointments.isEmpty) {
            return const Center(
              child: Text('No appointments available.'),
            );
          }

          // Filter appointments based on the widgetId
          Map<String, dynamic>? appointmentData = appointments.firstWhere(
            (appointment) => appointment['id'] == widget.id,
            orElse: () => null,
          );

          if (appointmentData == null) {
            return Center(
              child: Text('Appointment not found for id: ${widget.id}'),
            );
          }
          String name = appointmentData['name'];
          String pet = appointmentData['pet'];

          Timestamp startTime = appointmentData['startTime'];
          Timestamp endTime = appointmentData['endTime'];

          DateTime startTimeDateTime = startTime.toDate();
          DateTime endTimeDateTime = endTime.toDate();

          String formattedDateStart =
              DateFormat('MMMM d, y hh:mm a').format(startTimeDateTime);

          String formattedDateEnd =
              DateFormat('MMMM d, y hh:mm a').format(endTimeDateTime);

          bool accept = appointmentData['accept'];
          bool deny = appointmentData['deny'];
          bool done = appointmentData['done'];

          Widget iconStatus() {
            if (accept == true) {
              if (done == true) {
                return const Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 100,
                );
              }
              return const Icon(
                Icons.check,
                color: Colors.orange,
                size: 100,
              );
            } else if (deny) {
              return const Icon(
                Icons.close,
                color: Colors.red,
                size: 100,
              );
            } else {
              return const Icon(
                Icons.watch_later,
                color: Colors.black,
                size: 100,
              );
            }
          }

          Widget textStatus() {
            if (accept == true) {
              if (done == true) {
                return const Text(
                  'DONE',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                      color: Colors.green),
                  textAlign: TextAlign.center,
                );
              }
              return const Text(
                'APPROVED',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                    color: Colors.orange),
                textAlign: TextAlign.center,
              );
            } else if (deny) {
              return const Text(
                'DENIED',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                    color: Colors.red),
                textAlign: TextAlign.center,
              );
            } else {
              return const Text(
                'PENDING',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                    color: Colors.black),
                textAlign: TextAlign.center,
              );
            }
          }

          // Build your UI using the filtered appointmentData
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CircleAvatar(
                      radius: 65.0,
                      backgroundColor: const Color(0xff0C356A),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 60.0,
                        child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: iconStatus()),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    textStatus(),
                    const SizedBox(height: 16.0),
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      pet,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      formattedDateStart,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 24.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      formattedDateEnd,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 24.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            DocumentReference documentReference =
                                FirebaseFirestore.instance
                                    .collection('appointments')
                                    .doc('schedules');

                            // Fetch the document
                            DocumentSnapshot documentSnapshot =
                                await documentReference.get();

                            if (documentSnapshot.exists) {
                              // Get the current array
                              List<dynamic> appointments =
                                  documentSnapshot['appointments'];

                              // Find the index where 'id' is equal to widgetId
                              int index = appointments.indexWhere(
                                  (appointment) =>
                                      appointment['id'] == widget.id);

                              if (index != -1) {
                                // Update the 'action' for the found element
                                appointments[index]['accept'] = false;
                                appointments[index]['done'] = false;
                                appointments[index]['deny'] = true;

                                // Update the entire array in Firestore
                                await documentReference.update({
                                  'appointments': appointments,
                                });

                                print('Firestore update successful');
                              } else {
                                print('Element not found in the array');
                              }
                            } else {
                              print('Document does not exist');
                            }
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('Deny'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.red), // Set your desired color
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            DocumentReference documentReference =
                                FirebaseFirestore.instance
                                    .collection('appointments')
                                    .doc('schedules');

                            // Fetch the document
                            DocumentSnapshot documentSnapshot =
                                await documentReference.get();

                            if (documentSnapshot.exists) {
                              // Get the current array
                              List<dynamic> appointments =
                                  documentSnapshot['appointments'];

                              // Find the index where 'id' is equal to widgetId
                              int index = appointments.indexWhere(
                                  (appointment) =>
                                      appointment['id'] == widget.id);

                              if (index != -1) {
                                // Update the 'action' for the found element
                                appointments[index]['accept'] = false;
                                appointments[index]['done'] = false;
                                appointments[index]['deny'] = false;

                                // Update the entire array in Firestore
                                await documentReference.update({
                                  'appointments': appointments,
                                });

                                print('Firestore update successful');
                              } else {
                                print('Element not found in the array');
                              }
                            } else {
                              print('Document does not exist');
                            }
                          },
                          icon: const Icon(Icons.watch_later),
                          label: const Text('Pending'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.grey), // Set your desired color
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            DocumentReference documentReference =
                                FirebaseFirestore.instance
                                    .collection('appointments')
                                    .doc('schedules');

                            // Fetch the document
                            DocumentSnapshot documentSnapshot =
                                await documentReference.get();

                            if (documentSnapshot.exists) {
                              // Get the current array
                              List<dynamic> appointments =
                                  documentSnapshot['appointments'];

                              // Find the index where 'id' is equal to widgetId
                              int index = appointments.indexWhere(
                                  (appointment) =>
                                      appointment['id'] == widget.id);

                              if (index != -1) {
                                // Update the 'action' for the found element
                                appointments[index]['accept'] = true;
                                appointments[index]['done'] = false;
                                appointments[index]['deny'] = false;

                                // Update the entire array in Firestore
                                await documentReference.update({
                                  'appointments': appointments,
                                });

                                print('Firestore update successful');
                              } else {
                                print('Element not found in the array');
                              }
                            } else {
                              print('Document does not exist');
                            }
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Approve'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.orange), // Set your desired color
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
