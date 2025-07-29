import 'package:flutter/material.dart';

class CommonStatusBadge extends StatelessWidget {
  final String status;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const CommonStatusBadge({
    Key? key,
    required this.status,
    this.fontSize,
    this.padding,
  }) : super(key: key);

  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'processed':
        return '#4CAF50';
      case 'rejected':
        return '#F44336';
      case 'pending':
      case 'in process':
      case 'un-processed':
      case 'un reported':
        return '#FF9800';
      default:
        return '#9E9E9E';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Color(int.parse(
          _getStatusColor(status).replaceAll('#', '0xFF'),
        )),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize ?? 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
} 