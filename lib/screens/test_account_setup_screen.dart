import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stylesync/core/theme/app_colors.dart';
import 'package:stylesync/core/theme/app_typography.dart';

class TestAccountSetupScreen extends StatefulWidget {
  const TestAccountSetupScreen({super.key});

  @override
  State<TestAccountSetupScreen> createState() => _TestAccountSetupScreenState();
}

class _TestAccountSetupScreenState extends State<TestAccountSetupScreen> {
  bool isLoading = false;
  String status = '';

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

  void _log(String message) {
    debugPrint(message);
    setState(() {
      status += '$message\n';
    });
  }

  Future<void> deleteExistingAccounts() async {
    _log('🔍 Checking for existing accounts...');

    for (final account in testAccounts) {
      final email = account['email'] as String;
      try {
        final methods =
            await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

        if (methods.isNotEmpty) {
          _log('  ⚠️  Found existing: $email');

          // Delete from Firestore
          final users = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .get();

          for (final doc in users.docs) {
            await doc.reference.delete();
            _log('  ✅ Deleted from Firestore');
          }

          // Delete from username index
          final username = email.split('@')[0];
          await FirebaseFirestore.instance
              .collection('username_index')
              .doc(username)
              .delete();
          _log('  ✅ Deleted from index');
        } else {
          _log('  ℹ️  Not found: $email');
        }
      } catch (e) {
        _log('  ❌ Error: ${e.toString().substring(0, 50)}');
      }
    }
  }

  Future<void> createTestAccounts() async {
    _log('\n🚀 Creating test accounts...\n');

    for (final account in testAccounts) {
      try {
        final email = account['email'] as String;
        final password = account['password'] as String;
        final displayName = account['displayName'] as String;
        final isPremium = account['isPremium'] as bool;

        _log('📝 Creating: $email');

        // Create Auth user with email and password
        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = userCredential.user!;
        await user.updateDisplayName(displayName);
        _log('  ✅ Auth user created');

        // Create Firestore document
        final now = DateTime.now();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'uid': user.uid,
          'email': email,
          'displayName': displayName,
          'role': 'customer',
          'isPremium': isPremium,
          'premiumExpiresAt': isPremium
              ? now.add(const Duration(days: 365))
              : null,
          'accountStatus': 'active',
          'profileComplete': true,
          'createdAt': now,
          'updatedAt': now,
          'bio': 'Test ${isPremium ? 'Premium' : 'Free'} Customer',
          'notifications': {
            'email': true,
            'push': true,
            'sms': false,
          },
        });
        _log('  ✅ Firestore created');

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
        _log('  ✅ Index created');
        _log('   Password: $password');
        _log('   Premium: $isPremium\n');
      } catch (e) {
        _log('❌ Error: $e\n');
      }
    }
  }

  Future<void> setupAccounts() async {
    setState(() {
      isLoading = true;
      status = '';
    });

    try {
      await deleteExistingAccounts();
      await createTestAccounts();
      _log('✅ Setup complete!');
    } catch (e) {
      _log('❌ Fatal error: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Test Account Setup', style: AppTypography.orbitronHeading(18)),
        backgroundColor: AppColors.deepNavy,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.glassFill,
                border: Border.all(color: AppColors.glassBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ℹ️ Test Accounts',
                    style: AppTypography.orbitronHeading(16),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Free Account:\nroniandave@gmail.com',
                    style: AppTypography.interBody(12).copyWith(color: AppColors.kTeal),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Premium Account:\ntolentino.roniandave@dnsc.edu.ph',
                    style: AppTypography.interBody(12).copyWith(color: AppColors.accentCyan),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Setup Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : setupAccounts,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(AppColors.kTeal),
                        ),
                      )
                    : const Icon(Icons.person_add),
                label: Text(
                  isLoading ? 'Setting up...' : 'Create Test Accounts',
                  style: AppTypography.orbitronHeading(14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentCyan,
                  foregroundColor: AppColors.deepNavy,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Status Log
            if (status.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.deepNavy,
                  border: Border.all(color: AppColors.kTeal),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 Setup Log:',
                      style: AppTypography.orbitronHeading(14),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      status,
                      style: AppTypography.interBody(11)
                          .copyWith(color: AppColors.kSuccess),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
