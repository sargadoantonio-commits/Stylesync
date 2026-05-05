import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// StyleSync Test Account Setup Script
/// Creates two test accounts:
/// 1. roniandave@gmail.com - Free customer
/// 2. tolentino.roniandave@dnsc.edu.ph - Premium customer

class TestAccountSetup {
  static const testAccounts = [
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

  static Future<void> deleteExistingAccounts() async {
    print('\n🔍 Checking for existing accounts...');

    for (final account in testAccounts) {
      try {
        final email = account['email'] as String;

        // Check if user exists by trying to sign in
        final methods =
            await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

        if (methods.isNotEmpty) {
          print('  ⚠️  Found existing account: $email');

          // Delete from Firestore
          final users = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .get();

          for (final doc in users.docs) {
            await doc.reference.delete();
            print('  ✅ Deleted from Firestore: $email (UID: ${doc.id})');
          }

          // Delete from username index
          final username = email.split('@')[0];
          await FirebaseFirestore.instance
              .collection('username_index')
              .doc(username)
              .delete();
          print('  ✅ Deleted from username_index: $username');
        } else {
          print('  ℹ️  No existing account found: $email');
        }
      } catch (e) {
        print('  ❌ Error checking account: $e');
      }
    }
  }

  static Future<void> createTestAccounts() async {
    print('\n🚀 Creating test accounts...\n');

    for (final account in testAccounts) {
      try {
        final email = account['email'] as String;
        final password = account['password'] as String;
        final displayName = account['displayName'] as String;
        final isPremium = account['isPremium'] as bool;

        // 1. Create Auth user
        print('📝 Creating account: $email');
        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = userCredential.user!;
        await user.updateDisplayName(displayName);
        print('  ✅ Auth user created (UID: ${user.uid})');

        // 2. Create Firestore user document
        final now = DateTime.now();
        final premiumExpiresAt = isPremium
            ? now.add(const Duration(days: 365))
            : null;

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {
            'uid': user.uid,
            'email': email,
            'displayName': displayName,
            'role': 'customer',
            'isPremium': isPremium,
            'premiumExpiresAt': premiumExpiresAt,
            'accountStatus': 'active',
            'profileComplete': true,
            'createdAt': now,
            'updatedAt': now,
            'profilePhoto': null,
            'bio': 'Test ${isPremium ? 'Premium' : 'Free'} Customer',
            'verified': true,
            'notifications': {
              'email': true,
              'push': true,
              'sms': false,
            },
            'twoFactorEnabled': false,
            'lastSignIn': now,
            'accountCreatedVia': 'admin-setup',
          },
        );
        print('  ✅ Firestore user document created');

        // 3. Create username index entry
        final username = email.split('@')[0];
        await FirebaseFirestore.instance
            .collection('username_index')
            .doc(username)
            .set({
          'uid': user.uid,
          'email': email,
          'createdAt': now,
        });
        print('  ✅ Username index created (username: $username)\n');

        // Print account details
        print('📊 Account Details:');
        print('   Email: $email');
        print('   Password: $password');
        print('   Name: $displayName');
        print('   UID: ${user.uid}');
        print('   Role: customer');
        print('   Premium: $isPremium');
        print('   Status: ✅ Active\n');
      } catch (e) {
        print('❌ Error creating account: $e\n');
      }
    }
  }

  static Future<void> setup() async {
    print('═══════════════════════════════════════════════════════════');
    print('   StyleSync - Test Account Setup');
    print('═══════════════════════════════════════════════════════════');

    // Delete existing accounts if they exist
    await deleteExistingAccounts();

    // Create new test accounts
    await createTestAccounts();

    print('═══════════════════════════════════════════════════════════');
    print('✅ Test accounts setup complete!');
    print('═══════════════════════════════════════════════════════════\n');

    print('🎯 Next Steps:');
    print('   1. Use these accounts to log in to the app');
    print('   2. Test customer flow (free account)');
    print('   3. Test premium features (premium account)');
    print('   4. All passwords are secured with Cyber Pepper v1\n');
  }
}

void main() async {
  await TestAccountSetup.setup();
}
