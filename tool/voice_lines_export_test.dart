import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kids_drawing_flutter/core/audio/voice.clips.dart';
import 'package:kids_drawing_flutter/core/tools/stationary/brush.tool.dart';
import 'package:kids_drawing_flutter/core/tools/stationary/category.tool.stationary.dart';
import 'package:kids_drawing_flutter/core/tools/stationary/color.balls.tool.dart';
import 'package:kids_drawing_flutter/core/tools/stationary/crayon.tool.dart';
import 'package:kids_drawing_flutter/core/tools/stationary/glitter.tool.dart';
import 'package:kids_drawing_flutter/core/tools/stationary/letters.tool.dart';
import 'package:kids_drawing_flutter/core/tools/stationary/marker.tool.dart';
import 'package:kids_drawing_flutter/core/tools/stationary/pencil.tool.dart';
import 'package:kids_drawing_flutter/core/tools/stationary/spray.tool.dart';
import 'package:kids_drawing_flutter/core/tools/stationary/tape.tool.dart';
import 'package:kids_drawing_flutter/core/tools/stationary/watercolor.tool.dart';
import 'package:kids_drawing_flutter/data/seed/artwork.seed.catalog.dart';
import 'package:kids_drawing_flutter/types/tools/stationary.model.dart';

/// Writes every line the app can speak to `tool/voice_lines.json`, with the
/// exact filename each clip must be saved as in `assets/voice/en/`.
///
/// It is a test only because the catalogs import `dart:ui`, which a plain
/// `dart run` script cannot load. Run it with:
///
///     flutter test test/voice_lines_export_test.dart
void main() {
  test('export the lines the app speaks', () async {
    final lines = <String, String>{};

    void add(String key, String text) {
      if (text.trim().isEmpty) {
        return;
      }
      lines[key] = text;
    }

    void addPool(String key, List<String> pool) {
      for (var index = 0; index < pool.length; index++) {
        add('$key.$index', pool[index]);
      }
    }

    // Genre voice lines are now loaded from the database (Supabase sync).
    // This test exports only the stationary/artwork lines that are still
    // statically defined in code.

    for (final category in CategoryTools().getCategoryList()) {
      addPool('category.${category.name}', category.voice);
    }

    final sticks = <String, List<StationaryModel>>{
      'pencil': PencilTools().getLists(),
      'marker': MarkerTools().getLists(),
      'glitter': GlitterTools().getLists(),
      'brush': BrushTools().getLists(),
      'crayon': CrayonTools().getLists(),
      'spray': SprayTools().getLists(),
      'watercolor': WatercolorTools().getLists(),
      'color-balls': ColorBallTools().getLists(),
      'tape': TapeTools().getLists(),
      'letters': LetterTools().getLists(),
    };
    for (final entry in sticks.entries) {
      for (final stick in entry.value) {
        add('tool.${entry.key}.${stick.name}', stick.spokenName);
      }
    }

    for (final artwork in const ArtworkSeedCatalog().entries) {
      add('artwork.${artwork.artworkKey}', artwork.voice ?? artwork.title);
    }

    // One clip per distinct line: `yellow` is shared by seven categories.
    final byText = <String, List<String>>{};
    for (final entry in lines.entries) {
      byText.putIfAbsent(entry.value, () => []).add(entry.key);
    }

    final exported = byText.entries
        .map(
          (entry) => {
            'text': entry.key,
            'file': VoiceClips.fileNameFor(entry.key),
            'keys': entry.value..sort(),
          },
        )
        .toList();
    exported.sort(
      (a, b) => (a['file']! as String).compareTo(b['file']! as String),
    );

    const encoder = JsonEncoder.withIndent('  ');
    File('tool/voice_lines.json').writeAsStringSync(
      '${encoder.convert({'language': 'en', 'lines': exported})}\n',
    );

    // ignore: avoid_print
    print('wrote tool/voice_lines.json — ${exported.length} clips');
  });
}
