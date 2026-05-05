import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:lottie/lottie.dart";

import "package:stylesync/core/theme/app_colors.dart";
import "package:stylesync/core/theme/app_typography.dart";
import "package:stylesync/core/theme/style_button.dart";
import "package:stylesync/features/barbers/presentation/providers/barber_providers.dart";
import "package:stylesync/features/queue/presentation/queue_providers.dart";
import "../domain/service_models.dart";
import "providers/service_providers.dart";
import "package:stylesync/core/formatters/ph_formatters.dart";

class PaymentOverlay extends ConsumerStatefulWidget {
  const PaymentOverlay({super.key, required this.service});
  final ServiceDoc service;

  @override
  ConsumerState<PaymentOverlay> createState() => _PaymentOverlayState();
}

class _PaymentOverlayState extends ConsumerState<PaymentOverlay> {
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    final barberAsync = ref.watch(barberByIdProvider(widget.service.barberId));
    final _ = ref.watch(defaultShopIdProvider);

    return Material(
      color: Colors.black.withValues(alpha: 0.62),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: AppColors.accentRed.withValues(alpha: 0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentRed.withValues(alpha: 0.18),
                      blurRadius: 28,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: barberAsync.when(
                    loading: () =>
                        _body(context, gcashQrUrl: "", barberName: "Loading�"),
                    error: (e, _) => _body(context,
                        gcashQrUrl: "", barberName: e.toString()),
                    data: (barber) => _body(
                      context,
                      gcashQrUrl: barber?.gcashQrUrl ?? "",
                      barberName: barber?.name.isNotEmpty == true
                          ? barber!.name
                          : "Your Barber",
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context,
      {required String gcashQrUrl, required String barberName}) {
    final amount = widget.service.amount;
    final isConfirmed = widget.service.status == ServiceStatus.paymentConfirmed;
    final isSent = widget.service.status == ServiceStatus.paymentSent || _sent;

    if (isConfirmed) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset("assets/lottie/sharp_look.json", repeat: false),
          const SizedBox(height: 8),
          Text("Sharp Look!", style: AppTypography.orbitronHeading(20)),
          const SizedBox(height: 6),
          Text(
            "Payment confirmed.",
            style: AppTypography.interBody(14)
                .copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          StyleButton(
            label: "Close",
            icon: Icons.check_rounded,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.qr_code_rounded, color: AppColors.accentRed),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Pay via GCash",
                style: AppTypography.orbitronHeading(18),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Send exactly ${PhFormatters.peso(amount)} to $barberName.",
          style: AppTypography.interBody(14),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: const BoxDecoration(color: AppColors.background),
              child: gcashQrUrl.isEmpty
                  ? Center(
                      child: Text(
                        "GCash QR not set yet.",
                        style: AppTypography.interBody(13)
                            .copyWith(color: AppColors.textMuted),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Image.network(
                      gcashQrUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          "Unable to load QR.",
                          style: AppTypography.interBody(13)
                              .copyWith(color: AppColors.textMuted),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        StyleButton(
          label: isSent ? "Payment sent (waiting)" : "Payment Sent",
          icon: isSent ? Icons.hourglass_top_rounded : Icons.send_rounded,
          onPressed: isSent
              ? null
              : () async {
                  await ref.read(serviceRepositoryProvider).customerPaymentSent(
                        widget.service.shopId,
                        widget.service.id,
                      );

                  if (!mounted) return;
                  setState(() => _sent = true);
                },
        ),
        const SizedBox(height: 10),
        Text(
          "After you tap Payment Sent, your barber will confirm receipt.",
          style:
              AppTypography.interBody(13).copyWith(color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
