import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/component/button/mobile_pay_button.dart';
import 'package:kopa/component/future_handler.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/fine_box_details.dart';
import 'package:kopa/model/fine_details.dart';
import 'package:kopa/model/fine_type_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/model/user_fine_details.dart';
import 'package:kopa/page/in_form/in_form_ui.dart';
import 'package:kopa/page/team_fines/assign_fines_modal.dart';
import 'package:kopa/page/team_fines/create_fine_type_modal.dart';
import 'package:kopa/page/team_fines/deposit_modal.dart';
import 'package:kopa/page/team_fines/mobile_pay_setup_modal.dart';
import 'package:kopa/repository/fines_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';
import 'package:kopa/utils/app_analytics.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

enum TeamOwnerFinesSegments { overview, fineTypes, personal }

const _thumbMascot = 'assets/illustrations/kopa_thumb.svg';
const _heartMascot = 'assets/illustrations/kopa_heart.svg';
const _flagMascot = 'assets/illustrations/kopa_flag.svg';

class TeamFinesPage extends StatefulWidget {
  final bool showBackButton;

  const TeamFinesPage({super.key, this.showBackButton = true});

  @override
  State<TeamFinesPage> createState() => _TeamFinesPageState();
}

class _TeamFinesPageState extends State<TeamFinesPage> {
  late Future<FineBoxDetails> fineBoxDetails;
  late Future<List<FineTypeDetails>> fineTypeDetails;
  late Future<UserDetails> currentUserData;

  TeamOwnerFinesSegments _selectedSegment = TeamOwnerFinesSegments.overview;
  final Set<int> _selectedPersonalFineIds = {};

  @override
  void initState() {
    super.initState();
    AppAnalytics.logScreenView('team_fines');
    AppAnalytics.logEvent('fine_box_opened');
    fineBoxDetails = FinesRepository.getFineBox();
    fineTypeDetails = FinesRepository.getFineTypes();
    final user = context.read<AuthCubit>().state.user;
    if (user == null) {
      currentUserData = Future.error(
        Exception('Ingen bruger fundet. Log venligst ind igen.'),
      );
    } else {
      currentUserData = Future.value(user);
    }
  }

  Future<void> _refreshFineBox() async {
    setState(() {
      _selectedPersonalFineIds.clear();
      fineBoxDetails = FinesRepository.getFineBox();
    });
  }

  Future<void> _refreshFineTypes() async {
    setState(() {
      fineTypeDetails = FinesRepository.getFineTypes();
    });
  }

  void _selectSegment(TeamOwnerFinesSegments value) {
    AppAnalytics.logEvent(
      'fine_box_segment_selected',
      parameters: {'segment': value.name},
    );
    setState(() {
      _selectedSegment = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return PageScaffold(
      title: l10n.fineBoxTitle,
      showBackButton: widget.showBackButton,
      showTopBar: false,
      backgroundColor: appColors.background,
      useBottomSafeArea: widget.showBackButton,
      body: FutureHandler<UserDetails>(
        future: currentUserData,
        onSuccess: (context, user) {
          final segment = user.isTeamOwner
              ? _selectedSegment
              : TeamOwnerFinesSegments.personal;

          return FutureHandler<FineBoxDetails>(
            future: fineBoxDetails,
            onSuccess: (context, fineBox) {
              return RefreshIndicator(
                color: appColors.grass,
                onRefresh: _refreshFineBox,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _FineHeader(
                        title: segment == TeamOwnerFinesSegments.personal
                            ? l10n.fineBoxMyFines
                            : l10n.fineBoxTitle,
                        subtitle: _teamSubtitle(user),
                        showBackButton: widget.showBackButton,
                      ),
                    ),
                    if (user.isTeamOwner)
                      SliverToBoxAdapter(
                        child: _SegmentTabs(
                          selectedSegment: _selectedSegment,
                          onChanged: _selectSegment,
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: KeyedSubtree(
                          key: ValueKey(segment),
                          child: switch (segment) {
                            TeamOwnerFinesSegments.overview =>
                              _buildOverview(fineBox, user),
                            TeamOwnerFinesSegments.fineTypes =>
                              _buildFineTypes(),
                            TeamOwnerFinesSegments.personal =>
                              _buildPersonal(fineBox, user),
                          },
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height:
                            mainTabBottomContentPadding(context) + Spacing.lg,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOverview(FineBoxDetails fineBox, UserDetails user) {
    final l10n = AppLocalizations.of(context)!;
    final total = fineBox.currentAmount + fineBox.totalOwedAmount;
    final progress =
        total <= 0 ? 0.0 : (fineBox.currentAmount / total).clamp(0.0, 1.0);
    final topOffenders = _userFineSummaries(fineBox.userFineDetails)
        .where((summary) => summary.unpaidAmount > 0)
        .toList()
      ..sort((a, b) => b.unpaidAmount.compareTo(a.unpaidAmount));
    final recentFines = _fineRows(fineBox.userFineDetails)
      ..sort((a, b) => b.fine.createdAt.compareTo(a.fine.createdAt));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TeamHero(
            total: total,
            collected: fineBox.currentAmount,
            outstanding: fineBox.totalOwedAmount,
            progress: progress,
          ),
          const SizedBox(height: Spacing.itemGap),
          _QuickActions(
            onGiveFine: _openAssignFines,
            onDeposit: () => _openTeamDeposit(fineBox),
            onFineTypes: () => _selectSegment(TeamOwnerFinesSegments.fineTypes),
          ),
          if (user.isTeamOwner || !fineBox.hasMobilePayBox) ...[
            const SizedBox(height: Spacing.itemGap),
            _MobilePaySetupPanel(
              isTeamOwner: user.isTeamOwner,
              onSetup: () => _openMobilePaySetup(fineBox.mobilePayBoxId),
              configuredBox: fineBox.mobilePayBoxId,
            ),
          ],
          const SizedBox(height: Spacing.lg),
          InFormSectionTitle(title: l10n.fineBoxPodiumTitle),
          const SizedBox(height: Spacing.sm),
          if (topOffenders.isEmpty)
            _MascotMessage(
              text: l10n.fineBoxPodiumEmpty,
              mascot: _heartMascot,
              color: AppColors.of(context).lightGrass,
            )
          else
            _FinePodium(leaders: topOffenders.take(3).toList()),
          const SizedBox(height: Spacing.lg),
          InFormSectionTitle(title: l10n.fineBoxRecentTitle),
          const SizedBox(height: Spacing.sm),
          if (recentFines.isEmpty)
            _EmptyPanel(text: l10n.fineBoxRecentEmpty)
          else
            _GroupedPanel(
              children: recentFines
                  .take(5)
                  .map((row) => _RecentFineRow(row: row))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildFineTypes() {
    final l10n = AppLocalizations.of(context)!;

    return FutureHandler<List<FineTypeDetails>>(
      future: fineTypeDetails,
      allowEmpty: true,
      onSuccess: (context, fineTypes) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PrimaryActionButton(
                icon: CupertinoIcons.plus,
                label: l10n.fineBoxCreateFineType,
                onPressed: () => _openCreateFineType(fineTypes),
              ),
              const SizedBox(height: Spacing.lg),
              InFormSectionTitle(
                title: l10n.fineBoxCatalogTitle,
                action: fineTypes.isEmpty
                    ? null
                    : l10n.fineBoxCatalogCount(fineTypes.length),
              ),
              const SizedBox(height: Spacing.sm),
              if (fineTypes.isEmpty)
                _MascotMessage(
                  text: l10n.fineBoxCatalogEmpty,
                  mascot: _flagMascot,
                  color: AppColors.of(context).lightSky65,
                )
              else
                _GroupedPanel(
                  children: fineTypes
                      .map(
                        (fineType) => _FineTypeRow(
                          fineType: fineType,
                          onDeleted: _refreshFineTypes,
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPersonal(FineBoxDetails fineBox, UserDetails user) {
    final l10n = AppLocalizations.of(context)!;
    final appColors = AppColors.of(context);
    final userFineDetails = _findUserFineDetails(fineBox, user);
    final allFines = userFineDetails?.fineDetailsList ?? [];
    final unpaidFines = allFines.where((fine) => !fine.hasBeenPaid).toList();
    final paidFines = allFines.where((fine) => fine.hasBeenPaid).toList();
    final selectedFines = unpaidFines
        .where((fine) => _selectedPersonalFineIds.contains(fine.id))
        .toList();
    final unpaidAmount = unpaidFines.fold<int>(
      0,
      (sum, fine) => sum + fine.owedAmount,
    );
    final paidAmount =
        paidFines.fold<int>(0, (sum, fine) => sum + fine.owedAmount);
    final selectedAmount = selectedFines.fold<int>(
      0,
      (sum, fine) => sum + fine.owedAmount,
    );
    final allSelected = unpaidFines.isNotEmpty &&
        _selectedPersonalFineIds.length == unpaidFines.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (unpaidAmount > 0)
            _PersonalDebtHero(
              amount: unpaidAmount,
              unpaidCount: unpaidFines.length,
            )
          else
            const _DebtFreeHero(),
          const SizedBox(height: Spacing.itemGap),
          Row(
            children: [
              InFormMetric(
                label: l10n.fineBoxStatFines,
                value: '${allFines.length}',
                color: appColors.lightSky65,
                icon: CupertinoIcons.doc_text,
              ),
              const SizedBox(width: Spacing.sm),
              InFormMetric(
                label: l10n.fineBoxOutstanding,
                value: _kr(unpaidAmount),
                color: appColors.warningSurface,
                icon: CupertinoIcons.hourglass,
              ),
              const SizedBox(width: Spacing.sm),
              InFormMetric(
                label: l10n.fineBoxStatPaid,
                value: _kr(paidAmount),
                color: appColors.lightGrass75,
                icon: CupertinoIcons.checkmark_seal,
              ),
            ],
          ),
          if (unpaidFines.isNotEmpty) ...[
            const SizedBox(height: Spacing.lg),
            InFormSectionTitle(
              title: l10n.fineBoxUnpaidTitle,
              action:
                  allSelected ? l10n.fineBoxDeselectAll : l10n.fineBoxSelectAll,
              onAction: () => _toggleAllPersonalFines(unpaidFines),
            ),
            const SizedBox(height: Spacing.sm),
            _GroupedPanel(
              children: unpaidFines
                  .map(
                    (fine) => _SelectableFineRow(
                      fine: fine,
                      selected: _selectedPersonalFineIds.contains(fine.id),
                      onTap: () => _togglePersonalFine(fine.id),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: Spacing.itemGap),
            _PaymentPanel(
              selectedCount: selectedFines.length,
              selectedAmount: selectedAmount,
              userName: user.name,
              mobilePayBoxId: fineBox.mobilePayBoxId,
              isTeamOwner: user.isTeamOwner,
              onSetupMobilePay: () =>
                  _openMobilePaySetup(fineBox.mobilePayBoxId),
              onCashPaid: selectedFines.isEmpty
                  ? null
                  : () => _markSelectedPersonalFinesPaid(
                        fineBox.id,
                        selectedFines,
                        selectedAmount,
                      ),
            ),
          ],
          if (paidFines.isNotEmpty) ...[
            const SizedBox(height: Spacing.lg),
            InFormSectionTitle(title: l10n.fineBoxHistoryTitle),
            const SizedBox(height: Spacing.sm),
            _GroupedPanel(
              children: paidFines
                  .take(5)
                  .map((fine) => _HistoryFineRow(fine: fine))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openAssignFines() async {
    AppAnalytics.logEvent('fine_assign_started');
    final result = await showCupertinoModalBottomSheet(
      expand: true,
      context: context,
      builder: (context) => AssignFinesModal(),
    );
    if (result == true) {
      _refreshFineBox();
    }
  }

  Future<void> _openTeamDeposit(FineBoxDetails fineBox) async {
    AppAnalytics.logEvent('fine_deposit_started');
    final result = await showCupertinoModalBottomSheet(
      expand: true,
      context: context,
      builder: (context) => DepositModal(
          fineBoxId: fineBox.id, mobilePayBoxId: fineBox.mobilePayBoxId),
    );

    if (result != null) {
      _refreshFineBox();
    }
  }

  Future<void> _openCreateFineType(List<FineTypeDetails> fineTypes) async {
    final result = await showCupertinoModalBottomSheet(
      expand: true,
      context: context,
      builder: (context) => CreateFineTypeModal(
        fineTypeDetailsList: fineTypes,
      ),
    );

    if (result == true) {
      _refreshFineTypes();
    }
  }

  Future<void> _openMobilePaySetup([String? initialValue]) async {
    final result = await showCupertinoModalBottomSheet(
      expand: false,
      context: context,
      builder: (context) => MobilePaySetupModal(initialValue: initialValue),
    );

    if (result == true) {
      await _refreshFineBox();
    }
  }

  void _togglePersonalFine(int fineId) {
    setState(() {
      if (_selectedPersonalFineIds.contains(fineId)) {
        _selectedPersonalFineIds.remove(fineId);
      } else {
        _selectedPersonalFineIds.add(fineId);
      }
    });
  }

  void _toggleAllPersonalFines(List<FineDetails> unpaidFines) {
    setState(() {
      if (_selectedPersonalFineIds.length == unpaidFines.length) {
        _selectedPersonalFineIds.clear();
      } else {
        _selectedPersonalFineIds
          ..clear()
          ..addAll(unpaidFines.map((fine) => fine.id));
      }
    });
  }

  Future<void> _markSelectedPersonalFinesPaid(
    int fineBoxId,
    List<FineDetails> selectedFines,
    int selectedAmount,
  ) async {
    if (selectedFines.isEmpty || selectedAmount <= 0) {
      return;
    }

    await FinesRepository.depositAmountToFineBox(
      fineBoxId,
      selectedAmount.toString(),
      selectedFines.map((fine) => fine.id).toList(),
    );
    AppAnalytics.logEvent(
      'fine_deposit_completed',
      parameters: {'fine_count': selectedFines.length},
    );
    if (mounted) {
      await _refreshFineBox();
    }
  }

  UserFineDetails? _findUserFineDetails(
    FineBoxDetails fineBox,
    UserDetails user,
  ) {
    for (final details in fineBox.userFineDetails) {
      if (details.userDetails.id == user.id) {
        return details;
      }
    }
    return null;
  }

  String _teamSubtitle(UserDetails user) {
    final teamTitle = user.teamDetails?.title;
    return teamTitle == null || teamTitle.isEmpty ? user.name : teamTitle;
  }
}

class _FineHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showBackButton;

  const _FineHeader({
    required this.title,
    required this.subtitle,
    required this.showBackButton,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, Spacing.md),
      child: Row(
        children: [
          if (showBackButton) ...[
            CupertinoButton(
              minimumSize: const Size.square(32),
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).maybePop(),
              child: Icon(
                CupertinoIcons.arrow_left,
                color: appColors.dirt,
                size: 22,
              ),
            ),
            const SizedBox(width: Spacing.itemGap),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: appTextStyles.pageTitle.copyWith(
                    color: appColors.dirt,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: appTextStyles.body3
                      .copyWith(color: appColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentTabs extends StatelessWidget {
  final TeamOwnerFinesSegments selectedSegment;
  final ValueChanged<TeamOwnerFinesSegments> onChanged;

  const _SegmentTabs({
    required this.selectedSegment,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        0,
        Spacing.md,
        Spacing.md,
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: appColors.surface,
          borderRadius: BorderRadius.circular(Spacing.borderRadiusFull),
        ),
        child: Row(
          children: TeamOwnerFinesSegments.values.map((segment) {
            final selected = selectedSegment == segment;
            return Expanded(
              child: Semantics(
                button: true,
                selected: selected,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(segment),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? appColors.grass : AppColors.transparent,
                      borderRadius:
                          BorderRadius.circular(Spacing.borderRadiusFull),
                    ),
                    child: Text(
                      switch (segment) {
                        TeamOwnerFinesSegments.overview =>
                          l10n.fineBoxSegmentOverview,
                        TeamOwnerFinesSegments.fineTypes =>
                          l10n.fineBoxSegmentFineTypes,
                        TeamOwnerFinesSegments.personal =>
                          l10n.fineBoxSegmentFines,
                      },
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: appTextStyles.caption.copyWith(
                        color: selected ? appColors.white : appColors.dirt,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Grass-coloured hero showing the full kitty with an animated count-up.
class _TeamHero extends StatelessWidget {
  final double total;
  final double collected;
  final double outstanding;
  final double progress;

  const _TeamHero({
    required this.total,
    required this.collected,
    required this.outstanding,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;

    return _HeroShell(
      color: appColors.grass,
      mascot: _thumbMascot,
      mascotColor: appColors.lightGrass,
      header: [
        InFormEyebrow(
          label: l10n.fineBoxHeroEyebrow,
          color: appColors.lightGrass,
        ),
        const SizedBox(height: Spacing.md),
        _CountUpAmount(
          amount: total,
          color: appColors.white,
          unitColor: appColors.lightGrass,
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          l10n.fineBoxPaidPercent((progress * 100).round()),
          style: appTextStyles.body3.copyWith(
            color: appColors.white.withValues(alpha: .86),
          ),
        ),
      ],
      footer: [
        _AnimatedProgressBar(
          value: progress,
          trackColor: appColors.white.withValues(alpha: .2),
          fillColor: appColors.lightGrass,
        ),
        const SizedBox(height: Spacing.md),
        Row(
          children: [
            Expanded(
              child: _HeroStat(
                label: l10n.fineBoxCollected,
                value: _kr(collected.round()),
                dotColor: appColors.lightGrass,
              ),
            ),
            Expanded(
              child: _HeroStat(
                label: l10n.fineBoxOutstanding,
                value: _kr(outstanding.round()),
                dotColor: appColors.white.withValues(alpha: .35),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Jord-coloured hero for players who still owe the team.
class _PersonalDebtHero extends StatelessWidget {
  final int amount;
  final int unpaidCount;

  const _PersonalDebtHero({required this.amount, required this.unpaidCount});

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;

    return _HeroShell(
      color: appColors.dirt,
      mascot: _flagMascot,
      mascotColor: appColors.lightGrass,
      header: [
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: [
            InFormEyebrow(
              label: l10n.fineBoxPersonalEyebrow,
              color: appColors.lightGrass,
            ),
            InFormEyebrow(
              label: l10n.fineBoxUnpaidCount(unpaidCount),
              color: appColors.sunset,
            ),
          ],
        ),
        const SizedBox(height: Spacing.md),
        _CountUpAmount(
          amount: amount.toDouble(),
          color: appColors.white,
          unitColor: appColors.sunset,
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          l10n.fineBoxPersonalOwed,
          style: appTextStyles.body3.copyWith(
            color: appColors.white.withValues(alpha: .86),
          ),
        ),
      ],
    );
  }
}

class _DebtFreeHero extends StatelessWidget {
  const _DebtFreeHero();

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;

    return _HeroShell(
      color: appColors.lightGrass,
      mascot: _heartMascot,
      mascotColor: appColors.grass,
      header: [
        InFormEyebrow(
          label: l10n.fineBoxPersonalEyebrow,
          color: appColors.surface,
        ),
        const SizedBox(height: Spacing.md),
        Text(
          l10n.fineBoxDebtFreeTitle,
          style: appTextStyles.h2.copyWith(color: appColors.dirt),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          l10n.fineBoxDebtFreeBody,
          style: appTextStyles.body3.copyWith(color: appColors.dirt),
        ),
      ],
    );
  }
}

class _HeroShell extends StatelessWidget {
  final Color color;
  final String mascot;
  final Color mascotColor;
  final List<Widget> header;
  final List<Widget> footer;

  const _HeroShell({
    required this.color,
    required this.mascot,
    required this.mascotColor,
    required this.header,
    this.footer = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusLargeIncreased),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            right: -6,
            child: _FloatingMascot(asset: mascot, color: mascotColor),
          ),
          Padding(
            padding: const EdgeInsets.all(Spacing.lg - 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 96),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: header,
                  ),
                ),
                if (footer.isNotEmpty) ...[
                  const SizedBox(height: Spacing.lg - 4),
                  ...footer,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mascot that drifts gently up and down to give the hero some life.
class _FloatingMascot extends StatefulWidget {
  final String asset;
  final Color color;

  const _FloatingMascot({required this.asset, required this.color});

  @override
  State<_FloatingMascot> createState() => _FloatingMascotState();
}

class _FloatingMascotState extends State<_FloatingMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final mascot = InFormMascot(
      asset: widget.asset,
      size: 108,
      color: widget.color,
    );
    if (reduceMotion) return mascot;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Transform.translate(
          offset: Offset(0, -6 * t),
          child: Transform.rotate(angle: (t - .5) * .08, child: child),
        );
      },
      child: mascot,
    );
  }
}

class _CountUpAmount extends StatelessWidget {
  final double amount;
  final Color color;
  final Color unitColor;

  const _CountUpAmount({
    required this.amount,
    required this.color,
    required this.unitColor,
  });

  @override
  Widget build(BuildContext context) {
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: amount),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _thousands(value.round()),
                style: appTextStyles.h2.copyWith(
                  color: color,
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'kr',
                style: appTextStyles.subtitle1.copyWith(color: unitColor),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnimatedProgressBar extends StatelessWidget {
  final double value;
  final Color trackColor;
  final Color fillColor;

  const _AnimatedProgressBar({
    required this.value,
    required this.trackColor,
    required this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Spacing.borderRadiusFull),
      child: Container(
        height: 10,
        color: trackColor,
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value),
          duration: const Duration(milliseconds: 1100),
          curve: Curves.easeOutCubic,
          builder: (context, animated, _) => FractionallySizedBox(
            widthFactor: animated,
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(Spacing.borderRadiusFull),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final Color dotColor;

  const _HeroStat({
    required this.label,
    required this.value,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 3),
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: appTextStyles.caption.copyWith(
                  color: appColors.white.withValues(alpha: .86),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: appTextStyles.subtitle1.copyWith(
                  color: appColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onGiveFine;
  final VoidCallback onDeposit;
  final VoidCallback onFineTypes;

  const _QuickActions({
    required this.onGiveFine,
    required this.onDeposit,
    required this.onFineTypes,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _PressableTile(
              color: appColors.dirt,
              onTap: onGiveFine,
              padding: const EdgeInsets.all(Spacing.md),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: appColors.lightGrass,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.plus,
                      color: appColors.dirt,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: Spacing.itemGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.fineBoxGiveFine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: appTextStyles.subtitle2.copyWith(
                            color: appColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.fineBoxGiveFineHint,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: appTextStyles.caption.copyWith(
                            color: appColors.white.withValues(alpha: .78),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          _SquareAction(
            icon: CupertinoIcons.arrow_down_circle,
            label: l10n.fineBoxDeposit,
            onTap: onDeposit,
          ),
          const SizedBox(width: Spacing.sm),
          _SquareAction(
            icon: CupertinoIcons.list_bullet,
            label: l10n.fineBoxSegmentFineTypes,
            onTap: onFineTypes,
          ),
        ],
      ),
    );
  }
}

class _SquareAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SquareAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return SizedBox(
      width: 78,
      child: _PressableTile(
        color: appColors.surface,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.xs,
          vertical: Spacing.itemGap,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: appColors.grass, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: appTextStyles.caption.copyWith(
                color: appColors.dirt,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tile that springs down slightly while pressed.
class _PressableTile extends StatefulWidget {
  final Widget child;
  final Color color;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;

  const _PressableTile({
    required this.child,
    required this.color,
    required this.onTap,
    required this.padding,
  });

  @override
  State<_PressableTile> createState() => _PressableTileState();
}

class _PressableTileState extends State<_PressableTile> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? .96 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(Spacing.borderRadiusLarge),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _PrimaryActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return _PressableTile(
      color: appColors.grass,
      onTap: onPressed,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: appColors.white, size: 20),
          const SizedBox(width: Spacing.sm),
          Text(
            label,
            style: appTextStyles.subtitle2.copyWith(
              color: appColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Classic three-step podium: second, first and third place.
class _FinePodium extends StatelessWidget {
  final List<_UserFineSummary> leaders;

  const _FinePodium({required this.leaders});

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    _UserFineSummary? at(int index) =>
        index < leaders.length ? leaders[index] : null;

    return InFormPanel(
      padding: const EdgeInsets.fromLTRB(
        Spacing.itemGap,
        Spacing.lg,
        Spacing.itemGap,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _PodiumColumn(
            summary: at(1),
            place: 2,
            blockHeight: 64,
            accent: appColors.sky,
            onAccent: appColors.white,
          ),
          const SizedBox(width: Spacing.sm),
          _PodiumColumn(
            summary: at(0),
            place: 1,
            blockHeight: 92,
            accent: appColors.grass,
            onAccent: appColors.white,
          ),
          const SizedBox(width: Spacing.sm),
          _PodiumColumn(
            summary: at(2),
            place: 3,
            blockHeight: 46,
            accent: appColors.sunset,
            onAccent: appColors.dirt,
          ),
        ],
      ),
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  final _UserFineSummary? summary;
  final int place;
  final double blockHeight;
  final Color accent;
  final Color onAccent;

  const _PodiumColumn({
    required this.summary,
    required this.place,
    required this.blockHeight,
    required this.accent,
    required this.onAccent,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final leader = place == 1;
    final summary = this.summary;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (summary != null) ...[
            if (leader)
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.xs),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: appColors.sunset,
                  size: 24,
                ),
              ),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accent, width: 2.5),
              ),
              child: InFormAvatar(
                name: summary.user.name,
                radius: leader ? 28 : 22,
                backgroundColor: appColors.offWhite,
                foregroundColor: appColors.dirt,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              _firstName(summary.user.name),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: appTextStyles.bodyBold.copyWith(
                color: appColors.dirt,
                fontSize: leader ? 16 : 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _kr(summary.unpaidAmount),
              style: appTextStyles.caption.copyWith(
                color: appColors.errorForeground,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: Spacing.sm),
          ],
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: summary == null ? 12 : blockHeight),
            duration: Duration(milliseconds: 700 + (3 - place) * 120),
            curve: Curves.easeOutBack,
            builder: (context, height, _) => Container(
              height: math.max(0, height),
              width: double.infinity,
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: Spacing.sm),
              decoration: BoxDecoration(
                color: summary == null ? appColors.offWhite : accent,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(Spacing.borderRadiusMedium),
                ),
              ),
              child: summary == null || height < 32
                  ? null
                  : Text(
                      '$place',
                      style: appTextStyles.h5.copyWith(
                        color: onAccent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Surface panel that stacks rows with hairline dividers between them.
class _GroupedPanel extends StatelessWidget {
  final List<Widget> children;

  const _GroupedPanel({required this.children});

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);

    return InFormPanel(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Spacing.borderRadiusLarge),
        child: Column(
          children: [
            for (var index = 0; index < children.length; index++) ...[
              children[index],
              if (index < children.length - 1)
                Divider(
                  height: 1,
                  indent: Spacing.md,
                  endIndent: Spacing.md,
                  color: appColors.divider.withValues(alpha: .4),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecentFineRow extends StatelessWidget {
  final _FineRowData row;

  const _RecentFineRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final paid = row.fine.hasBeenPaid;

    return Padding(
      padding: Spacing.listItemPadding,
      child: Row(
        children: [
          InFormAvatar(name: row.user.name, radius: 19),
          const SizedBox(width: Spacing.itemGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: appTextStyles.bodyBold.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 3),
                Text(
                  '${row.fine.fineTypeDetails.title} · ${_relativeDate(row.fine.createdAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: appTextStyles.caption
                      .copyWith(color: appColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          _AmountPill(
            amount: row.fine.owedAmount,
            paid: paid,
            paidLabel: l10n.fineBoxPaidBadge,
          ),
        ],
      ),
    );
  }
}

class _AmountPill extends StatelessWidget {
  final int amount;
  final bool paid;
  final String paidLabel;

  const _AmountPill({
    required this.amount,
    required this.paid,
    required this.paidLabel,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _kr(amount),
          style: appTextStyles.bodyBold.copyWith(
            color: paid ? appColors.textSecondary : appColors.errorForeground,
            fontWeight: FontWeight.w800,
            decoration: paid ? TextDecoration.lineThrough : null,
            decorationColor: appColors.textSecondary,
          ),
        ),
        if (paid) ...[
          const SizedBox(height: 3),
          Text(
            paidLabel,
            style: appTextStyles.caption.copyWith(
              color: appColors.successForeground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _SelectableFineRow extends StatelessWidget {
  final FineDetails fine;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableFineRow({
    required this.fine,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Semantics(
      checked: selected,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          color: selected ? appColors.lightGrass55 : AppColors.transparent,
          padding: Spacing.listItemPadding,
          child: Row(
            children: [
              _SelectionDot(selected: selected),
              const SizedBox(width: Spacing.itemGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fine.fineTypeDetails.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: appTextStyles.bodyBold.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _fineSubline(fine),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: appTextStyles.caption
                          .copyWith(color: appColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                _kr(fine.owedAmount),
                style: appTextStyles.bodyBold.copyWith(
                  color: selected
                      ? appColors.successForeground
                      : appColors.errorForeground,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionDot extends StatelessWidget {
  final bool selected;

  const _SelectionDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: selected ? appColors.grass : AppColors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? appColors.grass : appColors.grey4,
          width: 2,
        ),
      ),
      child: AnimatedScale(
        scale: selected ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: Icon(CupertinoIcons.checkmark, color: appColors.white, size: 14),
      ),
    );
  }
}

class _HistoryFineRow extends StatelessWidget {
  final FineDetails fine;

  const _HistoryFineRow({required this.fine});

  @override
  Widget build(BuildContext context) {
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: Spacing.listItemPadding,
      child: Row(
        children: [
          _DateBadge(date: fine.createdAt),
          const SizedBox(width: Spacing.itemGap),
          Expanded(
            child: Text(
              fine.fineTypeDetails.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: appTextStyles.bodyBold.copyWith(fontSize: 15),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          _AmountPill(
            amount: fine.owedAmount,
            paid: true,
            paidLabel: l10n.fineBoxPaidBadge,
          ),
        ],
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  final DateTime date;

  const _DateBadge({required this.date});

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      width: 44,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: appColors.offWhite,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusMedium),
      ),
      child: Column(
        children: [
          Text(
            date.day.toString().padLeft(2, '0'),
            style: appTextStyles.bodyBold.copyWith(
              color: appColors.dirt,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _monthName(date.month),
            style: appTextStyles.caption.copyWith(
              color: appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FineTypeRow extends StatefulWidget {
  final FineTypeDetails fineType;
  final VoidCallback onDeleted;

  const _FineTypeRow({
    required this.fineType,
    required this.onDeleted,
  });

  @override
  State<_FineTypeRow> createState() => _FineTypeRowState();
}

class _FineTypeRowState extends State<_FineTypeRow> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.itemGap,
        Spacing.xs,
        Spacing.itemGap,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: appColors.lightGrass55,
              borderRadius: BorderRadius.circular(Spacing.borderRadiusMedium),
            ),
            child: Icon(CupertinoIcons.tag, color: appColors.grass, size: 20),
          ),
          const SizedBox(width: Spacing.itemGap),
          Expanded(
            child: Text(
              widget.fineType.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: appTextStyles.bodyBold.copyWith(fontSize: 15),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: appColors.offWhite,
              borderRadius: BorderRadius.circular(Spacing.borderRadiusFull),
            ),
            child: Text(
              _kr(widget.fineType.defaultAmount),
              style: appTextStyles.caption.copyWith(
                color: appColors.dirt,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Semantics(
            button: true,
            label: localizations.fineTypeDeleteIconLabel,
            child: CupertinoButton(
              minimumSize: const Size(44, 44),
              padding: EdgeInsets.zero,
              onPressed: _isDeleting ? null : _confirmDelete,
              child: _isDeleting
                  ? CupertinoActivityIndicator(color: appColors.error)
                  : Icon(
                      CupertinoIcons.trash,
                      color: appColors.grey5,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final localizations = AppLocalizations.of(context)!;

    final shouldDelete = await showCupertinoDialog<bool>(
          context: context,
          builder: (dialogContext) => CupertinoAlertDialog(
            title: Text(localizations.fineTypeDeleteTitle),
            content: Text(
                localizations.fineTypeDeleteMessage(widget.fineType.title)),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(localizations.commonCancel),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(localizations.commonDelete),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete || !mounted) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      await FinesRepository.deleteFineType(widget.fineType.id);
      AppAnalytics.logEvent('fine_type_deleted');

      if (mounted) {
        widget.onDeleted();
      }
    } on FineTypeInUseException {
      if (mounted) {
        await _showDeleteFailure(localizations.fineTypeDeleteInUseMessage);
      }
    } catch (_) {
      if (mounted) {
        await _showDeleteFailure(localizations.fineTypeDeleteFailureMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<void> _showDeleteFailure(String message) {
    final localizations = AppLocalizations.of(context)!;

    return showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(localizations.fineTypeDeleteFailureTitle),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(localizations.commonOk),
          ),
        ],
      ),
    );
  }
}

class _MobilePaySetupPanel extends StatelessWidget {
  final bool isTeamOwner;
  final VoidCallback? onSetup;
  final bool framed;
  final String? configuredBox;

  const _MobilePaySetupPanel({
    required this.isTeamOwner,
    required this.onSetup,
    this.framed = true,
    this.configuredBox,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final isConfigured = configuredBox?.trim().isNotEmpty ?? false;

    final icon = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: appColors.lightSky55,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusMedium),
      ),
      child: Icon(CupertinoIcons.creditcard, color: appColors.sky, size: 20),
    );

    // Once the Box is set up the owner only needs a compact status row.
    if (isConfigured && framed) {
      return InFormPanel(
        padding: const EdgeInsets.fromLTRB(
          Spacing.md,
          Spacing.itemGap,
          Spacing.xs,
          Spacing.itemGap,
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: Spacing.itemGap),
            Expanded(
              child: Text(
                l10n.fineBoxMobilePayConnected,
                style: appTextStyles.bodyBold.copyWith(fontSize: 15),
              ),
            ),
            Icon(
              CupertinoIcons.checkmark_seal_fill,
              color: appColors.grass,
              size: 20,
            ),
            if (isTeamOwner && onSetup != null)
              Semantics(
                button: true,
                label: l10n.mobilePayBoxEdit,
                child: CupertinoButton(
                  minimumSize: const Size(44, 44),
                  padding: EdgeInsets.zero,
                  onPressed: onSetup,
                  child: Icon(
                    CupertinoIcons.pencil,
                    color: appColors.grey5,
                    size: 20,
                  ),
                ),
              )
            else
              const SizedBox(width: Spacing.itemGap),
          ],
        ),
      );
    }

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        icon,
        const SizedBox(width: Spacing.itemGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isConfigured
                    ? l10n.mobilePayBoxTitle
                    : l10n.mobilePayBoxMissing,
                style: appTextStyles.bodyBold.copyWith(fontSize: 15),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                isTeamOwner
                    ? l10n.mobilePayBoxInstructions
                    : l10n.mobilePayBoxOwnerRequired,
                style: appTextStyles.body3.copyWith(
                  color: appColors.textSecondary,
                ),
              ),
              if (isTeamOwner && onSetup != null) ...[
                const SizedBox(height: Spacing.itemGap),
                InFormPill(
                  label: isConfigured
                      ? l10n.mobilePayBoxEdit
                      : l10n.mobilePayBoxAdd,
                  icon: isConfigured
                      ? CupertinoIcons.pencil
                      : CupertinoIcons.plus,
                  selected: true,
                  selectedColor: appColors.sky,
                  onTap: onSetup!,
                ),
              ],
            ],
          ),
        ),
      ],
    );

    return framed
        ? InFormPanel(
            color: appColors.lightSky55,
            child: content,
          )
        : content;
  }
}

class _PaymentPanel extends StatelessWidget {
  final int selectedCount;
  final int selectedAmount;
  final String userName;
  final String? mobilePayBoxId;
  final bool isTeamOwner;
  final VoidCallback? onSetupMobilePay;
  final VoidCallback? onCashPaid;

  const _PaymentPanel({
    required this.selectedCount,
    required this.selectedAmount,
    required this.userName,
    required this.mobilePayBoxId,
    required this.isTeamOwner,
    required this.onSetupMobilePay,
    required this.onCashPaid,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final l10n = AppLocalizations.of(context)!;
    final hasBox = mobilePayBoxId?.trim().isNotEmpty ?? false;

    return InFormPanel(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  l10n.fineBoxSelectedCount(selectedCount),
                  style: appTextStyles.body3.copyWith(
                    color: appColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: Text(
                  _kr(selectedAmount),
                  key: ValueKey(selectedAmount),
                  style: appTextStyles.sectionHeader.copyWith(
                    color: appColors.dirt,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.itemGap),
          if (!hasBox)
            _MobilePaySetupPanel(
              isTeamOwner: isTeamOwner,
              onSetup: onSetupMobilePay,
              framed: false,
            )
          else
            MobilePayButton(
              amount: selectedAmount,
              message: 'Bøder - $userName',
              mobilePayBoxId: mobilePayBoxId,
              buttonText: l10n.mobilePayDeposit,
              outlined: false,
              width: double.infinity,
            ),
          const SizedBox(height: Spacing.sm),
          Center(
            child: CupertinoButton(
              minimumSize: const Size(0, 36),
              padding: EdgeInsets.zero,
              onPressed: onCashPaid,
              child: Text(
                l10n.fineBoxMarkCashPaid,
                style: appTextStyles.caption.copyWith(
                  color: onCashPaid == null
                      ? appColors.textSecondary.withValues(alpha: .45)
                      : appColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MascotMessage extends StatelessWidget {
  final String text;
  final String mascot;
  final Color color;

  const _MascotMessage({
    required this.text,
    required this.mascot,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return InFormPanel(
      color: color,
      padding: const EdgeInsets.all(Spacing.md),
      child: Row(
        children: [
          InFormMascot(asset: mascot, size: 64, color: appColors.dirt),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text(
              text,
              style: appTextStyles.body.copyWith(color: appColors.dirt),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final String text;

  const _EmptyPanel({required this.text});

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return InFormPanel(
      padding: const EdgeInsets.all(Spacing.md + 2),
      child: Text(
        text,
        style: appTextStyles.body3.copyWith(color: appColors.textSecondary),
      ),
    );
  }
}

class _UserFineSummary {
  final UserDetails user;
  final int fineCount;
  final int unpaidAmount;
  final int paidAmount;

  const _UserFineSummary({
    required this.user,
    required this.fineCount,
    required this.unpaidAmount,
    required this.paidAmount,
  });
}

class _FineRowData {
  final UserDetails user;
  final FineDetails fine;

  const _FineRowData({required this.user, required this.fine});
}

List<_UserFineSummary> _userFineSummaries(List<UserFineDetails> details) {
  return details.map((userFine) {
    final unpaid = userFine.fineDetailsList
        .where((fine) => !fine.hasBeenPaid)
        .fold<int>(0, (sum, fine) => sum + fine.owedAmount);
    final paid = userFine.fineDetailsList
        .where((fine) => fine.hasBeenPaid)
        .fold<int>(0, (sum, fine) => sum + fine.owedAmount);
    return _UserFineSummary(
      user: userFine.userDetails,
      fineCount: userFine.fineDetailsList.length,
      unpaidAmount: unpaid,
      paidAmount: paid,
    );
  }).toList();
}

List<_FineRowData> _fineRows(List<UserFineDetails> details) {
  return details
      .expand((userFine) => userFine.fineDetailsList.map(
            (fine) => _FineRowData(user: userFine.userDetails, fine: fine),
          ))
      .toList();
}

/// Danish-style thousands grouping, e.g. 12500 -> 12.500.
String _thousands(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

String _kr(int amount) => '${_thousands(amount)} kr';

String _firstName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    return 'Spiller';
  }
  return trimmed.split(RegExp(r'\s+')).first;
}

String _fineSubline(FineDetails fine) {
  final note = fine.note?.trim();
  final date = '${fine.createdAt.day.toString().padLeft(2, '0')}. '
      '${_monthName(fine.createdAt.month)}';
  if (note == null || note.isEmpty) {
    return date;
  }
  return '$date · $note';
}

String _relativeDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final fineDay = DateTime(date.year, date.month, date.day);
  final days = today.difference(fineDay).inDays;
  if (days <= 0) {
    final hours = math.max(1, now.difference(date).inHours);
    return hours == 1 ? '1 time siden' : '$hours timer siden';
  }
  if (days == 1) {
    return 'I går';
  }
  return '$days dage siden';
}

String _monthName(int month) {
  return switch (month) {
    1 => 'Jan',
    2 => 'Feb',
    3 => 'Mar',
    4 => 'Apr',
    5 => 'Maj',
    6 => 'Jun',
    7 => 'Jul',
    8 => 'Aug',
    9 => 'Sep',
    10 => 'Okt',
    11 => 'Nov',
    12 => 'Dec',
    _ => '',
  };
}
