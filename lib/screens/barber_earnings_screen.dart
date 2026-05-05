import 'package:flutter/material.dart';
import 'package:stylesync/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BarberEarningsScreen extends StatefulWidget {
  const BarberEarningsScreen({super.key});

  @override
  State<BarberEarningsScreen> createState() => _BarberEarningsScreenState();
}

class _BarberEarningsScreenState extends State<BarberEarningsScreen> {
  late String _uid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBg,
      appBar: AppBar(
        backgroundColor: AppColors.kBg,
        title: const Text('Earnings', style: TextStyle(color: AppColors.kText)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Total Earnings Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.kAccent,
                    AppColors.kAccent.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Earnings',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.kBg,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('bookings')
                        .where('barberId', isEqualTo: _uid)
                        .where('status', isEqualTo: 'completed')
                        .snapshots(),
                    builder: (context, snapshot) {
                      double total = 0;
                      if (snapshot.hasData) {
                        for (var doc in snapshot.data!.docs) {
                          total += (doc['totalCost'] as num?)?.toDouble() ?? 0;
                        }
                      }

                      return Text(
                        '₱${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.kBg,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Services Completed',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.kBg.withOpacity(0.8),
                            ),
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('bookings')
                                .where('barberId', isEqualTo: _uid)
                                .where('status', isEqualTo: 'completed')
                                .snapshots(),
                            builder: (context, snapshot) {
                              return Text(
                                '${snapshot.data?.docs.length ?? 0}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.kBg,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Avg Rating',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.kBg.withOpacity(0.8),
                            ),
                          ),
                          const Row(
                            children: [
                              Text(
                                '4.8',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.kBg,
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(Icons.star, size: 16, color: AppColors.kBg),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Services Breakdown
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Text(
                'SERVICES BREAKDOWN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.kMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            _buildServiceBreakdownCard('Fade Design', 12, 8400),
            _buildServiceBreakdownCard('Clean Fade', 8, 5600),
            _buildServiceBreakdownCard('Beard Trim', 15, 4500),
            _buildServiceBreakdownCard('Classic Cut', 10, 6000),

            const SizedBox(height: 32),

            // Recent Completions
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Text(
                'RECENT COMPLETIONS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.kMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .where('barberId', isEqualTo: _uid)
                  .where('status', isEqualTo: 'completed')
                  .orderBy('bookedDate', descending: true)
                  .limit(10)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppColors.kAccent),
                    ),
                  );
                }

                final completions = snapshot.data?.docs ?? [];

                if (completions.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No completions yet',
                        style: TextStyle(color: AppColors.kMuted),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: completions.length,
                  itemBuilder: (context, idx) {
                    final booking =
                        completions[idx].data() as Map<String, dynamic>;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.kCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.kBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking['serviceId'] ?? 'Service',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.kText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                booking['bookedDate'] ?? 'Today',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.kMuted,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '₱${booking['totalCost'] ?? 0}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.kGold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 32),

            // Comparison Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.kCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.kBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'vs Yesterday',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.kMuted,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '+₱450',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.kSuccess,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.trending_up,
                              size: 16, color: AppColors.kSuccess),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.kCard2,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.show_chart,
                        size: 24, color: AppColors.kAccent),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceBreakdownCard(String service, int count, int amount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.kCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.kBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.kText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$count completed',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.kMuted,
                ),
              ),
            ],
          ),
          Text(
            '₱$amount',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.kGold,
            ),
          ),
        ],
      ),
    );
  }
}
