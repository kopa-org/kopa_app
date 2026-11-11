import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopa/component/button/full_width_button.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/season_wrapped.dart';
import 'package:kopa/page/wrapped/wrapped_slides.dart';
import 'package:kopa/repository/season_wrapped_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';
import 'package:kopa/utils/app_analytics.dart';

/// Lets a team leader pick which award categories go into the Wrapped.
/// Categories without enough data this season are shown but locked.
///
/// Returns true when the settings were saved.
Future<bool> showWrappedSettingsSheet(
  BuildContext context, {
  required int teamId,
  required SeasonWrapped wrapped,
  Future<void> Function(int teamId, List<String> disabled)? save,
}) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _WrappedSettingsSheet(
      teamId: teamId,
      wrapped: wrapped,
      save: save ?? SeasonWrappedRepository.updateDisabledCategories,
    ),
  );
  return saved == true;
}

class _WrappedSettingsSheet extends StatefulWidget {
  final int teamId;
  final SeasonWrapped wrapped;
  final Future<void> Function(int teamId, List<String> disabled) save;

  const _WrappedSettingsSheet({
    required this.teamId,
    required this.wrapped,
    required this.save,
  });

  @override
  State<_WrappedSettingsSheet> createState() => _WrappedSettingsSheetState();
}

class _WrappedSettingsSheetState extends State<_WrappedSettingsSheet> {
  late final Set<String> _disabled = widget.wrapped.disabledCategories.toSet();
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.save(widget.teamId, _disabled.toList()..sort());
      AppAnalytics.logEvent('season_wrapped_settings_saved');
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = AppLocalizations.of(context)!.wrappedSettingsError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.grey3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),
          Text(
            l10n.wrappedSettingsTitle,
            style: textStyles.h4.copyWith(
              color: colors.dirt,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            l10n.wrappedSettingsBody,
            style: textStyles.body3.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: Spacing.sm),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final category in widget.wrapped.categories)
                  SwitchListTile.adaptive(
                    key: ValueKey('wrapped_category_${category.key}'),
                    contentPadding: EdgeInsets.zero,
                    activeTrackColor: colors.primary,
                    value:
                        category.available && !_disabled.contains(category.key),
                    onChanged: !category.available || _saving
                        ? null
                        : (on) => setState(() {
                              on
                                  ? _disabled.remove(category.key)
                                  : _disabled.add(category.key);
                            }),
                    title: Text(
                      wrappedCategoryTitle(l10n, category.key),
                      style: textStyles.body3.copyWith(
                        color: colors.dirt,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: Text(
                      category.available
                          ? _detail(context, category)
                          : l10n.wrappedSettingsNoData,
                      style: textStyles.caption.copyWith(
                        color: category.available
                            ? colors.grey5
                            : WrappedPalette.warningText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: Spacing.sm),
            Text(
              _error!,
              style: textStyles.caption.copyWith(color: colors.error),
            ),
          ],
          const SizedBox(height: Spacing.md),
          FullWidthButton(
            icon: Icons.check_rounded,
            buttonText: l10n.wrappedSettingsSave,
            loading: _saving,
            enabled: !_saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  String _detail(BuildContext context, WrappedCategory category) {
    final l10n = AppLocalizations.of(context)!;
    final count = category.count.toInt();
    return switch (category.key) {
      'form' => l10n.wrappedDetailForm(count),
      'goals' => l10n.wrappedDetailGoals(count),
      'assists' => l10n.wrappedDetailAssists(count),
      'motm' => l10n.wrappedDetailMotm(count),
      'iron' => l10n.wrappedDetailIron(count),
      'fines' => l10n.wrappedDetailFines(
          '${NumberFormat.decimalPattern(Localizations.localeOf(context).toLanguageTag()).format(count)} kr.',
        ),
      'cards' => l10n.wrappedDetailCards(count),
      'lantern' => l10n.wrappedDetailLantern,
      _ => '',
    };
  }
}
