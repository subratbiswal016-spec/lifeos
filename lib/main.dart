import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/services/notification_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize offline storage
  await Hive.initFlutter();

  // Initialize notifications
  await NotificationService().init();
  
  runApp(
    const ProviderScope(
      child: LifeOSApp(),
    ),
  );
}
