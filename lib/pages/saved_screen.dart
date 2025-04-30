import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gaigai/models/saved_place.dart';

Future<List<SavedPlace>> loadSavedPlaces() async {
  final String jsonString = await rootBundle.loadString('assets/saved_place.json');
  final List<dynamic> jsonList = json.decode(jsonString);
  return jsonList.map((json) => SavedPlace.fromJson(json)).toList();
}

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  Widget buildSavedCard(SavedPlace place) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: Container(
        height: 118,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFD9D9D9),
              blurRadius: 15,
              offset: Offset(5, 5),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                place.imagePath,
                width: 114,
                height: 118,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 18, 25, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Icon(Icons.navigate_next_sharp),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Last Updated: ${place.lastUpdated}',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        title: const Text(
          'Saved',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 33, 16, 0),
        child: FutureBuilder<List<SavedPlace>>(
          future: loadSavedPlaces(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error loading data'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No saved places'));
            }
            final savedPlaces = snapshot.data!;
            return ListView.builder(
              itemCount: savedPlaces.length,
              itemBuilder: (context, index) {
                return buildSavedCard(savedPlaces[index]);
              },
            );
          },
        ),
      ),
    );
  }
}