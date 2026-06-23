import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

/// Thin wrapper around Firebase initialization.
/// Call [FirebaseService.initialize()] once in main() before runApp.
class FirebaseService {
  FirebaseService._();

  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
