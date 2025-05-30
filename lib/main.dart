import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:gaigai/pages/home_screen.dart';
import 'package:gaigai/pages/safety_mode_screen.dart';
import 'package:gaigai/pages/emergency_screen.dart';
import 'package:gaigai/pages/saved_screen.dart';
import 'package:gaigai/pages/settings.dart';
import 'package:gaigai/util/device_info.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

import 'firebase_options.dart';

import 'features/prompt/prompt_view_model.dart';
import 'features/placeTourist/place_tourist_view_model.dart';
import 'models/emergency_viewmodel.dart';

late BaseDeviceInfo deviceInfo;
final _logger = Logger('MyApp');

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Enable frame scheduling
    await Future.delayed(Duration.zero);
    
    // Initialize Firebase only if it hasn't been initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    // Configure Firestore settings
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,      
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, 
    );

    // Initialize device info
    deviceInfo = await DeviceInfo.initialize(DeviceInfoPlugin());

    runApp(const MyApp());
  } catch (e) {
    _logger.severe('Error during initialization: $e');
    // Still run the app even if Firebase fails
    runApp(const MyApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  late GenerativeModel geminiModel;
  @override
  void initState() {
    const apiKey = 'AIzaSyAXz890tXxgth2r3q5QZoP97_ctSWM-Ba8';
    if (apiKey == 'key not found') {
      throw InvalidApiKey(
        'Key not found in environment. Please add an API key.',
      );
    }

    geminiModel = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.4,
        topK: 32,
        topP: 1,
        maxOutputTokens: 4096,
         responseMimeType: 'application/json', 
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
      ],
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final placeTouristViewModel = PlaceTouristViewModel();

    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => PromptViewModel(
              textModel: geminiModel,
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => placeTouristViewModel,
          ),
          ChangeNotifierProvider(
            create: (_) => EmergencyViewModel(),
          ),
        ],
        child: SafeArea(
          child: MaterialApp(
            title: 'Safety App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.white,
              fontFamily: 'OpenSans',
            ),
            debugShowCheckedModeBanner: false,

            scrollBehavior: const ScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.mouse,
                PointerDeviceKind.touch,
                PointerDeviceKind.stylus,
                PointerDeviceKind.unknown,
              },
            ),
            home: const MainNavigationScreen(),
          ),
        ),
      );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int? _selectedIndex;

  final List<Widget> _screens = [
    const SafetyModeScreen(),
    const EmergencyScreen(),
    SavedScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = _selectedIndex == index ? null : index;
    });
  }

  @override
Widget build(BuildContext context) {
  return PopScope(
    canPop: _selectedIndex == null,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop && _selectedIndex != null) {
        setState(() {
          _selectedIndex = null;
        });
      }
    },
    child: Scaffold(
      body: _selectedIndex == null ? const HomeScreen() : _screens[_selectedIndex!],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xffffffff),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            label: 'Safety Mode',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emergency_outlined),
            label: 'Emergency',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex ?? 0,
        selectedItemColor: _selectedIndex == null ? Colors.grey : Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    ),
  );
  }
} 