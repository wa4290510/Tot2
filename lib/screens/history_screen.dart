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
        const SliverFillRemaining(hasScrollBody: false, child: Center(child: Text('لسه مفيش مباريات محفوظة', style: TextStyle(color: AppTheme.ivory, fontSize: 20, fontWeight: FontWeight.w800))))
      else
        SliverPadding(padding: const EdgeInsets.fromLTRB(18, 10, 18, 30), sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) => _HistoryCard(match: history[index], date: _date(history[index].finishedAt)), childCount: history.length))),
    ]);
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.match, required this.date});
  final MatchRecord match;
  final String date;

  Future<void> _edit(BuildContext context) async {
    final edited = await showDialog<MatchRecord>(context: context, builder: (_) => _EditScoreDialog(match: match));
    if (edited != null && context.mounted) await context.read<MatchStore>().update(edited);
  }

  @override
  Widget build(BuildContext context) => Card(color: AppTheme.ivory, margin: const EdgeInsets.only(bottom: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Row(children: [Expanded(child: Text('فوز ${match.winnerName}', style: const TextStyle(color: AppTheme.navy, fontSize: 18, fontWeight: FontWeight.w800))), Text(date, style: const TextStyle(color: AppTheme.muted, fontSize: 12))]),
    const SizedBox(height: 12),
    ...match.teams.map((team) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Expanded(child: Text(team.name, style: const TextStyle(color: AppTheme.navy, fontWeight: FontWeight.w800))), Text('${team.totalScore} نقطة', style: const TextStyle(color: AppTheme.orange, fontSize: 18, fontWeight: FontWeight.w900))]))),
    if (match.rounds.isNotEmpty) ...[const Divider(height: 20), const Text('الجولات', style: TextStyle(color: AppTheme.navy, fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text(match.rounds.map((r) => 'ج${r.round}: ${r.teamName} +${r.points}').join('  •  '), style: TextStyle(color: AppTheme.navy.withOpacity(.7), fontSize: 12))],
    const Divider(height: 22),
    Row(children: [Text('هدف الفوز ${match.targetScore}', style: const TextStyle(color: AppTheme.muted, fontSize: 12)), const Spacer(), IconButton(onPressed: () => _edit(context), tooltip: 'تعديل النتيجة', icon: const Icon(Icons.edit_note, color: AppTheme.orange)), IconButton(onPressed: () => shareMatch(match), tooltip: 'مشاركة', icon: const Icon(Icons.ios_share, color: AppTheme.orange)), IconButton(onPressed: () => context.read<MatchStore>().remove(match.id), tooltip: 'حذف', icon: const Icon(Icons.delete_outline, color: Colors.redAccent))]),
  ])));
}

class _EditScoreDialog extends StatefulWidget {
  const _EditScoreDialog({required this.match});
  final MatchRecord match;
  @override
  State<_EditScoreDialog> createState() => _EditScoreDialogState();
}

class _EditScoreDialogState extends State<_EditScoreDialog> {
  late final List<TextEditingController> _controllers = [for (final team in widget.match.teams) TextEditingController(text: '${team.totalScore}')];
  @override
  void dispose() { for (final controller in _controllers) controller.dispose(); super.dispose(); }

  void _save() {
    final scores = _controllers.map((controller) => int.tryParse(controller.text.trim())).toList();
    if (scores.any((score) => score == null || score! < 0)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اكتب نقاط صحيحة أكبر من أو تساوي صفر')));
      return;
    }
    final teams = [for (var i = 0; i < widget.match.teams.length; i++) widget.match.teams[i].copyWith(totalScore: scores[i]!)];
    var winnerIndex = 0;
    for (var i = 1; i < teams.length; i++) {
      if (teams[i].totalScore > teams[winnerIndex].totalScore) winnerIndex = i;
    }
    Navigator.pop(context, widget.match.copyWith(teams: teams, winnerName: teams[winnerIndex].name));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: AppTheme.navyLight,
        title: const Text('تعديل النتيجة', style: TextStyle(color: AppTheme.ivory, fontWeight: FontWeight.w900)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('عدّل مجموع النقاط النهائي لكل فريق. سيتم تحديث اسم الفائز تلقائيًا.', style: TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 14),
          for (var i = 0; i < widget.match.teams.length; i++) ...[
            TextField(controller: _controllers[i], keyboardType: TextInputType.number, textDirection: TextDirection.rtl, style: const TextStyle(color: AppTheme.ivory), decoration: InputDecoration(labelText: widget.match.teams[i].name, labelStyle: const TextStyle(color: AppTheme.muted), prefixIcon: const Icon(Icons.scoreboard_outlined))),
            const SizedBox(height: 10),
          ],
        ])),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')), FilledButton(onPressed: _save, style: FilledButton.styleFrom(backgroundColor: AppTheme.orange, foregroundColor: AppTheme.navy), child: const Text('حفظ التعديل'))],
      );
}
