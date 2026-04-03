import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../app_theme.dart';

enum TimerState { idle, running, paused }

class TimerProvider extends ChangeNotifier {
  // ── 타이머 설정 ──
  int _totalSeconds = 25 * 60;
  int _remainingSeconds = 25 * 60;
  TimerState _timerState = TimerState.idle;
  Timer? _timer;

  // ── 오디오 플레이어 ──
  // AudioPlayer 인스턴스를 하나 유지해두고 재사용
  // (매번 새로 만들면 메모리 낭비)
  final AudioPlayer _audioPlayer = AudioPlayer();

  // ── 색상 ──
  Color _ringColor = AppColors.primary;
  Color _uiColor = AppColors.primary;

  // ── 세션 카운트 ──
  int completedSessions = 0;
  int goalSessions = 8;

  // ── Getters ──
  int get totalSeconds => _totalSeconds;
  int get remainingSeconds => _remainingSeconds;
  TimerState get timerState => _timerState;
  Color get ringColor => _ringColor;
  Color get uiColor => _uiColor;
  bool get isRunning => _timerState == TimerState.running;

  double get progress =>
      _totalSeconds == 0 ? 0 : 1 - (_remainingSeconds / _totalSeconds);

  String get timeDisplay {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get buttonLabel {
    switch (_timerState) {
      case TimerState.idle:
        return 'Start';
      case TimerState.running:
        return 'Pause';
      case TimerState.paused:
        return 'Resume';
    }
  }

  IconData get buttonIcon {
    switch (_timerState) {
      case TimerState.idle:
        return Icons.play_arrow_rounded;
      case TimerState.running:
        return Icons.pause_rounded;
      case TimerState.paused:
        return Icons.play_arrow_rounded;
    }
  }

  // ── 타이머 시간 설정 ──
  void setDuration(int minutes) {
    _stop();
    _timerState = TimerState.idle;
    _totalSeconds = minutes * 60;
    _remainingSeconds = minutes * 60;
    notifyListeners();
  }

  // ── 메인 버튼 동작 ──
  void startPause() {
    switch (_timerState) {
      case TimerState.idle:
      case TimerState.paused:
        _start();
        break;
      case TimerState.running:
        _pause();
        break;
    }
  }

  void _start() {
    _timerState = TimerState.running;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        // 타이머 완료
        _timer?.cancel();
        _timerState = TimerState.idle;
        completedSessions++;
        _playComplete(); // ← 완료 효과음 재생
        notifyListeners();
      }
    });
    notifyListeners();
  }

  void _pause() {
    _timer?.cancel();
    _timerState = TimerState.paused;
    notifyListeners();
  }

  void _stop() {
    _timer?.cancel();
    _timerState = TimerState.idle;
  }

  void reset() {
    _stop();
    _remainingSeconds = _totalSeconds;
    notifyListeners();
  }

  // ── 효과음 재생 ──
  Future<void> _playComplete() async {
    try {
      // 볼륨 설정: 0.0(무음) ~ 1.0(최대)
      // 0.6 정도면 너무 시끄럽지 않고 적당히 들림
      await _audioPlayer.setVolume(0.6);

      // AssetSource: pubspec.yaml에 등록한 assets 폴더 기준 경로
      // 'sounds/complete.mp3' = assets/sounds/complete.mp3
      await _audioPlayer.play(AssetSource('sounds/complete.mp3'));
    } catch (e) {
      // 파일이 없거나 재생 실패해도 앱이 죽지 않도록 예외 처리
      debugPrint('효과음 재생 실패: $e');
    }
  }

  // ── 색상 변경 ──
  void setRingColor(Color color) {
    _ringColor = color;
    notifyListeners();
  }

  void setUiColor(Color color) {
    _uiColor = color;
    notifyListeners();
  }

  Color get onUiColor => AppColors.contrastOn(_uiColor);
  Color get onRingColor => AppColors.contrastOn(_ringColor);

  @override
  void dispose() {
    _timer?.cancel();
    // AudioPlayer도 반드시 dispose해서 리소스 해제
    _audioPlayer.dispose();
    super.dispose();
  }
}
