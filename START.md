# 心灵方舟 - 快速启动指南

## 🚀 快速开始

### 1. 安装Flutter依赖
```bash
flutter pub get
```

### 2. 检查Flutter环境
```bash
flutter doctor
```
确保所有项都是✅（Android Studio可能显示未安装，这不影响运行）

### 3. 连接Android设备
- 真机：开启USB调试，连接电脑
- 模拟器：启动Android模拟器

### 4. 运行应用
```bash
flutter run
```

## 📱 功能测试清单

### ✅ 危机检测
- [ ] 点击"测试输入检测"
- [ ] 输入"自杀"等关键词
- [ ] 观察是否自动进入安全岛
- [ ] 检查情绪状态是否更新

### ✅ 安全岛界面
- [ ] 点击"手动进入安全岛"
- [ ] 观察呼吸动画是否流畅
- [ ] 检查星光背景效果
- [ ] 尝试拨打热线电话

### ✅ 设置页面
- [ ] 点击右上角设置图标
- [ ] 测试紧急联系功能开关
- [ ] 添加一个紧急联系人
- [ ] 调节音频音量
- [ ] 测试数据备份功能

### ✅ 数据备份
- [ ] 在设置中点击"备份数据"
- [ ] 等待备份完成
- [ ] 尝试分享备份文件
- [ ] 测试数据恢复功能

## 🔧 常见问题

### 1. 依赖安装失败
**解决方案：**
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

### 2. 构建失败
**解决方案：**
```bash
flutter clean
flutter run
```

### 3. Hive初始化失败
**解决方案：**
确保 `main.dart` 中正确调用了 `await StorageService.initialize()`

### 4. 无法检测到关键词
**解决方案：**
- 检查输入的文本是否包含列表中的关键词
- 确保点击了"提交检测"或输入时触发实时检测

### 5. 设置页面不显示
**解决方案：**
- 检查是否正确导入了 `SettingsScreen`
- 确认路由导航代码正确

## 📦 项目文件说明

### 核心文件
- `lib/main.dart` - 应用入口，初始化Hive
- `lib/app.dart` - 主应用Widget
- `pubspec.yaml` - 依赖配置

### 功能模块
- `lib/core/detection/` - 危机检测引擎
- `lib/core/state/` - 状态管理（Riverpod）
- `lib/core/encryption/` - 数据加密
- `lib/features/safe_harbor/` - 安全岛功能
- `lib/features/settings/` - 设置页面
- `lib/features/backup/` - 数据备份
- `lib/data/local_storage/` - Hive本地存储

### 配置文件
- `android/app/src/main/AndroidManifest.xml` - Android权限配置
- `assets/data/hotlines.json` - 离线热线数据

## 🎯 下一步开发建议

### 短期优化
1. 添加心跳声音频文件
2. 完善错误提示
3. 添加情绪记录可视化
4. 优化动画性能

### 中期功能
1. iOS适配
2. 多语言支持
3. 夜间模式优化
4. 情绪图表分析

### 长期规划
1. Web版本
2. 云端备份（可选）
3. AI情绪分析增强
4. 社区功能

## 📝 开发笔记

### 数据流程
1. 用户输入 → 危机检测器 → 更新情绪状态
2. 检测到危机 → 自动进入安全岛
3. 用户操作 → 更新本地存储（Hive）
4. 数据备份 → 加密 → 导出.heart文件

### 状态管理
- 使用 Riverpod 进行全局状态管理
- `emotionStateProvider` - 情绪状态
- `userStateProvider` - 用户设置

### 本地存储
- Hive 用于高性能本地存储
- 所有数据自动序列化/反序列化
- 支持数据加密导出

## 📚 技术文档

- [Flutter官方文档](https://flutter.dev/docs)
- [Riverpod文档](https://riverpod.dev/)
- [Hive文档](https://docs.hivedb.dev/)
- [Encrypt包文档](https://pub.dev/packages/encrypt)

---

**祝你开发顺利！** 🎉
