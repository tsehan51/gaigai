//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

//import '../../services/firestore.dart';
import 'place_tourist_model.dart';

class PlaceTouristViewModel extends ChangeNotifier {
  List<PlaceTourist> placeTourist = [];

  final recipePath = '/placeTourist';
  //final firestore = FirebaseFirestore.instance;
/*
  SavedRecipesViewModel() {
    firestore.collection(recipePath).snapshots().listen((querySnapshot) {
      recipes = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Recipe.fromFirestore(data);
      }).toList();
      notifyListeners();
    });
  }

  void deleteRecipe(Recipe recipe) {
    FirestoreService.deleteRecipe(recipe);
  }

  void updateRecipe(Recipe recipe) {
    FirestoreService.updateRecipe(recipe);
    notifyListeners();
  }
  */
}
