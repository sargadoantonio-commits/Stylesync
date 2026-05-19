import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "../core/theme/app_colors.dart";
import "../core/theme/app_typography.dart";
import "../core/theme/responsive_helper.dart";
import "../core/theme/style_button.dart";
import "../core/theme/glass_card.dart";
import "../widgets/section_pill_badge.dart";
import '../features/shop/presentation/providers/shop_providers.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen>
    with SingleTickerProviderStateMixin {
  static const String kShopName = "Kings Cut Studio";
  static const String kShopAddr = "456 Style Avenue, Downtown";
  final List<String> barbers = ["Jamie", "Noah", "Ari"];
  final List<String> services = [
    "Classic Cut",
    "Skin Fade",
    "Beard Sculpt",
    "Shampoo + Style"
  ];

  String? _selectedBarber;
  String? _selectedService;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _confirmed = false;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accentRed,
            onPrimary: AppColors.white,
            surface: AppColors.card,
            onSurface: AppColors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 14, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          timePickerTheme: const TimePickerThemeData(
            dialHandColor: AppColors.accentRed,
            hourMinuteColor: AppColors.card,
            dayPeriodColor: AppColors.card,
          ),
        ),
        child: child!,
      ),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _confirmBooking() async {
    if (_selectedBarber == null ||
        _selectedService == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please select barber, service, date, and time.")),
      );
      return;
    }

    setState(() {
      _confirmed = true;
    });

    // Persist booking to Firestore
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      // Try to get selected shop id from app state (fallback: first shop in DB)
      String? shopId = ref.read(selectedShopIdProvider);
      if (shopId == null) {
        final firstShopSnap = await FirebaseFirestore.instance
            .collection('shops')
            .limit(1)
            .get();
        if (firstShopSnap.docs.isNotEmpty) shopId = firstShopSnap.docs.first.id;
      }

      if (shopId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No shop selected. Please select a shop.')),
        );
        setState(() {
          _confirmed = false;
        });
        return;
      }
      final bookedDateStr = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2,'0')}-${_selectedDate!.day.toString().padLeft(2,'0')}";
      final bookedTimeStr = _selectedTime!.format(context);
      // Lookup shop info for display and persistence
      final shopDoc = await FirebaseFirestore.instance.collection('shops').doc(shopId).get();
      final shopName = shopDoc.data()?['name'] ?? kShopName;
      final shopAddr = shopDoc.data()?['address'] ?? kShopAddr;

      final data = {
        'shopId': shopId,
        'shopName': shopName,
        'shopAddr': shopAddr,
        'customerId': uid,
        'serviceId': _selectedService,
        'barberId': _selectedBarber,
        'bookedDate': bookedDateStr,
        'bookedTime': bookedTimeStr,
        'totalCost': 500,
        'status': 'upcoming',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add document to bookings collection
      FirebaseFirestore.instance.collection('bookings').add(data).then((docRef) {
        final referenceCode = 'SS-${docRef.id.substring(0,5).toUpperCase()}';
        // Save referenceCode on the booking doc
        docRef.update({'referenceCode': referenceCode});

        // Navigate to confirmation screen with extras
        context.push('/booking/confirmed', extra: {
          'referenceCode': referenceCode,
          'barber': _selectedBarber,
          'service': _selectedService,
          'price': 500.0,
          'date': _selectedDate,
          'time': bookedTimeStr,
          'shopName': shopName,
          'shopAddr': shopAddr,
        });
      }).catchError((err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create booking: $err')),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Booking confirmed with $_selectedBarber at $shopName on ${_selectedDate!.month}/${_selectedDate!.day} at ${_selectedTime!.format(context)}.",
          ),
          backgroundColor: AppColors.accentRed,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving booking: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsivePadding = ResponsiveHelper.getResponsivePadding(context);
    final responsiveSpacing =
        ResponsiveHelper.getResponsiveSpacing(context, 16);
    final responsiveButtonHeight =
        ResponsiveHelper.getResponsiveButtonHeight(context);

    // Calculate current step (1-4)
    int currentStep = 1;
    if (_selectedBarber != null) currentStep = 2;
    if (_selectedService != null) currentStep = 3;
    if (_selectedDate != null && _selectedTime != null) currentStep = 4;

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        backgroundColor: AppColors.deepNavy,
        title:
            Text("Book Appointment", style: AppTypography.orbitronHeading(18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.accentMagenta),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(responsivePadding),
        children: [
          // Step Indicator
          Padding(
            padding: EdgeInsets.only(bottom: responsiveSpacing),
            child: Row(
              children: List.generate(4, (index) {
                final stepNum = index + 1;
                final isCompleted = stepNum < currentStep;
                final isActive = stepNum == currentStep;
                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted || isActive
                              ? AppColors.accentMagenta
                              : AppColors.card,
                          border: Border.all(
                            color: isActive
                                ? AppColors.accentMagenta
                                : AppColors.textMuted.withOpacity(0.3),
                            width: isActive ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check,
                                  color: AppColors.white, size: 20)
                              : Text(
                                  '$stepNum',
                                  style: AppTypography.interBody(14,
                                          weight: FontWeight.w700)
                                      .copyWith(
                                    color: isActive
                                        ? AppColors.white
                                        : AppColors.textMuted,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ['Shop', 'Barber', 'Service', 'Date'][index],
                        style: AppTypography.interBody(11).copyWith(
                          color: isActive
                              ? AppColors.accentMagenta
                              : AppColors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: responsiveSpacing),
          GlassCard(
            child: Padding(
              padding: EdgeInsets.all(responsivePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionPillBadge(label: "Appointment"),
                  SizedBox(height: responsiveSpacing * 0.6),
                  Text("Select a shop, barber, service, and schedule a time.",
                      style: AppTypography.interBody(14)
                          .copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
          SizedBox(height: responsiveSpacing),
          // Shop selection
          GlassCard(
            child: Padding(
              padding: EdgeInsets.all(responsivePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionPillBadge(label: "Shop"),
                  SizedBox(height: responsiveSpacing * 0.6),
                  Builder(builder: (ctx) {
                    final shopsAsync = ref.watch(allShopsProvider);
                    final selectedShopId = ref.watch(selectedShopIdProvider);
                    return shopsAsync.when(
                      data: (shops) {
                        if (shops.isEmpty) {
                          // Provide a fallback choice for development/testing: Elcorte
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (ref.read(selectedShopIdProvider) == null) {
                              ref.read(selectedShopIdProvider.notifier).state = 'elcorte';
                            }
                          });

                          final isSelected = selectedShopId == 'elcorte';
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('No shops available',
                                  style: AppTypography.interBody(12)
                                      .copyWith(color: AppColors.kMuted)),
                              SizedBox(height: responsiveSpacing * 0.5),
                              Wrap(
                                children: [
                                  ChoiceChip(
                                    label: const Text('Elcorte'),
                                    selected: isSelected,
                                    selectedColor: AppColors.accentMagenta,
                                    backgroundColor: AppColors.card,
                                    onSelected: (_) {
                                      ref.read(selectedShopIdProvider.notifier).state = 'elcorte';
                                    },
                                  ),
                                ],
                              ),
                            ],
                          );
                        }

                        // Ensure selectedShopId defaults to first shop if null
                        if (selectedShopId == null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ref
                                .read(selectedShopIdProvider.notifier)
                                .state = shops.first.shopId;
                          });
                        }

                        final selected = shops.firstWhere(
                            (s) => s.shopId == selectedShopId,
                            orElse: () => shops.first);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.store_outlined,
                                    color: AppColors.accentMagenta, size: 20),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(selected.name ?? kShopName,
                                        style: AppTypography.orbitronHeading(14)
                                            .copyWith(color: AppColors.kText)),
                                    Text(selected.address ?? kShopAddr,
                                        style: AppTypography.interBody(12)
                                            .copyWith(color: AppColors.kMuted)),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: responsiveSpacing * 0.75),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: shops.map((shop) {
                                  final isSelected = shop.shopId == selected.shopId;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        right: responsiveSpacing * 0.5),
                                    child: ChoiceChip(
                                      label: Text(shop.name ?? 'Shop'),
                                      selected: isSelected,
                                      selectedColor: AppColors.accentMagenta,
                                      backgroundColor: AppColors.card,
                                      onSelected: (_) {
                                        ref
                                            .read(selectedShopIdProvider
                                                .notifier)
                                            .state = shop.shopId;
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const SizedBox(
                          height: 40,
                          child: Center(child: CircularProgressIndicator())),
                      error: (e, st) => Text('Failed to load shops',
                          style: AppTypography.interBody(12)
                              .copyWith(color: AppColors.kMuted)),
                    );
                  }),
                ],
              ),
            ),
          ),
          SizedBox(height: responsiveSpacing * 0.75),
          _buildSection("Barber", barbers, _selectedBarber,
              (value) => setState(() => _selectedBarber = value), context),
          SizedBox(height: responsiveSpacing * 0.75),
          _buildSection("Service", services, _selectedService,
              (value) => setState(() => _selectedService = value), context),
          SizedBox(height: responsiveSpacing * 0.75),
          GlassCard(
            child: Padding(
              padding: EdgeInsets.all(responsivePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("Date & Time", style: AppTypography.orbitronHeading(14)),
                  SizedBox(height: responsiveSpacing),
                  ResponsiveHelper.isSmallDevice(context)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OutlinedButton(
                              onPressed: _pickDate,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppColors.kBorder, width: 1.5),
                                foregroundColor: AppColors.accentMagenta,
                                minimumSize: Size.fromHeight(
                                    responsiveButtonHeight * 0.8),
                              ),
                              child: Text(_selectedDate == null
                                  ? "Pick date"
                                  : "${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}"),
                            ),
                            SizedBox(height: responsiveSpacing * 0.75),
                            OutlinedButton(
                              onPressed: _pickTime,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppColors.kBorder, width: 1.5),
                                foregroundColor: AppColors.accentMagenta,
                                minimumSize: Size.fromHeight(
                                    responsiveButtonHeight * 0.8),
                              ),
                              child: Text(_selectedTime == null
                                  ? "Pick time"
                                  : _selectedTime!.format(context)),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _pickDate,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: AppColors.kBorder, width: 1.5),
                                  foregroundColor: AppColors.accentMagenta,
                                ),
                                child: Text(_selectedDate == null
                                    ? "Pick date"
                                    : "${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}"),
                              ),
                            ),
                            SizedBox(width: responsiveSpacing * 0.75),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _pickTime,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: AppColors.kBorder, width: 1.5),
                                  foregroundColor: AppColors.accentMagenta,
                                ),
                                child: Text(_selectedTime == null
                                    ? "Pick time"
                                    : _selectedTime!.format(context)),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
          SizedBox(height: responsiveSpacing * 1.5),
          if (_confirmed)
            GlassCard(
              child: Padding(
                padding: EdgeInsets.all(responsivePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Upcoming Booking",
                        style: AppTypography.orbitronHeading(14)),
                    SizedBox(height: responsiveSpacing * 0.6),
                    Text("$_selectedService with $_selectedBarber",
                        style: AppTypography.interBody(15)
                            .copyWith(color: AppColors.white)),
                    SizedBox(height: responsiveSpacing * 0.4),
                    Text(kShopName,
                        style: AppTypography.interBody(13)
                            .copyWith(color: AppColors.textMuted)),
                    SizedBox(height: responsiveSpacing * 0.4),
                    Text(
                        "${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year} • ${_selectedTime!.format(context)}",
                        style: AppTypography.interBody(13)
                            .copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
          SizedBox(height: responsiveSpacing * 1.25),
          // Price Summary
          if (_selectedService != null)
            GlassCard(
              child: Padding(
                padding: EdgeInsets.all(responsivePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Price Summary",
                        style: AppTypography.orbitronHeading(14)),
                    SizedBox(height: responsiveSpacing * 0.75),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_selectedService!,
                            style: AppTypography.interBody(13)
                                .copyWith(color: AppColors.textMuted)),
                        Text("₱500",
                            style: AppTypography.interBody(13,
                                    weight: FontWeight.w600)
                                .copyWith(color: AppColors.white)),
                      ],
                    ),
                    SizedBox(height: responsiveSpacing * 0.5),
                    const Divider(color: AppColors.kBorder),
                    SizedBox(height: responsiveSpacing * 0.5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total",
                            style: AppTypography.orbitronHeading(14)
                                .copyWith(color: AppColors.white)),
                        Text("₱500",
                            style: AppTypography.orbitronHeading(14)
                                .copyWith(
                                    color: AppColors.accentMagenta,
                                    fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: responsiveSpacing),
          SizedBox(
            height: responsiveButtonHeight,
            child: StyleButton(
              label: "Confirm booking",
              icon: Icons.event_available_rounded,
              onPressed: _confirmBooking,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> options, String? selected,
      ValueChanged<String> onSelected, BuildContext context) {
    final responsivePadding = ResponsiveHelper.getResponsivePadding(context);
    final responsiveSpacing =
        ResponsiveHelper.getResponsiveSpacing(context, 12);

    return GlassCard(
      child: Padding(
        padding: EdgeInsets.all(responsivePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.orbitronHeading(14)),
            SizedBox(height: responsiveSpacing),
            Wrap(
              spacing: responsiveSpacing * 0.8,
              runSpacing: responsiveSpacing * 0.8,
              children: options.map((option) {
                final isSelected = option == selected;
                return ChoiceChip(
                  label: Text(option,
                      style: AppTypography.interBody(13).copyWith(
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textPrimary)),
                  selected: isSelected,
                  selectedColor: AppColors.accentMagenta,
                  backgroundColor: AppColors.card,
                  onSelected: (_) => onSelected(option),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
