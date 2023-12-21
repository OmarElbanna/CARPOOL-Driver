import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> getUserTrips(String userId) async {
  QuerySnapshot<Map<String, dynamic>> requestsSnapshot = await FirebaseFirestore
      .instance
      .collection('requests')
      .where('userId', isEqualTo: userId)
      .get();

  List tripIds = requestsSnapshot.docs.map((doc) => doc['tripId']).toList();
  if (tripIds.isEmpty) {
    print("############################################");
    List<Map<String, dynamic>> empty = [];
    return empty;
  }

  QuerySnapshot<Map<String, dynamic>> tripsSnapshot = await FirebaseFirestore
      .instance
      .collection('trips')
      .where(FieldPath.documentId, whereIn: tripIds)
      .get();

  List<Map<String, dynamic>> userTrips = tripsSnapshot.docs.map((tripDoc) {
    var tripDetails = tripDoc.data();
    var requestId =
        requestsSnapshot.docs.firstWhere((doc) => doc['tripId'] == tripDoc.id);

    var status = requestId['status'];

    return {'details': tripDetails, 'status': status};
  }).toList();

  return userTrips;
}

Future<QuerySnapshot<Map<String, dynamic>>> getDriverTrips(String driverId) async{
  return await FirebaseFirestore.instance.collection('trips').where('driverId',isEqualTo:driverId).get();
}

Future<List<Map<String, dynamic>>> getTripRequests(String tripId) async {
  QuerySnapshot<Map<String, dynamic>> requestsSnapshot = await FirebaseFirestore
      .instance
      .collection('requests')
      .where('tripId', isEqualTo: tripId)
      .get();

  List userIds = requestsSnapshot.docs.map((doc) => doc['userId']).toList();
  if (userIds.isEmpty) {
    List<Map<String, dynamic>> empty = [];
    return empty;
  }

  QuerySnapshot<Map<String, dynamic>> usersSnapshot = await FirebaseFirestore
      .instance
      .collection('users')
      .where(FieldPath.documentId, whereIn: userIds)
      .get();

  List<Map<String, dynamic>> userRequests = usersSnapshot.docs.map((userDoc) {
    var userDetails = userDoc.data();
    var requestId =
    requestsSnapshot.docs.firstWhere((doc) => doc['userId'] == userDoc.id);

    var status = requestId['status'];

    return {'details': userDetails, 'status': status,'requestId':requestId.id};
  }).toList();

  return userRequests;
}

Stream<List<Map<String, dynamic>>> getTripRequestsStream(String tripId) {
  StreamController<List<Map<String, dynamic>>> controller =
  StreamController<List<Map<String, dynamic>>>();

  FirebaseFirestore.instance
      .collection('requests')
      .where('tripId', isEqualTo: tripId)
      .snapshots()
      .listen((requestsSnapshot) async {
    List userIds = requestsSnapshot.docs.map((doc) => doc['userId']).toList();

    if (userIds.isEmpty) {
      controller.add([]); // Add an empty list to the stream
      return;
    }

    FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: userIds)
        .snapshots()
        .listen((usersSnapshot) {
      List<Map<String, dynamic>> userRequests = usersSnapshot.docs.map((userDoc) {
        var userDetails = userDoc.data();
        var requestId = requestsSnapshot.docs
            .firstWhere((doc) => doc['userId'] == userDoc.id);

        var status = requestId['status'];

        return {'details': userDetails, 'status': status, 'requestId': requestId.id};
      }).toList();

      controller.add(userRequests); // Add the userRequests list to the stream
    });
  });

  return controller.stream;
}

