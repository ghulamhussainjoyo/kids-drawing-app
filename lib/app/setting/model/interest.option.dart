class InterestOption {
  final String id;
  final String labelKey;
  final String? svgPath;
  final String? imagePath;

  const InterestOption({
    required this.id,
    required this.labelKey,
    this.svgPath,
    this.imagePath,
  });

  static const List<InterestOption> catalog = [
    InterestOption(
      id: 'animals',
      labelKey: 'interest.animals',
      svgPath: 'assets/svgs/interests/animals.svg',
      imagePath: 'assets/gallery/animals.png',
    ),
    InterestOption(
      id: 'music',
      labelKey: 'interest.music',
      svgPath: 'assets/svgs/interests/music.svg',
      imagePath: 'assets/gallery/music.png',
    ),
    InterestOption(
      id: 'seasons',
      labelKey: 'interest.seasons',
      svgPath: 'assets/svgs/interests/seasons.svg',
      imagePath: 'assets/gallery/seasons.png',
    ),
    InterestOption(
      id: 'school',
      labelKey: 'interest.school',
      svgPath: 'assets/svgs/interests/school.svg',
      imagePath: 'assets/gallery/school.png',
    ),
    InterestOption(
      id: 'transport',
      labelKey: 'interest.transport',
      svgPath: 'assets/svgs/interests/transport.svg',
      imagePath: 'assets/gallery/transport.png',
    ),
    InterestOption(
      id: 'princes',
      labelKey: 'interest.princesses',
      svgPath: 'assets/svgs/interests/princes.svg',
      imagePath: 'assets/gallery/princes.png',
    ),
    InterestOption(
      id: 'fruit-garden',
      labelKey: 'interest.fruit_garden',
      svgPath: 'assets/svgs/interests/fruit-garden.svg',
      imagePath: 'assets/gallery/fruit- garden.png',
    ),
  ];
}
