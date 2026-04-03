import 'package:flutter/material.dart';

class AppColors {
  // ── Primary 기본값 ──
  static const primary      = Color(0xFF0ABBA1); // 메인 청록색
  static const primaryDim   = Color(0xFF009C85); // 더 진한 청록 (hover/pressed)
  static const primaryFixed = Color(0xFFBBFFF5); // 연한 민트 (배경 강조용)
  static const onPrimary    = Color(0xFF002D27); // primary 위 텍스트 (매우 어두운 청록)

  // ── Dark mode surfaces ──
  static const surfaceDark = Color(0xFF0E0E0E);
  static const surfaceContainerDark = Color(0xFF191A1A);
  static const surfaceContainerHighDark = Color(0xFF1F2020);
  static const surfaceContainerHighestDark = Color(0xFF252626);
  static const surfaceContainerLowDark = Color(0xFF131313);
  static const surfaceBrightDark = Color(0xFF2B2C2C);

  // ── Light mode surfaces ──
  static const surfaceLight = Color(0xFFF5F5F5);
  static const surfaceContainerLight = Color(0xFFEAEAEA);
  static const surfaceContainerHighLight = Color(0xFFDEDEDE);
  static const surfaceContainerHighestLight = Color(0xFFD2D2D2);
  static const surfaceContainerLowLight = Color(0xFFF0F0F0);
  static const surfaceBrightLight = Color(0xFFFFFFFF);

  // ── Text ──
  static const onSurfaceDark = Color(0xFFE7E5E5);
  static const onSurfaceVariantDark = Color(0xFFACABAA);
  static const onSurfaceLight = Color(0xFF1A1A1A);
  static const onSurfaceVariantLight = Color(0xFF5A5A5A);

  // ── Outline ──
  static const outline = Color(0xFF767575);
  static const outlineVariant = Color(0xFF484848);

  // ────────────────────────────────────────────
  // 자동 대비색 계산
  // ────────────────────────────────────────────
  // WCAG 기준 상대 휘도(luminance) 계산
  // 사람 눈은 RGB를 선형으로 인식하지 않아서 감마 보정이 필요함
  static double _luminance(Color c) {
    double linearize(int v) {
      final s = v / 255.0;
      // sRGB → 선형 RGB 변환 (IEC 61966-2-1 표준)
      return s <= 0.03928
          ? s / 12.92
          : ((s + 0.055) / 1.055) * ((s + 0.055) / 1.055);
    }

    // WCAG 2.1 가중치: 인간 눈의 색 감도 (녹색 > 빨강 > 파랑)
    return 0.2126 * linearize(c.red) +
        0.7152 * linearize(c.green) +
        0.0722 * linearize(c.blue);
  }

  /// 주어진 배경색 위에 올릴 텍스트/아이콘의 최적 색상 반환
  /// 밝은 배경 → 어두운 색, 어두운 배경 → 밝은 색
  ///
  /// [bg]       : 배경색 (버튼 색 등)
  /// [darkText] : 어두운 텍스트로 쓸 색 (기본: 거의 검정)
  /// [lightText]: 밝은 텍스트로 쓸 색 (기본: 거의 흰색)
  static Color contrastOn(
    Color bg, {
    Color darkText = const Color(0xFF1A1A1A),
    Color lightText = const Color(0xFFF0F0F0),
  }) {
    final lum = _luminance(bg);
    // 휘도 0.179 기준 (WCAG 4.5:1 대비비 기준점)
    // 밝은 색(lum > 0.179)이면 어두운 텍스트, 아니면 밝은 텍스트
    return lum > 0.179 ? darkText : lightText;
  }

  /// 선택된 UI 색상 위에 올라갈 강조 텍스트 색 반환
  /// contrastOn()과 동일하지만 더 강한 대비를 원할 때 사용
  static Color contrastOnStrong(Color bg) => contrastOn(
    bg,
    darkText: const Color(0xFF0A0A0A), // 더 진한 검정
    lightText: const Color(0xFFFFFFFF), // 순백
  );
}

class AppTheme {
  static ThemeData dark() => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.surfaceDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.onSurfaceDark,
    ),
  );

  static ThemeData light() => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.surfaceLight,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.onSurfaceLight,
    ),
  );
}
