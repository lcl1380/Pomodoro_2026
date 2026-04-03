import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_theme.dart';
import '../providers/timer_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/timer_ring.dart';
import '../widgets/preset_selector.dart';
import 'settings_screen.dart';

import '../providers/title_provider.dart';

// ──────────────────────────────────────────────
// TimerScreen : 앱의 메인 화면 전체 레이아웃
// ──────────────────────────────────────────────
class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;

    // isDark에 따라 색상을 골라주는 헬퍼 함수
    // 라이트/다크 색상 쌍이 필요할 때마다 c(dark, light) 로 사용
    Color c(Color dark, Color light) => isDark ? dark : light;

    return Scaffold(
      backgroundColor: c(AppColors.surfaceDark, AppColors.surfaceLight),

      body: Stack(
        children: [
          // ── 메인 콘텐츠 (스크롤 가능하게) ──
          SingleChildScrollView(
            child: Padding(
              // 좌우 32px, 위아래 24px 여백
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── ① 상단 앱바 영역 ──
                  _TopBar(isDark: isDark),

                  const SizedBox(height: 40),

                  // ── ② 원형 타이머 링 ──
                  const TimerRing(),

                  const SizedBox(height: 48),

                  // ── ③ 프리셋 버튼 (25min / 15min / Custom) ──
                  const PresetSelector(),

                  const SizedBox(height: 32),

                  // ── ④ Start/Pause + Reset 버튼 ──
                  _ControlButtons(isDark: isDark),

                  // 하단 여백 (라이트/다크 아이콘 공간 확보)
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),

          // ── ⑥ 우측 하단 라이트/다크 토글 아이콘 (항상 위에 떠있음) ──
          const Positioned(right: 24, bottom: 24, child: _ThemeToggle()),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// _TopBar : 커스텀 타이틀 + 설정 아이콘
// ──────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final bool isDark;
  const _TopBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    // TitleProvider를 watch → 타이틀이 바뀌면 자동으로 갱신
    final titleText = context.watch<TitleProvider>().title;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ── 타이틀 텍스트 ──
        // Flexible로 감싸야 긴 텍스트가 설정 아이콘을 밀어내지 않음
        Flexible(
          child: Text(
            titleText,
            // overflow: 너무 길면 말줄임표(...)로 처리
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              // ── 한글/영어/이모지 모두 대응하는 폰트 설정 ──
              // fontFamilyFallback : 주 폰트에 없는 문자를 대체 폰트로 처리
              // 순서대로 시도 → 앞 폰트에 해당 문자가 없으면 다음으로 넘어감
              //
              // 'Space Grotesk' : 영어/숫자 (기존 디자인 유지)
              // 'Noto Sans KR'  : 한글 (google_fonts 패키지로 로드)
              // 'Noto Color Emoji' : 이모지 (Windows/Mac 기본 내장)
              fontFamily: 'SpaceGrotesk',
              fontFamilyFallback: const [
                'Noto Sans KR', // 한글 대응
                'Noto Color Emoji', // 이모지 대응 (OS 기본 폰트)
                'Segoe UI Emoji', // Windows 이모지 폰트
                'Apple Color Emoji', // macOS/iOS 이모지 폰트
              ],
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.onSurfaceDark
                  : AppColors.onSurfaceLight,
            ),
          ),
        ),

        const SizedBox(width: 8),

        // 설정 아이콘
        IconButton(
          icon: Icon(
            Icons.tune_rounded,
            color: isDark
                ? AppColors.onSurfaceVariantDark
                : AppColors.onSurfaceVariantLight,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// _ControlButtons : Start / Pause / Resume + Reset
// ──────────────────────────────────────────────
class _ControlButtons extends StatelessWidget {
  final bool isDark;
  const _ControlButtons({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerProvider>();

    return Row(
      children: [
        // ── 메인 버튼 : flex 8 (전체의 80%) ──
        Flexible(
          flex: 8,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: ElevatedButton.icon(
              key: ValueKey(timer.buttonLabel),
              icon: Icon(timer.buttonIcon),
              label: Text(
                timer.buttonLabel,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: timer.uiColor,
                foregroundColor: timer.onUiColor,
                // minimumSize의 너비를 double.infinity로 설정해야
                // Flexible 안에서 가득 채워짐
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: timer.startPause,
            ),
          ),
        ),

        // ── 간격 ──
        const SizedBox(width: 12),

        // ── Reset 버튼 : flex 2 (전체의 20%) ──
        Flexible(
          flex: 2,
          child: AnimatedOpacity(
            opacity: timer.timerState == TimerState.idle ? 0.35 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
              // 높이는 고정, 너비는 Flexible이 결정
              width: double.infinity,
              height: 64,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isDark
                        ? AppColors.outlineVariant
                        : AppColors.outline.withOpacity(0.4),
                  ),
                  // padding을 0으로 줘야 좁은 공간에서 아이콘이 잘림
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: timer.timerState == TimerState.idle
                    ? null
                    : timer.reset,
                child: Icon(
                  Icons.refresh_rounded,
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariantLight,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// _ThemeToggle : 우측 하단 라이트/다크 전환 아이콘
// ──────────────────────────────────────────────
class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;

    return GestureDetector(
      onTap: themeProvider.toggle, // 탭하면 테마 전환
      child: AnimatedContainer(
        // duration : 전환 애니메이션 시간
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceContainerHighDark
              : AppColors.surfaceContainerHighLight,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        // 다크모드면 해 아이콘(light_mode), 라이트모드면 달 아이콘(dark_mode)
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          size: 20,
          color: isDark
              ? AppColors.onSurfaceVariantDark
              : AppColors.onSurfaceVariantLight,
        ),
      ),
    );
  }
}
