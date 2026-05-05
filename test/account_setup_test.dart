import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylesync/firebase_options.dart';

void main() {
  group('Test Account Setup', () {
    late FirebaseAuth auth;
    late FirebaseFirestore firestore;

    setUpAll(() async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      auth = FirebaseAuth.instance;
      firestore = FirebaseFirestore.instance;
      
      // Connect to emulators
      try {
        await auth.useAuthEmulator('localhost', 9099);
        firestore.useFirestoreEmulator('localhost', 8080);
        print('[Test] Connected to Firebase emulators');
      } catch (e) {
        print('[Test] Emulator connection error: $e');
      }
    });

    test('Create test accounts', () async {
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

      print('\n═══════════════════════════════════════════════════');
      print('  📱 STYLESYNC TEST ACCOUNT SETUP');
      print('═══════════════════════════════════════════════════\n');

      // Delete existing accounts
      print('🔍 Checking for existing accounts...\n');
      
      for (final account in testAccounts) {
        final email = account['email'] as String;
        try {
          final methods = await auth.fetchSignInMethodsForEmail(email);
          if (methods.isNotEmpty) {
            print('  ⚠️  Found existing: $email');
            
            // Get and delete the user

            try {
              // Try to delete from Firestore first
              final userQuery = await firestore
                  .collection('users')
                  .where('email', isEqualTo: email)
                  .get();

              for (final doc in userQuery.docs) {
                await doc.reference.delete();
                print('     ✅ Deleted from Firestore');
              }

              // Delete username index
              final username = email.split('@')[0];
              await firestore.collection('username_index').doc(username).delete();
              print('     ✅ Deleted from index');
            } catch (e) {
              print('     ℹ️  Could not delete: $e');
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
          final userCredential = await auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          final userUid = userCredential.user!.uid;
          await userCredential.user!.updateDisplayName(displayName);
          print('   ✅ Auth user created (UID: $userUid)');

          // Create Firestore document
          final username = email.split('@')[0];
          
          await firestore.collection('users').doc(userUid).set({
            'uid': userUid,
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
          await firestore.collection('username_index').doc(username).set({
            'uid': userUid,
            'email': email,
          });

          print('   ✅ Username index created\n');
        } catch (e) {
          print('   ❌ Error: $e\n');
          rethrow;
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

      // Verify accounts were created
      print('✅ Verifying accounts...\n');
      
      for (final account in testAccounts) {
        final email = account['email'] as String;
        try {
          final methods = await auth.fetchSignInMethodsForEmail(email);
          if (methods.isNotEmpty) {
            print('✓ $email verified');
          }
        } catch (e) {
          print('✗ $email verification failed: $e');
        }
      }
    });
  });
}
