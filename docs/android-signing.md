# Android 应用签名配置指南

本文档介绍如何为 ChatMcp Android 应用配置签名，以便发布到 Google Play Store 或其他应用商店。

## 📋 目录

- [本地开发环境配置](#本地开发环境配置)
- [GitHub Actions 配置](#github-actions-配置)
- [签名验证](#签名验证)
- [常见问题](#常见问题)

## 🔧 本地开发环境配置

### 1. 生成签名密钥

运行以下命令生成签名密钥：

```bash
./scripts/create_keystore.sh
```

脚本会引导您完成以下步骤：
- 输入密钥库文件名（默认：`chatmcp-release-key.jks`）
- 输入密钥别名（默认：`chatmcp`）
- 设置密钥库密码和密钥密码
- 输入证书信息（姓名、组织等）

### 2. 配置环境变量

脚本会自动创建 `android/signing.env` 文件，包含以下配置：

```bash
SIGNING_STORE_PATH=keystore/chatmcp-release-key.jks
SIGNING_KEY_ALIAS=chatmcp
SIGNING_STORE_PASSWORD=your_store_password
SIGNING_KEY_PASSWORD=your_key_password
```

### 3. 本地构建签名 APK

```bash
# 构建签名的 APK
flutter build apk --release

# 构建签名的 App Bundle（推荐用于 Google Play）
flutter build appbundle --release
```

## 🚀 GitHub Actions 配置

### 1. 设置 GitHub Secrets

在您的 GitHub 仓库中，转到 `Settings` > `Secrets and variables` > `Actions`，添加以下 secrets：

| Secret 名称 | 描述 | 示例值 |
|------------|------|--------|
| `SIGNING_KEYSTORE` | 密钥库文件的 base64 编码 | `MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC...` |
| `SIGNING_KEY_ALIAS` | 密钥别名 | `chatmcp` |
| `SIGNING_STORE_PASSWORD` | 密钥库密码 | `your_store_password` |
| `SIGNING_KEY_PASSWORD` | 密钥密码 | `your_key_password` |

### 2. 生成密钥库的 base64 编码

根据您的操作系统，使用以下命令之一：

**macOS:**
```bash
base64 -i android/app/keystore/chatmcp-release-key.jks | pbcopy
```

**Linux:**
```bash
base64 -w 0 android/app/keystore/chatmcp-release-key.jks | xclip -selection clipboard
```

**Windows:**
```cmd
certutil -encode android/app/keystore/chatmcp-release-key.jks temp.base64 && type temp.base64 | clip && del temp.base64
```

### 3. 触发构建

GitHub Actions 会在以下情况下自动构建签名的 Android 应用：

- 推送带有 `v*` 标签的提交（如 `v1.0.0`）
- 手动触发工作流程

构建完成后，您可以在以下位置找到文件：
- **Artifacts**: 每次构建的临时文件
- **Releases**: 标签构建的正式发布文件

## ✅ 签名验证

### 验证 APK 签名

使用以下命令验证 APK 是否正确签名：

```bash
# 查看 APK 签名信息
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk

# 验证 APK 签名
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk
```

### 验证 App Bundle 签名

```bash
# 使用 bundletool 验证 AAB 文件
java -jar bundletool.jar validate --bundle=build/app/outputs/bundle/release/app-release.aab
```

## 🔒 安全最佳实践

1. **密钥安全**：
   - 将密钥库文件保存在安全的位置
   - 定期备份密钥库文件
   - 不要将密钥库文件提交到版本控制系统

2. **密码管理**：
   - 使用强密码
   - 将密码存储在安全的密码管理器中
   - 定期更换密码

3. **访问控制**：
   - 限制对 GitHub Secrets 的访问权限
   - 定期审查有权访问签名密钥的人员

## 🛠️ 常见问题

### Q: 构建时提示 "签名配置不完整"

**A**: 检查以下项目：
- 确保所有 GitHub Secrets 都已正确设置
- 验证密钥库文件的 base64 编码是否正确
- 确认密钥别名和密码是否匹配

### Q: 如何更新签名密钥？

**A**: 
1. 生成新的密钥库文件
2. 更新 GitHub Secrets 中的相关值
3. 重新构建应用

**注意**: 更换签名密钥后，用户需要卸载旧版本才能安装新版本。

### Q: 如何为不同环境使用不同的签名？

**A**: 可以创建多个构建变体：
- `debug`: 使用调试签名
- `release`: 使用发布签名
- `staging`: 使用测试签名

### Q: App Bundle 和 APK 有什么区别？

**A**: 
- **APK**: 传统的 Android 应用包格式，包含所有架构的代码
- **App Bundle**: Google 推荐的格式，支持动态交付，用户只下载适合其设备的代码

## 📚 相关资源

- [Android 应用签名官方文档](https://developer.android.com/studio/publish/app-signing)
- [Flutter Android 构建文档](https://docs.flutter.dev/deployment/android)
- [Google Play 发布指南](https://developer.android.com/distribute/googleplay)

## 🆘 获取帮助

如果您在配置过程中遇到问题，请：

1. 检查本文档的常见问题部分
2. 查看 GitHub Actions 的构建日志
3. 在项目仓库中创建 Issue

---

**重要提醒**: 请妥善保管您的签名密钥，丢失密钥将导致无法更新已发布的应用！ 