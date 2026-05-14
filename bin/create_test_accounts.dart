import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with emulator configuration
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Connect to emulators
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);

  print('═══════════════════════════════════════════════════════════');
  print('   StyleSync - Test Account Creation');
  print('═══════════════════════════════════════════════════════════\n');

  await createTestAccounts();

  print('\n═══════════════════════════════════════════════════════════');
  print('✅ Test accounts created successfully!');
  print('═══════════════════════════════════════════════════════════\n');

  exit(0);
}

Future<void> createTestAccounts() async {
  final testAccounts = [
    {
      'email': 'roniandave@gmail.com',
      'password': 'TestPassword123!@#',
      'displayName': 'Roni Dave',
      'isPremium': false,
    },
    {
      'email': 'tolentino.roniandave@dnsc.edu.ph',
      'password': 'PremiumPass456!@#',
      'displayName': 'Roni Tolentino',
      'isPremium': true,
    },
  ];

  for (final account in testAccounts) {
    try {
      final email = account['email'] as String;
      final password = account['password'] as String;
      final displayName = account['displayName'] as String;
      final isPremium = account['isPremium'] as bool;

      print('📝 Creating: $email');

      // Create Auth user
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;
      await user.updateDisplayName(displayName);
      print('  ✅ Auth user created (UID: ${user.uid})');

      // Create Firestore document
      final now = DateTime.now();
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'displayName': displayName,
        'role': 'customer',
        'isPremium': isPremium,
        'premiumExpiresAt': isPremium
            ? now.add(const Duration(days: 365))
            : null,
        'accountStatus': 'active',
        'profileComplete': false,
        'createdAt': now,
        'updatedAt': now,
        'bio': 'Test ${isPremium ? 'Premium' : 'Free'} Customer',
        'verified': false,
        'notifications': {
          'email': true,
          'push': true,
          'sms': false,
        },
      });
      print('  ✅ Firestore user document created');

      // Create username index
      final username = email.split('@')[0];
      await FirebaseFirestore.instance
          .collection('username_index')
          .doc(username)
          .set({
        'uid': user.uid,
        'email': email,
        'createdAt': now,
      });
      print('  ✅ Username index created\n');

      // Print credentials
      print('📊 Account Details:');
      print('   Email: $email');
      print('   Password: $password');
      print('   Name: $displayName');
      print('   UID: ${user.uid}');
      print('   Premium: $isPremium\n');
    } catch (e) {
      print('❌ Error creating account: $e\n');
    }
  }
}
