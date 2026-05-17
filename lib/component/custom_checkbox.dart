import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        if (onChanged != null) {
          onChanged!(!value);
        }
      },
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: appColors.black,
            width: 2,
          ),
          color: value == true ? appColors.black : appColors.surface,
        ),
        child: value
            ? Icon(
                CupertinoIcons.check_mark,
                color: appColors.surface,
                size: 14,
              )
            : null,
      ),
    );
  }
}

/*
                                                      Container(
                                                        width: 22,
                                                        height: 22,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                            color:
                                                                CupertinoColors
                                                                    .black,
                                                            width: 2,
                                                          ),
                                                          color: selectedPlayers[
                                                                          fine[
                                                                              'id']]![
                                                                      player
                                                                          .id] ==
                                                                  true
                                                              ? CupertinoColors
                                                                  .black
                                                              : CupertinoColors
                                                                  .white,
                                                        ),
                                                        child: selectedPlayers[fine[
                                                                        'id']]![
                                                                    player
                                                                        .id] ==
                                                                true
                                                            ? Icon(
                                                                CupertinoIcons
                                                                    .checkmark,
                                                                color:
                                                                    CupertinoColors
                                                                        .white,
                                                                size: 16)
                                                            : null,
                                                      ),
 */
