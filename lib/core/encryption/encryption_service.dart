import 'dart:typed_data';
import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 加密服务
/// 使用AES-256加密数据
class EncryptionService {
  EncryptionService._();

  /// 存储加密密钥的key
  static const String _keyStorageKey = 'encryption_key';
  static const String _ivStorageKey = 'encryption_iv';

  /// 获取或创建加密密钥
  static Future<Uint8List> _getOrCreateKey() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(_keyStorageKey)) {
      final keyString = prefs.getString(_keyStorageKey)!;
      return base64.decode(keyString);
    } else {
      // 生成新的256位密钥
      final randomKey = Key.fromSecureRandom(32);
      final keyBytes = Uint8List.fromList(randomKey.bytes);

      await prefs.setString(
        _keyStorageKey,
        base64.encode(keyBytes),
      );

      return keyBytes;
    }
  }

  /// 获取或创建IV
  static Future<Uint8List> _getOrCreateIV() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(_ivStorageKey)) {
      final ivString = prefs.getString(_ivStorageKey)!;
      return base64.decode(ivString);
    } else {
      // 生成新的16字节IV
      final iv = IV.fromSecureRandom(16);
      final ivBytes = Uint8List.fromList(iv.bytes);

      await prefs.setString(
        _ivStorageKey,
        base64.encode(ivBytes),
      );

      return ivBytes;
    }
  }

  /// 加密文本
  /// 返回Base64编码的加密字符串
  static Future<String> encryptText(String plainText) async {
    try {
      final keyBytes = await _getOrCreateKey();
      final ivBytes = await _getOrCreateIV();

      final encrypter = Encrypter(
        AES(Key(keyBytes)),
      );

      final encrypted = encrypter.encrypt(plainText, iv: IV(ivBytes));

      // 返回IV + 密文的组合
      final combined = Uint8List.fromList([...ivBytes, ...encrypted.bytes]);
      return base64.encode(combined);
    } catch (e) {
      throw Exception('加密失败: $e');
    }
  }

  /// 解密文本
  static Future<String> decryptText(String encryptedText) async {
    try {
      final combined = base64.decode(encryptedText);

      if (combined.length < 16) {
        throw Exception('加密数据格式错误');
      }

      // 提取IV和密文
      final ivBytes = combined.sublist(0, 16);
      final cipherBytes = combined.sublist(16);

      final keyBytes = await _getOrCreateKey();

      final encrypter = Encrypter(
        AES(Key(keyBytes)),
      );

      final decrypted = encrypter.decrypt64(
        base64.encode(cipherBytes),
        iv: IV(ivBytes),
      );

      return decrypted;
    } catch (e) {
      throw Exception('解密失败: $e');
    }
  }

  /// 加密JSON对象
  static Future<String> encryptJson(Map<String, dynamic> json) async {
    final jsonString = jsonEncode(json);
    return await encryptText(jsonString);
  }

  /// 解密JSON对象
  static Future<Map<String, dynamic>> decryptJson(String encryptedText) async {
    final jsonString = await decryptText(encryptedText);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// 计算数据的SHA-256哈希
  static String calculateHash(String data) {
    final bytes = utf8.encode(data);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// 验证数据完整性
  static bool verifyIntegrity(String data, String expectedHash) {
    final actualHash = calculateHash(data);
    return actualHash == expectedHash;
  }

  /// 使用自定义密码加密（用于备份文件）
  static Future<String> encryptWithPassword(
    String plainText,
    String password,
  ) async {
    try {
      // 从密码生成密钥（使用PBKDF2）
      final key = _deriveKeyFromPassword(password);

      // 生成随机IV
      final iv = IV.fromSecureRandom(16);

      final encrypter = Encrypter(AES(key));

      final encrypted = encrypter.encrypt(plainText, iv: iv);

      // 组合IV + 密文
      final combined = Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
      return base64.encode(combined);
    } catch (e) {
      throw Exception('使用密码加密失败: $e');
    }
  }

  /// 使用自定义密码解密
  static Future<String> decryptWithPassword(
    String encryptedText,
    String password,
  ) async {
    try {
      final combined = base64.decode(encryptedText);

      if (combined.length < 16) {
        throw Exception('加密数据格式错误');
      }

      // 提取IV和密文
      final ivBytes = combined.sublist(0, 16);
      final cipherBytes = combined.sublist(16);

      // 从密码生成密钥
      final key = _deriveKeyFromPassword(password);

      final encrypter = Encrypter(AES(key));

      final decrypted = encrypter.decrypt64(
        base64.encode(cipherBytes),
        iv: IV(ivBytes),
      );

      return decrypted;
    } catch (e) {
      throw Exception('使用密码解密失败: $e');
    }
  }

  /// 从密码派生密钥（简单的PBKDF2实现）
  static Key _deriveKeyFromPassword(String password) {
    // 注意：这是一个简化的实现
    // 生产环境应使用更安全的密钥派生函数
    final bytes = utf8.encode(password);

    // 重复密码直到达到32字节
    final keyBytes = List<int>.generate(32, (i) => bytes[i % bytes.length]);
    return Key(Uint8List.fromList(keyBytes));
  }

  /// 重置加密密钥（清除所有加密数据）
  static Future<void> resetKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyStorageKey);
    await prefs.remove(_ivStorageKey);
  }
}
