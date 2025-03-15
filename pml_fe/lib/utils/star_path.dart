import 'dart:math';
import 'package:flutter/material.dart';

class StarPath {
  static Path create(double size) {
    final Path path = Path();
    double outerRadius = size;
    double innerRadius = size / 2.5;
    final angle = pi / 5.0;

    path.moveTo(outerRadius * cos(0.0), outerRadius * sin(0.0));

    for (int i = 1; i < 10; i++) {
      double radius = i.isEven ? outerRadius : innerRadius;
      double x = radius * cos(angle * i);
      double y = radius * sin(angle * i);
      path.lineTo(x, y);
    }

    path.close();

    return path;
  }
}
