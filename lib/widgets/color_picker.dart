import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_theme.dart';
import '../providers/timer_provider.dart';

// ──────────────────────────────────────────────
// ColorPickerPanel : 2D 팔레트 + 슬라이더 + HEX 입력
// colorTarget : 'ring'(링 색) 또는 'ui'(UI 색) 구분
// ──────────────────────────────────────────────
class ColorPickerPanel extends StatefulWidget {
  // 외부에서 어떤 색상을 편집할지 지정
  final String colorTarget; // 'ring' | 'ui'

  const ColorPickerPanel({super.key, required this.colorTarget});

  @override
  State<ColorPickerPanel> createState() => _ColorPickerPanelState();
}

class _ColorPickerPanelState extends State<ColorPickerPanel> {
  double _hue = 195;
  double _saturation = 0.7;
  double _value = 1.0;

  bool _showLoupe = false;
  Offset _loupePos = Offset.zero;

  // HEX 입력 필드 컨트롤러
  final _hexController = TextEditingController();
  // HEX 입력값이 유효하지 않을 때 에러 메시지 표시용
  String? _hexError;

  Color get _currentColor =>
      HSVColor.fromAHSV(1, _hue, _saturation, _value).toColor();

  @override
  void initState() {
    super.initState();
    // 초기 HEX 값을 현재 색으로 설정
    _hexController.text = _colorToHex(_currentColor);
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  // Color → "#RRGGBB" 문자열 변환
  String _colorToHex(Color c) =>
      '#${c.value.toRadixString(16).substring(2).toUpperCase()}';

  // 색 변경 시 provider에 알리고 HEX 필드도 갱신
  void _notifyColor() {
    final timer = context.read<TimerProvider>();
    if (widget.colorTarget == 'ring') {
      timer.setRingColor(_currentColor);
    } else {
      timer.setUiColor(_currentColor);
    }
    // 팔레트 조작 중에는 HEX 필드를 덮어씀
    _hexController.text = _colorToHex(_currentColor);
    // 커서를 항상 끝으로 이동 (입력 중 깜빡임 방지)
    _hexController.selection = TextSelection.fromPosition(
      TextPosition(offset: _hexController.text.length),
    );
  }

  // ── HEX 문자열 → HSV 변환 및 검증 ──
  void _onHexSubmitted(String raw) {
    // '#' 제거 후 대문자로 정규화
    final clean = raw.replaceAll('#', '').toUpperCase().trim();

    // 유효성 검사 1: 길이가 정확히 6자리인지
    if (clean.length != 6) {
      setState(() => _hexError = '6자리 HEX 코드를 입력하세요 (예: 4CD6FF)');
      return;
    }

    // 유효성 검사 2: 0-9, A-F 문자만 포함하는지
    final validHex = RegExp(r'^[0-9A-F]{6}$');
    if (!validHex.hasMatch(clean)) {
      setState(() => _hexError = '올바른 HEX 코드가 아닙니다');
      return;
    }

    // 검증 통과 → Color로 변환
    final color = Color(int.parse('FF$clean', radix: 16));

    // Color → HSV 역변환 (팔레트 커서 위치도 업데이트)
    final hsv = HSVColor.fromColor(color);
    setState(() {
      _hue = hsv.hue;
      _saturation = hsv.saturation;
      _value = hsv.value;
      _hexError = null; // 에러 초기화
    });
    _notifyColor();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('SATURATION & VALUE'),
        const SizedBox(height: 10),
        _buildPalette(),
        const SizedBox(height: 20),

        _SectionLabel('HUE SPECTRUM'),
        const SizedBox(height: 10),
        _HueSlider(
          hue: _hue,
          onChanged: (h) {
            setState(() => _hue = h);
            _notifyColor();
          },
        ),
        const SizedBox(height: 20),

        _SectionLabel('BRIGHTNESS'),
        const SizedBox(height: 10),
        _ValueSlider(
          hue: _hue,
          value: _value,
          onChanged: (v) {
            setState(() => _value = v);
            _notifyColor();
          },
        ),
        const SizedBox(height: 20),

        // ── HEX 입력 + 미리보기 ──
        _buildHexInput(),
      ],
    );
  }

  // ── HEX 직접 입력 영역 ──
  Widget _buildHexInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // 색 미리보기 사각형
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _currentColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.outlineVariant.withOpacity(0.4),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // HEX 텍스트 입력 필드
            Expanded(
              child: TextField(
                controller: _hexController,
                // 대문자 자동 변환 (소문자로 쳐도 자동 변환됨)
                textCapitalization: TextCapitalization.characters,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariantDark,
                  letterSpacing: 1,
                ),
                decoration: InputDecoration(
                  // '#' 기호를 앞에 고정으로 표시
                  prefixText: _hexController.text.startsWith('#') ? '' : '#',
                  prefixStyle: GoogleFonts.spaceGrotesk(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  hintText: '4CD6FF',
                  hintStyle: TextStyle(
                    color: AppColors.onSurfaceVariantDark.withOpacity(0.4),
                  ),
                  // 에러가 있으면 빨간 밑줄, 없으면 primary 색 밑줄
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: _hexError != null
                          ? Colors.redAccent
                          : AppColors.outlineVariant,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: _hexError != null
                          ? Colors.redAccent
                          : AppColors.primary,
                      width: 2,
                    ),
                  ),
                  // 에러 메시지 표시 (null이면 숨김)
                  errorText: _hexError,
                  errorStyle: GoogleFonts.manrope(
                    fontSize: 10,
                    color: Colors.redAccent,
                  ),
                ),
                // 엔터/확인 키를 누르면 검증 실행
                onSubmitted: _onHexSubmitted,
                // 타이핑 중에는 에러 메시지를 지워서 UX 개선
                onChanged: (_) {
                  if (_hexError != null) setState(() => _hexError = null);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPalette() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        const h = 200.0;

        return Stack(
          children: [
            GestureDetector(
              onTapDown: (d) => _onInteract(d.localPosition, w, h, end: true),
              onPanStart: (d) => _onInteract(d.localPosition, w, h, end: false),
              onPanUpdate: (d) =>
                  _onInteract(d.localPosition, w, h, end: false),
              onPanEnd: (_) => setState(() => _showLoupe = false),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CustomPaint(
                  size: Size(w, h),
                  painter: _PalettePainter(hue: _hue),
                ),
              ),
            ),
            // 선택 커서
            Positioned(
              left: _saturation * w - 10,
              top: (1 - _value) * h - 10,
              child: IgnorePointer(
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentColor,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: const [
                      BoxShadow(color: Colors.black38, blurRadius: 4),
                    ],
                  ),
                ),
              ),
            ),
            // 돋보기
            if (_showLoupe)
              Positioned(
                left: (_loupePos.dx - 30).clamp(0, w - 60),
                top: (_loupePos.dy - 70).clamp(0, double.infinity),
                child: IgnorePointer(child: _Loupe(color: _currentColor)),
              ),
          ],
        );
      },
    );
  }

  void _onInteract(Offset pos, double w, double h, {required bool end}) {
    setState(() {
      _saturation = (pos.dx / w).clamp(0.0, 1.0);
      _value = (1 - pos.dy / h).clamp(0.0, 1.0);
      _showLoupe = !end;
      _loupePos = pos;
    });
    _notifyColor();
  }
}

// ── 이하 내부 위젯들 (기존과 동일) ──

class _PalettePainter extends CustomPainter {
  final double hue;
  const _PalettePainter({required this.hue});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final hueColor = HSVColor.fromAHSV(1, hue, 1, 1).toColor();
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.white, hueColor],
        ).createShader(rect),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_PalettePainter old) => old.hue != hue;
}

class _HueSlider extends StatelessWidget {
  final double hue;
  final ValueChanged<double> onChanged;
  const _HueSlider({required this.hue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (d) => onChanged(
            (d.localPosition.dx / constraints.maxWidth * 360).clamp(0, 360),
          ),
          onPanUpdate: (d) => onChanged(
            (d.localPosition.dx / constraints.maxWidth * 360).clamp(0, 360),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: CustomPaint(
              size: Size(constraints.maxWidth, 28),
              painter: _HuePainter(hue: hue),
            ),
          ),
        );
      },
    );
  }
}

class _HuePainter extends CustomPainter {
  final double hue;
  const _HuePainter({required this.hue});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFFF0000),
            Color(0xFFFFFF00),
            Color(0xFF00FF00),
            Color(0xFF00FFFF),
            Color(0xFF0000FF),
            Color(0xFFFF00FF),
            Color(0xFFFF0000),
          ],
        ).createShader(rect),
    );
    final cx = hue / 360 * size.width;
    canvas.drawCircle(
      Offset(cx, size.height / 2),
      12,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(cx, size.height / 2),
      12,
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_HuePainter old) => old.hue != hue;
}

class _ValueSlider extends StatelessWidget {
  final double hue;
  final double value;
  final ValueChanged<double> onChanged;
  const _ValueSlider({
    required this.hue,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (d) => onChanged(
            (d.localPosition.dx / constraints.maxWidth).clamp(0, 1),
          ),
          onPanUpdate: (d) => onChanged(
            (d.localPosition.dx / constraints.maxWidth).clamp(0, 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: CustomPaint(
              size: Size(constraints.maxWidth, 28),
              painter: _ValuePainter(hue: hue, value: value),
            ),
          ),
        );
      },
    );
  }
}

class _ValuePainter extends CustomPainter {
  final double hue, value;
  const _ValuePainter({required this.hue, required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final hueColor = HSVColor.fromAHSV(1, hue, 1, 1).toColor();
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.black, hueColor],
        ).createShader(rect),
    );
    final cx = value * size.width;
    canvas.drawCircle(
      Offset(cx, size.height / 2),
      12,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(cx, size.height / 2),
      12,
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_ValuePainter old) => old.hue != hue || old.value != value;
}

class _Loupe extends StatelessWidget {
  final Color color;
  const _Loupe({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 8)],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.manrope(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: AppColors.onSurfaceVariantDark,
      ),
    );
  }
}
