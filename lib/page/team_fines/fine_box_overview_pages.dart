part of 'team_fines_page.dart';

/// Every player with fines this season, most owed first.
class FineBoxPlayersPage extends StatefulWidget {
  final bool canDelete;
  final Future<FineBoxDetails> Function() loadFineBox;
  final Future<void> Function(int fineId) deleteFine;
  final Future<void> Function(List<int> fineIds) markPaid;

  const FineBoxPlayersPage({
    super.key,
    required this.canDelete,
    this.loadFineBox = FinesRepository.getFineBox,
    this.deleteFine = FinesRepository.deleteUserFine,
    this.markPaid = FinesRepository.markUserFinesPaid,
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
          markPaid: widget.markPaid,
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

  /// Marks fines as paid on the player's behalf (fine admins only).
  final Future<void> Function(List<int> fineIds) markPaid;

  const FineBoxHistoryPage({
    super.key,
    required this.title,
    this.userId,
    required this.canDelete,
    this.loadFineBox = FinesRepository.getFineBox,
    this.deleteFine = FinesRepository.deleteUserFine,
    this.markPaid = FinesRepository.markUserFinesPaid,
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

  /// Marks [rows] as paid after confirmation: one fine, or all of a player's.
  Future<void> _markPaid(List<_FineRowData> rows) async {
    if (rows.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final amount = _kr(rows.fold(0, (sum, row) => sum + row.fine.owedAmount));
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(l10n.fineBoxMarkPaid),
        content: Text(
          rows.length == 1
              ? l10n.fineBoxMarkPaidBody(
                  rows.first.fine.fineTypeDetails.title,
                  rows.first.user.name,
                )
              : l10n.fineBoxMarkAllPaidBody(rows.first.user.name, amount),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.fineBoxDeleteCancel),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.fineBoxMarkPaid),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await widget.markPaid(rows.map((row) => row.fine.id).toList());
      AppAnalytics.logEvent(
        'fine_marked_paid_by_admin',
        parameters: {'fine_count': rows.length},
      );
      if (mounted) {
        setState(() {
          _fineBox = widget.loadFineBox();
        });
      }
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.fineBoxMarkPaidFailed)),
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
          final unpaid = rows.where((row) => !row.fine.hasBeenPaid).toList();
          // "Mark all" only on one player's own history.
          final canMarkAll =
              widget.canDelete && widget.userId != null && unpaid.length > 1;

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
                        onMarkPaid: widget.canDelete && !row.fine.hasBeenPaid
                            ? () => _markPaid([row])
                            : null,
                      ),
                  ],
                ),
              if (canMarkAll) ...[
                const SizedBox(height: Spacing.md),
                FullWidthButton(
                  key: const ValueKey('mark-all-fines-paid'),
                  icon: CupertinoIcons.checkmark_circle,
                  buttonText: l10n.fineBoxMarkAllPaid(
                    _kr(unpaid.fold(
                        0, (sum, row) => sum + row.fine.owedAmount)),
                  ),
                  onPressed: () => _markPaid(unpaid),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
