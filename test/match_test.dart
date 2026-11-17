import 'package:flutter_test/flutter_test.dart';
import 'package:match_score/models/match.dart';

void main() {
  test('player serializes and restores its score', () {
    const player = Player(name: 'أحمد', score: 7);
    final restored = Player.fromJson(player.toJson());
    expect(restored.name, 'أحمد');
    expect(restored.score, 7);
  });

  test('match record preserves players and winner', () {
    final record = MatchRecord(
      id: '1',
      players: const [Player(name: 'أحمد', score: 10), Player(name: 'علي', score: 4)],
      targetScore: 10,
      startedAt: DateTime(2026, 1, 1),
      finishedAt: DateTime(2026, 1, 1, 12),
      winnerName: 'أحمد',
    );
    final restored = MatchRecord.fromJson(record.toJson());
    expect(restored.players.length, 2);
    expect(restored.winnerName, 'أحمد');
    expect(restored.targetScore, 10);
  });
}
