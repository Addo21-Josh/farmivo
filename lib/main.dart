import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/bootstrap.dart';

void main() async {
  final app = await bootstrap(() => const FarmivoApp());
  runApp(app);
}
