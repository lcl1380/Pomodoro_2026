import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_theme.dart';
import '../providers/timer_provider.dart';
import '../providers/theme_provider.dart';

// ──────────────────────────────────────────────
// PresetSelector : 25min / 50min / Custom 선택 버튼
// ──────────────────────────────────────────────
class PresetSelector extends StatefulWidget {
  const PresetSelector({super.key});

  @override
  State<PresetSelector> createState() => _PresetSelectorState();
}

class _PresetSelectorState extends State<PresetSelector> {
  // 현재 선택된 프리셋 인덱스 (0=25min, 1=50min, 2=Custom)
  int _selectedIndex = 0;

  // Custom 입력 시 사용하는 TextEditingController
  // 텍스트 필드의 값을 읽거나 초기화할 때 사용
  final _customController = TextEditingController();

  // 프리셋 목록: label(표시 텍스트)과 minutes(분) 쌍
  final List<_Preset> _presets = const [
    _Preset(label: '25 min', minutes: 25),
    _Preset(label: '50 min', minutes: 50),
    _Preset(label: 'Custom', minutes: -1), // -1 = 직접 입력
  ];

  @override
  void dispose() {
    // 위젯이 사라질 때 컨트롤러 메모리 해제 (필수)
    _customController.dispose();
    super.dispose();
  }

  // Custom 선택 시 다이얼로그(팝업) 표시
  void _showCustomDialog(BuildContext context, TimerProvider timer) {
    _customController.clear(); // 이전에 입력한 값 초기화

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHighDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '타이머 시간 설정',
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.onSurfaceDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: _customController,
          // 숫자 키패드만 열리도록
          keyboardType: TextInputType.number,
          autofocus: true, // 다이얼로그 열리자마자 키보드 올라옴
          style: TextStyle(color: AppColors.onSurfaceDark),
          decoration: InputDecoration(
            hintText: '분 단위로 입력 (1 ~ 240)',
            hintStyle: TextStyle(color: AppColors.onSurfaceVariantDark),
            suffixText: 'min',
            suffixStyle: TextStyle(color: AppColors.primary),
            // 입력 필드 하단 선만 표시 (Stitch 디자인 가이드 스타일)
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // 취소: 다이얼로그 닫기
            child: Text(
              '취소',
              style: TextStyle(color: AppColors.onSurfaceVariantDark),
            ),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(_customController.text);
              // 1~180 범위만 허용
              if (value != null && value >= 1 && value <= 240) {
                timer.setDuration(value);
                Navigator.pop(ctx);
              }
            },
            child: Text(
              '확인',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerProvider>();
    final isDark = context.watch<ThemeProvider>().isDark;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceContainerDark
            : AppColors.surfaceContainerLight,
        borderRadius: BorderRadius.circular(999), // 완전한 알약 모양
      ),
      child: Row(
        children: List.generate(_presets.length, (i) {
          final isSelected = _selectedIndex == i;
          final preset = _presets[i];

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedIndex = i);

                if (preset.minutes == -1) {
                  // Custom 선택 → 다이얼로그 표시
                  _showCustomDialog(context, timer);
                } else {
                  // 프리셋 선택 → 바로 타이머 시간 설정
                  timer.setDuration(preset.minutes);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  // 선택된 항목만 배경색 강조
                  color: isSelected
                      ? (isDark
                            ? AppColors.surfaceContainerHighDark
                            : AppColors.surfaceContainerHighLight)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Custom 항목에만 연필 아이콘 표시
                    if (preset.minutes == -1) ...[
                      Icon(
                        Icons.edit_rounded,
                        size: 13,
                        color: isSelected
                            ? timer.uiColor
                            : AppColors.onSurfaceVariantDark,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      preset.label,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        // 선택된 항목은 primary 색, 나머지는 흐린 색
                        color: isSelected
                            ? timer.uiColor
                            : AppColors.onSurfaceVariantDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// 프리셋 데이터 구조체 (label + minutes 묶음)
// const 생성자를 쓰면 컴파일 타임에 상수로 처리되어 성능에 유리
class _Preset {
  final String label;
  final int minutes;
  const _Preset({required this.label, required this.minutes});
}
