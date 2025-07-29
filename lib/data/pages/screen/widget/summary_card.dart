import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;
  final IconData? icon;

  const SummaryCard({
    Key? key,
    required this.title,
    required this.value,
    this.valueColor,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryCardsRow extends StatelessWidget {
  final List<SummaryCard> cards;
  final double spacing;

  const SummaryCardsRow({
    Key? key,
    required this.cards,
    this.spacing = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: cards.asMap().entries.map((entry) {
          final index = entry.key;
          final card = entry.value;
          
          return Expanded(
            child: index < cards.length - 1
                ? Padding(
                    padding: EdgeInsets.only(right: spacing),
                    child: card,
                  )
                : card,
          );
        }).toList(),
      ),
    );
  }
} 