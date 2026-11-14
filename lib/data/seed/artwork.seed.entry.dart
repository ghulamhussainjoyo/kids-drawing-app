/// One catalog row to install from [lib/data/seed] into Floor.
class ArtworkSeedEntry {
  final String artworkKey;
  final String genre;
  final String title;
  final bool isPremium;
  final String templateJson;

  const ArtworkSeedEntry({
    required this.artworkKey,
    required this.genre,
    required this.title,
    required this.isPremium,
    required this.templateJson,
  });
}
