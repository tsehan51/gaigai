import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:gaigai/features/prompt/prompt_view_model.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PromptViewModel>();
    
    return Scaffold(
      body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(width: 25),
                                  CircleAvatar(
                                    backgroundColor: Color(0x7FFB8500),
                                    radius: 24,
                                    child: Text(
                                      'T',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Nunito',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 216),
                              Center(
                                child: Text(
                                  "Where to? \nI'll keep you safe.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.12,
                                  ),
                                ),
                              ),
                              SizedBox(height: 44),
                              SizedBox(
                                height: 52,
                                child: Container(
                                  decoration: BoxDecoration(
                                  color: Colors.grey[200], 
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: viewModel.promptTextController,
                                          onChanged: (value) {
                                            viewModel.notify();
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Describe your trip',
                                            border: OutlineInputBorder(   
                                            borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                      IntrinsicWidth(
                                        child:
                                            TextFormField(
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(borderSide: BorderSide.none),
                                              suffixIcon: Icon(Icons.calendar_today),
                                            ),
                                            onTap: () async {
                                              final selectedDate = await showDatePicker( context: context,  // Must provide context
                                                initialDate: viewModel.selectedDate ?? DateTime.now(),
                                                firstDate: DateTime(2000),
                                                lastDate: DateTime(2100),
                                              );
                                              if (selectedDate != null) {
                                                
                                                viewModel.selectedDate = selectedDate;
                                                viewModel.notify();
                                              }
                                            },
                                            controller: TextEditingController(
                                              text: viewModel.selectedDate != null 
                                                ? DateFormat('MM/dd/yyyy').format(viewModel.selectedDate!)
                                                : '',
                                            ),
                                          ),
                                      ),
                                      ElevatedButton(
                                        onPressed: viewModel.isLoading ? null : () => viewModel.submitPrompt(),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(width: 8),
                                            viewModel.isLoading
                                                ? const CircularProgressIndicator()
                                                : const Icon(Symbols.send),
                                          ],
                                        ),
                                      ),
                                    ]
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              // Display area for errors or responses
                              if (viewModel.geminiFailureResponse != null) 
                                _buildErrorCard(context, viewModel.geminiFailureResponse!),
                              if (viewModel.placeTourist != null)
                                _buildPlaceTouristCard(context, viewModel),
                            ],
                          ),
                        ),
                        
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/map.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                    
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            }
          ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String errorMessage) {
    return Card(
      color: Colors.red[50],
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          errorMessage,
          style: TextStyle(color: Colors.red[800]),
        ),
      ),
    );
  }

  Widget _buildPlaceTouristCard(BuildContext context, PromptViewModel viewModel) {
    final place = viewModel.placeTourist!;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    place.title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: FutureBuilder<bool>(
                    future: viewModel.isBookmarked(), 
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(); 
                      } else if (snapshot.hasError) {
                        debugPrint('Error in snapshot: ${snapshot.error}'); 
                        return Icon(Icons.error, color: Colors.red); 
                      } else if (snapshot.hasData) {
                        bool isBookmarked = snapshot.data!; 
                        return Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: Colors.black,
                          size: 24,
                        );
                      } else {
                        return Icon(Icons.bookmark_border, color: const Color(0x7FFFB703), size: 24); 
                      }
                    },
                  ),
                  onPressed: viewModel.toggleBookmark,
                )
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
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black,),
            ),
            TextSpan(text: value, style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4, letterSpacing: 0.2,)),
          ],
        ),
      ),
    );
  }
} 