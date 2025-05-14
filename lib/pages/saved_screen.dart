import 'package:gaigai/features/placeTourist/place_tourist_view_model.dart';
import 'package:gaigai/features/placeTourist/place_tourist_model.dart';
import 'package:gaigai/features/prompt/prompt_view_model.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:gaigai/models/saved_place.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PlaceTouristViewModel>();

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
        child: ListView.builder(
              itemCount: viewModel.placeTourist.length,
              itemBuilder: (context, index) {
                final placeTourist = viewModel.placeTourist[index];
                return _BuildSavedCard(
                   key: Key('$index-${placeTourist.hashCode}'),
                   placeTourist: placeTourist,
                   index: index,);
              },
            )
        ),
    );
  }
}

class _BuildSavedCard extends StatefulWidget {
  const _BuildSavedCard({
    super.key,
    required this.placeTourist,
    this.index = 0,
  });

  final PlaceTourist placeTourist;
  final int index;

  @override
  State<_BuildSavedCard> createState() => _BuildSavedCardState();
  
  }

  class _BuildSavedCardState extends State<_BuildSavedCard> {

    @override
    Widget build(BuildContext context) {
    final viewModel = context.watch<PlaceTouristViewModel>();

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
                'assets/Muar.jpg',
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
                          widget.placeTourist.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await showDialog<Null>(
                              context: context,
                              builder: (context) {
                                return _buildPlaceTouristCard(context, viewModel, widget.placeTourist);
                              },
                            );
                          },
                          child: const Icon(Icons.navigate_next_sharp),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Last Updated: a few seconds ago',
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
}

Widget _buildPlaceTouristCard(BuildContext context, PlaceTouristViewModel viewModel, PlaceTourist place) {

     return Padding(
        padding: const EdgeInsets.fromLTRB(16, 33, 16, 33),
        child: SizedBox(
          height: 400, 
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            place.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Row(
                            children: [
                              StatefulBuilder(
                                builder: (context, setState) {
                                  return IconButton(
                                    icon: FutureBuilder<bool>(
                                      future: viewModel.isBookmarked(place), 
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const CircularProgressIndicator(); 
                                        } else if (snapshot.hasError) {
                                          print("Error in snapshot: ${snapshot.error}"); 
                                          return Icon(Icons.error, color: Colors.red); 
                                        } else if (snapshot.hasData) {
                                          bool isBookmarked = snapshot.data!; 
                                          return Icon(
                                            isBookmarked ? Icons.bookmark_border: Icons.bookmark,
                                            color: Colors.black,
                                            size: 24,
                                          );
                                        } else {
                                          return Icon(Icons.bookmark, color: const Color(0x7FFFB703), size: 24); 
                                        }
                                      },
                                    ),
                                    onPressed: () {
                                      viewModel.toggleBookmark(place);
                                      setState(() {});
                                    }
                                  );
                                }
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.black,
                                  size: 24,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(),
                      _buildDetailRow('Location', place.placeTourist),
                      _buildDetailRow('Date', DateFormat('yyyy-MM-dd').format(place.dateTourist)),
                      _buildDetailRow('Flood Risk', place.floodRisk),
                      _buildDetailRow('Flood Risk Explanation', place.floodRiskExplanation),
                      _buildDetailRow('Earthquake Risk', place.earthquakeRisk),
                      _buildDetailRow('Earthquake Risk Explanation', place.earthquakeRiskExplanation),
                      _buildDetailRow('Scam Risk Level', place.scamRiskLevel),
                      _buildDetailRow('Scam Types', place.scamTypes),
                      _buildDetailRow('Conclusion', place.conclusion),
                      _buildDetailRow('Conclusion Explanation', place.conclusionExplanation),
                      if (place.travelTips.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Travel Tips:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: place.travelTips.map((tip) => Text('• $tip')).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: \n',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
