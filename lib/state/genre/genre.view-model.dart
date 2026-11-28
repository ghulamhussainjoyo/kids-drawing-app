import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/gallery/screen/gallery.screen.dart';
import 'package:kids_drawing_flutter/core/audio/app.sound.dart';
import 'package:kids_drawing_flutter/data/repositories/genre/genre.repository.dart';
import 'package:kids_drawing_flutter/types/genre/genre.model.dart';

class GenreViewModel extends ChangeNotifier {
  final GenreRepository genreRepository;
  final AppSound sound;

  GenreViewModel({required this.genreRepository, required this.sound});

  List<GenreModel> genres = [];
  GenreModel? selectedGenre;
  bool _loaded = false;

  bool get loaded => _loaded;

  Future<void> loadGenres(String language) async {
    genres = await genreRepository.getGenres(language);
    _loaded = true;
    notifyListeners();
  }

  void selectGenre(GenreModel genre) {
    selectedGenre = genre;
    notifyListeners();
  }

  Future<void> openGenre(BuildContext context, GenreModel genre) async {
    selectGenre(genre);
    sound.genreOpened(genre);
    await Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => GalleryScreen(category: genre.id),
      ),
    );
    await sound.playAppMusic();
  }
}
