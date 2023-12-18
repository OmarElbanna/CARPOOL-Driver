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
        future: getUserTrips(user.uid),
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
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text(
              'Sorry, you have no trips',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            );
          }
          final trips = snapshot.data;
          return ListView.builder(
            itemCount: trips.length,
            itemBuilder: (context, index) {
              DateTime date = trips[index]['details']['time'].toDate();
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
                          '${trips[index]['details']['from']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Icon(Icons.arrow_right_alt),
                        Text(
                          '${trips[index]['details']['to']}',
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
                            Row(
                              children: [
                                const Icon(
                                  Icons.attach_money,
                                  color: Colors.green,
                                ),
                                Text(
                                  ' Price: ${trips[index]['details']['price']}',
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.error_outline_rounded,
                                color: Colors.blueGrey[700]),
                            Text('Status: ${trips[index]['status']}')
                          ],
                        )
                      ],
                    ),
                    onTap: () async {
                      {
                        String driverId = trips[index]['details']['driverId'];
                        final driverDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(driverId)
                            .get();
                        final driverInfo = driverDoc.data();
                        Trip trip = Trip(
                            from: trips[index]['details']['from'],
                            to: trips[index]['details']['to'],
                            price: trips[index]['details']['price'],
                            time: trips[index]['details']['time'].toDate(),
                            from_lat: trips[index]['details']['from_lat'],
                            from_lng: trips[index]['details']['from_lng'],
                            to_lat: trips[index]['details']['to_lat'],
                            to_lng: trips[index]['details']['to_lng'],
                            driverName:
                                "${driverInfo!['firstName']} ${driverInfo['lastName']}",
                            carModel: driverInfo['carModel'],
                            carColor: driverInfo['carColor'],
                            status: trips[index]['status']);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TripDetailsScreen(
                              data: trip,
                              isBooking: false,
                            ),
                          ),
                        );
                      }
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
