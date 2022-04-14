import 'package:flutter/material.dart';
import 'package:wave_slider/core/wave_controller.dart';
import 'package:wave_slider/widgets/wave_painter.dart';

class WaveSlider extends StatefulWidget {
  const WaveSlider({
    Key? key,
    this.width = 350.0,
    this.height = 50.0,
    this.color = Colors.black,
    required this.onChanged,
    required this.onChangeStart,
  })  : assert(height >= 15 && height <= 600),
        super(key: key);

  final double width;
  final double height;
  final Color color;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeStart;

  @override
  State<WaveSlider> createState() => _WaveSliderState();
}

class _WaveSliderState extends State<WaveSlider>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0;
  double _dragPercentage = 0;

  late final WaveSliderController _sliderController;

  @override
  void initState() {
    super.initState();
    _sliderController = WaveSliderController(vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _sliderController.dispose();
    super.dispose();
  }

  void _handleChangeUpdate(double dragPercentage) {
    widget.onChanged(dragPercentage);
  }

  void _handleChangeStart(double dragPercentage) {
    widget.onChangeStart(dragPercentage);
  }

  void _onDragUpdate(DragUpdateDetails update) {
    Offset offset = update.localPosition;
    _sliderController.setStateToSliding();
    _updateDragPosition(offset);
    _handleChangeUpdate(_dragPercentage);
  }

  void _onDragStart(DragStartDetails startDetails) {
    Offset offset = startDetails.localPosition;
    _sliderController.setStateToStart();
    _updateDragPosition(offset);
    _handleChangeStart(_dragPercentage);
  }

  void _onDragEnd(DragEndDetails endDetails) {
    _sliderController.setStateToStopping();
    setState(() {});
  }

  void _updateDragPosition(Offset offset) {
    double value = offset.dx;
    double newDragPosition = 0;
    if (value <= 0) {
      newDragPosition = 0;
    } else if (value >= widget.width) {
      newDragPosition = widget.width;
    } else {
      newDragPosition = value;
    }
    setState(() {
      _dragPosition = newDragPosition;
      _dragPercentage = _dragPosition / widget.width;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: SizedBox(
        height: widget.height,
        width: widget.width,
        child: CustomPaint(
          painter: WavePainter(
            sliderPosition: _dragPosition,
            dragPercentage: _dragPercentage,
            color: widget.color,
            animationProgress: _sliderController.progress,
            sliderState: _sliderController.state,
          ),
        ),
      ),
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragEnd: _onDragEnd,
    );
  }
}
