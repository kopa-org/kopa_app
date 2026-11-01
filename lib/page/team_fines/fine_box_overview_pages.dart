part of 'team_fines_page.dart';

/// Every player with fines this season, most owed first.
class FineBoxPlayersPage extends StatefulWidget {
  final bool canDelete;
  final Future<FineBoxDetails> Function() loadFineBox;
  final Future<void> Function(int fineId) deleteFine;

  const FineBoxPlayersPage({
    super.key,
    required this.canDelete,
    this.loadFineBox = FinesRepository.getFineBox,
    this.deleteFine = FinesRepository.deleteUserFine,
  });

  @override
  State<FineBoxPlayersPage> createState() => _FineBoxPlayersPageState();
}

class _FineBoxPlayersPageState extends State<FineBoxPlayersPage> {
  late Future<FineBoxDetails> _fineBox = widget.loadFineBox();

  Future<void> _openPlayer(_UserFineSummary summary) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FineBoxHistoryPage(
          title: summary.user.name,
          userId: summary.user.id,
          canDelete: widget.canDelete,
          loadFineBox: widget.loadFineBox,
          deleteFine: widget.deleteFine,
        ),
      ),
    );
    if (mounted) _reload();
  }

  void _reload() {
    setState(() {
      _fineBox = widget.loadFineBox();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PageScaffold(
      title: l10n.fineBoxPlayersTitle,
      showBackButton: true,
      backgroundColor: AppColors.of(context).background,
      body: FutureHandler<FineBoxDetails>(
        future: _fineBox,
        onSuccess: (context, fineBox) {
          final summaries = _userFineSummaries(fineBox.userFineDetails)
            ..sort((a, b) {
              final byAmount = b.unpaidAmount.compareTo(a.unpaidAmount);
              return byAmount != 0
                  ? byAmount
                  : a.user.name.compareTo(b.user.name);
            });

          return ListView(
            padding: const EdgeInsets.all(Spacing.md),
            children: [
              if (summaries.isEmpty)
                _EmptyPanel(text: l10n.fineBoxRecentEmpty)
              else
                _GroupedPanel(
                  children: [
                    for (final summary in summaries)
                      _FinePlayerRow(
                        summary: summary,
                        onTap: () => _openPlayer(summary),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FinePlayerRow extends StatelessWidget {
  final _UserFineSummary summary;
  final VoidCallback onTap;

  const _FinePlayerRow({required this.summary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final owes = summary.unpaidAmount > 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: Spacing.listItemPadding,
        child: Row(
          children: [
            InFormAvatar(name: summary.user.name, radius: 19),
            const SizedBox(width: Spacing.itemGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: appTextStyles.bodyBold.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l10n.fineBoxPlayerFineCount(summary.fineCount),
                    style: appTextStyles.caption
                        .copyWith(color: appColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Text(
              owes ? _kr(summary.unpaidAmount) : l10n.fineBoxAllPaid,
              style: appTextStyles.bodyBold.copyWith(
                color: owes
                    ? appColors.errorForeground
                    : appColors.successForeground,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: Spacing.xs),
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: appColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// All fines this season, newest first, optionally for one player.
class FineBoxHistoryPage extends StatefulWidget {
  final String title;
  final int? userId;
  final bool canDelete;
  final Future<FineBoxDetails> Function() loadFineBox;
  final Future<void> Function(int fineId) deleteFine;

  const FineBoxHistoryPage({
    super.key,
    required this.title,
    this.userId,
    required this.canDelete,
    this.loadFineBox = FinesRepository.getFineBox,
    this.deleteFine = FinesRepository.deleteUserFine,
  });

  @override
  State<FineBoxHistoryPage> createState() => _FineBoxHistoryPageState();
}

class _FineBoxHistoryPageState extends State<FineBoxHistoryPage> {
  late Future<FineBoxDetails> _fineBox = widget.loadFineBox();

  Future<void> _delete(_FineRowData row) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(l10n.fineBoxDeleteFine),
        content: Text(
          l10n.fineBoxDeleteFineBody(
            row.fine.fineTypeDetails.title,
            row.user.name,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.fineBoxDeleteCancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.fineBoxDeleteFine),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await widget.deleteFine(row.fine.id);
      AppAnalytics.logEvent('fine_deleted');
      if (mounted) {
        setState(() {
          _fineBox = widget.loadFineBox();
        });
      }
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.fineBoxDeleteFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PageScaffold(
      title: widget.title,
      showBackButton: true,
      backgroundColor: AppColors.of(context).background,
      body: FutureHandler<FineBoxDetails>(
        future: _fineBox,
        onSuccess: (context, fineBox) {
          final rows = _fineRows(fineBox.userFineDetails)
              .where(
                (row) => widget.userId == null || row.user.id == widget.userId,
              )
              .toList()
            ..sort((a, b) => b.fine.createdAt.compareTo(a.fine.createdAt));

          return ListView(
            padding: const EdgeInsets.all(Spacing.md),
            children: [
              if (rows.isEmpty)
                _EmptyPanel(text: l10n.fineBoxRecentEmpty)
              else
                _GroupedPanel(
                  children: [
                    for (final row in rows)
                      _RecentFineRow(
                        row: row,
                        // Paid fines are already counted in the box.
                        onDelete: widget.canDelete && !row.fine.hasBeenPaid
                            ? () => _delete(row)
                            : null,
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
