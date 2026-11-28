import 'package:flutter_test/flutter_test.dart';
import 'package:kids_drawing_flutter/core/audio/voice.clips.dart';

/// The clip filename is a contract: the renderer in `tool/` and the admin
/// dashboard that uploads artwork voices both reproduce this rule. Changing
/// it on one side only makes every clip unfindable.
void main() {
  test('a line always maps to the same file name', () {
    expect(VoiceClips.fileNameFor('yellow'), 'yellow_05bf6449.mp3');
    expect(VoiceClips.fileNameFor('Ooh!'), 'ooh_49dd8c50.mp3');
    expect(
      VoiceClips.fileNameFor('A school bag, ready for books!'),
      'a_school_bag_ready_for_books_a7551a9f.mp3',
    );
  });

  test('case, punctuation and spacing do not change the file', () {
    final plain = VoiceClips.fileNameFor('yellow');
    expect(VoiceClips.fileNameFor('  YELLOW  '), plain);
  });

  test('two different lines never share a file', () {
    expect(
      VoiceClips.fileNameFor('Pencil time! Scribble scribble!'),
      isNot(VoiceClips.fileNameFor('Pencil time! Scribble!')),
    );
  });

  test('a long line is cut short but stays unique', () {
    final name = VoiceClips.fileNameFor(
      'This is a very long spoken line that goes well past the slug limit.',
    );
    expect(name.length, lessThanOrEqualTo(61));
    expect(name, endsWith('.mp3'));
    expect(name, isNot(contains('_.')));
  });
}
