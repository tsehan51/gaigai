import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../../services/firestore.dart';
import 'place_tourist_model.dart';

class PlaceTouristViewModel extends ChangeNotifier {
  List<PlaceTourist> placeTourist = [];

  final placeTouristPath = '/placeTourist';
  final firestore = FirebaseFirestore.instance;

  PlaceTouristViewModel() {
    firestore.collection(placeTouristPath).snapshots().listen((querySnapshot) {
      placeTourist = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return PlaceTourist.fromFirestore(data);
      }).toList();
      notifyListeners();
    });
  }

  void deletePlace(PlaceTourist place) {
    FirestoreService.deletePlace(place);
  }

  void updatePlace(PlaceTourist place) {
    FirestoreService.updatePlace(place);
    notifyListeners();
  }

  Future<bool> isBookmarked(PlaceTourist place) async {
    bool result = await FirestoreService.isBookmarked(place);
  
    if (result) {
    return true;
    } else {
      return false;
    }
  }

  void toggleBookmark(PlaceTourist place) async {
    if (await isBookmarked(place)) {
      await FirestoreService.deletePlace(place);
    } else {
      await FirestoreService.savePlace(place);
    }

    notifyListeners();
  }
  
}
