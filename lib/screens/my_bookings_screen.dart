import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stylesync/core/theme/app_colors.dart';
import 'package:stylesync/core/constants.dart' as _flags;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/bottom_nav_bar.dart';
import '../core/router/app_routes.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: AppColors.kBg,
      bottomNavigationBar: const BottomNavBar(currentRoute: AppRoutes.myBookings),
      appBar: AppBar(
        backgroundColor: AppColors.kBg,
        title:
            const Text('My Bookings', style: TextStyle(color: AppColors.kText)),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.kAccent,
          indicatorWeight: 3,
          labelColor: AppColors.kAccent,
          unselectedLabelColor: AppColors.kMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Upcoming
          _buildBookingsList(uid, 'upcoming'),
          // Completed
          _buildBookingsList(uid, 'completed'),
          // Cancelled
          _buildBookingsList(uid, 'cancelled'),
        ],
      ),
    );
  }

  Widget _buildBookingsList(String uid, String status) {
    if (_flags.kUseDemoBarberUI) {
      final demo = [
        {
          'referenceCode': 'SS-10001',
          'serviceId': 'Fade + Design',
          'barberId': 'Jay Barber',
          'bookedDate': 'May 20, 2026',
          'bookedTime': '10:00 AM',
          'totalCost': 550,
          'status': 'upcoming'
        },
        {
          'referenceCode': 'SS-10002',
          'serviceId': 'Beard Trim',
          'barberId': 'Mike Santos',
          'bookedDate': 'May 10, 2026',
          'bookedTime': '2:30 PM',
          'totalCost': 200,
          'status': 'completed'
        },
        {
          'referenceCode': 'SS-10003',
          'serviceId': 'Classic Cut',
          'barberId': 'Carlo Reyes',
          'bookedDate': 'Apr 28, 2026',
          'bookedTime': '11:00 AM',
          'totalCost': 350,
          'status': 'cancelled'
        },
      ].where((b) => b['status'] == status).toList();

      if (demo.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 56, color: AppColors.kMuted),
              const SizedBox(height: 16),
              Text(
                'No $status bookings',
                style: const TextStyle(color: AppColors.kMuted, fontSize: 14),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        itemCount: demo.length,
        itemBuilder: (context, index) {
          final booking = demo[index] as Map<String, dynamic>;
          final referenceCode = booking['referenceCode'] as String? ?? 'SS-XXXXX';
          final serviceId = booking['serviceId'] as String? ?? 'Unknown Service';
          final barberId = booking['barberId'] as String? ?? 'Unknown Barber';
          final bookedDate = booking['bookedDate'] as String? ?? 'Unknown Date';
          final bookedTime = booking['bookedTime'] as String? ?? 'Unknown Time';
          final totalCost = (booking['totalCost'] as num?)?.toInt() ?? 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.kCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.kBorder),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            serviceId,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.kText,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.kCard2,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              referenceCode,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.kGold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Barber: $barberId',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.kMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 14, color: AppColors.kAccent),
                          const SizedBox(width: 6),
                          Text(
                            bookedDate,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.kText,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.access_time_outlined,
                              size: 14, color: AppColors.kAccent),
                          const SizedBox(width: 6),
                          Text(
                            bookedTime,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.kText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.kMuted,
                            ),
                          ),
                          Text(
                            '₱$totalCost',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.kGold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 0,
                  color: AppColors.kBorder,
                  thickness: 1,
                ),
                SizedBox(
                  height: 42,
                  child: Row(
                    children: [
                      if (status == 'upcoming')
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Reschedule feature coming soon'),
                                  backgroundColor: AppColors.kMuted,
                                ),
                              );
                            },
                            child: const Text(
                              'Reschedule',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.kAccent,
                              ),
                            ),
                          ),
                        )
                      else if (status == 'completed')
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              context.push('/booking');
                            },
                            child: const Text(
                              'Rebook',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.kAccent,
                              ),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              context.push('/booking');
                            },
                            child: const Text(
                              'New Booking',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.kAccent,
                              ),
                            ),
                          ),
                        ),
                      if (status == 'upcoming')
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: AppColors.kCard,
                                  title: const Text(
                                    'Cancel Booking?',
                                    style: TextStyle(color: AppColors.kText),
                                  ),
                                  content: const Text(
                                    'Are you sure you want to cancel this booking?',
                                    style: TextStyle(color: AppColors.kMuted),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => ctx.pop(),
                                      child: const Text('No',
                                          style: TextStyle(
                                              color: AppColors.kAccent)),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        ctx.pop();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text(
                                              'Demo: booking cancelled locally'),
                                          backgroundColor: AppColors.kMuted,
                                        ));
                                      },
                                      child: const Text('Cancel Booking',
                                          style: TextStyle(
                                              color: AppColors.kDanger)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.kDanger,
                              ),
                            ),
                          ),
                        )
                      else if (status == 'completed')
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Review feature coming soon'),
                                  backgroundColor: AppColors.kMuted,
                                ),
                              );
                            },
                            child: const Text(
                              'Review',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.kAccent,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    // Fallback: live Firestore stream
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('customerId', isEqualTo: uid)
          .where('status', isEqualTo: status)
          .orderBy('bookedDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.kAccent),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}',
                style: const TextStyle(color: AppColors.kMuted)),
          );
        }

        final bookings = snapshot.data?.docs ?? [];

        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 56, color: AppColors.kMuted),
                const SizedBox(height: 16),
                Text(
                  'No $status bookings',
                  style: const TextStyle(color: AppColors.kMuted, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
              final booking = bookings[index].data() as Map<String, dynamic>;
              final referenceCode = booking['referenceCode'] as String? ?? 'SS-XXXXX';
              final serviceId = booking['serviceId'] as String? ?? 'Unknown Service';
              final barberId = booking['barberId'] as String? ?? 'Unknown Barber';
              final bookedDate = booking['bookedDate'] as String? ?? 'Unknown Date';
              final bookedTime = booking['bookedTime'] as String? ?? 'Unknown Time';
              final totalCost = (booking['totalCost'] as num?)?.toInt() ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.kCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.kBorder),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with reference code
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              serviceId,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.kText,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.kCard2,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                referenceCode,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.kGold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Barber: $barberId',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.kMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Shop: ${booking['shopName'] ?? 'Unknown Shop'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.kMuted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Date and time
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 14, color: AppColors.kAccent),
                            const SizedBox(width: 6),
                            Text(
                              bookedDate,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.kText,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.access_time_outlined,
                                size: 14, color: AppColors.kAccent),
                            const SizedBox(width: 6),
                            Text(
                              bookedTime,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.kText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.kMuted,
                              ),
                            ),
                            Text(
                              '₱$totalCost',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.kGold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 0,
                    color: AppColors.kBorder,
                    thickness: 1,
                  ),
                  // Action buttons
                  SizedBox(
                    height: 42,
                    child: Row(
                      children: [
                        if (status == 'upcoming')
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                // Reschedule booking
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Reschedule feature coming soon'),
                                    backgroundColor: AppColors.kMuted,
                                  ),
                                );
                              },
                              child: const Text(
                                'Reschedule',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.kAccent,
                                ),
                              ),
                            ),
                          )
                        else if (status == 'completed')
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                context.push('/booking');
                              },
                              child: const Text(
                                'Rebook',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.kAccent,
                                ),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                context.push('/booking');
                              },
                              child: const Text(
                                'New Booking',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.kAccent,
                                ),
                              ),
                            ),
                          ),
                        if (status == 'upcoming')
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                // Cancel booking
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: AppColors.kCard,
                                    title: const Text(
                                      'Cancel Booking?',
                                      style: TextStyle(color: AppColors.kText),
                                    ),
                                    content: const Text(
                                      'Are you sure you want to cancel this booking?',
                                      style: TextStyle(color: AppColors.kMuted),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => ctx.pop(),
                                        child: const Text('No',
                                            style: TextStyle(
                                                color: AppColors.kAccent)),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection('bookings')
                                              .doc(bookings[index].id)
                                              .update({'status': 'cancelled'})
                                              .then((_) {
                                            ctx.pop();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Booking cancelled'),
                                              backgroundColor:
                                                  AppColors.kMuted,
                                            ));
                                          }).catchError((err) {
                                            ctx.pop();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text(
                                                  'Failed to cancel booking: $err'),
                                              backgroundColor:
                                                  AppColors.kDanger,
                                            ));
                                          });
                                        },
                                        child: const Text('Cancel Booking',
                                            style: TextStyle(
                                                color: AppColors.kDanger)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.kDanger,
                                ),
                              ),
                            ),
                          )
                        else if (status == 'completed')
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                // Leave review
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Review feature coming soon'),
                                    backgroundColor: AppColors.kMuted,
                                  ),
                                );
                              },
                              child: const Text(
                                'Review',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.kAccent,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
