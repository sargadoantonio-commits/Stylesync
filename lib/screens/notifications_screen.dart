import "package:flutter/material.dart";
import "../core/theme/app_colors.dart";
import "../core/theme/app_typography.dart";
import "../core/theme/glass_card.dart";
import "../core/router/app_routes.dart";
import "../widgets/section_pill_badge.dart";
import "../widgets/bottom_nav_bar.dart";

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _reminders = true;
  bool _queueAlerts = true;
  bool _arRecommendations = false;

  final List<Map<String, dynamic>> notifications = [
    {
      "title": "Queue update",
      "subtitle": "You're 2 spots closer to your barber.",
      "type": "queue",
      "timestamp": 15
    },
    {
      "title": "Booking reminder",
      "subtitle": "Your appointment is tomorrow at 3:00 PM.",
      "type": "booking",
      "timestamp": 120
    },
    {
      "title": "AR suggestion",
      "subtitle": "New look matches your face shape.",
      "type": "ar",
      "timestamp": 240
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      bottomNavigationBar: const BottomNavBar(currentRoute: AppRoutes.notifications),
      appBar: AppBar(
        backgroundColor: AppColors.deepNavy,
        title: Text("Notifications", style: AppTypography.orbitronHeading(18)),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionPillBadge(label: "Settings"),
                  const SizedBox(height: 10),
                  Text("Control the alerts you receive from StyleSync.",
                      style: AppTypography.interBody(14)
                          .copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text("Appointment reminders",
                      style: AppTypography.interBody(14)
                          .copyWith(color: AppColors.white)),
                  value: _reminders,
                  activeThumbColor: AppColors.accentMagenta,
                  onChanged: (value) => setState(() => _reminders = value),
                ),
                const Divider(color: AppColors.card),
                SwitchListTile(
                  title: Text("Queue updates",
                      style: AppTypography.interBody(14)
                          .copyWith(color: AppColors.white)),
                  value: _queueAlerts,
                  activeThumbColor: AppColors.accentMagenta,
                  onChanged: (value) => setState(() => _queueAlerts = value),
                ),
                const Divider(color: AppColors.card),
                SwitchListTile(
                  title: Text("AR recommendations",
                      style: AppTypography.interBody(14)
                          .copyWith(color: AppColors.white)),
                  value: _arRecommendations,
                  activeThumbColor: AppColors.accentMagenta,
                  onChanged: (value) =>
                      setState(() => _arRecommendations = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionPillBadge(label: "Recent alerts"),
          const SizedBox(height: 12),
          ...notifications.map((notification) {
            final type = notification["type"] as String;
            final timestamp = notification["timestamp"] as int;
            final borderColor = type == "queue"
                ? AppColors.accentMagenta
                : type == "booking"
                    ? AppColors.accentGold
                    : AppColors.accentCyan;
            final timeStr = timestamp < 60
                ? "${timestamp}m ago"
                : "${(timestamp / 60).floor()}h ago";

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.kBorder, width: 1),
                  color: AppColors.card,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 80,
                      decoration: BoxDecoration(
                        color: borderColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(13),
                          bottomLeft: Radius.circular(13),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notification["title"] as String,
                                style: AppTypography.interBody(15,
                                    weight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(notification["subtitle"] as String,
                                style: AppTypography.interBody(13)
                                    .copyWith(color: AppColors.textMuted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 6),
                            Text(timeStr,
                                style: AppTypography.interBody(11)
                                    .copyWith(color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.chevron_right,
                          color: AppColors.textMuted, size: 20),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
