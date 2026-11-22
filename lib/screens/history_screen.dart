import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/match.dart';
import '../services/match_store.dart';
import '../services/share_match.dart';
import '../theme.dart';
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  String _date(DateTime value) => '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  @override
  Widget build(BuildContext context) {
    final history = context.watch<MatchStore>().history;
    return CustomScrollView(slivers: [
      const SliverAppBar(pinned: true, title: Text('سجل المباريات', style: TextStyle(fontWeight: FontWeight.w800))),
      if (history.isEmpty) const SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('لسه مفيش مباريات محفوظة', style: TextStyle(color: AppTheme.ivory, fontSize: 20, fontWeight: FontWeight.w800))))
      else SliverPadding(padding: const EdgeInsets.fromLTRB(18, 10, 18, 30), sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) => _HistoryCard(match: history[index], date: _date(history[index].finishedAt)), childCount: history.length))),
    ]);
  }
}
class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.match, required this.date});
  final MatchRecord match;
  final String date;
  @override
  Widget build(BuildContext context) => Card(color: AppTheme.ivory, margin: const EdgeInsets.only(bottom: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Row(children: [Expanded(child: Text('فوز ${match.winnerName}', style: const TextStyle(color: AppTheme.navy, fontSize: 18, fontWeight: FontWeight.w800))), Text(date, style: const TextStyle(color: AppTheme.muted, fontSize: 12))]),
    const SizedBox(height: 12),
    ...match.teams.map((team) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Expanded(child: Text(team.name, style: const TextStyle(color: AppTheme.navy, fontWeight: FontWeight.w800))), Text('${team.totalScore} نقطة', style: const TextStyle(color: AppTheme.orange, fontSize: 18, fontWeight: FontWeight.w900))]))),
    if (match.rounds.isNotEmpty) ...[const Divider(height: 20), const Text('الجولات', style: TextStyle(color: AppTheme.navy, fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text(match.rounds.map((r) => 'ج${r.round}: ${r.teamName} +${r.points}').join('  •  '), style: TextStyle(color: AppTheme.navy.withOpacity(.7), fontSize: 12))],
    const Divider(height: 22),
    Row(children: [Text('هدف الفوز ${match.targetScore}', style: const TextStyle(color: AppTheme.muted, fontSize: 12)), const Spacer(), IconButton(onPressed: () => shareMatch(match), tooltip: 'مشاركة', icon: const Icon(Icons.ios_share, color: AppTheme.orange)), IconButton(onPressed: () => context.read<MatchStore>().remove(match.id), tooltip: 'حذف', icon: const Icon(Icons.delete_outline, color: Colors.redAccent))]),
  ])));
}
