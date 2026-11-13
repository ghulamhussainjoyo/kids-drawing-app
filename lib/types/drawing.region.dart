import 'dart:ui';

/// A closed, independently paintable part of an artwork.
///
/// [path] is in artwork coordinates and already excludes every region in
/// front of it, so it can be used directly as a stroke clip.
class DrawingRegion {
  const DrawingRegion({
    required this.id,
    required this.name,
    required this.path,
  });

  final String id;
  final String name;
  final Path path;
}
