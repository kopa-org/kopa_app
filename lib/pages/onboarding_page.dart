import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/onboarding_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

enum _OnboardingMode { create, join }

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _teamNameController = TextEditingController();
  final _searchController = TextEditingController();
  _OnboardingMode _mode = _OnboardingMode.create;
  int _createStep = 0;
  Map<String, dynamic>? _dbuData;
  Set<int> _selectedPlayerIndexes = {};

  @override
  void dispose() {
    _teamNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openDbu() async {
    final result = await context.push<String>(AppRouter.dbuWebview);
    if (result == null) return;

    final decoded = jsonDecode(result) as Map<String, dynamic>;
    final players = decoded['players'] as List<dynamic>? ?? [];
    final suggestedTeamName = _suggestedTeamName(decoded);
    setState(() {
      _dbuData = decoded;
      _teamNameController.text = suggestedTeamName.isNotEmpty
          ? suggestedTeamName
          : _teamNameController.text;
      _selectedPlayerIndexes = {
        for (var i = 0; i < players.length; i++)
          if (_emailLike(
              (players[i] as Map<String, dynamic>)['contact'] as String? ?? ''))
            i,
      };
      _createStep = 0;
    });
  }

  Future<void> _createTeam() async {
    final title = _teamNameController.text.trim();
    if (title.isEmpty) return;

    final players = (_dbuData?['players'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final inviteEmails = _selectedPlayerIndexes
        .map((index) => players[index]['contact'] as String? ?? '')
        .where(_emailLike)
        .toList();

    final success = await context.read<OnboardingCubit>().createTeam(
          title: title,
          dbuCalendarUrl: _dbuData?['webcal'] as String?,
          dbuContext: _dbuData,
          matches: (_dbuData?['matches'] as List<dynamic>? ?? [])
              .cast<Map<String, dynamic>>(),
          standings: (_dbuData?['standings'] as List<dynamic>? ?? [])
              .cast<Map<String, dynamic>>(),
          inviteEmails: inviteEmails,
        );

    if (success && mounted) {
      await context.read<AuthCubit>().init();
      if (mounted) context.go(AppRouter.home);
    }
  }

  Future<void> _requestJoin(int teamId) async {
    await context.read<OnboardingCubit>().requestToJoinTeam(teamId);
  }

  void _handlePrimaryAction() {
    if (_mode == _OnboardingMode.join) return;

    if (_createStep == 0 && _dbuData != null) {
      setState(() => _createStep = _hasPlayers ? 1 : 2);
      return;
    }

    if (_createStep == 1) {
      setState(() => _createStep = 2);
      return;
    }

    _createTeam();
  }

  bool get _hasPlayers {
    return (_dbuData?['players'] as List<dynamic>? ?? []).isNotEmpty;
  }

  bool get _hasMatches {
    return (_dbuData?['matches'] as List<dynamic>? ?? []).isNotEmpty;
  }

  bool _emailLike(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim());
  }

  String _suggestedTeamName(Map<String, dynamic> dbuData) {
    for (final key in ['suggestedTeamName', 'teamName', 'teamLabel']) {
      final value = dbuData[key] as String?;
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final textStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state.status == OnboardingStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? l10n.onboardingFailure),
              backgroundColor: colors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == OnboardingStatus.waitingApproval) {
          return _WaitingView(
            title: l10n.onboardingWaitingTitle,
            body: l10n.onboardingWaitingBody,
            cancelLabel: l10n.onboardingCancel,
            loading: state.status == OnboardingStatus.loading,
            onCancel: () =>
                context.read<OnboardingCubit>().cancelPendingJoinRequest(),
          );
        }

        final loading = state.status == OnboardingStatus.loading;
        final step = _mode == _OnboardingMode.create ? _createStep : 0;
        final title = _mode == _OnboardingMode.join
            ? l10n.onboardingJoinTeam
            : switch (_createStep) {
                0 => l10n.onboardingTitle,
                1 => 'Tilføj spillere',
                _ => l10n.onboardingMatches,
              };
        final subtitle = _mode == _OnboardingMode.join
            ? 'Find dit hold og send en anmodning til administratorerne.'
            : switch (_createStep) {
                0 =>
                  'Opret dit fodboldhold og saml spillere, kampe og statistikker ét sted.',
                1 =>
                  'Invitér spillere til holdet. De modtager en mail-invitation med det samme.',
                _ =>
                  'Synkroniser holdets kampprogram. Vi henter automatisk tider og steder fra DBU.',
              };
        final canAdvance = _mode == _OnboardingMode.create &&
            _teamNameController.text.trim().isNotEmpty &&
            !loading;
        final primaryLabel = _createStep == 2 || _dbuData == null
            ? l10n.onboardingCreate
            : l10n.onboardingContinue;

        return Scaffold(
          backgroundColor: colors.background,
          bottomNavigationBar: _mode == _OnboardingMode.create
              ? _BottomActionBar(
                  colors: colors,
                  textStyles: textStyles,
                  label: primaryLabel,
                  loading: loading,
                  icon: _createStep == 2 ? Icons.check : null,
                  onPressed: canAdvance ? _handlePrimaryAction : null,
                )
              : null,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: _KopaHeader(colors: colors),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    child: _OnboardingTitle(
                      colors: colors,
                      textStyles: textStyles,
                      step: step,
                      title: title,
                      subtitle: subtitle,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    _mode == _OnboardingMode.create && _createStep == 0
                        ? 20
                        : 16,
                    20,
                    _mode == _OnboardingMode.create && _createStep == 0
                        ? 20
                        : 16,
                    28,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _mode == _OnboardingMode.create
                        ? _CreateTeamView(
                            l10n: l10n,
                            colors: colors,
                            textStyles: textStyles,
                            step: _createStep,
                            teamNameController: _teamNameController,
                            dbuData: _dbuData,
                            selectedPlayerIndexes: _selectedPlayerIndexes,
                            loading: loading,
                            onOpenDbu: _openDbu,
                            onModeChanged: (mode) =>
                                setState(() => _mode = mode),
                            onTextChanged: () => setState(() {}),
                            onPlayerChanged: (index, selected) {
                              setState(() {
                                if (selected) {
                                  _selectedPlayerIndexes.add(index);
                                } else {
                                  _selectedPlayerIndexes.remove(index);
                                }
                              });
                            },
                          )
                        : _JoinTeamView(
                            l10n: l10n,
                            colors: colors,
                            textStyles: textStyles,
                            controller: _searchController,
                            results: state.searchResults,
                            loading: loading,
                            onModeChanged: (mode) =>
                                setState(() => _mode = mode),
                            onSearch:
                                context.read<OnboardingCubit>().searchTeams,
                            onRequestJoin: _requestJoin,
                          ),
                  ),
                ),
                if (_mode == _OnboardingMode.create && !_hasMatches)
                  const SliverFillRemaining(hasScrollBody: false),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CreateTeamView extends StatelessWidget {
  final AppLocalizations l10n;
  final AppColors colors;
  final AppTextStyles textStyles;
  final int step;
  final TextEditingController teamNameController;
  final Map<String, dynamic>? dbuData;
  final Set<int> selectedPlayerIndexes;
  final bool loading;
  final VoidCallback onOpenDbu;
  final ValueChanged<_OnboardingMode> onModeChanged;
  final VoidCallback onTextChanged;
  final void Function(int index, bool selected) onPlayerChanged;

  const _CreateTeamView({
    required this.l10n,
    required this.colors,
    required this.textStyles,
    required this.step,
    required this.teamNameController,
    required this.dbuData,
    required this.selectedPlayerIndexes,
    required this.loading,
    required this.onOpenDbu,
    required this.onModeChanged,
    required this.onTextChanged,
    required this.onPlayerChanged,
  });

  @override
  Widget build(BuildContext context) {
    final players = (dbuData?['players'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final matches = (dbuData?['matches'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    return switch (step) {
      0 => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ModeToggle(
              colors: colors,
              textStyles: textStyles,
              mode: _OnboardingMode.create,
              onChanged: onModeChanged,
            ),
            const SizedBox(height: 20),
            _FieldLabel(
                text: 'Forbund', colors: colors, textStyles: textStyles),
            const SizedBox(height: 8),
            _DbuCard(
              colors: colors,
              textStyles: textStyles,
              hasData: dbuData != null,
              onPressed: loading ? null : onOpenDbu,
            ),
            const SizedBox(height: 20),
            _FieldLabel(
              text: l10n.onboardingTeamName,
              colors: colors,
              textStyles: textStyles,
            ),
            const SizedBox(height: 8),
            _TextInput(
              colors: colors,
              textStyles: textStyles,
              controller: teamNameController,
              hintText: 'Skjold 7',
              onChanged: (_) => onTextChanged(),
            ),
          ],
        ),
      1 => _PlayersStep(
          colors: colors,
          textStyles: textStyles,
          players: players,
          selectedPlayerIndexes: selectedPlayerIndexes,
          onPlayerChanged: onPlayerChanged,
        ),
      _ => _MatchesStep(
          colors: colors,
          textStyles: textStyles,
          teamName: teamNameController.text.trim(),
          selectedCount: selectedPlayerIndexes.length,
          matches: matches,
        ),
    };
  }
}

class _JoinTeamView extends StatelessWidget {
  final AppLocalizations l10n;
  final AppColors colors;
  final AppTextStyles textStyles;
  final TextEditingController controller;
  final List<Map<String, dynamic>> results;
  final bool loading;
  final ValueChanged<_OnboardingMode> onModeChanged;
  final ValueChanged<String> onSearch;
  final ValueChanged<int> onRequestJoin;

  const _JoinTeamView({
    required this.l10n,
    required this.colors,
    required this.textStyles,
    required this.controller,
    required this.results,
    required this.loading,
    required this.onModeChanged,
    required this.onSearch,
    required this.onRequestJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ModeToggle(
          colors: colors,
          textStyles: textStyles,
          mode: _OnboardingMode.join,
          onChanged: onModeChanged,
        ),
        const SizedBox(height: 20),
        _SearchInput(
          colors: colors,
          textStyles: textStyles,
          controller: controller,
          hintText: l10n.onboardingSearchHint,
          onChanged: onSearch,
        ),
        const SizedBox(height: 12),
        if (loading) LinearProgressIndicator(color: colors.primary),
        if (!loading && controller.text.length >= 2 && results.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              l10n.onboardingNoResults,
              textAlign: TextAlign.center,
              style: textStyles.body3.copyWith(color: colors.textSecondary),
            ),
          ),
        ...results.map((team) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _OnboardingCard(
              colors: colors,
              child: Row(
                children: [
                  _Avatar(
                    colors: colors,
                    initials: _initials(team['title'] as String? ?? ''),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team['title'] as String? ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textStyles.subtitle2
                              .copyWith(color: colors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${team['member_count'] ?? 0} medlemmer',
                          style: textStyles.caption1
                              .copyWith(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () => onRequestJoin(team['id'] as int),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    child: Text(l10n.onboardingRequestJoin),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _PlayersStep extends StatefulWidget {
  final AppColors colors;
  final AppTextStyles textStyles;
  final List<Map<String, dynamic>> players;
  final Set<int> selectedPlayerIndexes;
  final void Function(int index, bool selected) onPlayerChanged;

  const _PlayersStep({
    required this.colors,
    required this.textStyles,
    required this.players,
    required this.selectedPlayerIndexes,
    required this.onPlayerChanged,
  });

  @override
  State<_PlayersStep> createState() => _PlayersStepState();
}

class _PlayersStepState extends State<_PlayersStep> {
  final _filterController = TextEditingController();

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _filterController.text.trim().toLowerCase();
    final visibleIndexes = [
      for (var i = 0; i < widget.players.length; i++)
        if (query.isEmpty ||
            (widget.players[i]['name'] as String? ?? '')
                .toLowerCase()
                .contains(query) ||
            (widget.players[i]['contact'] as String? ?? '')
                .toLowerCase()
                .contains(query))
          i,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SearchInput(
          colors: widget.colors,
          textStyles: widget.textStyles,
          controller: _filterController,
          hintText: 'Søg efter navn eller e-mail...',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        for (final index in visibleIndexes) ...[
          _PlayerRow(
            colors: widget.colors,
            textStyles: widget.textStyles,
            name: widget.players[index]['name'] as String? ?? '',
            contact: widget.players[index]['contact'] as String? ?? '',
            selected: widget.selectedPlayerIndexes.contains(index),
            onChanged: (selected) => widget.onPlayerChanged(index, selected),
          ),
          const SizedBox(height: 8),
        ],
        if (visibleIndexes.isEmpty)
          Text(
            'Ingen spillere fundet',
            textAlign: TextAlign.center,
            style: widget.textStyles.body3
                .copyWith(color: widget.colors.textSecondary),
          ),
      ],
    );
  }
}

class _MatchesStep extends StatelessWidget {
  final AppColors colors;
  final AppTextStyles textStyles;
  final String teamName;
  final int selectedCount;
  final List<Map<String, dynamic>> matches;

  const _MatchesStep({
    required this.colors,
    required this.textStyles,
    required this.teamName,
    required this.selectedCount,
    required this.matches,
  });

  @override
  Widget build(BuildContext context) {
    final shownMatches = matches.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryPill(
          colors: colors,
          textStyles: textStyles,
          text:
              '$selectedCount spillere • ${matches.length} kampe klar til oprettelse',
        ),
        const SizedBox(height: 12),
        if (shownMatches.isEmpty)
          _OnboardingCard(
            colors: colors,
            child: Text(
              'Ingen DBU-kampe fundet. Holdet oprettes uden kampprogram.',
              style: textStyles.body3.copyWith(color: colors.textSecondary),
            ),
          )
        else
          for (final match in shownMatches) ...[
            _MatchRow(
              colors: colors,
              textStyles: textStyles,
              title: _matchTitle(match, teamName),
              subtitle: _matchSubtitle(match),
            ),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _KopaHeader extends StatelessWidget {
  final AppColors colors;

  const _KopaHeader({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SvgPicture.asset(
        'assets/logos/Logo.svg',
        height: 36,
        colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
      ),
    );
  }
}

class _OnboardingTitle extends StatelessWidget {
  final AppColors colors;
  final AppTextStyles textStyles;
  final int step;
  final String title;
  final String subtitle;

  const _OnboardingTitle({
    required this.colors,
    required this.textStyles,
    required this.step,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            children: [
              _StepDots(colors: colors, step: step),
              const SizedBox(width: 8),
              Text(
                'Trin ${step + 1} af 3',
                style: textStyles.caption2.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: textStyles.h4.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: textStyles.body3.copyWith(
            color: colors.textSecondary,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _StepDots extends StatelessWidget {
  final AppColors colors;
  final int step;

  const _StepDots({required this.colors, required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: i == step ? 16 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == step ? colors.primary : const Color(0xFFD1D6E0),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          if (i != 2) const SizedBox(width: 4),
        ],
      ],
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final AppColors colors;
  final AppTextStyles textStyles;
  final _OnboardingMode mode;
  final ValueChanged<_OnboardingMode> onChanged;

  const _ModeToggle({
    required this.colors,
    required this.textStyles,
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.grey2,
        borderRadius: BorderRadius.circular(22.5),
      ),
      child: Row(
        children: [
          _ModeSegment(
            colors: colors,
            textStyles: textStyles,
            label: 'Opret hold',
            selected: mode == _OnboardingMode.create,
            onTap: () => onChanged(_OnboardingMode.create),
          ),
          _ModeSegment(
            colors: colors,
            textStyles: textStyles,
            label: 'Find hold',
            selected: mode == _OnboardingMode.join,
            onTap: () => onChanged(_OnboardingMode.join),
          ),
        ],
      ),
    );
  }
}

class _ModeSegment extends StatelessWidget {
  final AppColors colors;
  final AppTextStyles textStyles;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeSegment({
    required this.colors,
    required this.textStyles,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(18.5),
          ),
          child: Text(
            label,
            style: textStyles.body3.copyWith(
              color: selected ? colors.white : colors.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _DbuCard extends StatelessWidget {
  final AppColors colors;
  final AppTextStyles textStyles;
  final bool hasData;
  final VoidCallback? onPressed;

  const _DbuCard({
    required this.colors,
    required this.textStyles,
    required this.hasData,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return _OnboardingCard(
      colors: colors,
      onTap: onPressed,
      child: Row(
        children: [
          Icon(Icons.public, color: colors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasData ? 'DBU forbundet' : 'DBU',
                  style: textStyles.subtitle2.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasData
                      ? 'Holddata er importeret'
                      : 'Log ind via DBU for at importere holddata',
                  style: textStyles.caption2.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.grey2,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              hasData ? Icons.check : Icons.open_in_new,
              color: colors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  final AppColors colors;
  final AppTextStyles textStyles;
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  const _TextInput({
    required this.colors,
    required this.textStyles,
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: textStyles.body3.copyWith(
        color: colors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  final AppColors colors;
  final AppTextStyles textStyles;
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  const _SearchInput({
    required this.colors,
    required this.textStyles,
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: textStyles.body3.copyWith(color: colors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: textStyles.body3.copyWith(color: colors.textSecondary),
        prefixIcon: Icon(Icons.search, color: colors.textSecondary, size: 20),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 38, minHeight: 37),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D6E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final AppColors colors;
  final AppTextStyles textStyles;

  const _FieldLabel({
    required this.text,
    required this.colors,
    required this.textStyles,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: textStyles.caption2.copyWith(
        color: colors.textPrimary,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final AppColors colors;
  final AppTextStyles textStyles;
  final String name;
  final String contact;
  final bool selected;
  final ValueChanged<bool> onChanged;

  const _PlayerRow({
    required this.colors,
    required this.textStyles,
    required this.name,
    required this.contact,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _OnboardingCard(
      colors: colors,
      padding: const EdgeInsets.all(12),
      onTap: () => onChanged(!selected),
      child: Row(
        children: [
          _Avatar(colors: colors, initials: _initials(name)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyles.subtitle2.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contact,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      textStyles.caption1.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _CheckboxBox(colors: colors, selected: selected),
        ],
      ),
    );
  }
}

class _MatchRow extends StatelessWidget {
  final AppColors colors;
  final AppTextStyles textStyles;
  final String title;
  final String subtitle;

  const _MatchRow({
    required this.colors,
    required this.textStyles,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return _OnboardingCard(
      colors: colors,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.grey2,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.sports_soccer, color: colors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyles.subtitle2.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style:
                      textStyles.caption1.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final AppColors colors;
  final AppTextStyles textStyles;
  final String text;

  const _SummaryPill({
    required this.colors,
    required this.textStyles,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.grey2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, color: colors.primary, size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: textStyles.caption2.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  final AppColors colors;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const _OnboardingCard({
    required this.colors,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD1D6E0), width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final AppColors colors;
  final String initials;

  const _Avatar({required this.colors, required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.lightGrass65,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: colors.primary,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _CheckboxBox extends StatelessWidget {
  final AppColors colors;
  final bool selected;

  const _CheckboxBox({required this.colors, required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: selected ? colors.primary : colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: selected ? colors.primary : const Color(0xFFD1D6E0),
          width: 1.5,
        ),
      ),
      child: selected
          ? Icon(Icons.check, size: 14, color: colors.white)
          : const SizedBox.shrink(),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final AppColors colors;
  final AppTextStyles textStyles;
  final String label;
  final bool loading;
  final IconData? icon;
  final VoidCallback? onPressed;

  const _BottomActionBar({
    required this.colors,
    required this.textStyles,
    required this.label,
    required this.loading,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: colors.background,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: icon != null || loading
            ? FilledButton.icon(
                onPressed: loading ? null : onPressed,
                icon: loading
                    ? SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.white,
                        ),
                      )
                    : Icon(icon, size: 18),
                label: Text(label),
                style: _buttonStyle,
              )
            : FilledButton(
                onPressed: onPressed,
                style: _buttonStyle,
                child: Text(label),
              ),
      ),
    );
  }

  ButtonStyle get _buttonStyle {
    return FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(47),
      backgroundColor: colors.primary,
      foregroundColor: colors.white,
      disabledBackgroundColor: colors.grey3,
      disabledForegroundColor: colors.white,
      textStyle: textStyles.body1.copyWith(
        fontWeight: FontWeight.w800,
        color: colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }
}

class _WaitingView extends StatelessWidget {
  final String title;
  final String body;
  final String cancelLabel;
  final bool loading;
  final VoidCallback onCancel;

  const _WaitingView({
    required this.title,
    required this.body,
    required this.cancelLabel,
    required this.loading,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final textStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _KopaHeader(colors: colors),
              const Spacer(),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.hourglass_top, size: 48, color: colors.primary),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: textStyles.h5.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      body,
                      textAlign: TextAlign.center,
                      style: textStyles.body3
                          .copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: loading ? null : onCancel,
                      icon: const Icon(Icons.close),
                      label: Text(cancelLabel),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

String _initials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  return parts.take(2).map((part) => part[0].toUpperCase()).join();
}

String _matchTitle(Map<String, dynamic> match, String teamName) {
  for (final key in ['summary', 'title', 'name']) {
    final value = match[key] as String?;
    if (value != null && value.trim().isNotEmpty) return value.trim();
  }

  return teamName.isEmpty ? 'Kamp' : '$teamName - modstander';
}

String _matchSubtitle(Map<String, dynamic> match) {
  for (final key in ['dtstart', 'start', 'date']) {
    final value = match[key] as String?;
    if (value != null && value.trim().isNotEmpty) return value.trim();
  }

  return 'Tidspunkt afventer';
}
