import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:carpool_driver/services/database/Firestore_Queries.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/Trip.dart';

class TripRequestsScreen extends StatefulWidget {
  final Trip trip;

  const TripRequestsScreen({super.key, required this.trip});

  @override
  State<TripRequestsScreen> createState() => _TripRequestsScreenState();
}

class _TripRequestsScreenState extends State<TripRequestsScreen> {
  bool bypass = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Switch(
              value: bypass, // Set the initial value of the switch
              onChanged: (bool value) {
                setState(() {
                  bypass = value;
                });
              },
              activeTrackColor:
                  Colors.green, // Color of the switch track when OFF
            ),
          ),
        ],
        title: const Text(
          "Trip Requests",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
          child: StreamBuilder(
        stream: getTripRequestsStream(widget.trip.id!),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text(
              'Sorry, you have no requests',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            );
          }
          final userRequests = snapshot.data;
          return ListView.builder(
            itemCount: userRequests.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(3),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 4,
                  child: ListTile(
                      title: Row(
                        children: [
                          Icon(Icons.person),
                          Text("Name: "),
                          Text(
                            '${userRequests[index]['details']['firstName']} ${userRequests[index]['details']['lastName']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.error_outline_rounded),
                              Text("Status: "),
                              Text(
                                userRequests[index]['status'],
                                style: TextStyle(
                                    color: userRequests[index]['status'] ==
                                            'accepted'
                                        ? Colors.green
                                        : userRequests[index]['status'] ==
                                                'rejected'
                                            ? Colors.red
                                            : null),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.phone),
                              const Text("Phone Number: "),
                              Text('${userRequests[index]['details']['phone']}')
                            ],
                          )
                        ],
                      ),
                      trailing: userRequests[index]['status'] == 'requested'
                          ? Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(
                                onPressed: () async {
                                  if (widget.trip.acceptedRiders! < 4) {
                                    DateTime currentTime = DateTime.now();
                                    DateTime acceptanceDeadline;
                                    if (widget.trip.time!.hour == 7) {
                                      acceptanceDeadline = DateTime(
                                        widget.trip.time!.year,
                                        widget.trip.time!.month,
                                        widget.trip.time!.day - 1,
                                        23, // 10:00 pm
                                        30,
                                      );
                                    } else if (widget.trip.time!.hour == 17) {
                                      acceptanceDeadline = DateTime(
                                        widget.trip.time!.year,
                                        widget.trip.time!.month,
                                        widget.trip.time!.day,
                                        16,
                                        30,
                                      );
                                    } else {
                                      acceptanceDeadline = DateTime.now();
                                    }
                                    if (currentTime
                                            .isBefore(acceptanceDeadline) ||
                                        bypass) {
                                      await FirebaseFirestore.instance
                                          .collection('requests')
                                          .doc(userRequests[index]['requestId'])
                                          .update({'status': 'accepted'});
                                      await FirebaseFirestore.instance
                                          .collection('trips')
                                          .doc(widget.trip.id)
                                          .update({
                                        'acceptedRiders':
                                            FieldValue.increment(1)
                                      });
                                      setState(() {});
                                    } else {
                                      AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.error,
                                        animType: AnimType.rightSlide,
                                        title: 'Fail',
                                        desc:
                                            'Sorry, the acceptance deadline for this trip has passed. For testing purposes you can bypass this constraint by toggling the switch in the app bar',
                                        btnOkOnPress: () {},
                                      )..show();
                                    }
                                  } else {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.error,
                                      animType: AnimType.rightSlide,
                                      title: 'Fail',
                                      desc:
                                          'You can not accept more than 4 riders',
                                      btnOkOnPress: () {},
                                    )..show();
                                  }
                                },
                                icon: Icon(Icons.check),
                                color: Colors.green,
                              ),
                              IconButton(
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('requests')
                                      .doc(userRequests[index]['requestId'])
                                      .update({'status': 'rejected'});

                                  setState(() {});
                                },
                                icon: Icon(Icons.close),
                                color: Colors.red,
                              ),
                            ])
                          : null),
                ),
              );
            },
          );
        },
      )),
    );
  }
}
