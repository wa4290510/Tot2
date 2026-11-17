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
      if (history.isEmpty)
        const SliverFillRemaining(hasScrollBody: false, child: Center(child: Padding(padding: EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.sports_score_outlined, color: AppTheme.orange, size: 56), SizedBox(height: 14), Text('لسه مفيش مباريات محفوظة', style: TextStyle(color: AppTheme.ivory, fontSize: 20, fontWeight: FontWeight.w800)), SizedBox(height: 8), Text('ابدأ أول مباراة من تبويب المباراة.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.muted))]))))
      else
        SliverPadding(padding: const EdgeInsets.fromLTRB(18, 10, 18, 30), sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) {
          final match = history[index];
          return _HistoryCard(match: match, date: _date(match.finishedAt));
        }, childCount: history.length))),
    ]);
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.match, required this.date});
  final MatchRecord match;
  final String date;

  @override
  Widget build(BuildContext context) => Card(
        color: AppTheme.ivory,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [Expanded(child: Text('فوز ${match.winnerName}', style: const TextStyle(color: AppTheme.navy, fontSize: 18, fontWeight: FontWeight.w800))), Text(date, style: const TextStyle(color: AppTheme.muted, fontSize: 12))]),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: match.players.map((player) => Chip(label: Text('${player.name}: ${player.score}'), backgroundColor: AppTheme.navy.withValues(alpha: 0.08), side: BorderSide.none)).toList()),
          const Divider(height: 22),
          Row(children: [Text('حد الفوز ${match.targetScore}', style: const TextStyle(color: AppTheme.muted, fontSize: 12)), const Spacer(), IconButton(onPressed: () => shareMatch(match), tooltip: 'مشاركة', icon: const Icon(Icons.ios_share, color: AppTheme.orange)), IconButton(onPressed: () => context.read<MatchStore>().remove(match.id), tooltip: 'حذف', icon: const Icon(Icons.delete_outline, color: Colors.redAccent))]),
        ])),
      );
}
