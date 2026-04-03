import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_theme.dart';
import '../providers/theme_provider.dart';
import '../providers/timer_provider.dart';
import '../providers/title_provider.dart'; // ← 추가
import '../widgets/color_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // ── 타이틀 편집용 컨트롤러 ──
  // initState에서 현재 타이틀로 초기화
  late final TextEditingController _titleController;

  // 타이틀 입력 중 에러 메시지
  String? _titleError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));

    // 현재 저장된 타이틀로 텍스트 필드 초기화
    // context.read : initState에서는 watch 대신 read 사용
    final currentTitle = context.read<TitleProvider>().title;
    _titleController = TextEditingController(text: currentTitle);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  // ── 타이틀 저장 처리 ──
  void _saveTitle() {
    final input = _titleController.text;

    // 유효성 검사: 공백 제거 후 길이 확인
    if (input.trim().isEmpty) {
      setState(() => _titleError = '타이틀을 입력해주세요');
      return;
    }

    // 최대 길이 제한 (너무 길면 UI가 깨짐)
    if (input.trim().length > 30) {
      setState(() => _titleError = '30자 이내로 입력해주세요');
      return;
    }

    // 검증 통과 → 저장
    context.read<TitleProvider>().setTitle(input);
    setState(() => _titleError = null);

    // 키보드 닫기
    FocusScope.of(context).unfocus();

    // 저장 완료 스낵바
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '타이틀이 저장되었어요',
          style: GoogleFonts.manrope(color: AppColors.onSurfaceDark),
        ),
        backgroundColor: AppColors.surfaceContainerHighDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final timer = context.watch<TimerProvider>();
    final previewColor = _tabController.index == 0
        ? timer.ringColor
        : timer.uiColor;

    Color c(Color dark, Color light) => isDark ? dark : light;

    return Scaffold(
      backgroundColor: c(AppColors.surfaceDark, AppColors.surfaceLight),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 상단 바 ──
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: c(
                          AppColors.surfaceContainerHighDark,
                          AppColors.surfaceContainerHighLight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: c(
                          AppColors.onSurfaceDark,
                          AppColors.onSurfaceLight,
                        ),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Settings',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: c(
                        AppColors.onSurfaceDark,
                        AppColors.onSurfaceLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── 스크롤 가능한 본문 ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ════════════════════════════
                    // 섹션 1 : 앱 타이틀 커스텀
                    // ════════════════════════════
                    Text(
                      'App Title',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: c(
                          AppColors.onSurfaceDark,
                          AppColors.onSurfaceLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '앱 상단에 표시될 이름을 바꿔보세요 (한글·영어·이모지 모두 가능)',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariantDark,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 타이틀 입력 컨테이너
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: c(
                          AppColors.surfaceContainerHighDark,
                          AppColors.surfaceContainerHighLight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          // ── 텍스트 입력 필드 ──
                          Expanded(
                            child: TextField(
                              controller: _titleController,
                              // 최대 30자 제한
                              maxLength: 30,
                              style: TextStyle(
                                // 타이틀과 동일한 폰트 설정으로 미리보기처럼 보임
                                fontFamily: 'SpaceGrotesk',
                                fontFamilyFallback: const [
                                  'Noto Sans KR',
                                  'Noto Color Emoji',
                                  'Segoe UI Emoji',
                                  'Apple Color Emoji',
                                ],
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: c(
                                  AppColors.onSurfaceDark,
                                  AppColors.onSurfaceLight,
                                ),
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Pomodoro Cherish',
                                hintStyle: TextStyle(
                                  color: AppColors.onSurfaceVariantDark
                                      .withOpacity(0.5),
                                ),
                                // 글자 수 카운터 스타일
                                counterStyle: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.onSurfaceVariantDark,
                                ),
                                // 에러 메시지 표시
                                errorText: _titleError,
                                errorStyle: GoogleFonts.manrope(
                                  fontSize: 10,
                                  color: Colors.redAccent,
                                ),
                              ),
                              // 엔터 키 → 저장
                              onSubmitted: (_) => _saveTitle(),
                              // 타이핑 중 에러 초기화
                              onChanged: (_) {
                                if (_titleError != null) {
                                  setState(() => _titleError = null);
                                }
                              },
                            ),
                          ),

                          // ── 저장 버튼 ──
                          GestureDetector(
                            onTap: _saveTitle,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: timer.uiColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '저장',
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: timer.onUiColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 기본값 복구 버튼
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          _titleController.text = 'Pomodoro Cherish';
                          context.read<TitleProvider>().setTitle(
                            'Pomodoro Cherish',
                          );
                          setState(() => _titleError = null);
                        },
                        child: Text(
                          '기본값으로 복구',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariantDark,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 구분선
                    Divider(
                      color: AppColors.outlineVariant.withOpacity(0.3),
                      thickness: 1,
                    ),

                    const SizedBox(height: 24),

                    // ════════════════════════════
                    // 섹션 2 : Visual Identity (기존 색상 설정)
                    // ════════════════════════════
                    Text(
                      'Visual Identity',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: c(
                          AppColors.onSurfaceDark,
                          AppColors.onSurfaceLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '타이머 링과 UI 강조색을 커스터마이즈하세요',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariantDark,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── 탭 바 (링 색상 | UI 색상) ──
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: c(
                          AppColors.surfaceContainerDark,
                          AppColors.surfaceContainerLight,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: c(
                            AppColors.surfaceContainerHighDark,
                            AppColors.surfaceContainerHighLight,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelStyle: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        unselectedLabelStyle: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        labelColor: previewColor,
                        unselectedLabelColor: AppColors.onSurfaceVariantDark,
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _MiniSwatch(color: timer.ringColor),
                                const SizedBox(width: 6),
                                const Text('링 색상'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _MiniSwatch(color: timer.uiColor),
                                const SizedBox(width: 6),
                                const Text('UI 색상'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── 탭 콘텐츠 ──
                    // TabBarView는 Expanded 안에서만 높이를 알 수 있음
                    // 스크롤 뷰 안에서는 고정 높이 Container로 감싸야 함
                    SizedBox(
                      // 팔레트(200) + 슬라이더×2(28×2) + 여백 + HEX 입력 ≈ 420
                      height: 420,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _PickerTab(colorTarget: 'ring', isDark: isDark),
                          _PickerTab(colorTarget: 'ui', isDark: isDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 탭 안의 팔레트 컨테이너 (기존과 동일) ──
class _PickerTab extends StatelessWidget {
  final String colorTarget;
  final bool isDark;
  const _PickerTab({required this.colorTarget, required this.isDark});

  @override
  Widget build(BuildContext context) {
    Color c(Color dark, Color light) => isDark ? dark : light;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: c(
            AppColors.surfaceContainerHighDark,
            AppColors.surfaceContainerHighLight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: ColorPickerPanel(colorTarget: colorTarget),
      ),
    );
  }
}

// ── 탭 라벨 옆 미니 색상 스와치 (기존과 동일) ──
class _MiniSwatch extends StatelessWidget {
  final Color color;
  const _MiniSwatch({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 1),
      ),
    );
  }
}
