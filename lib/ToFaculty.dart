import 'package:carpool_driver/PinLocation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ToFaculty extends StatefulWidget {
  const ToFaculty({super.key});

  @override
  State<ToFaculty> createState() => _ToFacultyState();
}

class _ToFacultyState extends State<ToFaculty> {
  TextEditingController dateInput = TextEditingController();
  TextEditingController time = TextEditingController();
  TextEditingController destination = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController map = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  LatLng? selectedLocation;
  late User user;

  late DateTime? pickedDate;
  var gates = [
    'ASUFE Gate 3',
    'ASUFE Gate 4',
  ];
  String fromdropdownvalue = 'ASUFE Gate 3';

  String? validateDestination(String? value) {
    if (value == null || value.isEmpty) {
      return 'Destination is required';
    }
    return null;
  }

  String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    return null;
  }

  String? validateDate(String? value) {
    if (pickedDate == null) {
      return 'Date is required';
    }
    return null;
  }

  String? validateGate(String? value) {
    if (fromdropdownvalue == null) {
      return 'Gate is required';
    }
    return null;
  }

  @override
  void initState() {
    time.text = "7:30 AM";
    pickedDate = null;
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
          child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField(
                validator: validateGate,
                decoration: const InputDecoration(
                  label: Text("Destination Gate"),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                ),
                items: gates.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    fromdropdownvalue = newValue!;
                  });
                },
                value: fromdropdownvalue,
                icon: const Icon(Icons.keyboard_arrow_down),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: destination,
                validator: validateDestination,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  label: Text("Starting Location"),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                readOnly: true,
                onTap: () async {
                  selectedLocation = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PinLocationScreen()),
                  );

                  if (selectedLocation != null) {
                    // Handle the selectedLocation
                    print('Selected Location: $selectedLocation');
                    setState(() {
                      map.text = "Location is pinned successfully";
                    });
                  } else {
                    setState(() {
                      map.text = '';
                    });
                  }
                },
                controller: map,
                validator: (value) {
                  if (selectedLocation == null) {
                    return 'Please select a location on the map';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.pin_drop),
                  label: Text("Location on map"),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: dateInput,
                validator: validateDate,
                decoration: const InputDecoration(
                  label: Text("Date"),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                ),
                readOnly: true,
                //set it true, so that user will not able to edit text
                onTap: () async {
                  pickedDate = (await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100)));
                  if (pickedDate != null) {
                    String formattedDate =
                        "${pickedDate!.day}/${pickedDate!.month}/${pickedDate!.year}";
                    print(pickedDate);
                    setState(() {
                      dateInput.text = formattedDate;
                    });
                  } else {}
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                enabled: false,
                readOnly: true,
                controller: time,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  label: Text("Time"),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: price,
                validator: validatePrice,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  label: Text("Price"),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                ),
              ),
              const SizedBox(height: 1),
              MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    DateTime tripTime =
                        pickedDate!.add(const Duration(hours: 7, minutes: 30));
                    if (tripTime.compareTo(DateTime.now()) < 0) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Alert'),
                              content: const Text('You can not add this trip '),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'OK',
                                    style:
                                        TextStyle(color: Colors.blueGrey[700]),
                                  ),
                                ),
                              ],
                            );
                          });
                    } else {
                      await FirebaseFirestore.instance
                          .collection('trips')
                          .add({
                            'driverId': user.uid,
                            'from': destination.text,
                            'from_lat': selectedLocation!.latitude,
                            'from_lng': selectedLocation!.longitude,
                            'price': int.parse(price.text),
                            'time': Timestamp.fromDate(tripTime),
                            'to': fromdropdownvalue,
                            'to_lat': 30.06463470271536,
                            'to_lng': 31.278822840356383,
                            'status': "Not Finished",
                            'acceptedRiders': 0
                          })
                          .then((value) => showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Success'),
                                  content: const Text(
                                      'Trip has been added successfully'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'OK',
                                        style: TextStyle(
                                            color: Colors.blueGrey[700]),
                                      ),
                                    ),
                                  ],
                                );
                              }))
                          .catchError((error) => showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Fail'),
                                  content: const Text(
                                      'Error in adding the trip, please try again'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'OK',
                                        style: TextStyle(
                                            color: Colors.blueGrey[700]),
                                      ),
                                    ),
                                  ],
                                );
                              }));
                    }
                  }
                },
                color: Colors.blueGrey[700],
                child: const Text(
                  "Add Trip",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
