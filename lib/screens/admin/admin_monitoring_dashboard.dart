import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:stylesync/core/theme/app_colors.dart';
import 'package:stylesync/core/theme/app_typography.dart';
import 'package:stylesync/core/theme/glass_card.dart';
import 'package:stylesync/features/auth/presentation/providers/auth_providers.dart';

class AdminMonitoringDashboard extends ConsumerStatefulWidget {
  const AdminMonitoringDashboard({super.key});

  @override
  ConsumerState<AdminMonitoringDashboard> createState() =>
      _AdminMonitoringDashboardState();
}

class _AdminMonitoringDashboardState
    extends ConsumerState<AdminMonitoringDashboard> {
  late FirebaseFirestore _firestore;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
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
        title: Text('📊 Platform Admin Dashboard',
            style: AppTypography.orbitronHeading(18)),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome Section
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome, Admin',
                      style: AppTypography.orbitronHeading(20)),
                  const SizedBox(height: 8),
                  Text(
                    'Monitor all app activity, bookings, barbers, and revenue in real-time',
                    style: AppTypography.interBody(14)
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Key Metrics Row
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Total Bookings',
                  icon: '📅',
                  firestore: _firestore,
                  collection: 'bookings',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Active Barbers',
                  icon: '✂️',
                  firestore: _firestore,
                  collection: 'users',
                  filter: ('role', 'barber'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Total Customers',
                  icon: '👥',
                  firestore: _firestore,
                  collection: 'users',
                  filter: ('role', 'customer'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Shops Active',
                  icon: '🏪',
                  firestore: _firestore,
                  collection: 'shops',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Bookings Section
          Text('Recent Bookings',
              style: AppTypography.orbitronHeading(16)),
          const SizedBox(height: 12),
          _RecentBookingsWidget(firestore: _firestore),
          const SizedBox(height: 24),

          // Top Barbers Section
          Text('Top Barbers',
              style: AppTypography.orbitronHeading(16)),
          const SizedBox(height: 12),
          _TopBarbersWidget(firestore: _firestore),
          const SizedBox(height: 24),

          // Shop Performance Section
          Text('Shop Performance',
              style: AppTypography.orbitronHeading(16)),
          const SizedBox(height: 12),
          _ShopPerformanceWidget(firestore: _firestore),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String icon;
  final FirebaseFirestore firestore;
  final String collection;
  final (String, String)? filter;

  const _MetricCard({
    required this.title,
    required this.icon,
    required this.firestore,
    required this.collection,
    this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _fetchCount(),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        return GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 12),
                Text(count.toString(),
                    style: AppTypography.orbitronHeading(24)),
                const SizedBox(height: 4),
                Text(title,
                    style: AppTypography.interBody(12)
                        .copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<int> _fetchCount() async {
    try {
      Query query = firestore.collection(collection);

      if (filter != null) {
        query = query.where(filter!.$1, isEqualTo: filter!.$2);
      }

      final snapshot = await query.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error fetching count: $e');
      return 0;
    }
  }
}

class _RecentBookingsWidget extends StatelessWidget {
  final FirebaseFirestore firestore;

  const _RecentBookingsWidget({required this.firestore});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('bookings')
            .orderBy('createdAt', descending: true)
            .limit(5)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Text('No bookings yet',
                  style: AppTypography.interBody(14)
                      .copyWith(color: AppColors.textMuted)),
            );
          }

          return Column(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['customerName'] ?? 'Unknown',
                              style: AppTypography.interBody(13,
                                  weight: FontWeight.w600)),
                          Text('Barber: ${data['barberName'] ?? 'Unassigned'}',
                              style: AppTypography.interBody(11)
                                  .copyWith(color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(data['status'] ?? 'pending')
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        data['status']?.toUpperCase() ?? 'PENDING',
                        style: AppTypography.interBody(10,
                            weight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.accentCyan;
      case 'cancelled':
        return AppColors.accentRed;
      case 'confirmed':
        return AppColors.accentMagenta;
      default:
        return AppColors.textMuted;
    }
  }
}

class _TopBarbersWidget extends StatelessWidget {
  final FirebaseFirestore firestore;

  const _TopBarbersWidget({required this.firestore});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('users')
            .where('role', isEqualTo: 'barber')
            .orderBy('rating', descending: true)
            .limit(5)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Text('No barbers registered',
                  style: AppTypography.interBody(14)
                      .copyWith(color: AppColors.textMuted)),
            );
          }

          return Column(
            children: snapshot.data!.docs.asMap().entries.map((entry) {
              final index = entry.key;
              final doc = entry.value;
              final data = doc.data() as Map<String, dynamic>;

              return Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.accentMagenta.withValues(alpha: 0.3),
                      child: Text('${index + 1}',
                          style: AppTypography.interBody(12,
                              weight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['displayName'] ?? 'Unknown',
                              style: AppTypography.interBody(13,
                                  weight: FontWeight.w600)),
                          Text('⭐ ${data['rating'] ?? 0}/5',
                              style: AppTypography.interBody(11)
                                  .copyWith(color: AppColors.accentMagenta)),
                        ],
                      ),
                    ),
                    Text('${data['completedBookings'] ?? 0} jobs',
                        style: AppTypography.interBody(11)
                            .copyWith(color: AppColors.textMuted)),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _ShopPerformanceWidget extends StatelessWidget {
  final FirebaseFirestore firestore;

  const _ShopPerformanceWidget({required this.firestore});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('shops')
            .orderBy('totalRevenue', descending: true)
            .limit(5)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Text('No shops registered',
                  style: AppTypography.interBody(14)
                      .copyWith(color: AppColors.textMuted)),
            );
          }

          return Column(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['name'] ?? 'Unknown',
                              style: AppTypography.interBody(13,
                                  weight: FontWeight.w600)),
                          Text('${data['staffCount'] ?? 0} barbers',
                              style: AppTypography.interBody(11)
                                  .copyWith(color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₱${((data['totalRevenue'] ?? 0) as num).toStringAsFixed(0)}',
                          style: AppTypography.interBody(12,
                              weight: FontWeight.w700),
                        ),
                        Text('${data['completedBookings'] ?? 0} jobs',
                            style: AppTypography.interBody(10)
                                .copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
