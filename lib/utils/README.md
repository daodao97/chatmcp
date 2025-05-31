# Utils 工具类

## ToastUtils - Toast 通知工具

ToastUtils 提供了统一的 toast 通知功能，支持不同级别的消息提示。

### 使用方法

```dart
import '../utils/toast.dart';

// 错误级别 - 红色背景，持续 5 秒
ToastUtils.error('操作失败，请重试');

// 警告级别 - 橙色背景，持续 4 秒  
ToastUtils.warn('网络连接不稳定');

// 信息级别 - 蓝色背景，持续 3 秒
ToastUtils.info('正在处理您的请求');

// 成功级别 - 绿色背景，持续 3 秒
ToastUtils.success('操作成功完成');

// 自定义样式
ToastUtils.custom(
  message: '自定义消息',
  color: Colors.purple,
  duration: Duration(seconds: 2),
);
```

### 方法说明

#### error(String message, {Duration? duration})
- **用途**: 显示错误信息
- **颜色**: 红色 (Colors.red.shade600)
- **默认持续时间**: 5 秒
- **使用场景**: 操作失败、系统错误、验证失败等

#### warn(String message, {Duration? duration})
- **用途**: 显示警告信息
- **颜色**: 橙色 (Colors.orange.shade600)
- **默认持续时间**: 4 秒
- **使用场景**: 网络问题、权限不足、配置问题等

#### info(String message, {Duration? duration})
- **用途**: 显示一般信息
- **颜色**: 蓝色 (Colors.blue.shade600)
- **默认持续时间**: 3 秒
- **使用场景**: 状态更新、提示信息、进度通知等

#### success(String message, {Duration? duration})
- **用途**: 显示成功信息
- **颜色**: 绿色 (Colors.green.shade600)
- **默认持续时间**: 3 秒
- **使用场景**: 操作成功、保存完成、连接成功等

#### custom({required String message, required Color color, Duration? duration, Alignment? align, TextStyle? textStyle})
- **用途**: 显示自定义样式的 toast
- **参数**: 完全自定义所有样式属性
- **使用场景**: 需要特殊样式的场合

### 特性

- 🎨 **颜色编码**: 不同级别使用不同颜色，便于用户快速识别
- ⏱️ **智能持续时间**: 根据消息重要性自动调整显示时间
- 📱 **响应式设计**: 自动适配不同屏幕尺寸
- 🔧 **高度可定制**: 支持自定义样式和行为
- 🌍 **国际化友好**: 支持中文和其他语言

### 注意事项

1. 确保在 `main.dart` 中已正确配置 BotToast
2. 所有 toast 默认显示在屏幕顶部中央，距离顶部边缘有适当间距
3. 文字样式统一为白色，字体大小 14px，中等粗细
4. 建议根据消息重要性选择合适的级别

### 位置说明

Toast 通知使用 `Alignment(0.0, -0.8)` 定位：
- `0.0` 表示水平居中
- `-0.8` 表示垂直方向靠近顶部，但保持适当距离
- 这样既不会被状态栏遮挡，也不会紧贴屏幕边缘 