import 'package:kids_drawing_flutter/data/seed/artwork.seed.entry.dart';
import 'package:kids_drawing_flutter/data/seed/school/school.bag.seed.dart';
import 'package:kids_drawing_flutter/data/seed/school/school.eraser.seed.dart';
import 'package:kids_drawing_flutter/data/seed/school/school.pencil.seed.dart';

/// All Stage 1 seed entries to install into Floor.
class ArtworkSeedCatalog {
  const ArtworkSeedCatalog();

  List<ArtworkSeedEntry> get entries => [
    const SchoolBagSeed().entry,
    const SchoolPencilSeed().entry,
    const SchoolEraserSeed().entry,
  ];
}
