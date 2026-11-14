import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../bloc/contact_bloc.dart';

class InquiryBottomSheet extends StatefulWidget {
  final String listingId;
  const InquiryBottomSheet({super.key, required this.listingId});

  static Future<void> show(BuildContext context, {required String listingId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => InquiryBottomSheet(listingId: listingId),
    );
  }

  @override
  State<InquiryBottomSheet> createState() => _InquiryBottomSheetState();
}

class _InquiryBottomSheetState extends State<InquiryBottomSheet> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocProvider(
      create: (_) => sl<ContactBloc>(),
      child: BlocConsumer<ContactBloc, ContactState>(
        listener: (context, state) {
          if (state is InquirySentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.inquirySentSuccess)),
            );
            Navigator.of(context).pop();
          } else if (state is ContactError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.messageKey)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ContactLoading;

          return Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.sendMessage,
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
                const SizedBox(height: 16),
                AppTextField(
                  label: l10n.inquiryMessage,
                  hint: l10n.inquiryPlaceholder,
                  controller: _messageController,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: l10n.send,
                  isLoading: isLoading,
                  onPressed: () {
                    final text = _messageController.text.trim();
                    if (text.isNotEmpty) {
                      context.read<ContactBloc>().add(
                            SendContactInquiry(
                              listingId: widget.listingId,
                              content: text,
                            ),
                          );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
