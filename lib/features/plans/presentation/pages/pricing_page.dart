import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di/injection.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/entities/pricing_plan_entity.dart';
import '../bloc/pricing_bloc.dart';

/// Pricing & subscription plans comparison screen.
/// Traceability: REQ-031, REQ-032, REQ-033, REQ-034, SCR-014, API-061.
class PricingPage extends StatelessWidget {
  const PricingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => sl<PricingBloc>()..add(const FetchPricingPlansEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.pricingTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: BlocBuilder<PricingBloc, PricingState>(
          builder: (context, state) {
            if (state is PricingLoading || state is PricingInitial) {
              return const AppLoadingView();
            }

            if (state is PricingError) {
              return AppErrorView(
                message: state.message,
                onRetry: () {
                  context.read<PricingBloc>().add(const FetchPricingPlansEvent());
                },
              );
            }

            if (state is PricingLoaded) {
              if (state.plans.isEmpty) {
                return AppEmptyView(
                  title: l10n.pricingTitle,
                  message: l10n.vatExclusionNotice,
                );
              }

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  _buildHeader(context, l10n),
                  const SizedBox(height: AppSpacing.lg),
                  ...state.plans.map((plan) => _buildPlanCard(context, plan, l10n)),
                  const SizedBox(height: AppSpacing.xl),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          l10n.pricingSubtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.dividerLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'ℹ ${l10n.vatExclusionNotice}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    PricingPlanEntity plan,
    AppLocalizations l10n,
  ) {
    final isPopular = plan.popular;
    final isFree = plan.isFree || plan.price == 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPopular) const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        plan.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isPopular ? AppColors.primary : null,
                            ),
                      ),
                    ),
                    if (plan.nameEn != null && plan.nameEn != plan.name)
                      Text(
                        plan.nameEn!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMutedLight,
                            ),
                      ),
                  ],
                ),
                if (plan.description != null && plan.description!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    plan.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.xs,
                  children: [
                    Text(
                      isFree
                          ? l10n.freePrice
                          : AppFormatters.formatBdt(plan.price),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                    if (!isFree)
                      Text(
                        plan.interval == 'monthly' ? l10n.perMonth : '(${l10n.oneTime})',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                      ),
                  ],
                ),
                const Divider(height: AppSpacing.lg),
                Text(
                  l10n.pricingFeaturesIncluded,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                ...plan.features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: AppColors.success,
                          size: 18,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            feature,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: isFree
                        ? l10n.currentPlan
                        : (plan.ctaLabel ?? l10n.contactSales),
                    variant: isPopular
                        ? AppButtonVariant.primary
                        : AppButtonVariant.outline,
                    onPressed: () {
                      if (!isFree) {
                        // REQ-034: Pro/Business navigates to contact page
                        context.push('/contact');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              top: -8,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.mostPopular,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
