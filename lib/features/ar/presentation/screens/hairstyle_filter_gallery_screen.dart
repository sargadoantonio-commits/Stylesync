import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/enhanced_design_system.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../models/hairstyle_filter.dart';
import '../providers/hairstyle_filter_providers.dart';

class HairstyleFilterGalleryScreen extends ConsumerStatefulWidget {
  const HairstyleFilterGalleryScreen({super.key});

  @override
  ConsumerState<HairstyleFilterGalleryScreen> createState() => _HairstyleFilterGalleryScreenState();
}

class _HairstyleFilterGalleryScreenState extends ConsumerState<HairstyleFilterGalleryScreen> {
  late TextEditingController _searchController;
  String _selectedCategory = 'all';
  String _selectedFilter = 'trending';

  final List<String> categories = ['all', 'fade', 'undercut', 'crop', 'pompadour', 'blend', 'slick'];
  final List<(String, String)> filters = [
    ('trending', 'Trending'),
    ('popular', 'Popular'),
    ('newest', 'Newest'),
    ('premium', 'Premium'),
    ('ratings', 'Top Rated'),
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtersAsync = ref.watch(_getFiltersProvider());

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        backgroundColor: AppColors.deepNavy,
        elevation: 0,
        title: Text(
          'Hairstyle Filters',
          style: AppTypography.orbitronHeading(20, weight: FontWeight.w700),
        ),
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
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.accentMagenta),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(EnhancedSpacing.lg),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(EnhancedRadius.lg),
                border: Border.all(
                  color: AppColors.accentMagenta.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: AppTypography.interBody(13).copyWith(color: AppColors.white),
                decoration: InputDecoration(
                  hintText: 'Search filters...',
                  hintStyle: AppTypography.interBody(13).copyWith(color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(EnhancedSpacing.md),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
          ),

          // Filter categories
          SizedBox(
            height: 50,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: EnhancedSpacing.lg),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == _selectedCategory;

                return Padding(
                  padding: const EdgeInsets.only(right: EnhancedSpacing.md),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = category),
                    child: AnimatedContainer(
                      duration: EnhancedAnimations.fast,
                      padding: const EdgeInsets.symmetric(
                        horizontal: EnhancedSpacing.lg,
                        vertical: EnhancedSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  AppColors.accentMagenta,
                                  AppColors.accentMagenta.withValues(alpha: 0.7),
                                ],
                              )
                            : null,
                        color: !isSelected ? AppColors.deepNavy.withValues(alpha: 0.5) : null,
                        borderRadius: BorderRadius.circular(EnhancedRadius.pill),
                        border: Border.all(
                          color: isSelected ? AppColors.accentMagenta : AppColors.accentMagenta.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          category.replaceFirst(category[0], category[0].toUpperCase()),
                          style: AppTypography.interBody(11, weight: FontWeight.w600).copyWith(
                            color: isSelected ? AppColors.white : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Sorting filters
          SizedBox(
            height: 40,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: EnhancedSpacing.lg),
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final (filterKey, filterLabel) = filters[index];
                final isSelected = filterKey == _selectedFilter;

                return Padding(
                  padding: const EdgeInsets.only(right: EnhancedSpacing.md),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filterKey),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: EnhancedSpacing.md,
                        vertical: EnhancedSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(EnhancedRadius.pill),
                        border: Border.all(
                          color: isSelected ? AppColors.accentCyan : AppColors.textMuted.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          filterLabel,
                          style: AppTypography.interBody(10, weight: FontWeight.w600).copyWith(
                            color: isSelected ? AppColors.accentCyan : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: EnhancedSpacing.lg),

          // Filters grid
          Expanded(
            child: filtersAsync.when(
              data: (allFilters) {
                final filteredFilters = _filterHairstyles(allFilters);

                if (filteredFilters.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.content_cut_rounded,
                          size: 64,
                          color: AppColors.textMuted.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: EnhancedSpacing.lg),
                        Text(
                          'No filters found',
                          style: AppTypography.interBody(14).copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(EnhancedSpacing.lg),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: EnhancedSpacing.md,
                    mainAxisSpacing: EnhancedSpacing.md,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: filteredFilters.length,
                  itemBuilder: (context, index) {
                    final filter = filteredFilters[index];
                    return _buildFilterCard(filter);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.accentMagenta),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Error loading filters: $error',
                  style: AppTypography.interBody(12).copyWith(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<HairstyleFilter> _filterHairstyles(List<HairstyleFilter> allFilters) {
    var filtered = allFilters;

    // Apply category filter
    if (_selectedCategory != 'all') {
      filtered = filtered.where((f) => f.category == _selectedCategory).toList();
    }

    // Apply search
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered
          .where((f) =>
              f.name.toLowerCase().contains(query) ||
              f.description.toLowerCase().contains(query))
          .toList();
    }

    // Apply sorting
    switch (_selectedFilter) {
      case 'popular':
        filtered.sort((a, b) => b.usageCount.compareTo(a.usageCount));
        break;
      case 'newest':
        filtered.sort((a, b) => b.createdDate.compareTo(a.createdDate));
        break;
      case 'premium':
        filtered = filtered.where((f) => f.isPremium).toList();
        break;
      case 'ratings':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'trending':
      default:
        filtered = filtered.where((f) => f.trending).toList();
        break;
    }

    return filtered;
  }

  Widget _buildFilterCard(HairstyleFilter filter) {
    return GestureDetector(
      onTap: () {
        // Select filter and navigate to AR
        ref.read(selectedHairstyleFilterProvider.notifier).selectFilter(filter);
        context.push(AppRoutes.ar);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              filter.primaryColor.withValues(alpha: 0.15),
              filter.accentColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(EnhancedRadius.lg),
          border: Border.all(
            color: filter.primaryColor.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Background circle accent
            Positioned(
              right: -15,
              top: -15,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: filter.primaryColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(EnhancedSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  Container(
                    width: double.infinity,
                    height: 80,
                    decoration: BoxDecoration(
                      color: filter.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(EnhancedRadius.md),
                      border: Border.all(
                        color: filter.primaryColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.content_cut_rounded,
                        size: 40,
                        color: filter.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: EnhancedSpacing.md),
                  // Filter name
                  Expanded(
                    child: Text(
                      filter.name,
                      style: AppTypography.interBody(12, weight: FontWeight.w600)
                          .copyWith(color: AppColors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: EnhancedSpacing.sm),
                  // Rating and badges
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        filter.rating.toString(),
                        style: AppTypography.interBody(10)
                            .copyWith(color: AppColors.textMuted),
                      ),
                      const Spacer(),
                      if (filter.isPremium)
                        const Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: Color(0xFFFFD700),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Trending badge
            if (filter.trending)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: EnhancedSpacing.sm,
                    vertical: EnhancedSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: filter.accentColor.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(EnhancedRadius.pill),
                  ),
                  child: Text(
                    'Trending',
                    style: AppTypography.interBody(8, weight: FontWeight.w700)
                        .copyWith(color: AppColors.deepNavy),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  FutureProvider<List<HairstyleFilter>> _getFiltersProvider() {
    return allHairstyleFiltersProvider;
  }
}
