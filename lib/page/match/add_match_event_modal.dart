import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/component/button/button.dart';
import 'package:kopa/component/list_item/player_list_item.dart';
import 'package:kopa/model/create_match_event_command.dart';
import 'package:kopa/model/match_event_type.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/repository/match_repository.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

enum _PickRole { primary, secondary }

class _EventDraft {
  MatchEventType type;
  int? primaryId;
  int? secondaryId;
  int? minute;

  _EventDraft({
    this.type = MatchEventType.goal,
    this.primaryId,
    this.secondaryId,
    this.minute,
  });
}

Future<void> showAddMatchEventModal(
  BuildContext context,
  int matchId,
  List<UserDetails> squad,
  UserDetails currentUserData,
  Future<void> Function() onSaved,
) async {
  final theme = Theme.of(context);
  final appColors = theme.extension<AppColors>() ?? AppColors.light;
  final appTextStyles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

  _PickRole activeRole = _PickRole.primary;
  _EventDraft current = _EventDraft();
  final List<_EventDraft> staged = [];
  bool isSaving = false;

  final minuteController = TextEditingController();
  final minuteFocus = FocusNode();

  String getUserName(int? id) {
    if (id == null) return '';
    try {
      return squad.firstWhere((u) => u.id == id).name;
    } catch (_) {
      return 'Ukendt';
    }
  }

  String getPrimaryLabel(MatchEventType type) {
    switch (type) {
      case MatchEventType.goal: return 'Målscorer';
      case MatchEventType.substitution: return 'Spiller ind';
      case MatchEventType.penaltyKick: return 'Skytte';
      case MatchEventType.yellowCard:
      case MatchEventType.redCard:
        return 'Spiller';
    }
  }

  String? getSecondaryLabel(MatchEventType type) {
    switch (type) {
      case MatchEventType.goal: return 'Assist';
      case MatchEventType.substitution: return 'Spiller ud';
      default: return null;
    }
  }

  await showCupertinoModalPopup(
    context: context,
    builder: (modalContext) => StatefulBuilder(
      builder: (modalContext, setModalState) {
        Future<void> saveAll() async {
          if (staged.isEmpty || isSaving) return;
          setModalState(() => isSaving = true);
          try {
            final commands = staged.where((d) => d.primaryId != null).map((d) => CreateMatchEventCommand(
                  eventId: matchId,
                  type: d.type,
                  minute: d.minute ?? 0,
                  teamId: currentUserData.teamDetails.id,
                  goalscorerUserId: d.primaryId!,
                  assistMakerUserId: d.secondaryId,
                )).toList();

            if (commands.isEmpty) {
              setModalState(() => isSaving = false);
              return;
            }

            await MatchRepository.createMatchEvents(commands);
            await onSaved();
            if (modalContext.mounted) {
              Navigator.of(modalContext).pop();
            }
          } catch (e) {
            setModalState(() => isSaving = false);
          }
        }

        return Material(
          color: appColors.surface,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoNavigationBar(
                  backgroundColor: appColors.surface,
                  middle: Text('Tilføj begivenhed', style: appTextStyles.sectionHeader),
                  leading: CupertinoButton(padding: EdgeInsets.zero, child: const Text('Luk'), onPressed: () => Navigator.of(modalContext).pop()),
                  trailing: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: (!isSaving && staged.isNotEmpty) ? saveAll : null,
                    child: isSaving ? const CupertinoActivityIndicator() : Text('Gem', style: TextStyle(color: staged.isNotEmpty ? appColors.primary : appColors.divider)),
                  ),
                ),

                if (staged.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: appColors.divider.withValues(alpha: 0.1),
                      border: Border(bottom: BorderSide(color: appColors.divider)),
                    ),
                    constraints: const BoxConstraints(maxHeight: 150),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: staged.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final s = staged[i];
                        return Row(
                          children: [
                            Icon(Icons.event, size: 16, color: appColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${s.minute != null ? '${s.minute}\' ' : ''}${getUserName(s.primaryId)}${s.secondaryId != null ? ' (Sec: ${getUserName(s.secondaryId)})' : ''}',
                                style: appTextStyles.body,
                              ),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: Icon(CupertinoIcons.minus_circle_fill, color: appColors.error, size: 20),
                              onPressed: () => setModalState(() => staged.removeAt(i)),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 16),

                // Category Selection
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CupertinoSlidingSegmentedControl<MatchEventType>(
                    backgroundColor: appColors.divider,
                    thumbColor: appColors.surface,
                    groupValue: current.type,
                    children: {
                      MatchEventType.goal: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Mål')),
                      MatchEventType.substitution: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Udskiftning')),
                      MatchEventType.yellowCard: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Gult Kort')),
                      MatchEventType.redCard: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Rødt Kort')),
                      MatchEventType.penaltyKick: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Straffe')),
                    },
                    onValueChanged: (v) {
                      if (v != null) {
                        setModalState(() {
                          current.type = v;
                          current.primaryId = null;
                          current.secondaryId = null;
                          activeRole = _PickRole.primary;
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Minute and Player Selection
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Minute Input
                      SizedBox(
                        width: 70,
                        child: Column(
                          children: [
                            Text('Minut', style: appTextStyles.caption.copyWith(color: appColors.textSecondary)),
                            const SizedBox(height: 4),
                            CupertinoTextField(
                              controller: minuteController,
                              focusNode: minuteFocus,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              placeholder: '45',
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                color: appColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: appColors.divider, width: 2),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Primary Player
                      Expanded(
                        child: _SelectionBox(
                          label: getPrimaryLabel(current.type),
                          name: getUserName(current.primaryId),
                          isActive: activeRole == _PickRole.primary,
                          onTap: () => setModalState(() => activeRole = _PickRole.primary),
                        ),
                      ),
                      // Secondary Player (if applicable)
                      if (getSecondaryLabel(current.type) != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SelectionBox(
                            label: getSecondaryLabel(current.type)!,
                            name: getUserName(current.secondaryId),
                            isActive: activeRole == _PickRole.secondary,
                            onTap: () => setModalState(() => activeRole = _PickRole.secondary),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: ListView.builder(
                    itemCount: squad.length,
                    itemBuilder: (context, index) {
                      final u = squad[index];
                      final isPrimary = current.primaryId == u.id;
                      final isSecondary = current.secondaryId == u.id;

                      return PlayerListItem(
                        name: u.name,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isPrimary) _Badge(label: getPrimaryLabel(current.type)),
                            if (isSecondary && getSecondaryLabel(current.type) != null) _Badge(label: getSecondaryLabel(current.type)!),
                          ],
                        ),
                        onTap: () => setModalState(() {
                          if (activeRole == _PickRole.primary) {
                            current.primaryId = u.id;
                            if (getSecondaryLabel(current.type) != null) {
                              activeRole = _PickRole.secondary;
                            }
                          } else {
                            if (current.primaryId == u.id) return;
                            current.secondaryId = (current.secondaryId == u.id) ? null : u.id;
                          }
                        }),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Button(
                    buttonText: 'Tilføj til liste',
                    onPressed: () {
                      if (current.primaryId != null) {
                        setModalState(() {
                          current.minute = int.tryParse(minuteController.text);
                          staged.add(_EventDraft(
                            type: current.type,
                            primaryId: current.primaryId,
                            secondaryId: current.secondaryId,
                            minute: current.minute,
                          ));
                          current = _EventDraft(type: current.type); // retain type
                          activeRole = _PickRole.primary;
                          minuteController.clear();
                          minuteFocus.unfocus();
                        });
                      }
                    },
                    enabled: current.primaryId != null,
                  ),
                )
              ],
            ),
          ),
        );
      },
    ),
  );
}

class _SelectionBox extends StatelessWidget {
  final String label;
  final String name;
  final bool isActive;
  final VoidCallback onTap;

  const _SelectionBox({
    required this.label,
    required this.name,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? appColors.primary.withValues(alpha: 0.1) : appColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? appColors.primary : appColors.divider,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(label, style: appTextStyles.caption.copyWith(color: isActive ? appColors.primary : appColors.textSecondary), overflow: TextOverflow.ellipsis,),
            const SizedBox(height: 4),
            Text(
              name.isEmpty ? 'Vælg...' : name,
              style: appTextStyles.bodyBold.copyWith(
                color: name.isEmpty ? appColors.textSecondary.withValues(alpha: 0.5) : appColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: appColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
