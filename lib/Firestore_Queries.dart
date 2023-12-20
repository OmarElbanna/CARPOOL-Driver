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
