import 'package:flutter_test/flutter_test.dart';
import 'package:match_score/models/match.dart';
void main() {
  test('team serializes members and score', () {
    const team = Team(name: 'الرجالة', members: ['أحمد', 'علي'], totalScore: 7, roundScores: [3, 4]);
    final restored = Team.fromJson(team.toJson());
    expect(restored.name, 'الرجالة');
    expect(restored.members, ['أحمد', 'علي']);
    expect(restored.totalScore, 7);
    expect(restored.roundScores, [3, 4]);
  });
  test('match record preserves rounds and winner', () {
    final record = MatchRecord(id: '1', teams: const [Team(name: 'أبطال', totalScore: 10), Team(name: 'منافسون', totalScore: 4)], rounds: const [RoundScore(round: 1, teamName: 'أبطال', points: 10)], startedAt: DateTime(2026, 1, 1), finishedAt: DateTime(2026, 1, 1, 12), winnerName: 'أبطال');
    final restored = MatchRecord.fromJson(record.toJson());
    expect(restored.teams.length, 2);
    expect(restored.rounds.single.points, 10);
    expect(restored.winnerName, 'أبطال');
  });
}
