import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kopa/component/football_pitch.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/onboarding_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:kopa/repository/users_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

enum _OnboardingMode { create, join }

enum _TeamLogoShape { circle, square, shield, rounded }

enum _TeamLogoPattern { solid, verticalSplit, horizontalSplit, gradient }

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _teamNameController = TextEditingController();
  final _searchController = TextEditingController();
  bool _hasSelectedRole = false;
  _OnboardingMode _mode = _OnboardingMode.create;
  int _createStep = 0;
  int _joinStep = 0;
  Map<String, dynamic>? _dbuData;
  Set<int> _selectedPlayerIndexes = {};
  _PositionChoice _selectedPosition = _positionChoices[6];
  bool _usesElevenAside = true;
  Color _teamLogoColor = const Color(0xFF1B8B4B);
  _TeamLogoShape _teamLogoShape = _TeamLogoShape.circle;
  _TeamLogoPattern _teamLogoPattern = _TeamLogoPattern.solid;
  bool _savingPosition = false;
  Map<String, dynamic>? _pendingJoinTeam;

  @override
  void initState() {
    super.initState();
    final onboardingState = context.read<OnboardingCubit>().state;
    _applyInviteContext(onboardingState);
    if (onboardingState.status == OnboardingStatus.waitingApproval) {
      _applyPendingJoinContext(onboardingState);
    }
    final userOnboardingState =
        context.read<AuthCubit>().state.user?.onboardingState;
    if (userOnboardingState?.isWaitingApproval == true &&
        onboardingState.status != OnboardingStatus.waitingApproval) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<OnboardingCubit>().restorePendingJoinRequest();
      });
    }
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _applyInviteContext(OnboardingState state) {
    if (state.inviteToken == null || state.teamId == null) return;

    _hasSelectedRole = true;
    _mode = _OnboardingMode.join;
    _joinStep = 0;
    _applyPendingJoinContext(state);
  }

  void _applyPendingJoinContext(OnboardingState state) {
    if (state.teamId == null) return;

    _pendingJoinTeam = {
      'id': state.teamId,
      'title': state.teamTitle ?? '',
      if (state.teamLeaderName?.trim().isNotEmpty == true)
        'leader_name': state.teamLeaderName,
    };
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
        .map((index) => players[index])
        .map((player) => {
              'name': player['name'] as String? ?? '',
              'email': player['contact'] as String? ?? '',
            })
        .where((invite) => _emailLike(invite['email'] ?? ''))
        .toList();

    final success = await context.read<OnboardingCubit>().createTeam(
          title: title,
          dbuContext: _dbuData,
          standings: (_dbuData?['standings'] as List<dynamic>? ?? [])
              .cast<Map<String, dynamic>>(),
          inviteEmails: inviteEmails,
        );

    if (success && mounted) {
      await context.read<AuthCubit>().init();
      if (mounted) context.go(AppRouter.home);
    }
  }

  Future<void> _requestJoin(Map<String, dynamic> team) async {
    setState(() => _pendingJoinTeam = team);
    final success = await context
        .read<OnboardingCubit>()
        .requestToJoinTeam(team['id'] as int);
    if (!success && mounted) {
      setState(() => _pendingJoinTeam = null);
    }
  }

  Future<void> _saveSelectedPosition() async {
    setState(() => _savingPosition = true);
    try {
      final user =
          await UsersRepository.updatePosition(_selectedPosition.value);
      if (mounted) context.read<AuthCubit>().updateUser(user);
    } catch (_) {
      if (!mounted) return;
      final colors =
          Theme.of(context).extension<AppColors>() ?? AppColors.light;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kunne ikke gemme positionen. Prøv igen.'),
          backgroundColor: colors.error,
        ),
      );
      rethrow;
    } finally {
      if (mounted) setState(() => _savingPosition = false);
    }
  }

  Future<void> _handlePrimaryAction() async {
    if (_mode == _OnboardingMode.join) {
      if (_joinStep == 0) {
        final onboardingState = context.read<OnboardingCubit>().state;
        final isInviteFlow = onboardingState.inviteToken != null;
        final onboardingCubit = context.read<OnboardingCubit>();
        final authCubit = context.read<AuthCubit>();
        try {
          await _saveSelectedPosition();
        } catch (_) {
          return;
        }

        if (isInviteFlow) {
          final joined = await onboardingCubit.joinTeamWithToken();
          if (!joined) return;

          await authCubit.init();
          if (!mounted) return;
          onboardingCubit.clearOnboarding();
          context.go(AppRouter.home);
          return;
        }

        if (mounted) setState(() => _joinStep = 1);
      }
      return;
    }

    if (_createStep == 0) {
      setState(() => _createStep = 1);
      return;
    }

    if (_createStep == 1) {
      try {
        await _saveSelectedPosition();
      } catch (_) {
        return;
      }
      if (mounted) setState(() => _createStep = 2);
      return;
    }

    if (_createStep == 2) {
      setState(() => _createStep = _hasPlayers ? 3 : 4);
      return;
    }

    if (_createStep == 3) {
      setState(() => _createStep = 4);
      return;
    }

    if (_createStep == 4) {
      await _createTeam();
      return;
    }
  }

  void _handleBack() {
    if (_mode == _OnboardingMode.join) {
      if (_joinStep > 0) {
        setState(() => _joinStep -= 1);
      } else {
        setState(() => _hasSelectedRole = false);
      }
      return;
    }

    if (_createStep > 0) {
      if (_createStep == 4 && !_hasPlayers) {
        setState(() => _createStep = 2);
      } else {
        setState(() => _createStep -= 1);
      }
    } else {
      setState(() => _hasSelectedRole = false);
    }
  }

  bool get _hasPlayers {
    return (_dbuData?['players'] as List<dynamic>? ?? []).isNotEmpty;
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
        if (state.inviteToken != null && state.teamId != null) {
          setState(() => _applyInviteContext(state));
        }
        if (state.status == OnboardingStatus.waitingApproval &&
            state.teamId != null) {
          setState(() => _applyPendingJoinContext(state));
        }
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
        if (state.status == OnboardingStatus.waitingApproval ||
            (state.status == OnboardingStatus.loading &&
                state.pendingJoinRequestId != null)) {
          return _WaitingView(
            team: _pendingJoinTeam,
            cancelLabel: l10n.onboardingCancel,
            loading: state.status == OnboardingStatus.loading,
            onCancel: () async {
              await context.read<OnboardingCubit>().cancelPendingJoinRequest();
              if (mounted) setState(() => _pendingJoinTeam = null);
            },
          );
        }

        if (!_hasSelectedRole) {
          return _RoleQuestionView(
            colors: colors,
            textStyles: textStyles,
            onLeaderSelected: () {
              setState(() {
                _hasSelectedRole = true;
                _mode = _OnboardingMode.create;
              });
            },
            onPlayerSelected: () {
              setState(() {
                _hasSelectedRole = true;
                _mode = _OnboardingMode.join;
              });
            },
          );
        }

        final loading = state.status == OnboardingStatus.loading;
        final actionLoading = loading || _savingPosition;
        final step =
            _mode == _OnboardingMode.create ? _createStep : _joinStep + 1;
        final title = _mode == _OnboardingMode.join
            ? switch (_joinStep) {
                0 => 'Vælg din position',
                _ => l10n.onboardingJoinTeam,
              }
            : switch (_createStep) {
                0 => l10n.onboardingTitle,
                1 => 'Vælg din position',
                2 => 'Design dit holdlogo',
                3 => 'Tilføj spillere',
                _ => 'Klar til oprettelse',
              };
        final subtitle = _mode == _OnboardingMode.join
            ? switch (_joinStep) {
                0 => 'Tryk på din position på banen',
                _ =>
                  'Søg efter dit hold og send en anmodning om at blive tilføjet',
              }
            : switch (_createStep) {
                0 =>
                  'Opret dit fodboldhold og saml spillere, kampe og statistikker ét sted.',
                1 => 'Tryk på din position på banen',
                2 => 'Vælg en baggrundsfarve og form til jeres holdlogo',
                3 =>
                  'Invitér spillere til holdet. De modtager en mail-invitation med det samme.',
                _ => 'Gennemgå holdet og opret det, når oplysningerne er klar.',
              };
        final canAdvance = _mode == _OnboardingMode.create &&
            _teamNameController.text.trim().isNotEmpty &&
            !actionLoading;
        final primaryLabel = _mode == _OnboardingMode.create && _createStep == 4
            ? l10n.onboardingCreate
            : l10n.onboardingContinue;
        final showBottomAction =
            _mode == _OnboardingMode.create || _joinStep == 0;

        return Scaffold(
          backgroundColor: colors.background,
          bottomNavigationBar: showBottomAction
              ? _BottomActionBar(
                  colors: colors,
                  textStyles: textStyles,
                  label: primaryLabel,
                  loading: actionLoading,
                  icon: _mode == _OnboardingMode.create && _createStep == 4
                      ? Icons.check
                      : null,
                  onPressed: _mode == _OnboardingMode.create
                      ? (canAdvance ? _handlePrimaryAction : null)
                      : (actionLoading ? null : _handlePrimaryAction),
                )
              : null,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: _KopaHeader(
                      colors: colors,
                      showBack: true,
                      onBack: _handleBack,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: _OnboardingTitle(
                      colors: colors,
                      textStyles: textStyles,
                      step: step,
                      totalSteps: 5,
                      title: title,
                      subtitle: subtitle,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                    child: _mode == _OnboardingMode.create
                        ? _CreateTeamView(
                            l10n: l10n,
                            colors: colors,
                            textStyles: textStyles,
                            step: _createStep,
                            teamNameController: _teamNameController,
                            dbuData: _dbuData,
                            selectedPlayerIndexes: _selectedPlayerIndexes,
                            selectedPosition: _selectedPosition,
                            usesElevenAside: _usesElevenAside,
                            teamLogoColor: _teamLogoColor,
                            teamLogoShape: _teamLogoShape,
                            teamLogoPattern: _teamLogoPattern,
                            loading: loading,
                            onOpenDbu: _openDbu,
                            onTextChanged: () => setState(() {}),
                            onFormationChanged: (value) =>
                                setState(() => _usesElevenAside = value),
                            onPositionChanged: (value) =>
                                setState(() => _selectedPosition = value),
                            onLogoColorChanged: (value) =>
                                setState(() => _teamLogoColor = value),
                            onLogoShapeChanged: (value) =>
                                setState(() => _teamLogoShape = value),
                            onLogoPatternChanged: (value) =>
                                setState(() => _teamLogoPattern = value),
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
                        : _joinStep == 0
                            ? _PositionStep(
                                colors: colors,
                                textStyles: textStyles,
                                selectedPosition: _selectedPosition,
                                usesElevenAside: _usesElevenAside,
                                onFormationChanged: (value) =>
                                    setState(() => _usesElevenAside = value),
                                onPositionChanged: (value) =>
                                    setState(() => _selectedPosition = value),
                              )
                            : _JoinTeamView(
                                l10n: l10n,
                                colors: colors,
                                textStyles: textStyles,
                                controller: _searchController,
                                results: state.searchResults,
                                loading: loading,
                                onSearch:
                                    context.read<OnboardingCubit>().searchTeams,
                                onRequestJoin: _requestJoin,
                              ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RoleQuestionView extends StatelessWidget {
  final AppColors colors;
  final AppTextStyles textStyles;
  final VoidCallback onLeaderSelected;
  final VoidCallback onPlayerSelected;

  const _RoleQuestionView({
    required this.colors,
    required this.textStyles,
    required this.onLeaderSelected,
    required this.onPlayerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/logos/Logo.svg',
                    height: 36,
                    colorFilter:
                        ColorFilter.mode(colors.primary, BlendMode.srcIn),
                  ),
                  const Spacer(),
                  _HeaderStepDots(colors: colors),
                ],
              ),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.circular(90),
                    ),
                    child: SvgPicture.asset(
                      'assets/illustrations/onboarding_leader_question.svg',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Er du holdleder?',
                    textAlign: TextAlign.center,
                    style: textStyles.h4.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Hvis du er holdleder, kan du oprette og administrere dit hold, spillere samt kampe.',
                    textAlign: TextAlign.center,
                    style: textStyles.body3.copyWith(
                      color: colors.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 44),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    onPressed: onLeaderSelected,
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(Icons.chevron_right, size: 20),
                    label: const Text('Ja, jeg er holdleder'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(51),
                      backgroundColor: colors.primary,
                      foregroundColor: colors.white,
                      textStyle: textStyles.body1.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: onPlayerSelected,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(51),
                      foregroundColor: colors.textPrimary,
                      side: const BorderSide(
                        color: Color(0xFFD1D6E0),
                        width: 1.5,
                      ),
                      textStyle: textStyles.body1.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Nej, jeg er spiller'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderStepDots extends StatelessWidget {
  final AppColors colors;

  const _HeaderStepDots({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 6,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        for (var i = 0; i < 2; i++) ...[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D6E0),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          if (i == 0) const SizedBox(width: 6),
        ],
      ],
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
  final _PositionChoice selectedPosition;
  final bool usesElevenAside;
  final Color teamLogoColor;
  final _TeamLogoShape teamLogoShape;
  final _TeamLogoPattern teamLogoPattern;
  final bool loading;
  final VoidCallback onOpenDbu;
  final VoidCallback onTextChanged;
  final ValueChanged<bool> onFormationChanged;
  final ValueChanged<_PositionChoice> onPositionChanged;
  final ValueChanged<Color> onLogoColorChanged;
  final ValueChanged<_TeamLogoShape> onLogoShapeChanged;
  final ValueChanged<_TeamLogoPattern> onLogoPatternChanged;
  final void Function(int index, bool selected) onPlayerChanged;

  const _CreateTeamView({
    required this.l10n,
    required this.colors,
    required this.textStyles,
    required this.step,
    required this.teamNameController,
    required this.dbuData,
    required this.selectedPlayerIndexes,
    required this.selectedPosition,
    required this.usesElevenAside,
    required this.teamLogoColor,
    required this.teamLogoShape,
    required this.teamLogoPattern,
    required this.loading,
    required this.onOpenDbu,
    required this.onTextChanged,
    required this.onFormationChanged,
    required this.onPositionChanged,
    required this.onLogoColorChanged,
    required this.onLogoShapeChanged,
    required this.onLogoPatternChanged,
    required this.onPlayerChanged,
  });

  @override
  Widget build(BuildContext context) {
    final players = (dbuData?['players'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    return switch (step) {
      0 => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
              hintText: 'Dit holdnavn',
              onChanged: (_) => onTextChanged(),
            ),
          ],
        ),
      1 => _PositionStep(
          colors: colors,
          textStyles: textStyles,
          selectedPosition: selectedPosition,
          usesElevenAside: usesElevenAside,
          onFormationChanged: onFormationChanged,
          onPositionChanged: onPositionChanged,
        ),
      2 => _TeamLogoStep(
          colors: colors,
          textStyles: textStyles,
          teamName: teamNameController.text.trim(),
          color: teamLogoColor,
          shape: teamLogoShape,
          pattern: teamLogoPattern,
          onColorChanged: onLogoColorChanged,
          onShapeChanged: onLogoShapeChanged,
          onPatternChanged: onLogoPatternChanged,
        ),
      3 => _PlayersStep(
          colors: colors,
          textStyles: textStyles,
          players: players,
          selectedPlayerIndexes: selectedPlayerIndexes,
          onPlayerChanged: onPlayerChanged,
        ),
      _ => _MatchesStep(
          colors: colors,
          textStyles: textStyles,
          selectedCount: selectedPlayerIndexes.length,
        ),
    };
  }
}

class _PositionStep extends StatelessWidget {
  final AppColors colors;
  final AppTextStyles textStyles;
  final _PositionChoice selectedPosition;
  final bool usesElevenAside;
  final ValueChanged<bool> onFormationChanged;
  final ValueChanged<_PositionChoice> onPositionChanged;

  const _PositionStep({
    required this.colors,
    required this.textStyles,
    required this.selectedPosition,
    required this.usesElevenAside,
    required this.onFormationChanged,
    required this.onPositionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SegmentedToggle(
          colors: colors,
          textStyles: textStyles,
          usesElevenAside: usesElevenAside,
          onChanged: onFormationChanged,
        ),
        const SizedBox(height: 18),
        _PitchPicker(
          colors: colors,
          textStyles: textStyles,
          selectedPosition: selectedPosition,
          usesElevenAside: usesElevenAside,
          onPositionChanged: onPositionChanged,
        ),
        const SizedBox(height: 18),
        Text(
          'Du valgte: ${selectedPosition.label} (${selectedPosition.shortLabel})',
          textAlign: TextAlign.center,
          style: textStyles.body3.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _SegmentedToggle extends StatelessWidget {
  final AppColors colors;
  final AppTextStyles textStyles;
  final bool usesElevenAside;
  final ValueChanged<bool> onChanged;

  const _SegmentedToggle({
    required this.colors,
    required this.textStyles,
    required this.usesElevenAside,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE5E2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _SegmentedOption(
            colors: colors,
            textStyles: textStyles,
            label: '7-mand',
            selected: !usesElevenAside,
            onTap: () => onChanged(false),
          ),
          const SizedBox(width: 2),
          _SegmentedOption(
            colors: colors,
            textStyles: textStyles,
            label: '11-mand',
            selected: usesElevenAside,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _SegmentedOption extends StatelessWidget {
  final AppColors colors;
  final AppTextStyles textStyles;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentedOption({
    required this.colors,
    required this.textStyles,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Center(
            child: Text(
              label,
              style: textStyles.caption2.copyWith(
                color: selected ? colors.textPrimary : colors.textSecondary,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PitchPicker extends StatelessWidget {
  final AppColors colors;
  final AppTextStyles textStyles;
  final _PositionChoice selectedPosition;
  final bool usesElevenAside;
  final ValueChanged<_PositionChoice> onPositionChanged;

  const _PitchPicker({
    required this.colors,
    required this.textStyles,
    required this.selectedPosition,
    required this.usesElevenAside,
    required this.onPositionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final choices = usesElevenAside ? _positionChoices : _sevenAsideChoices;

    return AspectRatio(
      aspectRatio: 342 / 350,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return FootballPitch(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
            child: Stack(
              children: [
                for (final choice in choices)
                  Positioned(
                    left: choice.x * width - 17,
                    top: choice.y * height - 17,
                    width: 34,
                    height: 34,
                    child: _PositionButton(
                      colors: colors,
                      textStyles: textStyles,
                      choice: choice,
                      selected: choice.id == selectedPosition.id,
                      onTap: () => onPositionChanged(choice),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PositionButton extends StatelessWidget {
  final AppColors colors;
  final AppTextStyles textStyles;
  final _PositionChoice choice;
  final bool selected;
  final VoidCallback onTap;

  const _PositionButton({
    required this.colors,
    required this.textStyles,
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? colors.primary : colors.white.withValues(alpha: 0.15),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.white.withValues(alpha: selected ? 1 : 0.45),
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            choice.shortLabel,
            style: textStyles.caption2.copyWith(
              color: colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _TeamLogoStep extends StatelessWidget {
  final AppColors colors;
  final AppTextStyles textStyles;
  final String teamName;
  final Color color;
  final _TeamLogoShape shape;
  final _TeamLogoPattern pattern;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<_TeamLogoShape> onShapeChanged;
  final ValueChanged<_TeamLogoPattern> onPatternChanged;

  const _TeamLogoStep({
    required this.colors,
    required this.textStyles,
    required this.teamName,
    required this.color,
    required this.shape,
    required this.pattern,
    required this.onColorChanged,
    required this.onShapeChanged,
    required this.onPatternChanged,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _initials(teamName.isEmpty ? 'Skjold 7' : teamName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 196,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: _LogoPreview(
            initials: initials,
            color: color,
            shape: shape,
            pattern: pattern,
            size: 150,
            selected: true,
          ),
        ),
        const SizedBox(height: 26),
        _FieldLabel(
          text: 'Baggrundsfarve',
          colors: colors,
          textStyles: textStyles,
        ),
        const SizedBox(height: 10),
        _LogoColorPicker(
          selected: color,
          onChanged: onColorChanged,
        ),
        const SizedBox(height: 18),
        _FieldLabel(text: 'Form', colors: colors, textStyles: textStyles),
        const SizedBox(height: 10),
        _LogoShapePicker(
          colors: colors,
          initials: initials,
          color: color,
          pattern: pattern,
          selected: shape,
          onChanged: onShapeChanged,
        ),
        const SizedBox(height: 18),
        _FieldLabel(text: 'Mønster', colors: colors, textStyles: textStyles),
        const SizedBox(height: 10),
        _LogoPatternPicker(
          colors: colors,
          color: color,
          selected: pattern,
          onChanged: onPatternChanged,
        ),
      ],
    );
  }
}

class _LogoColorPicker extends StatelessWidget {
  final Color selected;
  final ValueChanged<Color> onChanged;

  const _LogoColorPicker({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final color in _logoColors)
          GestureDetector(
            onTap: () => onChanged(color),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: selected == color ? 3 : 0,
                ),
                boxShadow: selected == color
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.45),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}

class _LogoShapePicker extends StatelessWidget {
  final AppColors colors;
  final String initials;
  final Color color;
  final _TeamLogoPattern pattern;
  final _TeamLogoShape selected;
  final ValueChanged<_TeamLogoShape> onChanged;

  const _LogoShapePicker({
    required this.colors,
    required this.initials,
    required this.color,
    required this.pattern,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final shape in _TeamLogoShape.values)
          GestureDetector(
            onTap: () => onChanged(shape),
            child: _LogoPreview(
              initials: initials,
              color: selected == shape ? color : const Color(0xFFDCE5E2),
              shape: shape,
              pattern: selected == shape ? pattern : _TeamLogoPattern.solid,
              size: 56,
              selected: selected == shape,
              textColor:
                  selected == shape ? colors.white : colors.textSecondary,
            ),
          ),
      ],
    );
  }
}

class _LogoPatternPicker extends StatelessWidget {
  final AppColors colors;
  final Color color;
  final _TeamLogoPattern selected;
  final ValueChanged<_TeamLogoPattern> onChanged;

  const _LogoPatternPicker({
    required this.colors,
    required this.color,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final pattern in _TeamLogoPattern.values)
          GestureDetector(
            onTap: () => onChanged(pattern),
            child: Container(
              width: 56,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected == pattern
                      ? colors.primary
                      : const Color(0xFFD1D6E0),
                  width: selected == pattern ? 2 : 1,
                ),
              ),
              child: _PatternPreview(color: color, pattern: pattern),
            ),
          ),
      ],
    );
  }
}

class _LogoPreview extends StatelessWidget {
  final String initials;
  final Color color;
  final _TeamLogoShape shape;
  final _TeamLogoPattern pattern;
  final double size;
  final bool selected;
  final Color? textColor;

  const _LogoPreview({
    required this.initials,
    required this.color,
    required this.shape,
    required this.pattern,
    required this.size,
    required this.selected,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: pattern == _TeamLogoPattern.solid ? color : null,
        gradient: _logoGradient(color, pattern),
        shape: _logoShape(shape, selected),
        shadows: selected
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: size >= 100 ? 8 : 4,
                  offset: Offset(0, size >= 100 ? 4 : 2),
                ),
              ]
            : null,
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: size >= 100 ? 48 : 16,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _PatternPreview extends StatelessWidget {
  final Color color;
  final _TeamLogoPattern pattern;

  const _PatternPreview({
    required this.color,
    required this.pattern,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        gradient: _logoGradient(color, pattern),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _JoinTeamView extends StatelessWidget {
  final AppLocalizations l10n;
  final AppColors colors;
  final AppTextStyles textStyles;
  final TextEditingController controller;
  final List<Map<String, dynamic>> results;
  final bool loading;
  final ValueChanged<String> onSearch;
  final ValueChanged<Map<String, dynamic>> onRequestJoin;

  const _JoinTeamView({
    required this.l10n,
    required this.colors,
    required this.textStyles,
    required this.controller,
    required this.results,
    required this.loading,
    required this.onSearch,
    required this.onRequestJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SearchInput(
          colors: colors,
          textStyles: textStyles,
          controller: controller,
          hintText: l10n.onboardingSearchHint,
          onChanged: onSearch,
        ),
        const SizedBox(height: 18),
        if (loading) ...[
          LinearProgressIndicator(color: colors.primary),
          const SizedBox(height: 12),
        ],
        Text(
          'Søgeresultater',
          style: textStyles.caption2.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        if (!loading && controller.text.length >= 2 && results.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              l10n.onboardingNoResults,
              textAlign: TextAlign.center,
              style: textStyles.body3.copyWith(color: colors.textSecondary),
            ),
          ),
        const SizedBox(height: 12),
        ...results.map((team) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TeamSearchCard(
              colors: colors,
              textStyles: textStyles,
              team: team,
              actionLabel: 'Ansøg',
              onPressed: () => onRequestJoin(team),
            ),
          );
        }),
      ],
    );
  }
}

class _TeamSearchCard extends StatelessWidget {
  final AppColors colors;
  final AppTextStyles textStyles;
  final Map<String, dynamic> team;
  final String actionLabel;
  final VoidCallback? onPressed;
  final Widget? trailing;

  const _TeamSearchCard({
    required this.colors,
    required this.textStyles,
    required this.team,
    required this.actionLabel,
    this.onPressed,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final title =
        team['title'] as String? ?? team['teamTitle'] as String? ?? '';
    final memberCount = team['member_count'] ?? team['memberCount'];
    final leaderName =
        team['leader_name'] as String? ?? team['leaderName'] as String? ?? '';
    final subtitle = leaderName.trim().isNotEmpty
        ? 'Holdleder: ${leaderName.trim()}'
        : memberCount == null
            ? 'Holdleder: Afventer'
            : '$memberCount medlemmer';
    final series =
        team['series_name'] as String? ?? team['seriesName'] as String? ?? '';

    return _OnboardingCard(
      colors: colors,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _Avatar(
            colors: colors,
            initials: _initials(title),
            backgroundColor: _teamAccentColor(title),
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
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textStyles.caption1.copyWith(
                    color: colors.textSecondary,
                    fontSize: 13,
                    letterSpacing: 0,
                  ),
                ),
                if (series.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    series,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyles.caption2.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing ??
              OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(74, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  foregroundColor: colors.primary,
                  side: BorderSide(color: colors.primary, width: 1.5),
                  textStyle: textStyles.caption2.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text(actionLabel),
              ),
        ],
      ),
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
  final int selectedCount;

  const _MatchesStep({
    required this.colors,
    required this.textStyles,
    required this.selectedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryPill(
          colors: colors,
          textStyles: textStyles,
          text: '$selectedCount spillere',
        ),
        const SizedBox(height: 12),
        _OnboardingCard(
          colors: colors,
          child: Text(
            'Kopa synkroniserer det officielle kampprogram fra DBU efter oprettelse.',
            style: textStyles.body3.copyWith(color: colors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _KopaHeader extends StatelessWidget {
  final AppColors colors;
  final bool showBack;
  final VoidCallback? onBack;

  const _KopaHeader({
    required this.colors,
    this.showBack = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/logos/Logo.svg',
          height: 36,
          colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
        ),
        const Spacer(),
        if (showBack)
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            color: colors.textPrimary,
            tooltip: 'Tilbage',
          ),
      ],
    );
  }
}

class _OnboardingTitle extends StatelessWidget {
  final AppColors colors;
  final AppTextStyles textStyles;
  final int step;
  final int totalSteps;
  final String title;
  final String subtitle;

  const _OnboardingTitle({
    required this.colors,
    required this.textStyles,
    required this.step,
    required this.totalSteps,
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
              _StepDots(colors: colors, step: step, count: totalSteps),
              const SizedBox(width: 8),
              Text(
                'Trin ${step + 1} af $totalSteps',
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
  final int count;

  const _StepDots({
    required this.colors,
    required this.step,
    this.count = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: i == step ? 16 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == step ? colors.primary : const Color(0xFFD1D6E0),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          if (i != count - 1) const SizedBox(width: 4),
        ],
      ],
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
  final Color? backgroundColor;

  const _Avatar({
    required this.colors,
    required this.initials,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.lightGrass65,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: backgroundColor == null ? colors.primary : colors.textPrimary,
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
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _WaitingView extends StatelessWidget {
  final Map<String, dynamic>? team;
  final String cancelLabel;
  final bool loading;
  final VoidCallback onCancel;

  const _WaitingView({
    required this.team,
    required this.cancelLabel,
    required this.loading,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final textStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final title = team?['title'] as String? ?? 'dit hold';
    final displayTeam = team ?? const <String, dynamic>{'title': 'Dit hold'};

    return Scaffold(
      backgroundColor: colors.background,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: colors.background,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          child: OutlinedButton(
            onPressed: loading ? null : onCancel,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(47),
              foregroundColor: colors.error,
              backgroundColor: const Color(0xFFFEF2F2),
              side: BorderSide(color: colors.error, width: 1.5),
              textStyle: textStyles.body1.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: loading
                ? SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.error,
                    ),
                  )
                : Text(cancelLabel),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _KopaHeader(colors: colors),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StepDots(colors: colors, step: 2, count: 5),
                  const SizedBox(width: 8),
                  Text(
                    'Trin 3 af 5',
                    style: textStyles.caption2.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 52),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.grey2,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.primary),
                  ),
                  child: Icon(
                    Icons.schedule,
                    color: colors.primary,
                    size: 44,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Venter på accept',
                textAlign: TextAlign.center,
                style: textStyles.h5.copyWith(
                  color: colors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Du har ansøgt om at blive en del af $title. Du får besked, når holdlederen har accepteret din anmodning.',
                textAlign: TextAlign.center,
                style: textStyles.body3.copyWith(
                  color: colors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 26),
              _TeamSearchCard(
                colors: colors,
                textStyles: textStyles,
                team: displayTeam,
                actionLabel: '',
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: colors.warning),
                  ),
                  child: Text(
                    'Afventer',
                    style: textStyles.caption2.copyWith(
                      color: colors.warning,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PositionChoice {
  final String id;
  final String shortLabel;
  final String label;
  final String value;
  final double x;
  final double y;

  const _PositionChoice({
    required this.id,
    required this.shortLabel,
    required this.label,
    required this.value,
    required this.x,
    required this.y,
  });
}

const _positionChoices = <_PositionChoice>[
  _PositionChoice(
    id: 'mv',
    shortLabel: 'MV',
    label: 'Målmand',
    value: 'goalkeeper',
    x: 0.50,
    y: 0.90,
  ),
  _PositionChoice(
    id: 'vb',
    shortLabel: 'VB',
    label: 'Venstre back',
    value: 'back_wingback',
    x: 0.13,
    y: 0.70,
  ),
  _PositionChoice(
    id: 'cb-left',
    shortLabel: 'CB',
    label: 'Centerback',
    value: 'centre_back',
    x: 0.35,
    y: 0.73,
  ),
  _PositionChoice(
    id: 'cb-right',
    shortLabel: 'CB',
    label: 'Centerback',
    value: 'centre_back',
    x: 0.65,
    y: 0.73,
  ),
  _PositionChoice(
    id: 'hb',
    shortLabel: 'HB',
    label: 'Højre back',
    value: 'back_wingback',
    x: 0.87,
    y: 0.70,
  ),
  _PositionChoice(
    id: 'vm',
    shortLabel: 'VM',
    label: 'Venstre midtbane',
    value: 'midfield',
    x: 0.20,
    y: 0.50,
  ),
  _PositionChoice(
    id: 'cm',
    shortLabel: 'CM',
    label: 'Central midtbane',
    value: 'midfield',
    x: 0.50,
    y: 0.50,
  ),
  _PositionChoice(
    id: 'hm',
    shortLabel: 'HM',
    label: 'Højre midtbane',
    value: 'midfield',
    x: 0.80,
    y: 0.50,
  ),
  _PositionChoice(
    id: 'vw',
    shortLabel: 'VW',
    label: 'Venstre wing',
    value: 'wing',
    x: 0.17,
    y: 0.25,
  ),
  _PositionChoice(
    id: 'st',
    shortLabel: 'ST',
    label: 'Angriber',
    value: 'striker',
    x: 0.50,
    y: 0.21,
  ),
  _PositionChoice(
    id: 'hw',
    shortLabel: 'HW',
    label: 'Højre wing',
    value: 'wing',
    x: 0.83,
    y: 0.25,
  ),
];

const _sevenAsideChoices = <_PositionChoice>[
  _PositionChoice(
    id: 'mv',
    shortLabel: 'MV',
    label: 'Målmand',
    value: 'goalkeeper',
    x: 0.50,
    y: 0.88,
  ),
  _PositionChoice(
    id: 'vb',
    shortLabel: 'VB',
    label: 'Venstre back',
    value: 'back_wingback',
    x: 0.24,
    y: 0.66,
  ),
  _PositionChoice(
    id: 'hb',
    shortLabel: 'HB',
    label: 'Højre back',
    value: 'back_wingback',
    x: 0.76,
    y: 0.66,
  ),
  _PositionChoice(
    id: 'cm',
    shortLabel: 'CM',
    label: 'Central midtbane',
    value: 'midfield',
    x: 0.50,
    y: 0.49,
  ),
  _PositionChoice(
    id: 'vw',
    shortLabel: 'VW',
    label: 'Venstre wing',
    value: 'wing',
    x: 0.25,
    y: 0.28,
  ),
  _PositionChoice(
    id: 'st',
    shortLabel: 'ST',
    label: 'Angriber',
    value: 'striker',
    x: 0.50,
    y: 0.20,
  ),
  _PositionChoice(
    id: 'hw',
    shortLabel: 'HW',
    label: 'Højre wing',
    value: 'wing',
    x: 0.75,
    y: 0.28,
  ),
];

const _logoColors = <Color>[
  Color(0xFF1B8B4B),
  Color(0xFF15213D),
  Color(0xFFD22B2B),
  Color(0xFF1975F2),
  Color(0xFFF05A00),
  Color(0xFF6E22A8),
  Color(0xFF008E7B),
  Color(0xFF263238),
];

Gradient? _logoGradient(Color color, _TeamLogoPattern pattern) {
  final secondary = Color.lerp(color, Colors.white, 0.78)!;
  return switch (pattern) {
    _TeamLogoPattern.solid => null,
    _TeamLogoPattern.verticalSplit => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [color, color, secondary, secondary],
        stops: const [0, 0.5, 0.5, 1],
      ),
    _TeamLogoPattern.horizontalSplit => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color, color, secondary, secondary],
        stops: const [0, 0.5, 0.5, 1],
      ),
    _TeamLogoPattern.gradient => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [color, Colors.white],
      ),
  };
}

ShapeBorder _logoShape(_TeamLogoShape shape, bool selected) {
  final side = selected
      ? const BorderSide(color: Colors.white, width: 4)
      : BorderSide.none;
  return switch (shape) {
    _TeamLogoShape.circle => CircleBorder(side: side),
    _TeamLogoShape.square => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: side,
      ),
    _TeamLogoShape.shield => RoundedRectangleBorder(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        side: side,
      ),
    _TeamLogoShape.rounded => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: side,
      ),
  };
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

Color _teamAccentColor(String seed) {
  const colors = <Color>[
    Color(0xFF00943C),
    Color(0xFF3B82F6),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFFF59E0B),
    Color(0xFF14B8A6),
  ];
  if (seed.trim().isEmpty) return colors.first;
  final index =
      seed.codeUnits.fold<int>(0, (sum, code) => sum + code) % colors.length;
  return colors[index];
}
