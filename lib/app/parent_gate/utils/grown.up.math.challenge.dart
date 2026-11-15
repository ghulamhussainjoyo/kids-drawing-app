import 'dart:math';

/// Random addition challenge for the Ask a Grown-Up gate.
class GrownUpMathChallenge {
  GrownUpMathChallenge({
    required this.left,
    required this.right,
    required this.options,
  });

  final int left;
  final int right;
  final List<int> options;

  int get answer => left + right;

  String get equation => '$left + $right = ?';

  bool isCorrect(int choice) => choice == answer;

  static GrownUpMathChallenge generate([Random? random]) {
    final rng = random ?? Random();
    final left = 4 + rng.nextInt(12);
    final right = 3 + rng.nextInt(12);
    final answer = left + right;
    final options = <int>{answer};
    while (options.length < 3) {
      final offset = 1 + rng.nextInt(8);
      final wrong = rng.nextBool() ? answer + offset : answer - offset;
      if (wrong > 0 && wrong != answer) {
        options.add(wrong);
      }
    }
    final shuffled = options.toList()..shuffle(rng);
    return GrownUpMathChallenge(left: left, right: right, options: shuffled);
  }
}
