import 'package:share_plus/share_plus.dart';
import '../models/match.dart';

String matchSummary(MatchRecord match) {
  final scores = match.players.map((p) => '${p.name}: ${p.score}').join('، ');
  return 'نتيجة المباراة\n$scores\nالفائز: ${match.winnerName}\nحد الفوز: ${match.targetScore} نقطة';
}

Future<void> shareMatch(MatchRecord match) async {
  await SharePlus.instance.share(ShareParams(
    text: matchSummary(match),
    subject: 'نتيجة مباراة ${match.winnerName}',
  ));
}
