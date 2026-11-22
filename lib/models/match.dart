class Team {
  const Team({required this.name, this.members = const [], this.totalScore = 0, this.roundScores = const []});
  final String name;
  final List<String> members;
  final int totalScore;
  final List<int> roundScores;
  Team copyWith({String? name, List<String>? members, int? totalScore, List<int>? roundScores}) => Team(
        name: name ?? this.name,
        members: members ?? this.members,
        totalScore: totalScore ?? this.totalScore,
        roundScores: roundScores ?? this.roundScores,
      );
  Map<String, dynamic> toJson() => {'name': name, 'members': members, 'totalScore': totalScore, 'roundScores': roundScores};
  factory Team.fromJson(Map<String, dynamic> json) => Team(
        name: json['name'] as String? ?? 'فريق',
        members: ((json['members'] as List<dynamic>?) ?? const []).map((e) => e.toString()).toList(),
        totalScore: (json['totalScore'] as num?)?.toInt() ?? 0,
        roundScores: ((json['roundScores'] as List<dynamic>?) ?? const []).map((e) => (e as num).toInt()).toList(),
      );
}

class RoundScore {
  const RoundScore({required this.round, required this.teamName, required this.points});
  final int round;
  final String teamName;
  final int points;
  Map<String, dynamic> toJson() => {'round': round, 'teamName': teamName, 'points': points};
  factory RoundScore.fromJson(Map<String, dynamic> json) => RoundScore(
        round: (json['round'] as num?)?.toInt() ?? 1,
        teamName: json['teamName'] as String? ?? 'فريق',
        points: (json['points'] as num?)?.toInt() ?? 0,
      );
}

class MatchRecord {
  const MatchRecord({required this.id, required this.teams, required this.rounds, required this.startedAt, required this.finishedAt, required this.winnerName, this.targetScore = 30});
  final String id;
  final List<Team> teams;
  final List<RoundScore> rounds;
  final DateTime startedAt;
  final DateTime finishedAt;
  final String winnerName;
  final int targetScore;
  Map<String, dynamic> toJson() => {
        'id': id,
        'teams': teams.map((team) => team.toJson()).toList(),
        'rounds': rounds.map((round) => round.toJson()).toList(),
        'startedAt': startedAt.toIso8601String(),
        'finishedAt': finishedAt.toIso8601String(),
        'winnerName': winnerName,
        'targetScore': targetScore,
      };
  factory MatchRecord.fromJson(Map<String, dynamic> json) {
    final rawTeams = json['teams'] as List<dynamic>?;
    final teams = rawTeams == null
        ? ((json['players'] as List<dynamic>?) ?? const []).map((item) => Team(name: (item as Map)['name']?.toString() ?? 'فريق', totalScore: ((item)['score'] as num?)?.toInt() ?? 0)).toList()
        : rawTeams.map((item) => Team.fromJson(Map<String, dynamic>.from(item as Map))).toList();
    return MatchRecord(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      teams: teams,
      rounds: ((json['rounds'] as List<dynamic>?) ?? const []).map((item) => RoundScore.fromJson(Map<String, dynamic>.from(item as Map))).toList(),
      targetScore: (json['targetScore'] as num?)?.toInt() ?? 30,
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ?? DateTime.now(),
      finishedAt: DateTime.tryParse(json['finishedAt'] as String? ?? '') ?? DateTime.now(),
      winnerName: json['winnerName'] as String? ?? 'الفائز',
    );
  }
}
