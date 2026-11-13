import 'package:flutter/cupertino.dart';

abstract class StationaryModel {
  final String id;
  final String name;
  final double? size;
  final String image;
  final double imageSize;
  final Color color;

  const StationaryModel({
    required this.id,
    required this.name,
    required this.size,
    required this.image,
    required this.imageSize,
    required this.color,
  });
}
