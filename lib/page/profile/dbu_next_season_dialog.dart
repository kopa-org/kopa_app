import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/repository/team_dbu_repository.dart';

enum DbuNextSeasonAction { useCandidate, findManually, cancel }

class DbuNextSeasonResult {
  final DbuNextSeasonAction action;
  final DbuNextSeasonCandidate? candidate;

  const DbuNextSeasonResult(this.action, [this.candidate]);
}

/// Looks up the team's next DBU season and lets the user confirm it.
///
/// Closes itself with [DbuNextSeasonAction.findManually] when nothing is
/// found, so the caller can fall back to the manual DBU import.
class DbuNextSeasonDialog extends StatefulWidget {
  final int teamId;

  const DbuNextSeasonDialog({super.key, required this.teamId});

  static Future<DbuNextSeasonResult> show(
    BuildContext context, {
    required int teamId,
  }) async {
    final result = await showDialog<DbuNextSeasonResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DbuNextSeasonDialog(teamId: teamId),
    );
    return result ?? const DbuNextSeasonResult(DbuNextSeasonAction.cancel);
  }

  @override
  State<DbuNextSeasonDialog> createState() => _DbuNextSeasonDialogState();
}

class _DbuNextSeasonDialogState extends State<DbuNextSeasonDialog> {
  List<DbuNextSeasonCandidate>? _candidates;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final candidates = await TeamDbuRepository.findNextSeason(widget.teamId);
    if (!mounted) return;

    if (candidates.isEmpty) {
      Navigator.of(context).pop(
        const DbuNextSeasonResult(DbuNextSeasonAction.findManually),
      );
      return;
    }

    setState(() => _candidates = candidates);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final candidates = _candidates;

    if (candidates == null) {
      return AlertDialog(
        content: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(l10n.uiFindingNextSeason)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(
              const DbuNextSeasonResult(DbuNextSeasonAction.cancel),
            ),
            child: Text(l10n.fineBoxDeleteCancel),
          ),
        ],
      );
    }

    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateFormat = DateFormat.MMMd(locale);

    return AlertDialog(
      title: Text(l10n.uiNextSeasonFoundTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.uiNextSeasonFoundBody),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: candidates.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final candidate = candidates[index];
                  final firstMatch = candidate.firstUpcomingMatchOn;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      candidate.teamName.isNotEmpty
                          ? candidate.teamName
                          : candidate.seriesName,
                    ),
                    subtitle: Text(
                      [
                        [candidate.seriesName, candidate.poolLabel]
                            .where((part) => part.isNotEmpty)
                            .join(' · '),
                        if (firstMatch != null)
                          l10n.uiNextSeasonMatches(
                            candidate.upcomingMatchCount,
                            dateFormat.format(firstMatch),
                          ),
                      ].join('\n'),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).pop(
                      DbuNextSeasonResult(
                        DbuNextSeasonAction.useCandidate,
                        candidate,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(
            const DbuNextSeasonResult(DbuNextSeasonAction.cancel),
          ),
          child: Text(l10n.fineBoxDeleteCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(
            const DbuNextSeasonResult(DbuNextSeasonAction.findManually),
          ),
          child: Text(l10n.uiFindOnDbuMyself),
        ),
      ],
    );
  }
}
