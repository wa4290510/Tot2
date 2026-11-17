import 'package:flutter/material.dart';
import '../theme.dart';

class ScoreCard extends StatelessWidget {
  const ScoreCard({
    super.key,
    required this.name,
    required this.score,
    required this.target,
    required this.onIncrease,
    required this.onDecrease,
    required this.isWinner,
  });

  final String name;
  final int score;
  final int target;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    final progress = (score / target).clamp(0.0, 1.0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 14),
      decoration: BoxDecoration(
        color: isWinner ? AppTheme.green.withOpacity(0.18) : AppTheme.ivory,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isWinner ? AppTheme.green : Colors.transparent, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 18, offset: Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(child: Text(name, style: TextStyle(color: isWinner ? AppTheme.ivory : AppTheme.navy, fontSize: 19, fontWeight: FontWeight.w700))),
            if (isWinner) const Text('فائز', style: TextStyle(color: AppTheme.green, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(child: AnimatedSwitcher(duration: const Duration(milliseconds: 180), child: Text('$score', key: ValueKey(score), style: TextStyle(color: isWinner ? AppTheme.ivory : AppTheme.navy, fontSize: 54, height: 1, fontWeight: FontWeight.w900)))),
            IconButton(onPressed: score > 0 ? onDecrease : null, icon: Icon(Icons.remove_circle_outline, color: isWinner ? AppTheme.ivory : AppTheme.navy)),
            const SizedBox(width: 4),
            FilledButton(onPressed: onIncrease, style: FilledButton.styleFrom(backgroundColor: AppTheme.orange, foregroundColor: AppTheme.navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14)), child: const Text('+1', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
          ]),
          const SizedBox(height: 10),
          ClipRRect(borderRadius: BorderRadius.circular(9), child: LinearProgressIndicator(value: progress, minHeight: 7, backgroundColor: AppTheme.navy.withOpacity(0.1), valueColor: const AlwaysStoppedAnimation(AppTheme.orange))),
          const SizedBox(height: 6),
          Text('$score / $target نقطة', textAlign: TextAlign.end, style: TextStyle(color: isWinner ? AppTheme.ivory.withOpacity(0.7) : AppTheme.navy.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
