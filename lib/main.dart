import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/local_storage/storage_service.dart';
import 'app.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化Hive本地存储
  await StorageService.initialize();

  runApp(
    const ProviderScope(
      child: MindDarkApp(),
    ),
  );
}
