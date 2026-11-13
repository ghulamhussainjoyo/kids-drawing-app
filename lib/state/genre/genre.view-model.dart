import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/gallery/screen/gallery.screen.dart';
import 'package:kids_drawing_flutter/data/repositories/genre/genre.repository.dart';
import 'package:kids_drawing_flutter/types/genre/genre.model.dart';

class GenreViewModel extends ChangeNotifier {
  GenreViewModel() {
    genres = genreRepository.getGenreList();
  }

  final GenreRepository genreRepository = GenreRepository();
  List<GenreModel> genres = [];
  GenreModel? selectedGenre;

  void selectGenre(GenreModel genre) {
    selectedGenre = genre;
    notifyListeners();
  }

  List<GenreModel> getGenres() {
    return genreRepository.getGenreList();
  }

  void openGenre(BuildContext context, GenreModel genre) {
    selectGenre(genre);
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => GalleryScreen(category: genre.name),
      ),
    );
  }
}
