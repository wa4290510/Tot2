class Player {
  const Player({required this.name, this.score = 0});

  final String name;
  final int score;

  Player copyWith({String? name, int? score}) => Player(
        name: name ?? this.name,
        score: score ?? this.score,
      );

  Map<String, dynamic> toJson() => {'name': name, 'score': score};

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        name: json['name'] as String? ?? 'لاعب',
        score: (json['score'] as num?)?.toInt() ?? 0,
      );
}

class MatchRecord {
  const MatchRecord({
    required this.id,
    required this.players,
    required this.targetScore,
    required this.startedAt,
    required this.finishedAt,
    required this.winnerName,
  });

  final String id;
  final List<Player> players;
  final int targetScore;
  final DateTime startedAt;
  final DateTime finishedAt;
  final String winnerName;

  Map<String, dynamic> toJson() => {
        'id': id,
        'players': players.map((player) => player.toJson()).toList(),
        'targetScore': targetScore,
        'startedAt': startedAt.toIso8601String(),
        'finishedAt': finishedAt.toIso8601String(),
        'winnerName': winnerName,
      };

  factory MatchRecord.fromJson(Map<String, dynamic> json) => MatchRecord(
        id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
        players: ((json['players'] as List<dynamic>?) ?? const [])
            .map((item) => Player.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList(),
        targetScore: (json['targetScore'] as num?)?.toInt() ?? 10,
        startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ?? DateTime.now(),
        finishedAt: DateTime.tryParse(json['finishedAt'] as String? ?? '') ?? DateTime.now(),
        winnerName: json['winnerName'] as String? ?? 'الفائز',
      );
}
