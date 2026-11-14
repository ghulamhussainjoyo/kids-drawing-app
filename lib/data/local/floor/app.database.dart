import 'dart:async';

import 'package:floor/floor.dart';
import 'package:kids_drawing_flutter/data/local/floor/artwork.dao.dart';
import 'package:kids_drawing_flutter/data/local/floor/artwork.entity.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'app.database.g.dart';

@Database(version: 1, entities: [ArtworkEntity])
abstract class AppDatabase extends FloorDatabase {
  ArtworkDao get artworkDao;
}
