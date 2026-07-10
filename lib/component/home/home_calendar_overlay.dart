import 'package:flutter/material.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

const _danishMonths = <String>[
  'Januar',
  'Februar',
  'Marts',
  'April',
  'Maj',
  'Juni',
  'Juli',
  'August',
  'September',
  'Oktober',
  'November',
  'December',
];
const _danishWeekdays = <String>['M', 'T', 'O', 'T', 'F', 'L', 'S'];
const _initialPage = 1200;

Future<void> showHomeCalendarOverlay({
  required BuildContext context,
  required List<MatchDetails> events,
  required ValueChanged<MatchDetails> onEventTap,
}) async {
  final selectedEvent = await showGeneralDialog<MatchDetails>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Luk kalender',
    barrierColor: Colors.black.withValues(alpha: 0.22),
    transitionDuration: const Duration(milliseconds: 360),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return SafeArea(
        child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 60, 12, 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: HomeCalendarCard(
                events: events,
                onClose: () => Navigator.of(dialogContext).pop(),
                onEventTap: (event) => Navigator.of(dialogContext).pop(event),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final movement = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1.25),
            end: Offset.zero,
          ).animate(movement),
          child: child,
        ),
      );
    },
  );

  if (selectedEvent != null) onEventTap(selectedEvent);
}

class HomeCalendarCard extends StatefulWidget {
  const HomeCalendarCard({
    super.key,
    required this.events,
    required this.onEventTap,
    this.onClose,
    this.initialMonth,
    this.today,
  });

  final List<MatchDetails> events;
  final ValueChanged<MatchDetails> onEventTap;
  final VoidCallback? onClose;
  final DateTime? initialMonth;
  final DateTime? today;

  @override
  State<HomeCalendarCard> createState() => _HomeCalendarCardState();
}

class _HomeCalendarCardState extends State<HomeCalendarCard> {
  late final DateTime _originMonth;
  late final PageController _pageController;
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialMonth ?? widget.today ?? DateTime.now();
    _originMonth = DateTime(initial.year, initial.month);
    _visibleMonth = _originMonth;
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final textStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Material(
      color: colors.lightGrass65,
      elevation: 14,
      shadowColor: colors.dirt.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(Spacing.borderRadiusLargeIncreased),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Spacing.md, 12, Spacing.md, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_danishMonths[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                    key: const Key('calendar-month-label'),
                    style: textStyles.subtitle1.copyWith(
                      color: colors.grass,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _MonthButton(
                  tooltip: 'Forrige måned',
                  icon: Icons.chevron_left_rounded,
                  onPressed: () => _changeMonth(-1),
                ),
                _MonthButton(
                  tooltip: 'Næste måned',
                  icon: Icons.chevron_right_rounded,
                  onPressed: () => _changeMonth(1),
                ),
                if (widget.onClose != null) ...[
                  const SizedBox(width: 2),
                  _MonthButton(
                    tooltip: 'Luk kalender',
                    icon: Icons.close_rounded,
                    filled: true,
                    onPressed: widget.onClose!,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _LegendDot(color: colors.sunset),
                Text('Kamp',
                    style: textStyles.label.copyWith(color: colors.grass)),
                const SizedBox(width: 12),
                _LegendDot(color: colors.sky),
                Text('Træning',
                    style: textStyles.label.copyWith(color: colors.grass)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: _danishWeekdays
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: textStyles.caption3.copyWith(
                            color: colors.grass.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 228,
              child: PageView.builder(
                key: const Key('calendar-month-pages'),
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() => _visibleMonth = _monthForPage(page));
                },
                itemBuilder: (context, page) => _CalendarMonthGrid(
                  month: _monthForPage(page),
                  today: widget.today ?? DateTime.now(),
                  events: widget.events,
                  onEventTap: widget.onEventTap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime _monthForPage(int page) {
    return DateTime(
        _originMonth.year, _originMonth.month + page - _initialPage);
  }

  void _changeMonth(int delta) {
    final targetPage = (_pageController.page?.round() ?? _initialPage) + delta;
    _pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.filled = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return SizedBox.square(
      dimension: 36,
      child: IconButton(
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: filled ? colors.lightSky55 : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.borderRadiusSmall),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 19, color: colors.grass),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: const SizedBox.square(dimension: 5),
      ),
    );
  }
}

class _CalendarMonthGrid extends StatelessWidget {
  const _CalendarMonthGrid({
    required this.month,
    required this.today,
    required this.events,
    required this.onEventTap,
  });

  final DateTime month;
  final DateTime today;
  final List<MatchDetails> events;
  final ValueChanged<MatchDetails> onEventTap;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month);
    final gridStart = firstDay.subtract(Duration(days: firstDay.weekday - 1));

    return Column(
      children: List.generate(6, (week) {
        return Expanded(
          child: Row(
            children: List.generate(7, (weekday) {
              final date = gridStart.add(Duration(days: week * 7 + weekday));
              final dateEvents = events
                  .where((event) => _isSameDay(event.date.toLocal(), date))
                  .toList()
                ..sort((a, b) => a.date.compareTo(b.date));
              return Expanded(
                child: _CalendarDay(
                  date: date,
                  isInMonth: date.month == month.month,
                  isToday: _isSameDay(date, today),
                  events: dateEvents,
                  onTap: dateEvents.isEmpty
                      ? null
                      : () => onEventTap(dateEvents.first),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.date,
    required this.isInMonth,
    required this.isToday,
    required this.events,
    required this.onTap,
  });

  final DateTime date;
  final bool isInMonth;
  final bool isToday;
  final List<MatchDetails> events;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final textStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final keyDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    return Semantics(
      button: onTap != null,
      label: 'Kalenderdag ${date.day}',
      child: InkWell(
        key: Key('calendar-day-$keyDate'),
        borderRadius: BorderRadius.circular(Spacing.borderRadiusFull),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isToday ? colors.lightGrass : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${date.day}',
                style: textStyles.body3.copyWith(
                  color: colors.grass.withValues(alpha: isInMonth ? 1 : 0.25),
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              height: 7,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: events.take(2).map((event) {
                  final isTraining = event.type.toLowerCase() == 'training';
                  return Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: isTraining ? colors.sky : colors.sunset,
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
