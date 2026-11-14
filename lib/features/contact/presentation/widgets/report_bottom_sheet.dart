import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../bloc/report_bloc.dart';

class ReportBottomSheet extends StatefulWidget {
  final String listingId;
  const ReportBottomSheet({super.key, required this.listingId});

  static Future<void> show(BuildContext context, {required String listingId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ReportBottomSheet(listingId: listingId),
    );
  }

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  String _selectedReason = 'scam';
  final _detailsController = TextEditingController();

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final reasons = [
      {'key': 'scam', 'label': l10n.reasonScam},
      {'key': 'wrong_info', 'label': l10n.reasonWrongInfo},
      {'key': 'already_rented', 'label': l10n.reasonAlreadyRented},
      {'key': 'offensive', 'label': l10n.reasonOffensive},
      {'key': 'other', 'label': l10n.reasonOther},
    ];

    return BlocProvider(
      create: (_) => sl<ReportBloc>(),
      child: BlocConsumer<ReportBloc, ReportState>(
        listener: (context, state) {
          if (state is ReportSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.reportSuccess)),
            );
            Navigator.of(context).pop();
          } else if (state is ReportErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.messageKey)),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is ReportSubmitting;

          return Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.reportListing,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.reportReason,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...reasons.map((r) {
                    final key = r['key']!;
                    final label = r['label']!;
                    // ignore: deprecated_member_use
                    return RadioListTile<String>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(label),
                      value: key,
                      // ignore: deprecated_member_use
                      groupValue: _selectedReason,
                      // ignore: deprecated_member_use
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedReason = val);
                        }
                      },
                    );
                  }),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: l10n.reportDetails,
                    controller: _detailsController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: l10n.submitReport,
                    isLoading: isSubmitting,
                    onPressed: () {
                      context.read<ReportBloc>().add(
                            SubmitReportEvent(
                              listingId: widget.listingId,
                              reason: _selectedReason,
                              details: _detailsController.text.trim().isNotEmpty
                                  ? _detailsController.text.trim()
                                  : null,
                            ),
                          );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
