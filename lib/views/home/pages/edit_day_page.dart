import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rockstar_app/common/buttons/mini_primary_button.dart';
import 'package:rockstar_app/common/buttons/mini_secondary_button.dart';
import 'package:rockstar_app/common/buttons/secondary_button.dart';
import 'package:rockstar_app/views/home/pages/mini_primary_button_small.dart';
import 'package:rockstar_app/views/home/pages/mini_secondary_button_small.dart';
import 'package:rockstar_app/common/appBar/default_app_bar.dart';

/// 결과는 Map으로 반환: {'allDay': bool, 'ranges': [{'startMin':int,'endMin':int}, ...]}
class EditDayPage extends StatefulWidget {
  final DateTime date;
  final bool initialAllDay;
  final List<Map<String, int>> initialRanges;
  final Color? drawerBg;

  const EditDayPage({
    super.key,
    required this.date,
    required this.initialAllDay,
    required this.initialRanges,
    this.drawerBg,
  });

  @override
  State<EditDayPage> createState() => _EditDayPageState();
}

enum EditKind { available, allDay, partial }

class _EditDayPageState extends State<EditDayPage> {
  late EditKind kind;
  late List<Map<String, int>> ranges;

  @override
  void initState() {
    super.initState();
    if (widget.initialAllDay) {
      kind = EditKind.allDay;
    } else if (widget.initialRanges.isNotEmpty) {
      kind = EditKind.partial;
    } else {
      kind = EditKind.available;
    }
    ranges = [...widget.initialRanges];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      appBar: DefaultAppBar(
        title: '${widget.date.year}.${widget.date.month.toString().padLeft(2, '0')}.${widget.date.day.toString().padLeft(2, '0')}',
        onBack: () => Navigator.pop(context),
        actions: [
          TextButton(
            onPressed: _finish,
            child: Text(
              '완료',
              style: TextStyle(
                fontFamily: 'PixelFont',
                fontSize: 18,
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true, // ✅ 하단 잘림 방지
        child: Column(
          children: [
            const SizedBox(height: 8),
            _kindSelector(),
            const SizedBox(height: 12),
            if (kind == EditKind.partial) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  '불가능한 시간을 색칠해주세요',
                  style: TextStyle(
                    fontFamily: 'PixelFont',
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                ),
              ),
              Expanded(
                child: _PartialEditorWithHandle(
                  initialRanges: ranges,
                  onChanged: (r) => ranges = r,
                  bgColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  slotPixelHeight: 50,
                ),
              ),
            ] else
              const Spacer(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // 기존 _kindSelector() 전체 교체
  // _kindSelector 교체
  Widget _kindSelector() {
    const double outerPadding = 16; // 좌우 패딩
    const double gap = 8; // 버튼 사이 간격

    Widget button(EditKind k, String label) {
      final selected = (kind == k);
      final child = selected
          ? MiniPrimaryButtonSmall(
              label: label,
              onPressed: () => setState(() => kind = k),
            )
          : MiniSecondaryButtonSmall(
              label: label,
              onPressed: () => setState(() => kind = k),
            );
      return child;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: outerPadding),
      child: Row(
        children: [
          Expanded(child: button(EditKind.allDay, '종일불가')),
          const SizedBox(width: gap),
          Expanded(child: button(EditKind.partial, '부분불가')),
          const SizedBox(width: gap),
          Expanded(child: button(EditKind.available, '종일가능')),
        ],
      ),
    );
  }

  void _finish() {
    final bool allDay = (kind == EditKind.allDay);
    final List<Map<String, int>> out =
        (kind == EditKind.partial) ? _mergeRanges(ranges) : [];
    Navigator.pop<Map<String, dynamic>>(
      context,
      {'allDay': allDay, 'ranges': out},
    );
  }

  List<Map<String, int>> _mergeRanges(List<Map<String, int>> input) {
    final arr = input
        .where((m) => (m['endMin'] ?? 0) > (m['startMin'] ?? 0))
        .map((m) => {
              'startMin': (m['startMin']!).clamp(0, 1440),
              'endMin': (m['endMin']!).clamp(0, 1440)
            })
        .toList()
      ..sort((a, b) => (a['startMin']! != b['startMin']!)
          ? a['startMin']! - b['startMin']!
          : a['endMin']! - b['endMin']!);
    final out = <Map<String, int>>[];
    for (final cur in arr) {
      if (out.isEmpty || cur['startMin']! > out.last['endMin']!) {
        out.add({'startMin': cur['startMin']!, 'endMin': cur['endMin']!});
      } else {
        out.last = {
          'startMin': out.last['startMin']!,
          'endMin': (cur['endMin']! > out.last['endMin']!)
              ? cur['endMin']!
              : out.last['endMin']!,
        };
      }
    }
    return out;
  }
}

/// 드래그 불가 스크롤 비헤이비어(가운데 영역 사용자 드래그 금지)
class _NoDragScrollBehavior extends MaterialScrollBehavior {
  const _NoDragScrollBehavior();
  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{};
}

/// ===============================================
/// 부분불가 편집: 오른쪽 핸들 스크롤(핸들 폭 = 시간바 폭) + 시간바는 스크롤 금지
/// ===============================================
class _PartialEditorWithHandle extends StatefulWidget {
  final List<Map<String, int>> initialRanges;
  final ValueChanged<List<Map<String, int>>> onChanged;
  final Color bgColor;
  final double slotPixelHeight;

  const _PartialEditorWithHandle({
    super.key,
    required this.initialRanges,
    required this.onChanged,
    required this.bgColor,
    this.slotPixelHeight = 30,
  });

  @override
  State<_PartialEditorWithHandle> createState() =>
      _PartialEditorWithHandleState();
}

class _PartialEditorWithHandleState extends State<_PartialEditorWithHandle> {
  final int slotMinutes = 30; // 30분 그리드
  final ScrollController _scroll = ScrollController();

  late List<bool> _blocked; // 48칸
  int get _slots => (1440 / slotMinutes).round(); // 48

  int? _lastIdx;
  bool? _strokeTarget;
  int _paintVersion = 0; // ✅ 페인터 리페인트용 버전

  @override
  void initState() {
    super.initState();
    _blocked = List<bool>.filled(_slots, false);
    _apply(widget.initialRanges);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _apply(List<Map<String, int>> ranges) {
    for (final m in ranges) {
      final s =
          ((m['startMin'] ?? 0) / slotMinutes).floor().clamp(0, _slots - 1);
      final e = ((m['endMin'] ?? 0) / slotMinutes).ceil().clamp(0, _slots);
      for (int i = s; i < e; i++) _blocked[i] = true;
    }
    _paintVersion++;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const double leftLabelWidth = 50; // 라벨 너비
    const double gap = 15;
    const double verticalPadding = 12; // ✅ 위·아래 여백 추가

    return LayoutBuilder(
      builder: (context, c) {
        final contentHeight = _slots * widget.slotPixelHeight; // 실제 24h 높이
        final paddedHeight = contentHeight + verticalPadding * 2; // 스크롤 총 높이
        final hourStep = (60 ~/ slotMinutes);

        // 시간바 폭과 오른쪽 핸들 폭 동일
        final base = c.maxWidth - leftLabelWidth - gap;
        final double barWidth = base / 2;
        final double handleWidth = barWidth;

        return Row(
          children: [
            // 가운데: 컨텐츠(라벨+시간바)를 프로그램적으로만 스크롤
            SizedBox(
              width: c.maxWidth - handleWidth, // 오른쪽 핸들 제외
              child: ScrollConfiguration(
                behavior: const _NoDragScrollBehavior(), // 사용자 드래그 차단
                child: SingleChildScrollView(
                  controller: _scroll,
                  physics: const NeverScrollableScrollPhysics(),
                  child: SizedBox(
                    height: paddedHeight, // 패딩 포함 높이
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: verticalPadding), // ✅ 위·아래 여백
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 왼쪽 시간 라벨 (실제 그리는 높이는 contentHeight)
                          SizedBox(
                            width: leftLabelWidth,
                            child: CustomPaint(
                              size: Size(leftLabelWidth, contentHeight),
                              painter: _HourLabelsPainter(
                                slotHeight: widget.slotPixelHeight,
                                theme: Theme.of(context),
                              ),
                            ),
                          ),
                          const SizedBox(width: gap),
                          // 시간 바(페인팅 전용) — 실제 그리는 높이는 contentHeight
                          SizedBox(
                            width: barWidth,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onPanStart: (d) => _begin(
                                  d.localPosition.dy, widget.slotPixelHeight),
                              onPanUpdate: (d) => _move(
                                  d.localPosition.dy, widget.slotPixelHeight),
                              onPanEnd: (_) => _end(),
                              child: CustomPaint(
                                size: Size(barWidth, contentHeight),
                                painter: _VerticalPainter(
                                  blocked: _blocked,
                                  slotHeight: widget.slotPixelHeight,
                                  hourStep: hourStep,
                                  theme: Theme.of(context),
                                  bgColor: widget.bgColor,
                                  paintVersion: _paintVersion,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 오른쪽 스크롤 핸들: 폭을 시간바와 동일하게 (스크롤 방향 반전 유지)
            SizedBox(
              width: handleWidth,
              child: Listener(
                onPointerSignal: (ps) {
                  if (ps is PointerScrollEvent && _scroll.hasClients) {
                    final next = (_scroll.offset - ps.scrollDelta.dy)
                        .clamp(0.0, _scroll.position.maxScrollExtent);
                    _scroll.jumpTo(next);
                  }
                },
                onPointerMove: (e) {
                  if (_scroll.hasClients) {
                    final next = (_scroll.offset - e.delta.dy)
                        .clamp(0.0, _scroll.position.maxScrollExtent);
                    _scroll.jumpTo(next);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: widget.bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===== 페인트 토글 로직 =====
  int _idxFromDy(double dy, double slotHeight) {
    int idx = (dy / slotHeight).floor();
    if (idx < 0) idx = 0;
    if (idx >= _slots) idx = _slots - 1;
    return idx;
  }

  void _begin(double dy, double slotHeight) {
    final idx = _idxFromDy(dy, slotHeight);
    _strokeTarget = !_blocked[idx];
    _lastIdx = idx;
    _applyRange(idx, idx);
  }

  void _move(double dy, double slotHeight) {
    if (_lastIdx == null || _strokeTarget == null) return;
    final idx = _idxFromDy(dy, slotHeight);
    if (idx == _lastIdx) return;
    _applyRange(_lastIdx!, idx);
    _lastIdx = idx;
  }

  void _end() {
    _lastIdx = null;
    _strokeTarget = null;
    widget.onChanged(_mergeRanges(_toRanges()));
  }

  void _applyRange(int a, int b) {
    final lo = a < b ? a : b;
    final hi = a > b ? a : b;
    for (int i = lo; i <= hi; i++) _blocked[i] = _strokeTarget!;
    _paintVersion++; // 리페인트 트리거
    setState(() {});
  }

  List<Map<String, int>> _toRanges() {
    final out = <Map<String, int>>[];
    int i = 0;
    while (i < _blocked.length) {
      if (!_blocked[i]) {
        i++;
        continue;
      }
      final s = i;
      while (i < _blocked.length && _blocked[i]) i++;
      final e = i;
      out.add({'startMin': s * slotMinutes, 'endMin': e * slotMinutes});
    }
    return out;
  }

  List<Map<String, int>> _mergeRanges(List<Map<String, int>> input) {
    final arr = input
        .where((m) => (m['endMin'] ?? 0) > (m['startMin'] ?? 0))
        .map((m) => {
              'startMin': (m['startMin']!).clamp(0, 1440),
              'endMin': (m['endMin']!).clamp(0, 1440)
            })
        .toList()
      ..sort((a, b) => (a['startMin']! != b['startMin']!)
          ? a['startMin']! - b['startMin']!
          : a['endMin']! - b['endMin']!);
    final out = <Map<String, int>>[];
    for (final cur in arr) {
      if (out.isEmpty || cur['startMin']! > out.last['endMin']!) {
        out.add({'startMin': cur['startMin']!, 'endMin': cur['endMin']!});
      } else {
        out.last = {
          'startMin': out.last['startMin']!,
          'endMin': (cur['endMin']! > out.last['endMin']!)
              ? cur['endMin']!
              : out.last['endMin']!,
        };
      }
    }
    return out;
  }
}

/// 왼쪽 시간 라벨(시간바와 같은 컨텐츠 안에서 함께 스크롤)
class _HourLabelsPainter extends CustomPainter {
  final double slotHeight; // 30분 슬롯의 픽셀 높이
  final ThemeData theme;

  _HourLabelsPainter({required this.slotHeight, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(textDirection: TextDirection.ltr);

    // 00:00 ~ 24:00
    for (int h = 0; h <= 24; h++) {
      final yLine = h * 2 * slotHeight; // 정시 라인 (그리드 기준)

      final text = '${h.toString().padLeft(2, '0')}:00';
      tp.text = TextSpan(
        text: text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.secondaryContainer,
          fontFamily: 'PixelFont',
          fontSize: 18, // Reduced font size
        ),
      );
      tp.layout();

      double dy = yLine - tp.height / 2; // 중앙 정렬
      // No special handling for h == 0 or h == 24, as yLine already accounts for it.

      final dx = (size.width - tp.width - 2)
          .clamp(8.0, size.width); // Added left padding
      tp.paint(canvas, Offset(dx, dy));
    }
  }

  @override
  bool shouldRepaint(covariant _HourLabelsPainter old) =>
      old.slotHeight != slotHeight || old.theme != theme;
}

class _VerticalPainter extends CustomPainter {
  final List<bool> blocked;
  final double slotHeight;
  final int hourStep;
  final ThemeData theme;
  final Color bgColor;
  final int paintVersion;

  _VerticalPainter({
    required this.blocked,
    required this.slotHeight,
    required this.hourStep,
    required this.theme,
    required this.bgColor,
    required this.paintVersion,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = bgColor;
    final fill = Paint()..color = theme.colorScheme.primary.withOpacity(0.9);
    final grid = Paint()
      ..color = theme.colorScheme.secondaryContainer.withOpacity(0.5)
      ..strokeWidth = 1;

    // 배경
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      bg,
    );

    final w = size.width;

    // 칠해진 슬롯(불가)
    for (int i = 0; i < blocked.length; i++) {
      if (!blocked[i]) continue;
      final top = i * slotHeight;
      canvas.drawRect(Rect.fromLTWH(0, top, w, slotHeight), fill);
    }

    // 그리드 라인
    for (int i = 0; i <= blocked.length; i++) {
      double y;
      if (i == 0) {
        y = 0; // 맨 위 라인
      } else if (i == blocked.length) {
        y = size.height; // 맨 아래 라인
      } else {
        // 내부 라인은 반픽셀 스냅으로 선명하게
        y = (i * slotHeight).floorToDouble() + 0.5;
      }

      final isHour = (i % hourStep == 0);
      grid.strokeWidth = isHour ? 3.0 : 1.0;
      canvas.drawLine(Offset(0, y), Offset(w, y), grid);
    }
  }

  @override
  bool shouldRepaint(covariant _VerticalPainter old) =>
      old.paintVersion != paintVersion ||
      old.slotHeight != slotHeight ||
      old.bgColor != bgColor ||
      old.theme != theme;
}
