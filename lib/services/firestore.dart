import 'package:cloud_firestore/cloud_firestore.dart';

import '../features/placeTourist/place_tourist_model.dart';

const placeTouristePath = '/placeTourist';
final firestore = FirebaseFirestore.instance;

class FirestoreService {
  static Future<Null> savePlace(PlaceTourist place) async {
    await firestore
        .collection(placeTouristePath)
        .doc(place.id)
        .set(place.toFirestore());
  }

  static Future<Null> deletePlace(PlaceTourist place) async {
    await firestore.doc("$placeTouristePath/${place.id}").delete();
  }

  static Future<Null> updatePlace(PlaceTourist place) async {
    await firestore
        .doc("$placeTouristePath/${place.id}")
        .update(place.toFirestore());
  }

  static Future<bool> isBookmarked(PlaceTourist place) async {
    final doc = await FirebaseFirestore.instance
        .collection(placeTouristePath)
        .doc(place.id)
        .get();
    return doc.exists;
  }
  
}
