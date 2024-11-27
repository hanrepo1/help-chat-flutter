import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final String? userRole;

  MenuItem({
    required this.title,
    required this.icon,
    this.userRole,
  });

  @override
  String toString() {
    return 'MenuItem(title: $title, icon: $icon, userRole: $userRole)';
  }
}
