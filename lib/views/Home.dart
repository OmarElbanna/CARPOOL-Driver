import 'dart:async';
import 'package:carpool_driver/views/new%20trip/FromFaculty.dart';
import 'package:carpool_driver/services/database/Sqflite_Queries.dart';
import 'package:carpool_driver/views/new%20trip/ToFaculty.dart';
import 'my account/Account.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/Trip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late User user;

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
          title: const Text(
            "Add New Trip",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: const TabBarView(
          children: [
            FromFaculty(),
            ToFaculty(),
          ],
        ),
        drawer: Drawer(
            child: FutureBuilder(
                future: getUserData(user.uid),
                builder: (con, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final userData = snapshot.data![0] as Map<String, dynamic>;
                  return Column(
                    children: [
                      UserAccountsDrawerHeader(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                            color: Colors.white,
                            width: 2.0,
                          ))),
                          currentAccountPicture: const CircleAvatar(
                            radius: 200,
                            backgroundImage: AssetImage("images/download.png"),
                          ),
                          accountName: GestureDetector(
                            child: Text(
                              "${userData['firstName']} ${userData['lastName']}",
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            onTap: () {},
                          ),
                          accountEmail: Text(
                            userData['email'],
                            style: TextStyle(color: Colors.white),
                          )),
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
                        color: Colors.white,
                        thickness: 2,
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
                        color: Colors.white,
                        thickness: 2,
                      ),
                      ListTile(
                        title: const Text("Logout"),
                        leading: const Icon(Icons.logout_outlined),
                        onTap: () async {
                          await deleteUser();
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
