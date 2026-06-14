import 'dart:math';

import 'package:flutter/material.dart';

class CompassRingWidget extends StatelessWidget {
  final double heading;
  final double? targetHeading;

  const CompassRingWidget({
    super.key,
    required this.heading,
    this.targetHeading,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final accentColor = scheme.primary;
    final glowColor = isDark ? accentColor.withAlpha(100) : accentColor.withAlpha(80);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: glowColor,
                blurRadius: 24,
                spreadRadius: 8,
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: accentColor, width: 3),
          ),
          margin: const EdgeInsets.all(8),
        ),
        _buildDirectionLabel(context, 'N', 0, isTop: true),
        _buildDirectionLabel(context, 'S', 0, isBottom: true),
        _buildDirectionLabel(context, 'W', 270, isLeft: true),
        _buildDirectionLabel(context, 'E', 90, isRight: true),
        _buildDirectionLabel(context, 'NE', 45, topRight: true),
        _buildDirectionLabel(context, 'NW', 315, topLeft: true),
        _buildDirectionLabel(context, 'SE', 135, bottomRight: true),
        _buildDirectionLabel(context, 'SW', 225, bottomLeft: true),
        Transform.rotate(
          angle: heading * pi / 180,
          child: Icon(
            Icons.navigation,
            size: 64,
            color: accentColor,
          ),
        ),
        if (targetHeading != null)
          Transform.rotate(
            angle: targetHeading! * pi / 180,
            child: Icon(
              Icons.push_pin,
              size: 32,
              color: Colors.red,
            ),
          ),
      ],
    );
  }

  Widget _buildDirectionLabel(
    BuildContext context,
    String text,
    double angle, {
    bool isTop = false,
    bool isBottom = false,
    bool isLeft = false,
    bool isRight = false,
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    final accentColor = Theme.of(context).colorScheme.primary;
    final angleRad = angle * pi / 180;

    return Positioned.fill(
      child: Transform.rotate(
        angle: angleRad,
        child: Align(
          alignment: _getAlignment(isTop, isBottom, isLeft, isRight, topLeft, topRight, bottomLeft, bottomRight),
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
    );
  }

  Alignment _getAlignment(
    bool isTop, bool isBottom, bool isLeft, bool isRight,
    bool topLeft, bool topRight, bool bottomLeft, bool bottomRight,
  ) {
    if (topLeft) return const Alignment(-0.8, -0.8);
    if (topRight) return const Alignment(0.8, -0.8);
    if (bottomLeft) return const Alignment(-0.8, 0.8);
    if (bottomRight) return const Alignment(0.8, 0.8);
    if (isTop) return const Alignment(0, -0.9);
    if (isBottom) return const Alignment(0, 0.9);
    if (isLeft) return const Alignment(-0.9, 0);
    if (isRight) return const Alignment(0.9, 0);
    return Alignment.center;
  }
}