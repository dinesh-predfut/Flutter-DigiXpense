import 'package:flutter/material.dart';
import 'package:digi_xpense/data/pages/screen/widget/common_status_badge.dart';

class CommonListItemCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final List<Widget> subtitleWidgets;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;
  final double? marginBottom;

  const CommonListItemCard({
    Key? key,
    required this.leading,
    required this.title,
    required this.subtitleWidgets,
    this.trailing,
    this.onTap,
    this.contentPadding,
    this.marginBottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: marginBottom ?? 12),
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
      child: ListTile(
        contentPadding: contentPadding ?? const EdgeInsets.all(16),
        leading: leading,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: subtitleWidgets,
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}

class CommonListItemCardWithStatus extends StatelessWidget {
  final Widget leading;
  final String title;
  final List<Widget> subtitleWidgets;
  final String status;
  final String? date;
  final VoidCallback? onTap;

  const CommonListItemCardWithStatus({
    Key? key,
    required this.leading,
    required this.title,
    required this.subtitleWidgets,
    required this.status,
    this.date,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommonListItemCard(
      leading: leading,
      title: title,
      subtitleWidgets: subtitleWidgets,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CommonStatusBadge(status: status),
          if (date != null) ...[
            const SizedBox(height: 4),
            Text(
              date!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
} 