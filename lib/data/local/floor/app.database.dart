import 'dart:async';

import 'package:floor/floor.dart';
import 'package:kids_drawing_flutter/data/local/floor/artwork.dao.dart';
import 'package:kids_drawing_flutter/data/local/floor/artwork.entity.dart';
import 'package:kids_drawing_flutter/data/local/floor/genre.dao.dart';
import 'package:kids_drawing_flutter/data/local/floor/genre.entity.dart';
import 'package:kids_drawing_flutter/data/local/floor/language.dao.dart';
import 'package:kids_drawing_flutter/data/local/floor/language.entity.dart';
import 'package:kids_drawing_flutter/data/local/floor/translation.dao.dart';
import 'package:kids_drawing_flutter/data/local/floor/translation.entity.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'app.database.g.dart';

@Database(
  version: 3,
  entities: [
    ArtworkEntity,
    LanguageEntity,
    GenreEntity,
    TranslationEntity,
  ],
)
abstract class AppDatabase extends FloorDatabase {
  ArtworkDao get artworkDao;
  LanguageDao get languageDao;
  GenreDao get genreDao;
  TranslationDao get translationDao;
}
