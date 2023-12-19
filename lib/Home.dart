import 'dart:async';

import 'Account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Trip.dart';
import 'TripDetails.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController dateInput = TextEditingController();
  late DateTime? pickedDate;
  late User user;
  var gates = [
    'ASUFE Gate 3',
    'ASUFE Gate 4',
  ];
  String fromdropdownvalue = 'ASUFE Gate 3';

  void updateUser() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(tabs: [
            Tab(
              text: "From Faculty",
              icon: Icon(Icons.school),
            ),
            Tab(
              text: "To Faculty",
              icon: Icon(Icons.school_outlined),
            ),
          ]),
          backgroundColor: Colors.blueGrey[700],
          title: const Text(
            "Add New Ride",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  // key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField(
                        // validator: ,
                        decoration: const InputDecoration(
                          label: Text("Gate"),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
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
                        // controller: lastName,
                        // validator: validateLastName,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          label: Text("Destination"),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: dateInput,
                        //editing controller of this TextField
                        decoration: const InputDecoration(
                          label: Text("Date"),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                        ),
                        readOnly: true,
                        //set it true, so that user will not able to edit text
                        onTap: () async {
                          pickedDate = (await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100)))!;
                          if (pickedDate != null) {
                            String formattedDate  = "${pickedDate!.day}/${pickedDate!.month}/${pickedDate!.year}";
                            print(pickedDate);
                            setState(() {
                              dateInput.text = formattedDate;
                            });
                          } else {}
                        },
                      )
                    ],
                  ),
                ),
              )),
            ),
            SingleChildScrollView(
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  // key: _formKey,
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [],
                  ),
                ),
              )),
            ),
          ],
        ),
        drawer: Drawer(
            child: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get(),
                builder: (con, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Text('User data not found');
                  }
                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  return Column(
                    children: [
                      UserAccountsDrawerHeader(
                          decoration:
                              BoxDecoration(color: Colors.blueGrey[700]),
                          currentAccountPicture: const CircleAvatar(
                            radius: 200,
                            backgroundImage: AssetImage("images/download.png"),
                          ),
                          accountName: GestureDetector(
                            child: Text(
                              "${userData['firstName']} ${userData['lastName']}",
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            onTap: () {},
                          ),
                          accountEmail: Text(user.email!)),
                      ListTile(
                        title: const Text("Account"),
                        leading: const Icon(Icons.account_circle_rounded),
                        onTap: () {
                          Navigator.pop(context);
                          Timer(const Duration(milliseconds: 500), () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AccountScreen(updateCallback: updateUser),
                              ),
                            );
                          });
                        },
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                      ListTile(
                          title: const Text("My Trips"),
                          leading: const Icon(Icons.history),
                          onTap: () {
                            Navigator.pop(context);
                            Timer(const Duration(milliseconds: 500), () {
                              Navigator.pushNamed(context, '/mytrips');
                            });
                          }),
                      const Divider(
                        thickness: 1,
                      ),
                      ListTile(
                        title: const Text("Logout"),
                        leading: const Icon(Icons.logout_outlined),
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/login', (route) => false);
                        },
                      ),
                    ],
                  );
                })),
      ),
    );
  }
}
