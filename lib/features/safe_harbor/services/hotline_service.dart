import 'package:url_launcher/url_launcher_string.dart';
import '../models/hotline_model.dart';

/// 热线服务
/// 提供离线热线电话列表和拨打功能
class HotlineService {
  HotlineService._();

  /// 离线热线列表（内置在应用中）
  static final List<Hotline> hotlines = [
    Hotline(
      name: '北京心理援助热线',
      phone: '010-82951332',
      description: '24小时免费，专业心理咨询',
      tags: ['危机', '抑郁', '自杀干预'],
    ),
    Hotline(
      name: '希望24热线',
      phone: '400-161-9995',
      description: '全国性心理危机干预热线',
      tags: ['自杀预防', '情绪疏导'],
    ),
    Hotline(
      name: '浙江省心理援助热线',
      phone: '96525',
      description: '浙江省精神卫生中心',
      tags: ['本地', '专业'],
    ),
    Hotline(
      name: '上海心理援助热线',
      phone: '021-12320',
      description: '上海市精神卫生中心',
      tags: ['本地', '专业'],
    ),
    Hotline(
      name: '广州心理援助热线',
      phone: '020-81899120',
      description: '广州市心理危机干预中心',
      tags: ['本地', '24小时'],
    ),
    Hotline(
      name: '深圳心理援助热线',
      phone: '400-995-9959',
      description: '深圳市心理危机干预中心',
      tags: ['本地', '24小时'],
    ),
    Hotline(
      name: '青少年心理咨询热线',
      phone: '12355',
      description: '共青团青少年服务热线',
      tags: ['青少年', '成长'],
    ),
    Hotline(
      name: '全国妇联维权热线',
      phone: '12338',
      description: '全国妇女维权公益服务热线',
      tags: ['妇女', '维权'],
    ),
  ];

  /// 获取所有热线
  static List<Hotline> getAllHotlines() {
    return hotlines;
  }

  /// 根据标签筛选热线
  static List<Hotline> getHotlinesByTag(String tag) {
    return hotlines.where((h) => h.tags.contains(tag)).toList();
  }

  /// 根据关键词搜索热线
  static List<Hotline> searchHotlines(String keyword) {
    final lowerKeyword = keyword.toLowerCase();
    return hotlines.where((h) {
      return h.name.toLowerCase().contains(lowerKeyword) ||
             h.description.toLowerCase().contains(lowerKeyword) ||
             h.tags.any((t) => t.toLowerCase().contains(lowerKeyword));
    }).toList();
  }

  /// 拨打热线电话
  static Future<bool> callHotline(String phone) async {
    final url = 'tel:$phone';
    try {
      if (await canLaunchUrlString(url)) {
        return await launchUrlString(url);
      }
      return false;
    } catch (e) {
      print('拨打热线失败: $e');
      return false;
    }
  }

  /// 获取推荐热线（优先本地，其次24小时）
  static List<Hotline> getRecommendedHotlines() {
    final recommended = <Hotline>[];

    // 优先推荐24小时热线
    for (final hotline in hotlines) {
      if (hotline.description.contains('24小时') ||
          hotline.tags.contains('24小时')) {
        recommended.add(hotline);
      }
    }

    // 如果推荐不足3个，补充其他
    if (recommended.length < 3) {
      for (final hotline in hotlines) {
        if (!recommended.contains(hotline)) {
          recommended.add(hotline);
          if (recommended.length >= 3) break;
        }
      }
    }

    return recommended.take(3).toList();
  }
}
