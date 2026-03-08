import 'package:flutter/material.dart';
import 'item.dart';

extension ExpirationStatusUi on ExpirationStatus {
  Color get color {
    switch (this) {
      case ExpirationStatus.fresh:
        return Colors.green;
      case ExpirationStatus.warning:
        return Colors.yellow.shade700;
      case ExpirationStatus.urgent:
        return Colors.orange;
      case ExpirationStatus.expired:
        return Colors.red;
    }
  }

  String get label {
    switch (this) {
      case ExpirationStatus.fresh:
        return '新鲜';
      case ExpirationStatus.warning:
        return '注意';
      case ExpirationStatus.urgent:
        return '紧迫';
      case ExpirationStatus.expired:
        return '已过期';
    }
  }
}
