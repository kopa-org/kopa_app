import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kopa/component/button/button.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

Future<(int, int)?> showMatchScoreSheet({
  required BuildContext context,
  required String? homeTeam,
  required String? awayTeam,
  required int homeScore,
  required int awayScore,
  required Future<void> Function(int home, int away) onSave,
}) {
  FocusManager.instance.primaryFocus?.unfocus();
  return showModalBottomSheet<(int, int)>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: false,
    enableDrag: false,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (_) => MatchScoreSheet(
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeScore: homeScore,
      awayScore: awayScore,
      onSave: onSave,
    ),
  );
}

class MatchScoreSheet extends StatefulWidget {
  final String? homeTeam;
  final String? awayTeam;
  final int homeScore;
  final int awayScore;
  final Future<void> Function(int home, int away) onSave;

  const MatchScoreSheet({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.onSave,
  });

  @override
  State<MatchScoreSheet> createState() => _MatchScoreSheetState();
}

class _MatchScoreSheetState extends State<MatchScoreSheet> {
  late final _home = TextEditingController(text: widget.homeScore.toString());
  late final _away = TextEditingController(text: widget.awayScore.toString());
  final _awayFocus = FocusNode();
  bool _saving = false;
  bool _failed = false;

  int? _score(String text) {
    final value = int.tryParse(text);
    return value != null && value >= 0 ? value : null;
  }

  bool get _valid => _score(_home.text) != null && _score(_away.text) != null;

  @override
  void dispose() {
    _home.dispose();
    _away.dispose();
    _awayFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_valid || _saving) return;
    final home = _score(_home.text)!;
    final away = _score(_away.text)!;
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      await widget.onSave(home, away);
      if (!mounted) return;
      Navigator.of(context).pop((home, away));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: !_saving,
      child: Material(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: DefaultTextStyle(
          style: styles.body.copyWith(decoration: TextDecoration.none),
          // Keyboard insets already animate. Avoid a competing padding animation
          // and leave focus to the user so the keyboard stays shut on opening.
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      Expanded(
                          child: Text(l10n.matchScoreDialogTitle,
                              style: styles.sectionHeader)),
                      IconButton(
                        tooltip: l10n.commonCancel,
                        onPressed:
                            _saving ? null : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Text(l10n.matchScoreHelp,
                        style:
                            styles.body3.copyWith(color: colors.textSecondary)),
                    const SizedBox(height: 24),
                    _field(
                        controller: _home,
                        team: widget.homeTeam,
                        label: l10n.matchScoreHome,
                        key: const ValueKey('home-score'),
                        next: true),
                    const SizedBox(height: 12),
                    _field(
                        controller: _away,
                        team: widget.awayTeam,
                        label: l10n.matchScoreAway,
                        key: const ValueKey('away-score'),
                        next: false),
                    if (_failed) ...[
                      const SizedBox(height: 16),
                      Semantics(
                          liveRegion: true,
                          child: Text(l10n.matchScoreSaveFailed,
                              style: styles.body3
                                  .copyWith(color: colors.errorForeground))),
                    ],
                    const SizedBox(height: 24),
                    Button(
                        buttonText: l10n.matchScoreSave,
                        onPressed: _save,
                        enabled: _valid,
                        loading: _saving,
                        width: double.infinity,
                        icon: Icons.check),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
      {required TextEditingController controller,
      required String? team,
      required String label,
      required Key key,
      required bool next}) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    return TextField(
      key: key,
      controller: controller,
      focusNode: next ? null : _awayFocus,
      readOnly: _saving,
      keyboardType: TextInputType.number,
      textInputAction: next ? TextInputAction.next : TextInputAction.done,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: styles.h4.copyWith(decoration: TextDecoration.none),
      decoration: InputDecoration(
        labelText:
            team == null || team.trim().isEmpty ? label : '$label · $team',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        fillColor: colors.offWhite,
      ),
      onChanged: (_) => setState(() => _failed = false),
      onSubmitted: (_) => next ? _awayFocus.requestFocus() : _save(),
    );
  }
}
