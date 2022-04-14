import 'package:flutter/widgets.dart';

enum SliderState {
  starting,
  resting,
  sliding,
  stopping,
}

class WaveSliderController extends ChangeNotifier {
  final AnimationController controller;
  SliderState _state = SliderState.resting;

  WaveSliderController({required TickerProvider vsync})
      : controller = AnimationController(vsync: vsync) {
    controller
      ..addListener(_onProgressUpdate)
      ..addStatusListener(_onStatusUpdate);
  }

  double get progress => controller.value;
  SliderState get state => _state;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onProgressUpdate() {
    notifyListeners();
  }

  void _onStatusUpdate(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _onTransitionCompleted();
    }
  }

  void _onTransitionCompleted() {
    if (_state == SliderState.stopping) {
      setStateToResting();
    }
  }

  void _startAnimation() {
    controller.duration = const Duration(milliseconds: 500);
    controller.forward(from: 0.0);
    notifyListeners();
  }

  void setStateToResting() {
    _state = SliderState.resting;
  }

  void setStateToStart() {
    _startAnimation();
    _state = SliderState.starting;
  }

  void setStateToSliding() {
    _state = SliderState.sliding;
  }

  void setStateToStopping() {
    _startAnimation();
    _state = SliderState.stopping;
  }
}
