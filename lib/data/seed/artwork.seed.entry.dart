/// One catalog row to install from [lib/data/seed] into Floor.
class ArtworkSeedEntry {
  final String artworkKey;
  final String genre;
  final String title;

  /// Short line the voice reads when this artwork is opened.
  final String? voice;
  final bool isPremium;
  final String templateJson;

  const ArtworkSeedEntry({
    required this.artworkKey,
    required this.genre,
    required this.title,
    this.voice,
    required this.isPremium,
    required this.templateJson,
  });
}
