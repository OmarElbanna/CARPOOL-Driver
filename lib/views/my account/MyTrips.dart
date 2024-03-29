import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:carpool_driver/views/TripRequets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/Trip.dart';
import '../../services/database/Firestore_Queries.dart';

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
      appBar: AppBar(
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
              child: CircularProgressIndicator(),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 16,
                          width: 1, // Vertical bar width// Vertical bar color
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
                            Icon(
                              Icons.location_on,
                            ),
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
                                Icon(
                                  Icons.error_outline_rounded,
                                ),
                                Text('Status: ${trips[index]['status']}')
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.numbers),
                            Text(
                                'Accepted Riders: ${trips[index]['acceptedRiders']}'),
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
                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.error,
                                          animType: AnimType.rightSlide,
                                          title: 'Fail',
                                          desc:
                                              'You can not finish the trip until its time is started',
                                          btnOkOnPress: () {},
                                        )..show();
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
                      Trip trip = Trip(
                          id: trips[index].id,
                          acceptedRiders: trips[index]['acceptedRiders'],
                          time: date);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TripRequestsScreen(
                            trip: trip,
                          ),
                        ),
                      ).then((value) => setState(
                            () {},
                          ));
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
