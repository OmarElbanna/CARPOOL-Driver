import 'package:carpool_driver/Firestore_Queries.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'Trip.dart';

class TripRequestsScreen extends StatefulWidget {
  final Trip trip;

  const TripRequestsScreen({super.key, required this.trip});

  @override
  State<TripRequestsScreen> createState() => _TripRequestsScreenState();
}

class _TripRequestsScreenState extends State<TripRequestsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[600],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[700],
        title: const Text(
          "Trip Requests",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
          child: FutureBuilder(
        future: getTripRequests(widget.trip.id!),
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
                  color: Colors.white,
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
                      subtitle: Row(
                        children: [
                          Icon(Icons.error_outline_rounded),
                          Text("Status: "),
                          Text(userRequests[index]['status'])
                        ],
                      ),
                      trailing: userRequests[index]['status'] == 'requested'
                          ? Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(
                                onPressed: () async{
                                  await FirebaseFirestore.instance.collection('requests').doc(userRequests[index]['requestId']).update({'status':'accepted'});
                                  setState(() {});
                                },
                                icon: Icon(Icons.check),
                                color: Colors.green,
                              ),
                              IconButton(
                                onPressed: () async{
                                  await FirebaseFirestore.instance.collection('requests').doc(userRequests[index]['requestId']).update({'status':'Rejected'});

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
