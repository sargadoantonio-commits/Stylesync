import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:stylesync/core/theme/app_colors.dart';
import 'package:stylesync/core/theme/app_typography.dart';
import 'package:stylesync/core/theme/glass_card.dart';
import 'package:stylesync/features/auth/presentation/providers/auth_providers.dart';

class AdminPanel extends ConsumerStatefulWidget {
  const AdminPanel({super.key});

  @override
  ConsumerState<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends ConsumerState<AdminPanel> {
  late FirebaseFirestore _firestore;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
  }

  Future<int> _count(String collection, {String? field, dynamic value}) async {
    Query q = _firestore.collection(collection);
    if (field != null) q = q.where(field, isEqualTo: value);
    final snap = await q.get();
    return snap.docs.length;
  }

  Future<void> _promoteByEmail(BuildContext context, String email) async {
    final snack = ScaffoldMessenger.of(context);
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        snack.showSnackBar(const SnackBar(content: Text('User not found')));
        return;
      }

      final doc = query.docs.first;
      await doc.reference.update({'isAdmin': true, 'role': 'barber'});
      snack.showSnackBar(const SnackBar(content: Text('User promoted to admin')));
    } catch (e) {
      snack.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).valueOrNull;

    if (profile == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Admin Panel', style: AppTypography.orbitronHeading(18)),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Platform Overview', style: AppTypography.orbitronHeading(16)),
                        const SizedBox(height: 8),
                        Text('Quick metrics and user management', style: AppTypography.interBody(13).copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentMagenta),
                      onPressed: () async {
                        final emailCtrl = TextEditingController();
                        final result = await showDialog<String?>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Promote user to admin'),
                            content: TextField(
                              controller: emailCtrl,
                              decoration: const InputDecoration(hintText: 'user@example.com'),
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.of(ctx).pop(emailCtrl.text), child: const Text('Promote')),
                            ],
                          ),
                        );

                        if (result != null && result.trim().isNotEmpty) {
                          await _promoteByEmail(context, result.trim());
                        }
                      },
                      icon: const Icon(Icons.admin_panel_settings_rounded),
                      label: const Text('Promote by email'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Metrics row
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<int>(
                    future: _count('bookings'),
                    builder: (context, snap) {
                      final value = snap.data ?? 0;
                      return _SmallMetric(title: 'Total Bookings', value: value.toString(), icon: '📅');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FutureBuilder<int>(
                    future: _count('users', field: 'role', value: 'barber'),
                    builder: (context, snap) {
                      final value = snap.data ?? 0;
                      return _SmallMetric(title: 'Barbers', value: value.toString(), icon: '✂️');
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Users list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('users').orderBy('email').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) return const Center(child: Text('No users found'));

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>? ?? {};
                      final email = data['email'] ?? 'unknown';
                      final role = data['role'] ?? 'customer';
                      final displayName = data['displayName'] ?? '';
                      final isAdmin = data['isAdmin'] as bool? ?? false;

                      return Card(
                        color: AppColors.cardBg,
                        child: ListTile(
                          leading: CircleAvatar(child: Text(email.toString().isNotEmpty ? email[0].toUpperCase() : '?')), 
                          title: Text(email, style: AppTypography.interBody(14)),
                          subtitle: Text('$displayName • $role', style: AppTypography.interBody(12).copyWith(color: AppColors.textMuted)),
                          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                            ToggleButtons(
                              isSelected: [isAdmin],
                              onPressed: (_) async {
                                try {
                                  await doc.reference.update({'isAdmin': !isAdmin});
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${email} isAdmin: ${!isAdmin}')));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                }
                              },
                              children: const [Padding(padding: EdgeInsets.symmetric(horizontal:8.0), child: Icon(Icons.admin_panel_settings_rounded))],
                            ),
                            const SizedBox(width: 8),
                          ]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallMetric extends StatelessWidget {
  final String title;
  final String value;
  final String icon;

  const _SmallMetric({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AppTypography.interBody(12).copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 6),
              Text(value, style: AppTypography.orbitronHeading(16)),
            ])
          ],
        ),
      ),
    );
  }
}
