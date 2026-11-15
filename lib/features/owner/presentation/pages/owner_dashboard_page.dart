import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di/injection.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/entities/owner_listing_item.dart';
import '../bloc/owner_dashboard_bloc.dart';
import '../bloc/verification_bloc.dart';

/// Owner dashboard and "My listings" screen.
/// Traceability: REQ-027, REQ-028, REQ-029, SCR-013, API-027, API-035, API-036, API-040, API-041.
class OwnerDashboardPage extends StatelessWidget {
  const OwnerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OwnerDashboardBloc>(
          create: (_) => sl<OwnerDashboardBloc>()..add(const FetchOwnerDashboardData()),
        ),
        BlocProvider<VerificationBloc>(
          create: (_) => sl<VerificationBloc>()..add(const FetchVerificationDocumentsEvent()),
        ),
      ],
      child: const _OwnerDashboardView(),
    );
  }
}

class _OwnerDashboardView extends StatelessWidget {
  const _OwnerDashboardView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.dashboardTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.verified_user_outlined),
            tooltip: l10n.verificationTitle,
            onPressed: () => _showVerificationDialog(context, l10n),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<OwnerDashboardBloc>().add(const FetchOwnerDashboardData());
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/listings/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.postNewAd),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<OwnerDashboardBloc, OwnerDashboardState>(
        listener: (context, state) {
          if (state is OwnerDashboardLoaded && state.actionSuccessMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.actionSuccessMessage!)),
            );
          }
        },
        builder: (context, state) {
          if (state is OwnerDashboardLoading || state is OwnerDashboardInitial) {
            return const AppLoadingView();
          }

          if (state is OwnerDashboardError) {
            return AppErrorView(
              message: state.message,
              onRetry: () {
                context.read<OwnerDashboardBloc>().add(const FetchOwnerDashboardData());
              },
            );
          }

          if (state is OwnerDashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<OwnerDashboardBloc>().add(const FetchOwnerDashboardData());
              },
              child: CustomScrollView(
                slivers: [
                  // 1. Owner stats metrics cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: _buildStatsGrid(context, state, l10n, isDark),
                    ),
                  ),

                  // 2. Verification status banner
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: _buildVerificationBanner(context, l10n, isDark),
                    ),
                  ),

                  // 3. Status Filter Tabs
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: _buildStatusTabs(context, state, l10n),
                    ),
                  ),

                  // 4. Listings list or empty view
                  if (state.listings.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppEmptyView(
                        title: l10n.noOwnerListings,
                        message: l10n.noOwnerListingsSubtitle,
                        action: ElevatedButton(
                          onPressed: () => context.push('/listings/new'),
                          child: Text(l10n.postNewAd),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.md,
                        right: AppSpacing.md,
                        bottom: 80,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final listing = state.listings[index];
                            return _buildListingCard(context, listing, l10n, isDark);
                          },
                          childCount: state.listings.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    OwnerDashboardLoaded state,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - AppSpacing.sm * 3) / 4;
        return Row(
          children: [
            _buildStatCard(l10n.totalListings, state.stats.total.toString(), Icons.list_alt, cardWidth, isDark),
            const SizedBox(width: AppSpacing.sm),
            _buildStatCard(l10n.activeListings, state.stats.active.toString(), Icons.check_circle_outline, cardWidth, isDark),
            const SizedBox(width: AppSpacing.sm),
            _buildStatCard(l10n.views, state.stats.views.toString(), Icons.visibility_outlined, cardWidth, isDark),
            const SizedBox(width: AppSpacing.sm),
            _buildStatCard(l10n.saved, state.stats.favorites.toString(), Icons.favorite_border, cardWidth, isDark),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    double width,
    bool isDark,
  ) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBanner(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.primary.withAlpha(60)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.primary, size: 32),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.verificationTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  l10n.verificationSubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showVerificationDialog(context, l10n),
            child: Text(l10n.uploadDocument),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs(
    BuildContext context,
    OwnerDashboardLoaded state,
    AppLocalizations l10n,
  ) {
    final tabs = [
      ('all', l10n.all),
      ('active', l10n.statusActive),
      ('pending', l10n.statusPending),
      ('archived', l10n.statusArchived),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((tab) {
          final isSelected = state.activeFilter == tab.$1;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(tab.$2),
              selected: isSelected,
              onSelected: (_) {
                context
                    .read<OwnerDashboardBloc>()
                    .add(ChangeListingStatusFilter(tab.$1));
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListingCard(
    BuildContext context,
    OwnerListingItem listing,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final statusColor = _getStatusColor(listing.status);
    final statusText = _getStatusText(listing.status, l10n);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Container(
                    width: 76,
                    height: 76,
                    color: Colors.grey.withAlpha(40),
                    child: listing.images.isNotEmpty
                        ? Image.network(
                            listing.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.apartment, size: 36, color: Colors.grey),
                          )
                        : const Icon(Icons.apartment, size: 36, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                          if (listing.views > 0)
                            Row(
                              children: [
                                const Icon(Icons.visibility_outlined, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  '${listing.views}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        listing.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        listing.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${AppFormatters.formatBdt(listing.pricePerMonth)} ${l10n.perMonth}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    context.push('/listings/${listing.id}/edit');
                  },
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text(l10n.actionEdit),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (listing.status == 'pending' || listing.status == 'active')
                  OutlinedButton(
                    onPressed: () {
                      context.read<OwnerDashboardBloc>().add(
                            TransitionListingEvent(
                              id: listing.id,
                              action: 'withdraw',
                            ),
                          );
                    },
                    child: Text(l10n.actionWithdraw),
                  ),
                if (listing.status == 'active')
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<OwnerDashboardBloc>().add(
                              TransitionListingEvent(
                                id: listing.id,
                                action: 'archive',
                              ),
                            );
                      },
                      child: Text(l10n.actionArchive),
                    ),
                  ),
                if (listing.status == 'draft' || listing.status == 'withdrawn')
                  ElevatedButton(
                    onPressed: () {
                      context.read<OwnerDashboardBloc>().add(
                            TransitionListingEvent(
                              id: listing.id,
                              action: 'submit',
                            ),
                          );
                    },
                    child: Text(l10n.actionSubmit),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'archived':
        return Colors.grey;
      case 'withdrawn':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _getStatusText(String status, AppLocalizations l10n) {
    switch (status.toLowerCase()) {
      case 'active':
        return l10n.statusActive;
      case 'pending':
        return l10n.statusPending;
      case 'archived':
        return l10n.statusArchived;
      case 'withdrawn':
        return l10n.statusWithdrawn;
      default:
        return l10n.statusDraft;
    }
  }

  void _showVerificationDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogCtx) => BlocProvider.value(
        value: context.read<VerificationBloc>(),
        child: AlertDialog(
          title: Text(l10n.verificationTitle),
          content: BlocBuilder<VerificationBloc, VerificationState>(
            builder: (ctx, state) {
              if (state is VerificationLoading) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state is VerificationLoaded) {
                return SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.verificationSubtitle),
                      const SizedBox(height: AppSpacing.md),
                      if (state.documents.isEmpty)
                        Text(
                          l10n.noDocumentsUploaded,
                          style: const TextStyle(color: Colors.grey),
                        )
                      else
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: state.documents.length,
                            itemBuilder: (_, index) {
                              final doc = state.documents[index];
                              return ListTile(
                                leading: const Icon(Icons.description_outlined),
                                title: Text(doc.originalName),
                                subtitle: Text('${(doc.size / 1024).toStringAsFixed(1)} KB'),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              }

              return Text(l10n.noDocumentsUploaded);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(l10n.btnCancel),
            ),
            ElevatedButton(
              onPressed: () {
                // Mock uploading a test verification doc
                context.read<VerificationBloc>().add(
                      const UploadVerificationDocumentEvent(
                        filePath: 'nid_front.jpg',
                        fileName: 'nid_front.jpg',
                      ),
                    );
                Navigator.of(dialogCtx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.documentUploadedSuccess)),
                );
              },
              child: Text(l10n.uploadDocument),
            ),
          ],
        ),
      ),
    );
  }
}
