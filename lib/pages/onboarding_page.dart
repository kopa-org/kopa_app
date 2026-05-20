import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/cubits/onboarding_cubit.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/navigation/app_router.dart';

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
    setState(() {
      _dbuData = decoded;
      _teamNameController.text =
          decoded['teamName'] as String? ?? _teamNameController.text;
      _selectedPlayerIndexes = {
        for (var i = 0; i < players.length; i++)
          if (_emailLike(
              (players[i] as Map<String, dynamic>)['contact'] as String? ?? ''))
            i,
      };
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

  bool _emailLike(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state.status == OnboardingStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.errorMessage ?? l10n.onboardingFailure)),
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

        return Scaffold(
          appBar: AppBar(title: Text(l10n.onboardingTitle)),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                SegmentedButton<_OnboardingMode>(
                  segments: [
                    ButtonSegment(
                      value: _OnboardingMode.create,
                      icon: const Icon(Icons.add_circle_outline),
                      label: Text(l10n.onboardingCreateTeam),
                    ),
                    ButtonSegment(
                      value: _OnboardingMode.join,
                      icon: const Icon(Icons.search),
                      label: Text(l10n.onboardingJoinTeam),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (selection) =>
                      setState(() => _mode = selection.first),
                ),
                const SizedBox(height: 24),
                if (_mode == _OnboardingMode.create)
                  _CreateTeamView(
                    l10n: l10n,
                    theme: theme,
                    teamNameController: _teamNameController,
                    dbuData: _dbuData,
                    selectedPlayerIndexes: _selectedPlayerIndexes,
                    loading: state.status == OnboardingStatus.loading,
                    onOpenDbu: _openDbu,
                    onCreate: _createTeam,
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
                else
                  _JoinTeamView(
                    l10n: l10n,
                    controller: _searchController,
                    results: state.searchResults,
                    loading: state.status == OnboardingStatus.loading,
                    onSearch: context.read<OnboardingCubit>().searchTeams,
                    onRequestJoin: _requestJoin,
                  ),
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
  final ThemeData theme;
  final TextEditingController teamNameController;
  final Map<String, dynamic>? dbuData;
  final Set<int> selectedPlayerIndexes;
  final bool loading;
  final VoidCallback onOpenDbu;
  final VoidCallback onCreate;
  final void Function(int index, bool selected) onPlayerChanged;

  const _CreateTeamView({
    required this.l10n,
    required this.theme,
    required this.teamNameController,
    required this.dbuData,
    required this.selectedPlayerIndexes,
    required this.loading,
    required this.onOpenDbu,
    required this.onCreate,
    required this.onPlayerChanged,
  });

  @override
  Widget build(BuildContext context) {
    final players = (dbuData?['players'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final matches = (dbuData?['matches'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final standings = (dbuData?['standings'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onOpenDbu,
                icon: const Icon(Icons.public),
                label: Text(l10n.onboardingDbu),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: teamNameController,
          decoration: InputDecoration(
            labelText: l10n.onboardingTeamName,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        if (players.isNotEmpty) ...[
          Text(l10n.onboardingPlayers, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...List.generate(players.length, (index) {
            final player = players[index];
            return CheckboxListTile(
              value: selectedPlayerIndexes.contains(index),
              onChanged: (value) => onPlayerChanged(index, value ?? false),
              title: Text(player['name'] as String? ?? ''),
              subtitle: Text(player['contact'] as String? ?? ''),
              controlAffinity: ListTileControlAffinity.leading,
            );
          }),
          const SizedBox(height: 16),
        ],
        if (matches.isNotEmpty) ...[
          Text(l10n.onboardingMatches, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...matches.take(5).map((match) {
            return ListTile(
              leading: const Icon(Icons.sports_soccer),
              title: Text(match['summary'] as String? ?? ''),
              subtitle: Text(match['dtstart'] as String? ?? ''),
            );
          }),
          const SizedBox(height: 16),
        ],
        if (standings.isNotEmpty) ...[
          Text('Stilling', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...standings.take(5).map((standing) {
            return ListTile(
              dense: true,
              leading: Text('${standing['position'] ?? ''}'),
              title: Text(standing['teamName'] as String? ?? ''),
              trailing: Text('${standing['points'] ?? 0} p'),
            );
          }),
          const SizedBox(height: 16),
        ],
        FilledButton.icon(
          onPressed: loading ? null : onCreate,
          icon: loading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: Text(l10n.onboardingCreate),
        ),
      ],
    );
  }
}

class _JoinTeamView extends StatelessWidget {
  final AppLocalizations l10n;
  final TextEditingController controller;
  final List<Map<String, dynamic>> results;
  final bool loading;
  final ValueChanged<String> onSearch;
  final ValueChanged<int> onRequestJoin;

  const _JoinTeamView({
    required this.l10n,
    required this.controller,
    required this.results,
    required this.loading,
    required this.onSearch,
    required this.onRequestJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.onboardingSearchHint,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.search),
          ),
          onChanged: onSearch,
        ),
        const SizedBox(height: 16),
        if (loading) const LinearProgressIndicator(),
        if (!loading && controller.text.length >= 2 && results.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Text(l10n.onboardingNoResults),
          ),
        ...results.map((team) {
          return ListTile(
            title: Text(team['title'] as String? ?? ''),
            subtitle: Text('${team['member_count'] ?? 0} medlemmer'),
            trailing: FilledButton(
              onPressed: () => onRequestJoin(team['id'] as int),
              child: Text(l10n.onboardingRequestJoin),
            ),
          );
        }),
      ],
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
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hourglass_top, size: 48),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(body, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: loading ? null : onCancel,
                icon: const Icon(Icons.close),
                label: Text(cancelLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
