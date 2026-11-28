import 'package:kids_drawing_flutter/types/genre/genre.model.dart';

abstract class GenreRepository {
  Future<List<GenreModel>> getGenres(String language);
  Future<GenreModel?> getBySlug(String slug, String language);
}
