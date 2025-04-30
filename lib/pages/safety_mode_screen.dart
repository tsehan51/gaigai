import 'package:flutter/material.dart';

class SafetyModeScreen extends StatefulWidget {
  const SafetyModeScreen({super.key});

  @override
  State<SafetyModeScreen> createState() => _SafetyModeScreenState();
}

class _SafetyModeScreenState extends State<SafetyModeScreen> {
  bool light = true;
  bool danger = false;

  @override
  Widget build(BuildContext context) {
    const WidgetStateProperty<Color?> trackColor = WidgetStateProperty<Color?>.fromMap(
      <WidgetStatesConstraint, Color>{WidgetState.selected: Colors.black12},
    );

    final WidgetStateProperty<Color?> overlayColor = WidgetStateProperty<Color?>.fromMap(
      <WidgetState, Color>{
        WidgetState.selected: Colors.grey.shade200,
        WidgetState.disabled: Colors.grey,
      },
    );

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
          'Safety Mode Screen',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First Row with Horizontal Padding
          const SizedBox(height: 33),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Safety Mode',
                  style: TextStyle(fontSize: 18),
                ),
                Switch(
                  value: light,
                  overlayColor: overlayColor,
                  trackColor: trackColor,
                  thumbColor: const WidgetStatePropertyAll<Color>(Colors.black),
                  onChanged: (bool value) {
                    setState(() {
                      light = value;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          if(light) ...[
            // Second Row with Horizontal Padding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text(
                    'Activity:',
                    style: TextStyle(fontSize: 18),
                  ),
                  const Icon(
                    Icons.directions_walk_rounded,
                    size: 38,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 42),
            Expanded(
              child: Container(
                width: 412,
                height: 548,
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/googleMap.png'),
                    fit: BoxFit.cover,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
