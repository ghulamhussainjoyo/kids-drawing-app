class InterestOption {
  final String id;
  final String label;
  final String? svgPath;
  final String? imagePath;

  const InterestOption({
    required this.id,
    required this.label,
    this.svgPath,
    this.imagePath,
  });

  /// Slots for later SVG drops under assets/svgs/interests/.
  /// Falls back to gallery PNG until SVG assets exist.
  static const List<InterestOption> catalog = [
    InterestOption(
      id: 'animals',
      label: 'Animals',
      svgPath: 'assets/svgs/interests/animals.svg',
      imagePath: 'assets/gallery/animals.png',
    ),
    InterestOption(
      id: 'music',
      label: 'Music',
      svgPath: 'assets/svgs/interests/music.svg',
      imagePath: 'assets/gallery/music.png',
    ),
    InterestOption(
      id: 'seasons',
      label: 'Seasons',
      svgPath: 'assets/svgs/interests/seasons.svg',
      imagePath: 'assets/gallery/seasons.png',
    ),
    InterestOption(
      id: 'school',
      label: 'School',
      svgPath: 'assets/svgs/interests/school.svg',
      imagePath: 'assets/gallery/school.png',
    ),
    InterestOption(
      id: 'transport',
      label: 'Transport',
      svgPath: 'assets/svgs/interests/transport.svg',
      imagePath: 'assets/gallery/transport.png',
    ),
    InterestOption(
      id: 'princes',
      label: 'Princesses',
      svgPath: 'assets/svgs/interests/princes.svg',
      imagePath: 'assets/gallery/princes.png',
    ),
    InterestOption(
      id: 'fruit-garden',
      label: 'Fruit Garden',
      svgPath: 'assets/svgs/interests/fruit-garden.svg',
      imagePath: 'assets/gallery/fruit- garden.png',
    ),
  ];
}
