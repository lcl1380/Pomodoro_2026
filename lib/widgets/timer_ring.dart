import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/timer_provider.dart';
import '../providers/theme_provider.dart';
import '../app_theme.dart';

class TimerRing extends StatelessWidget {
  const TimerRing({super.key});

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerProvider>();
    final isDark = context.watch<ThemeProvider>().isDark;
    const double ringSize = 300.0;

    return SizedBox(
      width: ringSize,
      height: ringSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── 애니메이션 링 ──
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: timer.progress),
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeInOut,
            builder: (context, animatedProgress, _) {
              return CustomPaint(
                size: const Size(ringSize, ringSize),
                painter: _RingPainter(
                  progress: animatedProgress,
                  ringColor: timer.ringColor,
                  isDark: isDark,
                ),
              );
            },
          ),

          // ── 중앙 텍스트 ──
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 분:초
              RichText(
                text: TextSpan(
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 62,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -2,
                    color: isDark
                        ? AppColors.onSurfaceDark
                        : AppColors.onSurfaceLight,
                  ),
                  children: [
                    TextSpan(text: timer.timeDisplay.split(':')[0]),
                    TextSpan(
                      text: ':',
                      style: TextStyle(
                        color: timer.ringColor,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    TextSpan(text: timer.timeDisplay.split(':')[1]),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // FOCUS SESSION 라벨
              Text(
                'FOCUS SESSION',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3,
                  color: AppColors.onSurfaceVariantDark,
                ),
              ),

              const SizedBox(height: 10),

              // ── 진행률 % 표시 ──
              // (progress * 100).round() → 0~100 정수
              // timerState가 idle이면 0% 고정
              _ProgressBadge(
                percent: (timer.progress * 100).round(),
                color: timer.ringColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// _ProgressBadge : "57%" 형태의 진행률 표시 뱃지
// ──────────────────────────────────────────────
class _ProgressBadge extends StatelessWidget {
  final int percent; // 0 ~ 100
  final Color color; // 링 색상과 동일하게

  const _ProgressBadge({required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        // 링 색상을 10% 투명도로 배경에 사용 → 은은하게 강조
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            // 숫자 부분: 링 색상으로 강조
            TextSpan(
              text: '$percent',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            // "%" 부분: 살짝 흐리게
            TextSpan(
              text: '%',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// _RingPainter : 눈금 없이 링만 그림
// ──────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final bool isDark;

  const _RingPainter({
    required this.progress,
    required this.ringColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // 눈금이 없으므로 기존보다 radius를 크게 잡아 링을 더 넓게 활용
    final radius = size.width / 2 - 16;
    const strokeWidth = 18.0;

    // 배경 트랙
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = isDark
            ? AppColors.surfaceContainerHighestDark
            : AppColors.surfaceContainerHighestLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // 진행 호
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..color = ringColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.ringColor != ringColor ||
      old.isDark != isDark;
}
