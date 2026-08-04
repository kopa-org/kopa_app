import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/cubits/auth_cubit.dart';
import 'package:kopa/repository/onboarding_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class TeamJoinRequestsPage extends StatefulWidget {
  const TeamJoinRequestsPage({super.key});

  @override
  State<TeamJoinRequestsPage> createState() => _TeamJoinRequestsPageState();
}

class _TeamJoinRequestsPageState extends State<TeamJoinRequestsPage> {
  final _repository = OnboardingRepository();
  final Set<int> _savingRequestIds = {};
  late Future<List<_TeamJoinRequest>> _requestsFuture;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _requestsFuture = _loadRequests();
  }

  Future<List<_TeamJoinRequest>> _loadRequests() async {
    final currentUser = context.read<AuthCubit>().state.user;
    final teamId = currentUser?.teamDetails?.id;
    if (currentUser?.isTeamOwner != true || teamId == null) {
      throw Exception('Du har ikke adgang til holdanmodninger.');
    }

    final result = await _repository.listJoinRequests(teamId);
    if (result['success'] != true) {
      throw Exception(result['error'] ?? 'Kunne ikke hente anmodninger.');
    }

    return (result['join_requests'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(_TeamJoinRequest.fromJson)
        .toList();
  }

  Future<void> _refresh() async {
    setState(() {
      _errorMessage = null;
      _requestsFuture = _loadRequests();
    });
    await _requestsFuture;
  }

  Future<void> _respond(_TeamJoinRequest request, bool approve) async {
    if (_savingRequestIds.contains(request.id)) return;

    setState(() {
      _errorMessage = null;
      _savingRequestIds.add(request.id);
    });

    final result = approve
        ? await _repository.approveJoinRequest(request.id)
        : await _repository.rejectJoinRequest(request.id);

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _savingRequestIds.remove(request.id);
        _requestsFuture = _loadRequests();
      });
      return;
    }

    setState(() {
      _savingRequestIds.remove(request.id);
      _errorMessage = result['error'] ?? 'Kunne ikke behandle anmodning.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return PageScaffold(
      title: 'Holdanmodninger',
      showBackButton: true,
      backgroundColor: colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<_TeamJoinRequest>>(
            future: _requestsFuture,
            builder: (context, snapshot) {
              final requests = snapshot.data ?? const <_TeamJoinRequest>[];

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  Spacing.md,
                  Spacing.md,
                  Spacing.md,
                  120,
                ),
                children: [
                  Text(
                    'Afventer godkendelse (${requests.length})',
                    style: styles.subtitle2.copyWith(
                      color: colors.dirt,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: styles.caption1.copyWith(color: colors.error),
                    ),
                    const SizedBox(height: Spacing.sm),
                  ],
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.only(top: Spacing.xl),
                      child: Center(child: CupertinoActivityIndicator()),
                    )
                  else if (snapshot.hasError)
                    _EmptyJoinRequests(
                      message: snapshot.error.toString().replaceFirst(
                            'Exception: ',
                            '',
                          ),
                    )
                  else if (requests.isEmpty)
                    const _EmptyJoinRequests(
                      message: 'Ingen spillere afventer godkendelse.',
                    )
                  else
                    for (final request in requests)
                      _JoinRequestRow(
                        request: request,
                        isSaving: _savingRequestIds.contains(request.id),
                        onApprove: () => _respond(request, true),
                        onReject: () => _respond(request, false),
                      ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TeamJoinRequest {
  final int id;
  final String userName;
  final DateTime? insertedAt;

  const _TeamJoinRequest({
    required this.id,
    required this.userName,
    required this.insertedAt,
  });

  factory _TeamJoinRequest.fromJson(Map<String, dynamic> json) {
    return _TeamJoinRequest(
      id: json['id'] as int,
      userName: json['user_name'] as String? ?? 'Ukendt spiller',
      insertedAt: DateTime.tryParse(json['inserted_at']?.toString() ?? ''),
    );
  }
}

class _JoinRequestRow extends StatelessWidget {
  final _TeamJoinRequest request;
  final bool isSaving;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _JoinRequestRow({
    required this.request,
    required this.isSaving,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(Spacing.borderRadiusLarge),
      ),
      child: Row(
        children: [
          _JoinRequestAvatar(name: request.userName),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: styles.body3.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  _requestedAtLabel(request.insertedAt),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: styles.caption1.copyWith(color: colors.dirt),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          if (isSaving)
            const SizedBox(
              width: 32,
              height: 32,
              child: CupertinoActivityIndicator(),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _JoinRequestActionButton(
                  icon: CupertinoIcons.xmark,
                  color: colors.error,
                  backgroundColor: const Color(0xFFFFEBEE),
                  semanticLabel: 'Afvis ${request.userName}',
                  onPressed: onReject,
                ),
                const SizedBox(width: Spacing.sm),
                _JoinRequestActionButton(
                  icon: CupertinoIcons.checkmark_alt,
                  color: colors.primary,
                  backgroundColor: const Color(0xFFE8F5E9),
                  semanticLabel: 'Godkend ${request.userName}',
                  onPressed: onApprove,
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _requestedAtLabel(DateTime? insertedAt) {
    if (insertedAt == null) return 'Ny anmodning';
    final local = insertedAt.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return 'Anmodet $day/$month';
  }
}

class _JoinRequestAvatar extends StatelessWidget {
  final String name;

  const _JoinRequestAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: colors.offWhite,
        borderRadius: BorderRadius.circular(19),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: styles.body3.copyWith(
          color: colors.grass,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final initials = parts.take(2).map((part) => part[0].toUpperCase()).join();
    return initials.isEmpty ? '?' : initials;
  }
}

class _JoinRequestActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final String semanticLabel;
  final VoidCallback onPressed;

  const _JoinRequestActionButton({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.semanticLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size(32, 32),
        onPressed: onPressed,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

class _EmptyJoinRequests extends StatelessWidget {
  final String message;

  const _EmptyJoinRequests({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final styles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(Spacing.borderRadiusLarge),
      ),
      child: Text(
        message,
        style: styles.caption1.copyWith(color: colors.dirt),
        textAlign: TextAlign.center,
      ),
    );
  }
}
