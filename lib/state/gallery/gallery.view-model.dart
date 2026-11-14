import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/drawing/screen/drawing.screen.dart';
import 'package:kids_drawing_flutter/data/local/floor/artwork.entity.dart';
import 'package:kids_drawing_flutter/data/repositories/artwork/catalog.repository.dart';
import 'package:kids_drawing_flutter/state/drawing/drawing.view-model.dart';

class GalleryViewModel extends ChangeNotifier {
  GalleryViewModel({
    required this.catalogRepository,
    required this.drawingViewModel,
  });

  final CatalogRepository catalogRepository;
  final DrawingViewModel drawingViewModel;

  final Map<String, List<ArtworkEntity>> _byGenre = {};
  bool loading = false;

  List<ArtworkEntity> artworksForGenre(String genre) {
    return _byGenre[genre] ?? const [];
  }

  Future<void> loadGenre(String genre) async {
    loading = true;
    notifyListeners();
    final rows = await catalogRepository.listByGenre(genre);
    _byGenre[genre] = rows;
    loading = false;
    notifyListeners();
  }

  Future<void> loadAll(List<String> genreIds) async {
    loading = true;
    notifyListeners();
    for (final genreId in genreIds) {
      final rows = await catalogRepository.listByGenre(genreId);
      _byGenre[genreId] = rows;
    }
    loading = false;
    notifyListeners();
  }

  Future<void> openArtwork(BuildContext context, ArtworkEntity artwork) async {
    await drawingViewModel.selectArtwork(artwork.artworkKey);
    if (!context.mounted) {
      return;
    }
    final route = CupertinoPageRoute(
      builder: (context) => const DrawingScreen(),
    );
    await Navigator.push(context, route);
    await drawingViewModel.flushSave();
    await loadGenre(artwork.genre);
  }
}
