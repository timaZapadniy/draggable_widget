// ignore_for_file: no_leading_underscores_for_local_identifiers

library draggable_widget;

import 'package:flutter/material.dart';
import 'dart:math' as math;

// ignore: must_be_immutable
class DraggableWidget extends StatefulWidget {
  DraggableWidget({Key? key,
   required this.child,
   required this.topPadding,
   required this.leftPadding,
   required this.effectWidth,
   required this.effectHeight,}) : super(key: key);
  
  Widget child;
  double topPadding;
  double leftPadding;
  double effectWidth;
  double effectHeight;
  @override
  State<DraggableWidget> createState() => _DraggableWidgetState();
}

class _DraggableWidgetState extends State<DraggableWidget> {
  late double _width;
  late double _height;
  late double _top;
  late double _left;
  late double _effectWidth; /// in flutter pixels
  late double _effectHeight; /// in flutter pixels
  late Widget _child;

  @override
  void initState() {
    super.initState();
    _top = widget.topPadding;
    _left = widget.leftPadding;
    _effectWidth = widget.effectWidth;
    _effectHeight = widget.effectHeight;
    _child = widget.child;
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;

    return Positioned(
      left: _left,
      top: _top,
      width: _effectWidth,
      height: _effectHeight,
      child: _transformEffectWidget(_effectWidth, _effectHeight),
    );
  }

  Widget _transformEffectWidget(double width, double height) {
    return LayoutBuilder(builder: (context, constraints) {
      //границы для перетаскивания
      width = constraints.maxWidth;
      height = constraints.maxHeight;
      return _effectWidget(width, height);
    });
  }

  /// Считаем количество касаний
  int _touch = 0;

  /// Запоминаем исходное расстояние между пальцами при двойном нажатии
  late double _initialDistance;

  /// Запоминаем исходное расстояние между пальцами при двойном нажатии
  late double _sizeWidthBetweenStart;
  // ignore: unused_field
  late double _sizeHeightBetweenStart;
  // ignore: unused_field
  late double _leftBetweenStart;
  // ignore: unused_field
  late double _topBetweenStart;

  /// Запоминаем координаты пальцев при двойном нажатии
  late double _xFirstFingerTouch;
  late double _yFirstFingerTouch;
  late double _xSecondFingerTouch;
  late double _ySecondFingerTouch;
  late int _e1Pointer;

  /// Запоминаем координаты пальцев при одиночном нажатии
  late double _xSingleFingerTouchPosition;
  late double _ySingleFingerTouchPosition;

  late double _xSingleFingerInitEffectPosition;
  late double _ySingleFingerInitEffectPosition;

  /// Работа с поворотом экрана
  double _angle = 0;
  double _startAngle = 0;

  Widget _effectWidget(double width, double height) {
    return Listener(
      onPointerDown: (e) {
        setState(() {
          _touch++;
          switch (_touch) {
            case 1:
              _xFirstFingerTouch = e.position.dx.round().toDouble();
              _yFirstFingerTouch = e.position.dy.round().toDouble();
              _e1Pointer = e.pointer;
              _xSingleFingerTouchPosition = e.position.dx.round().toDouble();
              _ySingleFingerTouchPosition = e.position.dy.round().toDouble();
              _xSingleFingerInitEffectPosition = _left;
              _ySingleFingerInitEffectPosition = _top;
              break;
            case 2:
              _sizeWidthBetweenStart = _effectWidth;
              _sizeHeightBetweenStart = _effectHeight;
              _leftBetweenStart = _left;
              _topBetweenStart = _top;
              _xSecondFingerTouch = e.position.dx.round().toDouble();
              _ySecondFingerTouch = e.position.dy.round().toDouble();
              double angleTemp = math.atan2(
                  _yFirstFingerTouch - _ySecondFingerTouch,
                  _xFirstFingerTouch - _xSecondFingerTouch);
              _startAngle = _angle - angleTemp;
              double xDifference =
                  (_xFirstFingerTouch - _xSecondFingerTouch).abs();
              double yDifference =
                  (_yFirstFingerTouch - _ySecondFingerTouch).abs();
              _initialDistance = xDifference + yDifference;
              break;
          }
        });
      },
      onPointerMove: (e) {
        setState(() {
          switch (_touch) {
            case 1:
              _processDrag(e, _height, _width);
              break;
            case 2:
              _processScale(e, _width, _height);
              break;
          }
        });
      },
      onPointerUp: (e) {
        setState(() {
          _touch = 0;
        });
      },
      child: Transform.rotate(
        angle: _angle,
        child: _child,
      ),
    );
  }

  void _processScale(
      PointerMoveEvent e, double _screenWidth, double _screenHeight) {
    if (_e1Pointer == e.pointer) {
      _xFirstFingerTouch = e.position.dx.round().toDouble();
      _yFirstFingerTouch = e.position.dy.round().toDouble();
    } else {
      _xSecondFingerTouch = e.position.dx.round().toDouble();
      _ySecondFingerTouch = e.position.dy.round().toDouble();
    }
    double angleTemp = math.atan2(_yFirstFingerTouch - _ySecondFingerTouch,
        _xFirstFingerTouch - _xSecondFingerTouch);
    _angle = _startAngle + angleTemp;
    double xCurrentDistance = (_xFirstFingerTouch - _xSecondFingerTouch).abs();
    double yCurrentDistance = (_yFirstFingerTouch - _ySecondFingerTouch).abs();

    var fitOnScreen = _effectWidth + _left <= _screenWidth &&
        _effectHeight + _top <= _screenHeight;
    if (fitOnScreen) {
      double differenceSize =
          ((xCurrentDistance + yCurrentDistance) - _initialDistance);
      _setEffectSize(_sizeWidthBetweenStart + differenceSize);
    }
    if (_effectWidth + _left > _screenWidth) {
      _setEffectSize(_screenWidth - _left);
    }
    if (_effectHeight + _top > _screenHeight) {
      _setEffectSize(_screenHeight - _top);
    }
  }

  void _setEffectSize(double size) {
    _effectWidth = size;
    _effectHeight = size;
  }

  void _processDrag(
      PointerMoveEvent e, double _screenHeight, double _screenWidth) {
    double x = e.position.dx.round().toDouble();
    double y = e.position.dy.round().toDouble();
    var yDragDelta = y - _ySingleFingerTouchPosition;
    var xDragDelta = x - _xSingleFingerTouchPosition;
    double currentTop = _ySingleFingerInitEffectPosition + (yDragDelta);
    if ((currentTop + _effectHeight) > (_screenHeight)) {
      _top = (_screenHeight - _effectHeight);
    } else {
      _top = math.max(0, currentTop);
    }
    double currentLeft = _xSingleFingerInitEffectPosition + (xDragDelta);
    if ((currentLeft + _effectWidth) > (_screenWidth)) {
      _left = (_screenWidth - _effectWidth);
    } else {
      _left = math.max(0, currentLeft);
    }
  }
}
