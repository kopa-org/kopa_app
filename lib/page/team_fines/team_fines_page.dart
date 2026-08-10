import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/component/button/mobile_pay_button.dart';
import 'package:kopa/component/future_handler.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/model/fine_box_details.dart';
import 'package:kopa/model/fine_details.dart';
import 'package:kopa/model/fine_type_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/model/user_fine_details.dart';
import 'package:kopa/page/team_fines/assign_fines_modal.dart';
import 'package:kopa/page/team_fines/create_fine_type_modal.dart';
import 'package:kopa/page/team_fines/deposit_modal.dart';
import 'package:kopa/repository/fines_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/utils/app_analytics.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

enum TeamOwnerFinesSegments { overview, fineTypes, personal }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return PageScaffold(
      title: 'Bødekassen',
      showBackButton: widget.showBackButton,
      showTopBar: false,
      backgroundColor: appColors.background,
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
                color: appColors.primary,
                onRefresh: _refreshFineBox,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _FineHeader(
                        title: segment == TeamOwnerFinesSegments.personal
                            ? 'Mine Bøder'
                            : 'Bødekassen',
                        subtitle: _teamSubtitle(user),
                        showBackButton: widget.showBackButton,
                      ),
                    ),
                    if (user.isTeamOwner)
                      SliverToBoxAdapter(
                        child: _SegmentTabs(
                          selectedSegment: _selectedSegment,
                          onChanged: (value) {
                            AppAnalytics.logEvent(
                              'fine_box_segment_selected',
                              parameters: {'segment': value.name},
                            );
                            setState(() {
                              _selectedSegment = value;
                            });
                          },
                        ),
                      ),
                    if (segment == TeamOwnerFinesSegments.overview)
                      SliverToBoxAdapter(
                        child: _buildOverview(
                          fineBox,
                          user,
                          appColors,
                          appTextStyles,
                        ),
                      )
                    else if (segment == TeamOwnerFinesSegments.fineTypes)
                      SliverToBoxAdapter(
                        child: _buildFineTypes(
                          appColors,
                          appTextStyles,
                        ),
                      )
                    else
                      SliverToBoxAdapter(
                        child: _buildPersonal(
                          fineBox,
                          user,
                          appColors,
                          appTextStyles,
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

  Widget _buildOverview(
    FineBoxDetails fineBox,
    UserDetails user,
    AppColors appColors,
    AppTextStyles appTextStyles,
  ) {
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _KpiCard(
            label: 'Bødekassen total',
            amount: total,
            amountColor: appColors.success,
            icon: Icons.savings_outlined,
            bottom: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _InlineAmount(
                        label: 'Indsamlet',
                        amount: fineBox.currentAmount,
                      ),
                    ),
                    _InlineAmount(
                      label: 'Mangler',
                      amount: fineBox.totalOwedAmount,
                      amountColor: appColors.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: progress,
                    backgroundColor: appColors.grey2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(appColors.success),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _PrimaryActionButton(
            icon: CupertinoIcons.plus_circle,
            label: 'Giv bøde',
            onPressed: _openAssignFines,
          ),
          const SizedBox(height: 16),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitleRow(
                  title: 'Top syndere',
                  actionLabel: 'Personlig',
                  onAction: () {
                    setState(() {
                      _selectedSegment = TeamOwnerFinesSegments.personal;
                    });
                  },
                ),
                const SizedBox(height: 12),
                if (topOffenders.isEmpty)
                  Text(
                    'Ingen udestående bøder.',
                    style: appTextStyles.body3
                        .copyWith(color: appColors.textSecondary),
                  )
                else
                  Row(
                    children: topOffenders.take(3).map((summary) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _OffenderCard(summary: summary),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionTitleRow(title: 'Seneste bøder'),
          const SizedBox(height: 10),
          if (recentFines.isEmpty)
            _EmptyPanel(text: 'Ingen bøder tildelt endnu.')
          else
            ...recentFines.take(5).map(
                  (row) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _RecentFineRow(row: row),
                  ),
                ),
          const SizedBox(height: 8),
          _SecondaryActionRow(
            buttons: [
              _ActionSpec(
                label: 'Indbetal',
                icon: CupertinoIcons.arrow_up_square,
                onPressed: () => _openTeamDeposit(fineBox),
              ),
              _ActionSpec(
                label: 'Bødetyper',
                icon: CupertinoIcons.list_bullet,
                onPressed: () {
                  setState(() {
                    _selectedSegment = TeamOwnerFinesSegments.fineTypes;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFineTypes(
    AppColors appColors,
    AppTextStyles appTextStyles,
  ) {
    return FutureHandler<List<FineTypeDetails>>(
      future: fineTypeDetails,
      allowEmpty: true,
      onSuccess: (context, fineTypes) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PrimaryActionButton(
                icon: CupertinoIcons.plus_circle,
                label: 'Opret bødetype',
                onPressed: () => _openCreateFineType(fineTypes),
              ),
              const SizedBox(height: 16),
              _SectionTitleRow(title: 'Bødekatalog'),
              const SizedBox(height: 10),
              if (fineTypes.isEmpty)
                _EmptyPanel(text: 'Ingen bødetyper endnu.')
              else
                ...fineTypes.map(
                  (fineType) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _FineTypeRow(fineType: fineType),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPersonal(
    FineBoxDetails fineBox,
    UserDetails user,
    AppColors appColors,
    AppTextStyles appTextStyles,
  ) {
    final userFineDetails = _findUserFineDetails(fineBox, user);
    final allFines = userFineDetails?.fineDetailsList ?? [];
    final unpaidFines = allFines.where((fine) => !fine.hasBeenPaid).toList();
    final selectedFines = unpaidFines
        .where((fine) => _selectedPersonalFineIds.contains(fine.id))
        .toList();
    final unpaidAmount = unpaidFines.fold<int>(
      0,
      (sum, fine) => sum + fine.owedAmount,
    );
    final paidAmount = allFines
        .where((fine) => fine.hasBeenPaid)
        .fold<int>(0, (sum, fine) => sum + fine.owedAmount);
    final selectedAmount = selectedFines.fold<int>(
      0,
      (sum, fine) => sum + fine.owedAmount,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _KpiCard(
            label: 'Udestående hos holdet',
            amount: unpaidAmount.toDouble(),
            amountColor: appColors.error,
            icon: Icons.savings_outlined,
            bottom: Row(
              children: [
                Expanded(
                  child: Text(
                    'Alt udestående skal afregnes herunder',
                    style: appTextStyles.body3
                        .copyWith(color: appColors.textSecondary),
                  ),
                ),
                _SmallBadge(
                  label: '${unpaidFines.length} ubetalte',
                  backgroundColor: appColors.warning.withValues(alpha: .18),
                  textColor: const Color(0xFFB77900),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _PersonalStatTile(label: 'Bøder', value: '${allFines.length}'),
              const SizedBox(width: 8),
              _PersonalStatTile(
                label: 'Udestående',
                value: '$unpaidAmount kr',
                valueColor: appColors.error,
              ),
              const SizedBox(width: 8),
              _PersonalStatTile(label: 'Betalt', value: '$paidAmount kr'),
            ],
          ),
          const SizedBox(height: 18),
          _SectionTitleRow(
            title: 'Ubetalte bøder',
            actionLabel: unpaidFines.isEmpty
                ? null
                : _selectedPersonalFineIds.length == unpaidFines.length
                    ? 'Fravælg alle (${unpaidFines.length})'
                    : 'Vælg alle (${unpaidFines.length})',
            onAction: unpaidFines.isEmpty
                ? null
                : () => _toggleAllPersonalFines(unpaidFines),
          ),
          const SizedBox(height: 10),
          if (unpaidFines.isEmpty)
            _EmptyPanel(text: 'Du har ingen ubetalte bøder.')
          else
            ...unpaidFines.map(
              (fine) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SelectableFineRow(
                  fine: fine,
                  selected: _selectedPersonalFineIds.contains(fine.id),
                  onTap: () => _togglePersonalFine(fine.id),
                ),
              ),
            ),
          if (allFines.any((fine) => fine.hasBeenPaid)) ...[
            const SizedBox(height: 18),
            _SectionTitleRow(title: 'Tidligere bøder'),
            const SizedBox(height: 10),
            ...allFines.where((fine) => fine.hasBeenPaid).take(5).map(
                  (fine) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _HistoryFineRow(fine: fine),
                  ),
                ),
          ],
          if (unpaidFines.isNotEmpty) ...[
            const SizedBox(height: 16),
            _PaymentFooter(
              selectedCount: selectedFines.length,
              selectedAmount: selectedAmount,
              userName: user.name,
              onCashPaid: selectedFines.isEmpty
                  ? null
                  : () => _markSelectedPersonalFinesPaid(
                        fineBox.id,
                        selectedFines,
                        selectedAmount,
                      ),
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
      builder: (context) => DepositModal(fineBoxId: fineBox.id),
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
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (showBackButton) ...[
                CupertinoButton(
                  minimumSize: const Size.square(32),
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: Icon(
                    CupertinoIcons.arrow_left,
                    color: appColors.textPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: appTextStyles.h5.copyWith(
                    color: appColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: appTextStyles.body3.copyWith(color: appColors.textSecondary),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: TeamOwnerFinesSegments.values.map((segment) {
          final isSelected = selectedSegment == segment;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _SegmentChip(
                label: switch (segment) {
                  TeamOwnerFinesSegments.overview => 'Overblik',
                  TeamOwnerFinesSegments.fineTypes => 'Katalog',
                  TeamOwnerFinesSegments.personal => 'Mine',
                },
                selected: isSelected,
                onTap: () => onChanged(segment),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SegmentChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return CupertinoButton(
      minimumSize: const Size(0, 36),
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? appColors.grey2 : appColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? appColors.success : appColors.surface,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: appTextStyles.buttonSmall.copyWith(
            color: selected ? appColors.success : appColors.textSecondary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color amountColor;
  final IconData icon;
  final Widget bottom;

  const _KpiCard({
    required this.label,
    required this.amount,
    required this.amountColor,
    required this.icon,
    required this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return _SectionCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: appTextStyles.caption1.copyWith(
                        color: appColors.textSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatAmount(amount),
                      style: appTextStyles.h3.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: appColors.grey2,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: appColors.success, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: appColors.divider.withValues(alpha: .35), height: 1),
          const SizedBox(height: 16),
          bottom,
        ],
      ),
    );
  }
}

class _InlineAmount extends StatelessWidget {
  final String label;
  final double amount;
  final Color? amountColor;

  const _InlineAmount({
    required this.label,
    required this.amount,
    this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return RichText(
      text: TextSpan(
        style: appTextStyles.body3.copyWith(color: appColors.textSecondary),
        children: [
          TextSpan(text: '$label: '),
          TextSpan(
            text: '${amount.toStringAsFixed(0)} kr',
            style: TextStyle(
              color: amountColor ?? appColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
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
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: appColors.success,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: appColors.surface, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: appTextStyles.subtitle2.copyWith(
                color: appColors.surface,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryActionRow extends StatelessWidget {
  final List<_ActionSpec> buttons;

  const _SecondaryActionRow({required this.buttons});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: buttons.map((button) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _SecondaryActionButton(spec: button),
          ),
        );
      }).toList(),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final _ActionSpec spec;

  const _SecondaryActionButton({required this.spec});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: spec.onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: appColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(spec.icon, color: appColors.primary, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                spec.label,
                overflow: TextOverflow.ellipsis,
                style: appTextStyles.buttonSmall.copyWith(
                  color: appColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionSpec {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionSpec({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: appColors.black.withValues(alpha: .03),
            blurRadius: 8,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitleRow extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionTitleRow({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: appTextStyles.subtitle2.copyWith(
              color: appColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (actionLabel != null)
          CupertinoButton(
            minimumSize: const Size(0, 24),
            padding: EdgeInsets.zero,
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: appTextStyles.caption2.copyWith(
                color: appColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      ],
    );
  }
}

class _OffenderCard extends StatelessWidget {
  final _UserFineSummary summary;

  const _OffenderCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appColors.grey2,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _Avatar(initials: _initials(summary.user.name), size: 40),
          const SizedBox(height: 8),
          Text(
            _firstName(summary.user.name),
            overflow: TextOverflow.ellipsis,
            style: appTextStyles.caption2.copyWith(
              color: appColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            '${summary.unpaidAmount} kr',
            style: appTextStyles.caption2.copyWith(
              color: appColors.error,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentFineRow extends StatelessWidget {
  final _FineRowData row;

  const _RecentFineRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _Avatar(initials: _initials(row.user.name), size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.user.name,
                  overflow: TextOverflow.ellipsis,
                  style: appTextStyles.body3.copyWith(
                    color: appColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${row.fine.fineTypeDetails.title} • ${_relativeDate(row.fine.createdAt)}',
                  overflow: TextOverflow.ellipsis,
                  style: appTextStyles.caption1
                      .copyWith(color: appColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            '${row.fine.owedAmount} kr',
            style: appTextStyles.subtitle2.copyWith(
              color: appColors.error,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalStatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _PersonalStatTile({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: appColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: appTextStyles.caption3.copyWith(
                color: appColors.textSecondary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: appTextStyles.subtitle1.copyWith(
                color: valueColor ?? appColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
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
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? appColors.grey2 : appColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? appColors.success : appColors.surface,
          ),
        ),
        child: Row(
          children: [
            _SelectionDot(selected: selected),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fine.fineTypeDetails.title,
                    overflow: TextOverflow.ellipsis,
                    style: appTextStyles.body3.copyWith(
                      color: appColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    _fineSubline(fine),
                    overflow: TextOverflow.ellipsis,
                    style: appTextStyles.caption1
                        .copyWith(color: appColors.textSecondary),
                  ),
                ],
              ),
            ),
            Text(
              '${fine.owedAmount} kr',
              style: appTextStyles.subtitle2.copyWith(
                color: selected ? appColors.primary : appColors.error,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
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
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: selected ? appColors.success : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: selected ? appColors.success : appColors.grey4,
          width: 2,
        ),
      ),
      child: selected
          ? Icon(CupertinoIcons.checkmark, color: appColors.surface, size: 13)
          : null,
    );
  }
}

class _HistoryFineRow extends StatelessWidget {
  final FineDetails fine;

  const _HistoryFineRow({required this.fine});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _DatePill(date: fine.createdAt),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fine.fineTypeDetails.title,
                  overflow: TextOverflow.ellipsis,
                  style: appTextStyles.body3.copyWith(
                    color: appColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${fine.owedAmount} kr',
                  style: appTextStyles.body3.copyWith(
                    color: appColors.error,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          _SmallBadge(
            label: 'BETALT',
            backgroundColor: appColors.grey2,
            textColor: appColors.success,
          ),
        ],
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  final DateTime date;

  const _DatePill({required this.date});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return SizedBox(
      width: 44,
      child: Column(
        children: [
          Text(
            date.day.toString().padLeft(2, '0'),
            style: appTextStyles.caption2.copyWith(
              color: appColors.textSecondary,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            _monthName(date.month),
            style: appTextStyles.caption1.copyWith(
              color: appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FineTypeRow extends StatelessWidget {
  final FineTypeDetails fineType;

  const _FineTypeRow({required this.fineType});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: appColors.grey2,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(CupertinoIcons.tag, color: appColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fineType.title,
              overflow: TextOverflow.ellipsis,
              style: appTextStyles.body3.copyWith(
                color: appColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            '${fineType.defaultAmount} kr',
            style: appTextStyles.subtitle2.copyWith(
              color: appColors.error,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentFooter extends StatelessWidget {
  final int selectedCount;
  final int selectedAmount;
  final String userName;
  final VoidCallback? onCashPaid;

  const _PaymentFooter({
    required this.selectedCount,
    required this.selectedAmount,
    required this.userName,
    required this.onCashPaid,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: appColors.black.withValues(alpha: .05),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Valgt: $selectedCount bøder',
                    style: appTextStyles.body3.copyWith(
                      color: appColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  'Total: ',
                  style: appTextStyles.body3.copyWith(
                    color: appColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$selectedAmount kr',
                  style: appTextStyles.subtitle1.copyWith(
                    color: appColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            MobilePayButton(
              amount: selectedAmount,
              message: 'Bøder - $userName',
              buttonText: 'Indbetal med MobilePay',
            ),
            const SizedBox(height: 8),
            CupertinoButton(
              minimumSize: const Size(0, 24),
              padding: EdgeInsets.zero,
              onPressed: onCashPaid,
              child: Text(
                'Eller markér som kontant betalt',
                style: appTextStyles.caption2.copyWith(
                  color: onCashPaid == null
                      ? appColors.textSecondary.withValues(alpha: .45)
                      : appColors.textSecondary,
                  fontWeight: FontWeight.w900,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _SmallBadge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: appTextStyles.caption3.copyWith(
          color: textColor,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  final double size;

  const _Avatar({required this.initials, required this.size});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: appColors.grey2,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Text(
        initials,
        style: appTextStyles.caption2.copyWith(
          color: appColors.success,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final String text;

  const _EmptyPanel({required this.text});

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
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

String _formatAmount(double amount) => '${amount.toStringAsFixed(0)},-';

String _initials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    return '?';
  }
  return parts.take(2).map((part) => part[0].toUpperCase()).join();
}

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
  return '$date • $note';
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
