import 'package:flutter/material.dart';

// ──────────────────────────────────────────────
// TitleProvider : 앱 타이틀 텍스트 상태 관리
// ChangeNotifier를 상속하면 notifyListeners()로
// 이 값을 watch하는 모든 위젯을 자동으로 다시 그림
// ──────────────────────────────────────────────
class TitleProvider extends ChangeNotifier {
  // 기본 타이틀. 앱 처음 실행 시 이 값이 표시됨
  String _title = 'Pomodoro Cherish';

  String get title => _title;

  void setTitle(String newTitle) {
    // trim() : 앞뒤 공백 제거
    // 공백만 입력한 경우 기본값으로 복구
    final trimmed = newTitle.trim();
    _title = trimmed.isEmpty ? 'Pomodoro Cherish' : trimmed;
    notifyListeners();
  }
}
