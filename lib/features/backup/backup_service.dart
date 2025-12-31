import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/encryption/encryption_service.dart';
import '../../data/local_storage/storage_service.dart';
import '../../core/constants.dart';

/// 数据备份服务
/// 处理数据导出、导入和加密
class BackupService {
  BackupService._();

  /// 备份数据到.heart文件
  static Future<String> backupData({
    String? customPassword,
  }) async {
    try {
      // 1. 导出数据
      final data = StorageService.exportData();

      // 2. 转换为JSON字符串
      final jsonString = jsonEncode(data);

      // 3. 计算哈希
      final hash = EncryptionService.calculateHash(jsonString);

      // 4. 加密数据
      final encryptedData = customPassword != null
          ? await EncryptionService.encryptWithPassword(
              jsonString, customPassword)
          : await EncryptionService.encryptText(jsonString);

      // 5. 构建备份文件内容
      final backupContent = jsonEncode({
        'version': '1.0.0',
        'algorithm': 'AES-256',
        'hash': hash,
        'data': encryptedData,
      });

      // 6. 压缩数据（简单的GZIP压缩）
      final compressedData = _compressData(backupContent);

      // 7. 保存文件
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final filename =
          'minddark_backup_$timestamp${AppConstants.backupFileExtension}';
      final filepath = '${directory.path}/$filename';

      final file = File(filepath);
      await file.writeAsBytes(compressedData);

      return filepath;
    } catch (e) {
      throw Exception('备份失败: $e');
    }
  }

  /// 从.heart文件恢复数据
  static Future<bool> restoreData({
    required String filepath,
    String? password,
  }) async {
    try {
      // 1. 读取文件
      final file = File(filepath);
      if (!await file.exists()) {
        throw Exception('文件不存在');
      }

      // 2. 解压缩
      final compressedBytes = await file.readAsBytes();
      final jsonString = _decompressData(compressedBytes);

      // 3. 解析备份文件
      final backup = jsonDecode(jsonString) as Map<String, dynamic>;

      // 4. 验证版本
      final version = backup['version'] as String;
      if (version != '1.0.0') {
        throw Exception('不支持的备份版本: $version');
      }

      // 5. 解密数据
      final encryptedData = backup['data'] as String;
      final decryptedData = password != null
          ? await EncryptionService.decryptWithPassword(encryptedData, password)
          : await EncryptionService.decryptText(encryptedData);

      // 6. 验证哈希
      final expectedHash = backup['hash'] as String;
      final actualHash = EncryptionService.calculateHash(decryptedData);

      if (!EncryptionService.verifyIntegrity(decryptedData, expectedHash)) {
        throw Exception('数据完整性验证失败');
      }

      // 7. 解析并导入数据
      final data = jsonDecode(decryptedData) as Map<String, dynamic>;
      await StorageService.importData(data);

      return true;
    } catch (e) {
      throw Exception('恢复失败: $e');
    }
  }

  /// 分享备份文件
  static Future<void> shareBackup(String filepath) async {
    try {
      final file = File(filepath);
      await Share.shareXFiles(
        [XFile(filepath)],
        subject: '心灵方舟数据备份',
      );
    } catch (e) {
      throw Exception('分享失败: $e');
    }
  }

  /// 选择并恢复备份文件
  static Future<bool> selectAndRestoreBackup({
    String? password,
  }) async {
    try {
      // 1. 选择文件
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['heart'],
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      final filepath = result.files.single.path;
      if (filepath == null) {
        return false;
      }

      // 2. 恢复数据
      return await restoreData(
        filepath: filepath,
        password: password,
      );
    } catch (e) {
      throw Exception('选择和恢复备份失败: $e');
    }
  }

  /// 获取备份文件信息
  static Future<Map<String, dynamic>> getBackupInfo(String filepath) async {
    try {
      final file = File(filepath);
      if (!await file.exists()) {
        throw Exception('文件不存在');
      }

      final compressedBytes = await file.readAsBytes();
      final jsonString = _decompressData(compressedBytes);
      final backup = jsonDecode(jsonString) as Map<String, dynamic>;

      return {
        'version': backup['version'],
        'algorithm': backup['algorithm'],
        'hasPassword': backup.containsKey('passwordHash'),
        'fileSize': await file.length(),
        'filepath': filepath,
      };
    } catch (e) {
      throw Exception('获取备份信息失败: $e');
    }
  }

  /// 简单的数据压缩（使用GZIP）
  static Uint8List _compressData(String data) {
    final bytes = utf8.encode(data);
    return Uint8List.fromList(bytes);
    // 注意：实际应用中可以使用dart:io的GZipCodec进行压缩
    // 这里为了简化，直接返回原始数据
  }

  /// 简单的数据解压缩
  static String _decompressData(Uint8List bytes) {
    return utf8.decode(bytes);
    // 注意：实际应用中可以使用dart:io的GZipCodec进行解压
    // 这里为了简化，直接返回字符串
  }

  /// 删除备份文件
  static Future<bool> deleteBackup(String filepath) async {
    try {
      final file = File(filepath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('删除备份失败: $e');
    }
  }

  /// 获取所有备份文件列表
  static Future<List<String>> getBackupFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = <String>[];

      await for (final entity in directory.list()) {
        if (entity is File &&
            entity.path.endsWith(AppConstants.backupFileExtension)) {
          files.add(entity.path);
        }
      }

      return files;
    } catch (e) {
      throw Exception('获取备份列表失败: $e');
    }
  }
}
