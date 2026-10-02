import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/button/button.dart';
import 'package:kopa/helpers/mobile_pay_box_link.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/repository/fines_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class MobilePaySetupModal extends StatefulWidget {
  final String? initialValue;
  final Future<bool> Function(String) saveBox;

  const MobilePaySetupModal(
      {super.key,
      this.initialValue,
      this.saveBox = FinesRepository.updateMobilePayBoxId});

  @override
  State<MobilePaySetupModal> createState() => _MobilePaySetupModalState();
}

class _MobilePaySetupModalState extends State<MobilePaySetupModal> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
        text: MobilePayBoxLink.webUri(widget.initialValue ?? '')?.toString() ??
            widget.initialValue ??
            '');
  }

  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final boxId = MobilePayBoxLink.boxId(_controller.text);

    if (boxId == null) {
      setState(() {
        _error = AppLocalizations.of(context)!.mobilePayBoxInvalid;
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await widget.saveBox(boxId);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _error = AppLocalizations.of(context)!.mobilePayBoxSaveFailed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 18,
          bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.mobilePayBoxTitle,
              style: appTextStyles.h5.copyWith(
                color: appColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.mobilePayBoxInstructions,
              style: appTextStyles.body3.copyWith(
                color: appColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: _controller,
              enabled: !_isSaving,
              autocorrect: false,
              keyboardType: TextInputType.url,
              placeholder: 'https://qr.mobilepay.dk/box/…/pay-in',
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: appColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: appColors.divider),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: appTextStyles.caption2.copyWith(
                  color: appColors.error,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Button(
              icon: _isSaving
                  ? CupertinoIcons.hourglass
                  : CupertinoIcons.check_mark_circled,
              buttonText: l10n.mobilePayBoxSave,
              loading: _isSaving,
              width: double.infinity,
              backgroundColor: appColors.primary,
              foregroundColor: appColors.surface,
              onPressed: _isSaving ? () {} : _save,
            ),
          ],
        ),
      ),
    );
  }
}
