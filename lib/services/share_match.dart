import 'package:share_plus/share_plus.dart';
import '../models/match.dart';
String matchSummary(MatchRecord match) {
  final teams = match.teams.map((team) => '${team.name}: ${team.totalScore} نقطة').join('\n');
  final rounds = match.rounds.map((round) => 'جولة ${round.round}: ${round.teamName} +${round.points}').join('\n');
  return 'نتيجة المباراة\n$teams\n\nتفاصيل الجولات\n$rounds\n\nالفائز: ${match.winnerName}';
}
Future<void> shareMatch(MatchRecord match) async => Share.share(matchSummary(match), subject: 'نتيجة مباراة ${match.winnerName}');
