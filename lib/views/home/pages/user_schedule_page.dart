import 'dart:async';
import 'package:flutter/material.dart';
import 'edit_day_page.dart';

/// --------------------
/// 모델
/// --------------------
class MinuteRange {
  final int startMin; // [0,1440)
  final int endMin; // start < end
  const MinuteRange(this.startMin, this.endMin);
}

class DayAvailability {
  final bool allDay;
  final List<MinuteRange> ranges; // 부분 불가 여러 구간
  const DayAvailability({required this.allDay, required this.ranges});

  factory DayAvailability.available() =>
      const DayAvailability(allDay: false, ranges: []);
  factory DayAvailability.allDayBlocked() =>
      const DayAvailability(allDay: true, ranges: []);
  bool get isPartial => !allDay && ranges.isNotEmpty;
  bool get isAvailable => !allDay && ranges.isEmpty;
}

/// --------------------
/// 리포지토리(데모 InMemory)
/// --------------------
abstract class ScheduleRepository {
  Future<Map<DateTime, DayAvailability>> fetchMonth(
      int userId, DateTime anyDayInMonth);
  Future<DayAvailability> fetchDay(int userId, DateTime day);
  Future<void> saveDay(int userId, DateTime day, DayAvailability availability);
}

class InMemoryScheduleRepository implements ScheduleRepository {
  final Map<String, DayAvailability> _store = {
    '2025-08-10': DayAvailability.allDayBlocked(),
    '2025-08-11': const DayAvailability(
      allDay: false,
      ranges: [
        MinuteRange(12 * 60, 13 * 60),
        MinuteRange(12 * 60, 13 * 60),
        MinuteRange(12 * 60, 13 * 60),
        MinuteRange(12 * 60, 13 * 60),
        MinuteRange(12 * 60, 13 * 60),
        MinuteRange(12 * 60, 13 * 60),
        MinuteRange(12 * 60, 13 * 60),
        MinuteRange(12 * 60, 13 * 60),
        MinuteRange(12 * 60, 13 * 60),
        MinuteRange(12 * 60, 13 * 60),
        MinuteRange(12 * 60, 13 * 60),
        MinuteRange(19 * 60, 22 * 60)
      ],
    ),
    '2025-08-18': const DayAvailability(
        allDay: false, ranges: [MinuteRange(10 * 60, 11 * 60)]),
  };

  String _k(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Future<Map<DateTime, DayAvailability>> fetchMonth(
      int userId, DateTime anyDayInMonth) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final first = DateTime(anyDayInMonth.year, anyDayInMonth.month, 1);
    final next = DateTime(anyDayInMonth.year, anyDayInMonth.month + 1, 1);
    final days = next.difference(first).inDays;
    final map = <DateTime, DayAvailability>{};
    for (int i = 0; i < days; i++) {
      final d = DateTime(anyDayInMonth.year, anyDayInMonth.month, i + 1);
      map[d] = _store[_k(d)] ?? DayAvailability.available();
    }
    return map;
  }

  @override
  Future<DayAvailability> fetchDay(int userId, DateTime day) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return _store[_k(day)] ?? DayAvailability.available();
  }

  @override
  Future<void> saveDay(
      int userId, DateTime day, DayAvailability availability) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    _store[_k(day)] = availability;
  }
}

/// --------------------
/// 유틸
/// --------------------
Widget _dot({required Color color}) => Container(
      width: 12,
      height: 12,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
    );
String _fmtDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
String _mm(int m) =>
    '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';

List<MinuteRange> _mergeRanges(List<MinuteRange> input) {
  final arr = input
      .where((r) => r.endMin > r.startMin)
      .map((r) =>
          MinuteRange(r.startMin.clamp(0, 1440), r.endMin.clamp(0, 1440)))
      .toList()
    ..sort((a, b) => a.startMin != b.startMin
        ? a.startMin - b.startMin
        : a.endMin - b.endMin);
  final out = <MinuteRange>[];
  for (final cur in arr) {
    if (out.isEmpty || cur.startMin > out.last.endMin)
      out.add(cur);
    else
      out[out.length - 1] = MinuteRange(out.last.startMin,
          cur.endMin > out.last.endMin ? cur.endMin : out.last.endMin);
  }
  return out;
}

/// --------------------
/// 메인: 유저 스케줄 페이지
/// --------------------
class UserSchedulePage extends StatefulWidget {
  final int userId;
  final ScheduleRepository repository;
  UserSchedulePage({
    super.key,
    this.userId = 1,
    ScheduleRepository? repository,
  }) : repository = repository ?? InMemoryScheduleRepository();

  @override
  State<UserSchedulePage> createState() => _UserSchedulePageState();
}

class _UserSchedulePageState extends State<UserSchedulePage> {
  late DateTime _monthCursor;
  Map<DateTime, DayAvailability> _monthData = {};
  bool _loading = true;
  DateTime? _selectedDate;
  DayAvailability? _selectedDayAvailability;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _monthCursor = DateTime(now.year, now.month, 1);
    _loadMonth();
  }

  Future<void> _loadMonth() async {
    setState(() {
      _loading = true;
      _selectedDate = null; // Clear selected date
      _selectedDayAvailability = null; // Clear selected day availability
    });
    final data =
        await widget.repository.fetchMonth(widget.userId, _monthCursor);
    setState(() {
      _monthData = data;
      _loading = false;
    });
  }

  void _prevMonth() {
    _monthCursor = DateTime(_monthCursor.year, _monthCursor.month - 1, 1);
    _selectedDate = null; // Clear selected date
    _selectedDayAvailability = null; // Clear selected day availability
    _loadMonth();
  }

  void _nextMonth() {
    _monthCursor = DateTime(_monthCursor.year, _monthCursor.month + 1, 1);
    _selectedDate = null; // Clear selected date
    _selectedDayAvailability = null; // Clear selected day availability
    _loadMonth();
  }

  @override
  Widget build(BuildContext context) {
    final days = _daysInMonth(_monthCursor);
    final firstWeekday = DateTime(_monthCursor.year, _monthCursor.month, 1)
        .weekday; // 1=Mon..7=Sun
    final leadingBlanks = (firstWeekday % 7);
    final gridCount = leadingBlanks + days;
    final rows = ((gridCount + 6) ~/ 7);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '${_monthCursor.year}.${_monthCursor.month.toString().padLeft(2, '0')}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondaryContainer,
            fontSize: 34,
            fontFamily: 'PixelFont',
          ),
        ),
        actions: [
          IconButton(
              onPressed: _prevMonth,
              icon: Icon(Icons.chevron_left,
                  size: 30, // Increased size
                  color: Theme.of(context).colorScheme.secondaryContainer)),
          IconButton(
              onPressed: _nextMonth,
              icon: Icon(Icons.chevron_right,
                  size: 30, // Increased size
                  color: Theme.of(context).colorScheme.secondaryContainer)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _legend(context),
                _weekdayHeader(context),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(8),
                  itemCount: rows * 7,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemBuilder: (_, index) {
                    final dayIndex = index - leadingBlanks + 1;
                    if (dayIndex < 1 || dayIndex > days)
                      return const SizedBox.shrink();
                    final date = DateTime(
                        _monthCursor.year, _monthCursor.month, dayIndex);
                    final state =
                        _monthData[date] ?? DayAvailability.available();
                    final color = state.allDay
                        ? Colors.red.withOpacity(.18)
                        : (state.isPartial
                            ? Colors.amber.withOpacity(.20)
                            : Colors.transparent);
                    final borderColor = state.allDay
                        ? Colors.red
                        : (state.isPartial
                            ? Colors.amber.shade700
                            : Theme.of(context).dividerColor);

                    return _DayCell(
                      day: dayIndex,
                      bgColor: color,
                      borderColor: borderColor,
                      onTap: () async {
                        final detail = await widget.repository
                            .fetchDay(widget.userId, date);
                        setState(() {
                          _selectedDate = date;
                          _selectedDayAvailability = detail;
                        });
                      },
                    );
                  },
                ),
                _buildDayDetails(),
                // const SizedBox(height: 3),
              ],
            ),
    );
  }

  Widget _buildDayDetails() {
    if (_selectedDayAvailability == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final date = _selectedDate!;
    final day = _selectedDayAvailability!;
    String badge;
    Color badgeColor;
    if (day.allDay) {
      badge = '종일 불가';
      badgeColor = Colors.red;
    } else if (day.ranges.isNotEmpty) {
      badge = '부분 불가';
      badgeColor = Colors.amber.shade700;
    } else {
      badge = '가능';
      badgeColor = Colors.green;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(_fmtDate(date),
                style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'PixelFont',
                    color: theme.colorScheme.secondaryContainer,
                    fontSize: 22)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: badgeColor),
              ),
              child: Text(badge,
                  style: theme.textTheme.labelMedium?.copyWith(
                      color: badgeColor,
                      fontFamily: 'PixelFont',
                      fontSize: 14)),
            ),
            // Removed Spacer()
            IconButton(
              // Changed to IconButton
              icon: Icon(Icons.edit,
                  color: theme.colorScheme.secondaryContainer,
                  size: 24), // Edit icon
              onPressed: () async {
                // 편집 페이지로 이동
                final result =
                    await Navigator.of(context).push<Map<String, dynamic>>(
                  MaterialPageRoute(
                    builder: (_) => EditDayPage(
                      date: date,
                      initialAllDay: day.allDay,
                      initialRanges: day.ranges
                          .map((e) =>
                              {'startMin': e.startMin, 'endMin': e.endMin})
                          .toList(),
                      drawerBg: Theme.of(context).drawerTheme.backgroundColor,
                    ),
                  ),
                );
                if (result == null) return;

                // 결과 반영
                final bool allDay = result['allDay'] as bool;
                final List rangesJson = (result['ranges'] as List?) ?? [];
                final ranges = rangesJson
                    .map((m) =>
                        MinuteRange(m['startMin'] as int, m['endMin'] as int))
                    .toList();
                final saved = DayAvailability(
                    allDay: allDay, ranges: _mergeRanges(ranges));
                await widget.repository.saveDay(widget.userId, date, saved);
                setState(() {
                  _monthData[DateTime(date.year, date.month, date.day)] = saved;
                  _selectedDayAvailability = saved;
                });
                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('저장되었습니다.')));
                }
              },
            ),
          ]),
          if (day.allDay)
            Row(children: [
              _dot(color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                  child: Text('00:00–24:00',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'PixelFont',
                          color: theme.colorScheme.secondaryContainer,
                          fontSize: 18))),
            ])
          else if (day.ranges.isNotEmpty) ...[
            Builder(
              builder: (context) {
                final ranges = [...day.ranges]
                  ..sort((a, b) => a.startMin - b.startMin);
                return SizedBox(
                  height: 190, // 원하는 높이 유지/조절 가능
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: ranges.length + 1, // 마지막에 여유 공간용 아이템 추가
                    itemBuilder: (_, idx) {
                      if (idx == ranges.length) {
                        // 마지막 여유 공간
                        return const SizedBox(height: 90); // 네비게이션 높이보다 조금 크게
                      }
                      final r = ranges[idx];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            _dot(color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              '${_mm(r.startMin)}–${_mm(r.endMin)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontFamily: 'PixelFont',
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    fontSize: 18,
                                  ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ] else ...[
            Row(children: [
              _dot(color: Colors.green),
              const SizedBox(width: 8),
              Text('제한 없음',
                  style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'PixelFont',
                      color: theme.colorScheme.secondaryContainer,
                      fontSize: 18)),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _legend(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        _dot(color: Colors.red),
        const SizedBox(width: 4),
        Text('종일 불가',
            style: theme.textTheme.labelSmall?.copyWith(
                fontFamily: 'PixelFont',
                fontSize: 13,
                color: theme.colorScheme.secondaryContainer)),
        const SizedBox(width: 12),
        _dot(color: Colors.amber.shade700),
        const SizedBox(width: 4),
        Text('부분 불가',
            style: theme.textTheme.labelSmall?.copyWith(
                fontFamily: 'PixelFont',
                fontSize: 13,
                color: theme.colorScheme.secondaryContainer)),
      ]),
    );
  }

  Widget _weekdayHeader(BuildContext context) {
    final style = TextStyle(
        color: Theme.of(context).colorScheme.secondaryContainer,
        fontFamily: 'PixelFont',
        fontSize: 18);
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(children: [
        for (final d in days)
          Expanded(child: Center(child: Text(d, style: style)))
      ]),
    );
  }

  int _daysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final next = DateTime(month.year, month.month + 1, 1);
    return next.difference(first).inDays;
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final Color bgColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.bgColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor.withOpacity(.6)),
          ),
          padding: const EdgeInsets.all(8),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              '$day',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.secondaryContainer,
                fontFamily: 'PixelFont',
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
