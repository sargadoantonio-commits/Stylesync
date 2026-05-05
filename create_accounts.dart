import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  // Use emulator
  const useEmulator = true;
  
  if (useEmulator) {
    FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }

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

  print('═══════════════════════════════════════════════════\n');
  print('  📱 STYLESYNC TEST ACCOUNT SETUP\n');
  print('═══════════════════════════════════════════════════\n');

  // Check for existing accounts
  print('🔍 Checking for existing accounts...\n');
  
  for (final account in testAccounts) {
    final email = account['email'] as String;
    try {
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        print('  ⚠️  Found existing: $email');
        
        // Try to delete (this will fail in read-only mode, but that's ok)
        try {
          // We can't delete without being signed in as that user
          print('     ℹ️  Note: Cannot delete from this context');
        } catch (e) {
          print('     ℹ️  Skip: $e');
        }
      } else {
        print('  ℹ️  Not found: $email');
      }
    } catch (e) {
      print('  ❌ Error checking: $e');
    }
  }

  // Create test accounts
  print('\n🚀 Creating test accounts...\n');

  for (final account in testAccounts) {
    try {
      final email = account['email'] as String;
      final password = account['password'] as String;
      final displayName = account['displayName'] as String;
      final isPremium = account['isPremium'] as bool;

      print('📝 Creating: $email');

      // Create Auth user
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;
      await user.updateDisplayName(displayName);
      
      print('   ✅ Auth user created (UID: ${user.uid})');

      // Create Firestore document
      final username = email.split('@')[0];
      
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'displayName': displayName,
        'username': username,
        'role': 'customer',
        'isPremium': isPremium,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'profileImageUrl': '',
        'bio': '',
        'phone': '',
        'address': '',
        'city': '',
        'state': '',
        'country': '',
        'zipCode': '',
      });

      print('   ✅ Firestore user document created');

      // Create username index
      await FirebaseFirestore.instance.collection('username_index').doc(username).set({
        'uid': user.uid,
        'email': email,
      });

      print('   ✅ Username index created\n');
    } catch (e) {
      print('   ❌ Error: $e\n');
    }
  }

  print('═══════════════════════════════════════════════════');
  print('  ✅ Setup Complete!\n');
  print('  Login with:');
  print('  - Email: roniandave@gmail.com (Free)');
  print('  - Password: TestPassword123!@#\n');
  print('  - Email: tolentino.roniandave@dnsc.edu.ph (Premium)');
  print('  - Password: PremiumPass456!@#');
  print('═══════════════════════════════════════════════════\n');
}
