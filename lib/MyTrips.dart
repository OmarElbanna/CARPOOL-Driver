import 'package:carpool_driver/TripRequets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Trip.dart';
import 'Firestore_Queries.dart';
import 'TripDetails.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  late User user;
  List<Trip> trips = [];

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[600],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[700],
        title: const Text(
          "My Trips",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
          child: FutureBuilder(
        future: getDriverTrips(user.uid),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Text(
              'Sorry, you have no trips',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            );
          }
          final trips = snapshot.data.docs;
          return ListView.builder(
            itemCount: trips.length,
            itemBuilder: (context, index) {
              DateTime date = trips[index]['time'].toDate();
              String dateToShow = "${date.day}/${date.month}/${date.year}";
              String timeToShow = "${date.hour}:${date.minute}";
              return Padding(
                padding: const EdgeInsets.all(3),
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, color: Colors.blueGrey[700]),
                        const SizedBox(height: 4),
                        Container(
                          height: 16,
                          width: 1, // Vertical bar width
                          color: Colors.blueGrey[700], // Vertical bar color
                        ),
                      ],
                    ),
                    title: Row(
                      children: [
                        Text(
                          '${trips[index]['from']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Icon(Icons.arrow_right_alt),
                        Text(
                          '${trips[index]['to']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                color: Colors.blueGrey[700]),
                            const SizedBox(width: 4),
                            Text('Date: $dateToShow'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_filled,
                                  color: Colors.blueGrey[700],
                                ),
                                Text(' Time: $timeToShow'),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.error_outline_rounded,
                                    color: Colors.blueGrey[700]),
                                Text('Status: ${trips[index]['status']}')
                              ],
                            ),

                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.numbers),
                            Text('Accepted Riders: ${trips[index]['acceptedRiders']}'),

                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.attach_money,
                                  color: Colors.green,
                                ),
                                Text(
                                  ' Price: ${trips[index]['price']}',
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                            MaterialButton(
                              onPressed: trips[index]['status'] ==
                                  "Not Finished"
                                  ? () async {
                                if (date.compareTo(DateTime.now()) < 0) {
                                  await FirebaseFirestore.instance
                                      .collection('trips')
                                      .doc(trips[index].id)
                                      .update({'status': 'Finished'});
                                  setState(() {});
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Alert'),
                                          content: const Text(
                                              'You can not finish the trip until it starts '),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop();
                                              },
                                              child: Text(
                                                'OK',
                                                style: TextStyle(
                                                    color: Colors
                                                        .blueGrey[700]),
                                              ),
                                            ),
                                          ],
                                        );
                                      });
                                }
                              }
                                  : null,
                              child: Text(
                                'Finish',
                                style: TextStyle(color: Colors.white),
                              ),
                              color: Colors.red,
                              disabledColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                            ),
                          ],
                        )
                      ],
                    ),
                    onTap: () {
                      Trip trip = Trip(id: trips[index].id,acceptedRiders: trips[index]['acceptedRiders'],time: date);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TripRequestsScreen(
                            trip: trip,
                          ),
                        ),
                      ).then((value) => setState(() {

                      },));
                    },
                  ),
                ),
              );
            },
          );
        },
      )),
    );
  }
}
