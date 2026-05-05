import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:go_router/go_router.dart";
import "../core/router/app_routes.dart";
import "../core/theme/app_colors.dart";
import "../core/theme/app_typography.dart";
import "../core/theme/style_button.dart";
import "../core/theme/enhanced_design_system.dart";
import "../widgets/bottom_nav_bar.dart";

class StyleLibraryScreen extends StatefulWidget {
  const StyleLibraryScreen({super.key});

  @override
  State<StyleLibraryScreen> createState() => _StyleLibraryScreenState();
}

class _StyleLibraryScreenState extends State<StyleLibraryScreen> {
  final List<String> faceShapes = ["Oval", "Square", "Round", "Diamond"];
  final List<String> hairTypes = ["Straight", "Wavy", "Curly", "Coily"];
  final List<Map<String, dynamic>> styles = [
    {
      "name": "Modern Undercut",
      "feature": "Sharp sides, long top",
      "image": "assets/haircuts/undercut.png",
      "icon": Icons.content_cut_rounded,
    },
    {
      "name": "Textured Crop",
      "feature": "Soft fringe, matte finish",
      "image": "assets/haircuts/crop.png",
      "icon": Icons.agriculture_rounded,
    },
    {
      "name": "Classic Pompadour",
      "feature": "Volume and shine",
      "image": "assets/haircuts/pompadour.png",
      "icon": Icons.auto_fix_high_rounded,
    },
    {
      "name": "Skin Fade",
      "feature": "Smooth low fade",
      "image": "assets/haircuts/fade.png",
      "icon": Icons.zoom_out_map_rounded,
    },
    {
      "name": "Beard Blend",
      "feature": "Clean jawline",
      "image": "assets/haircuts/beard.png",
      "icon": Icons.face_rounded,
    },
  ];

  String _selectedFaceShape = "Oval";
  String _selectedHairType = "Straight";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      bottomNavigationBar: const BottomNavBar(currentRoute: AppRoutes.styleLibrary),
      appBar: AppBar(
        backgroundColor: AppColors.deepNavy,
        elevation: 0,
        title: Text("Style Library", style: AppTypography.orbitronHeading(20, weight: FontWeight.w700)),
        leading: Container(
          margin: const EdgeInsets.only(left: EnhancedSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.accentMagenta.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(EnhancedRadius.md),
            border: Border.all(
              color: AppColors.accentMagenta.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.accentMagenta),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 150,
            child: Container(
              decoration: BoxDecoration(
                gradient: EnhancedGradients.magentaToTransparent,
              ),
            ),
          ),
          ListView(
            padding: const EdgeInsets.all(EnhancedSpacing.xl),
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: EnhancedGradients.magentaPrimary,
                  borderRadius: BorderRadius.circular(EnhancedRadius.lg),
                  border: Border.all(
                    color: AppColors.accentMagenta.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                  boxShadow: EnhancedShadows.md,
                ),
                padding: const EdgeInsets.all(EnhancedSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: EnhancedSpacing.md,
                          vertical: EnhancedSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.accentMagenta.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(EnhancedRadius.pill),
                        border: Border.all(
                          color: AppColors.accentMagenta.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        "BROWSE STYLES",
                        style: AppTypography.interBody(10, weight: FontWeight.w700)
                            .copyWith(color: AppColors.accentMagenta),
                      ),
                    ),
                    const SizedBox(height: EnhancedSpacing.md),
                    Text("Filter by face shape, hair type, and trending looks.",
                        style: AppTypography.interBody(13)
                            .copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
              const SizedBox(height: EnhancedSpacing.xl),
              _buildFilterSection("Face shape", faceShapes, _selectedFaceShape,
                  (value) => setState(() => _selectedFaceShape = value)),
              const SizedBox(height: EnhancedSpacing.lg),
              _buildFilterSection("Hair type", hairTypes, _selectedHairType,
                  (value) => setState(() => _selectedHairType = value)),
              const SizedBox(height: EnhancedSpacing.xl),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: EnhancedSpacing.md,
                  mainAxisSpacing: EnhancedSpacing.md,
                  childAspectRatio: 0.7,
                ),
                itemCount: styles.length,
                itemBuilder: (context, index) {
                  final style = styles[index];
                  final colors = [
                    AppColors.accentMagenta,
                    AppColors.accentCyan,
                    AppColors.accentGold,
                    AppColors.accentMagenta,
                    AppColors.accentCyan,
                  ];
                  final accentColor = colors[index % colors.length];

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentColor.withValues(alpha: 0.12),
                            accentColor.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(EnhancedRadius.lg),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.25),
                          width: 1.2,
                        ),
                        boxShadow: EnhancedShadows.md,
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -15,
                            top: -15,
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(EnhancedSpacing.md),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Haircut Image/Icon Display
                                Container(
                                  width: double.infinity,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(EnhancedRadius.md),
                                    border: Border.all(
                                      color:
                                          accentColor.withValues(alpha: 0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(EnhancedRadius.md),
                                    child: Stack(
                                      children: [
                                        // Gradient background for haircut
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                accentColor.withValues(alpha: 0.15),
                                                accentColor.withValues(alpha: 0.05),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Try to load image, with gradient fallback
                                        Image.asset(
                                          style["image"] ?? "",
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            // Fallback: gradient + icon
                                            return Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    accentColor.withValues(alpha: 0.25),
                                                    accentColor.withValues(alpha: 0.08),
                                                  ],
                                                ),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  style["icon"] ??
                                                      Icons.content_cut_rounded,
                                                  size: 48,
                                                  color: accentColor,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: EnhancedSpacing.lg),
                                // Style Name
                                Text(
                                  style["name"]!,
                                  style: AppTypography.interBody(13,
                                          weight: FontWeight.w600)
                                      .copyWith(color: AppColors.white),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: EnhancedSpacing.sm),
                                // Feature Description
                                Text(
                                  style["feature"]!,
                                  style: AppTypography.interBody(11)
                                      .copyWith(color: AppColors.textMuted),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: EnhancedSpacing.lg),
                                // Try AR Button
                                SizedBox(
                                  height: 36,
                                  width: double.infinity,
                                  child: StyleButton(
                                    label: "Try AR",
                                    icon: Icons.camera_alt_rounded,
                                    onPressed: () =>
                                        context.push(AppRoutes.ar),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: EnhancedSpacing.section),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options,
      String selectedValue, ValueChanged<String> onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: EnhancedSpacing.sm),
          child: Text(title,
              style: AppTypography.orbitronHeading(14, weight: FontWeight.w700)
                  .copyWith(color: AppColors.white)),
        ),
        const SizedBox(height: EnhancedSpacing.md),
        Wrap(
          spacing: EnhancedSpacing.md,
          runSpacing: EnhancedSpacing.md,
          children: options.map((option) {
            final isSelected = option == selectedValue;
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onSelected(option);
              },
              child: AnimatedContainer(
                duration: EnhancedAnimations.fast,
                padding: const EdgeInsets.symmetric(
                    horizontal: EnhancedSpacing.lg,
                    vertical: EnhancedSpacing.md),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            AppColors.accentMagenta.withValues(alpha: 0.9),
                            AppColors.accentMagenta.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [
                            AppColors.deepNavy.withValues(alpha: 0.6),
                            AppColors.deepNavy.withValues(alpha: 0.4),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(EnhancedRadius.pill),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentMagenta.withValues(alpha: 0.5)
                        : AppColors.textMuted.withValues(alpha: 0.15),
                    width: 1.2,
                  ),
                  boxShadow: isSelected ? EnhancedShadows.lg : EnhancedShadows.sm,
                ),
                child: AnimatedScale(
                  scale: isSelected ? 1.05 : 1.0,
                  duration: EnhancedAnimations.fast,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(option,
                          style: AppTypography.interBody(13,
                                  weight: FontWeight.w600)
                              .copyWith(
                                  color: isSelected
                                      ? AppColors.white
                                      : AppColors.textMuted)),
                      if (isSelected) ...
                        [
                          const SizedBox(width: EnhancedSpacing.xs),
                          const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: AppColors.white,
                          ),
                        ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
