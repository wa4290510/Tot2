import 'package:flutter/material.dart';
import '../theme.dart';
class TeamScoreCard extends StatelessWidget {
  const TeamScoreCard({super.key, required this.team, required this.members, required this.score, required this.target, required this.selected, required this.onSelect});
  final String team;
  final List<String> members;
  final int score;
  final int target;
  final bool selected;
  final VoidCallback onSelect;
  @override
  Widget build(BuildContext context) {
    final progress = (score / target).clamp(0.0, 1.0);
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: selected ? AppTheme.orange : AppTheme.ivory, borderRadius: BorderRadius.circular(24), border: Border.all(color: selected ? AppTheme.orange : Colors.transparent, width: 2), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 7))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [Expanded(child: Text(team, style: TextStyle(color: selected ? AppTheme.navy : AppTheme.navy, fontSize: 21, fontWeight: FontWeight.w900))), if (selected) const Icon(Icons.touch_app, color: AppTheme.navy)]),
          const SizedBox(height: 5),
          Text(members.isEmpty ? 'بدون أعضاء مسجلين' : members.join('، '), style: TextStyle(color: AppTheme.navy.withOpacity(.65), fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          Text('$score', style: TextStyle(color: AppTheme.navy, fontSize: 58, height: .95, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: AppTheme.navy.withOpacity(.12), valueColor: AlwaysStoppedAnimation(selected ? AppTheme.navy : AppTheme.orange))),
          const SizedBox(height: 7),
          Text('$score / $target نقطة • اضغط للاختيار', style: TextStyle(color: AppTheme.navy.withOpacity(.7), fontWeight: FontWeight.w700, fontSize: 12)),
        ]),
      ),
    );
  }
}
