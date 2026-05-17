import 'package:flutter/material.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/component/chip/status_chip.dart';
import 'package:kopa/component/avatar/app_avatar.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String statusLabel;
  final ChipStatus status;
  final String? assignedPersonName;
  final String? assignedPersonImageUrl;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.statusLabel,
    this.status = ChipStatus.normal,
    this.assignedPersonName,
    this.assignedPersonImageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTextStyles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return KopaCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: appTextStyles.bodyBold,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              StatusChip(
                label: statusLabel,
                status: status,
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              if (assignedPersonName != null) ...[
                AppAvatar(
                  imageUrl: assignedPersonImageUrl,
                  initials: _getInitials(assignedPersonName!),
                  radius: 12,
                ),
                const SizedBox(width: Spacing.sm),
                Text(
                  assignedPersonName!,
                  style: appTextStyles.caption,
                ),
              ] else
                Text(
                  'Ikke tildelt',
                  style: appTextStyles.caption.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }
}
