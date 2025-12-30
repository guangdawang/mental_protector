import 'package:hive_flutter/hive_flutter.dart';
import '../models/contact_model.dart';
import '../../core/state/emotion_state.dart';

/// Hive类型ID
class HiveTypeIds {
  HiveTypeIds._();

  static const int emergencyContact = 0;
  static const int emotionRecord = 1;
  static const int userSettings = 2;
}

/// Hive适配器注册
/// 必须在应用启动时调用
class HiveAdapters {
  HiveAdapters._();

  /// 注册所有适配器
  static Future<void> registerAdapters() async {
    // 注册EmergencyContact适配器
    if (!Hive.isAdapterRegistered(HiveTypeIds.emergencyContact)) {
      Hive.registerAdapter(EmergencyContactAdapter());
    }

    // 注册EmotionRecord适配器
    if (!Hive.isAdapterRegistered(HiveTypeIds.emotionRecord)) {
      Hive.registerAdapter(EmotionRecordAdapter());
    }
  }

  /// 打开所有Box
  static Future<void> openBoxes() async {
    await Hive.openBox<EmergencyContact>('emergency_contacts');
    await Hive.openBox<EmotionRecord>('emotion_records');
    await Hive.openBox<String>('user_settings');
  }
}

/// EmergencyContact的Hive适配器
class EmergencyContactAdapter extends TypeAdapter<EmergencyContact> {
  @override
  final int typeId = HiveTypeIds.emergencyContact;

  @override
  EmergencyContact read(BinaryReader reader) {
    return EmergencyContact(
      id: reader.readString(),
      name: reader.readString(),
      phone: reader.readString(),
      relationship: reader.readString(),
      createdAt: DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, EmergencyContact obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.phone);
    writer.writeString(obj.relationship);
    writer.writeString(obj.createdAt.toIso8601String());
  }
}

/// EmotionRecord的Hive适配器
class EmotionRecordAdapter extends TypeAdapter<EmotionRecord> {
  @override
  final int typeId = HiveTypeIds.emotionRecord;

  @override
  EmotionRecord read(BinaryReader reader) {
    return EmotionRecord(
      level: reader.readInt(),
      timestamp: DateTime.parse(reader.readString()),
      note: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, EmotionRecord obj) {
    writer.writeInt(obj.level);
    writer.writeString(obj.timestamp.toIso8601String());
    writer.writeString(obj.note ?? '');
  }
}
