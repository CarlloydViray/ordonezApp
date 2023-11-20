import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ordonez_vet/models/calendarDataSource.dart';
import 'package:quickalert/quickalert.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ClientCalendarScreen extends StatefulWidget {
  const ClientCalendarScreen({super.key});

  @override
  State<ClientCalendarScreen> createState() => _ClientCalendarScreenState();
}

class _ClientCalendarScreenState extends State<ClientCalendarScreen> {
  List<String> petNames = [];
  String? selectedPet;

  final formKey = GlobalKey<FormState>();

  DateTime? checkInDate;
  DateTime? checkOutDate;

  TextEditingController checkInDateController = TextEditingController();
  TextEditingController checkOutDateController = TextEditingController();
  TextEditingController petNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadPetNames();
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        DateTime selectedDateTime = DateTime(picked.year, picked.month,
            picked.day, selectedTime.hour, selectedTime.minute);

        if (controller == checkInDateController) {
          // Check if the selected date is after the check-out date
          if (checkOutDate != null && selectedDateTime.isAfter(checkOutDate!)) {
            // Show an error or handle the case where check-in date is after check-out date
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Invalid Date'),
                  content: const Text(
                    'Check-in date cannot be after the check-out date.',
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
            return; // Stop further execution
          }

          // Format the DateTime using intl package
          String formattedDate =
              DateFormat('MMMM d, y hh:mm a').format(selectedDateTime);
          controller.text = formattedDate;

          setState(() {
            checkInDate = selectedDateTime;
          });
        } else if (controller == checkOutDateController) {
          // Check if the selected date is before the check-in date
          if (checkInDate != null && selectedDateTime.isBefore(checkInDate!)) {
            // Show an error or handle the case where check-out date is before check-in date
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Invalid Date'),
                  content: const Text(
                    'Check-out date cannot be before the check-in date.',
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
            return; // Stop further execution
          }

          // Format the DateTime using intl package
          String formattedDate =
              DateFormat('MMMM d, y hh:mm a').format(selectedDateTime);
          controller.text = formattedDate;

          setState(() {
            checkOutDate = selectedDateTime;
          });
        }
      }
    }
  }

  Future<void> loadPetNames() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      QuerySnapshot petSnapshot = await FirebaseFirestore.instance
          .collection('pets')
          .where('user_uid', isEqualTo: userId)
          .get();

      setState(() {
        // Explicitly cast elements to String
        petNames =
            petSnapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    }
  }

  Stream<List<Appointment>> fetchAppointmentsFromFirebase() {
    return FirebaseFirestore.instance
        .collection('appointments')
        .doc('schedules')
        .snapshots()
        .map((DocumentSnapshot documentSnapshot) {
      if (!documentSnapshot.exists) {
        return [];
      }

      Map<String, dynamic>? data =
          documentSnapshot.data() as Map<String, dynamic>?;

      if (data == null || !data.containsKey('appointments')) {
        return [];
      }

      List<Appointment> sfAppointments = (data['appointments'] as List<dynamic>)
          .map<Appointment?>((appointmentData) {
            DateTime startTime =
                (appointmentData['startTime'] as Timestamp).toDate();
            DateTime endTime =
                (appointmentData['endTime'] as Timestamp).toDate();
            String pet = appointmentData['pet'] as String;

            // Add a condition to check if the 'accept' field is true
            bool accept = appointmentData['accept'] ?? false;

            // Return null for appointments that do not meet the condition
            if (accept) {
              return Appointment(
                startTime: DateTime(
                  startTime.year,
                  startTime.month,
                  startTime.day,
                  startTime.hour,
                  startTime.minute,
                ),
                endTime: DateTime(
                  endTime.year,
                  endTime.month,
                  endTime.day,
                  endTime.hour,
                  endTime.minute,
                ),
                subject: pet,
                color: const Color(0xff3876BF),
              );
            } else {
              return null;
            }
          })
          .where((appointment) => appointment != null)
          .cast<Appointment>()
          .toList();

      return sfAppointments;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Schedule'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: StreamBuilder<List<Appointment>>(
          stream: fetchAppointmentsFromFirebase(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Appointment> appointments = snapshot.data!;
              return Stack(children: [
                SfCalendar(
                  view: CalendarView.month,
                  dataSource: MeetingDataSource(appointments),
                  headerStyle:
                      const CalendarHeaderStyle(textAlign: TextAlign.center),
                  monthViewSettings: const MonthViewSettings(
                      appointmentDisplayMode:
                          MonthAppointmentDisplayMode.appointment,
                      agendaViewHeight: 200,
                      showAgenda: true),
                ),
                Positioned(
                  bottom: 16.0,
                  right: 16.0,
                  child: FloatingActionButton(
                    backgroundColor: const Color(0xffFFC436),
                    onPressed: () {
                      showTimestampDialog(context);
                    },
                    child: const Icon(Icons.add),
                  ),
                ),
              ]);
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return const Center(
                child: Text('Error fetching appointments'),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }

  Future<void> showTimestampDialog(BuildContext context) async {
    AwesomeDialog(
      dismissOnTouchOutside: false,
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.bottomSlide,
      btnCancelOnPress: () {
        petNameController.clear();
        checkInDateController.clear();
        checkOutDateController.clear();
      },
      btnOkOnPress: () async {
        if (formKey.currentState!.validate()) {
          try {
            // Check for conflicting appointments
            DocumentSnapshot<Map<String, dynamic>> schedulesQuery =
                await FirebaseFirestore.instance
                    .collection('appointments')
                    .doc('schedules')
                    .get();

            List<dynamic> appointmentsData =
                schedulesQuery.data()?['appointments'] ?? [];

            bool hasConflict = false;

            for (var appointmentData in appointmentsData) {
              var startTime = appointmentData['startTime'];
              var endTime = appointmentData['endTime'];

              if (startTime != null &&
                  endTime != null &&
                  startTime is Timestamp &&
                  endTime is Timestamp) {
                if (startTime.toDate().isBefore(checkOutDate!) &&
                    endTime.toDate().isAfter(checkInDate!)) {
                  hasConflict = true;
                  break; // Exit the loop if a conflict is found
                }
              }
            }

            if (!hasConflict) {
              String generateRandomID() {
                Random random = Random();
                int randomNumber = random.nextInt(900000) + 100000;
                return randomNumber.toString();
              }

              DocumentReference unitRef = FirebaseFirestore.instance
                  .collection('appointments')
                  .doc('schedules');

              String id = generateRandomID();

              String? userId = FirebaseAuth.instance.currentUser?.uid;

              DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .get();

              if (userSnapshot.exists) {
                Map<String, dynamic> userData =
                    userSnapshot.data() as Map<String, dynamic>;

                if (userData.containsKey('user_fullName')) {
                  String userFullName = userData['user_fullName'];
                  await unitRef.update({
                    'appointments': FieldValue.arrayUnion([
                      {
                        'endTime': checkOutDate,
                        'startTime': checkInDate,
                        'name': userFullName,
                        'deny': false,
                        'pet': selectedPet,
                        'id': id,
                        'user_uid': userId,
                        'done': false,
                        'accept': false,
                        'timestamp': DateTime.now()
                      }
                    ])
                  });

                  QuickAlert.show(
                      context: context,
                      type: QuickAlertType.success,
                      title: 'Appointment Requested');
                } else {
                  print(
                      'Field "client_full_name" does not exist in the document');
                }
              } else {
                print('Document with ID $userId does not exist');
              }
            } else {
              // Conflicts found, show an error message
              QuickAlert.show(
                context: context,
                type: QuickAlertType.error,
                title: 'Appointment Conflict',
                text: 'The selected dates conflict with existing appointments.',
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to add appointment')),
            );

            print(e);
          }
        } else {
          QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: 'Please fill all input fields');
        }
      },
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const Text(
                'Request Appointment',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedPet,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.black),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPet = newValue;
                  });
                },
                items: petNames.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Select a Pet',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.black),
                  suffixIcon: Icon(Icons.pets),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a pet';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: checkInDateController,
                readOnly: true,
                onTap: () => _selectDate(context, checkInDateController),
                decoration: const InputDecoration(
                  labelText: 'Check-in Date',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.black),
                  suffixIcon: Icon(Icons.date_range),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: checkOutDateController,
                readOnly: true,
                onTap: () => _selectDate(context, checkOutDateController),
                decoration: const InputDecoration(
                  labelText: 'Check-out Date',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.black),
                  suffixIcon: Icon(Icons.date_range),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
            ],
          ),
        ),
      ),
    ).show();
  }

  String formatDate(DateTime date) {
    final formatter = DateFormat('MMMM dd, yyyy');
    return formatter.format(date);
  }
}
