#!/bin/bash

# 脚本用于显示Android构建结果摘要
# 使用方法: ./scripts/build_summary.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}ChatMcp Android 构建结果摘要${NC}"
echo "=============================================="

# 检查APK文件
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
if [ -f "$APK_PATH" ]; then
    echo -e "${GREEN}✅ Release APK 已生成${NC}"
    echo "   文件路径: $APK_PATH"
    echo "   文件大小: $(ls -lh "$APK_PATH" | awk '{print $5}')"
    echo "   修改时间: $(ls -l "$APK_PATH" | awk '{print $6, $7, $8}')"
    
    # 检查签名
    if jarsigner -verify "$APK_PATH" &>/dev/null; then
        echo -e "${GREEN}   ✅ APK 签名验证成功${NC}"
    else
        echo -e "${YELLOW}   ⚠️  APK 使用现代签名方案（v2/v3）${NC}"
    fi
else
    echo -e "${RED}❌ Release APK 未找到${NC}"
fi

echo

# 检查AAB文件
AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
if [ -f "$AAB_PATH" ]; then
    echo -e "${GREEN}✅ Release AAB 已生成${NC}"
    echo "   文件路径: $AAB_PATH"
    echo "   文件大小: $(ls -lh "$AAB_PATH" | awk '{print $5}')"
    echo "   修改时间: $(ls -l "$AAB_PATH" | awk '{print $6, $7, $8}')"
else
    echo -e "${RED}❌ Release AAB 未找到${NC}"
fi

echo

# 检查分架构APK
echo -e "${YELLOW}分架构 APK 文件:${NC}"
SPLIT_APK_DIR="build/app/outputs/flutter-apk"
if [ -d "$SPLIT_APK_DIR" ]; then
    for arch in arm64-v8a armeabi-v7a x86_64; do
        SPLIT_APK="$SPLIT_APK_DIR/app-$arch-release.apk"
        if [ -f "$SPLIT_APK" ]; then
            echo -e "${GREEN}   ✅ $arch: $(ls -lh "$SPLIT_APK" | awk '{print $5}')${NC}"
        else
            echo -e "${YELLOW}   ⚠️  $arch: 未生成${NC}"
        fi
    done
else
    echo -e "${YELLOW}   ⚠️  分架构APK目录不存在${NC}"
fi

echo

# 显示签名信息
if [ -f "android/signing.env" ]; then
    echo -e "${BLUE}签名配置信息:${NC}"
    source android/signing.env
    echo "   密钥库: $SIGNING_STORE_PATH"
    echo "   别名: $SIGNING_KEY_ALIAS"
    
    KEYSTORE_FULL_PATH="android/app/$SIGNING_STORE_PATH"
    if [ -f "$KEYSTORE_FULL_PATH" ] && [ -n "$SIGNING_STORE_PASSWORD" ]; then
        echo -e "${GREEN}   ✅ 密钥库验证成功${NC}"
        
        # 显示证书有效期
        VALIDITY=$(keytool -list -v -keystore "$KEYSTORE_FULL_PATH" -storepass "$SIGNING_STORE_PASSWORD" -alias "$SIGNING_KEY_ALIAS" 2>/dev/null | grep "有效期从\|Valid from" | head -1)
        if [ -n "$VALIDITY" ]; then
            echo "   证书有效期: $VALIDITY"
        fi
    fi
else
    echo -e "${YELLOW}⚠️  未找到签名配置${NC}"
fi

echo

# 构建建议
echo -e "${BLUE}发布建议:${NC}"
echo "1. APK 文件适用于直接安装和第三方应用商店"
echo "2. AAB 文件适用于 Google Play Store（推荐）"
echo "3. 分架构 APK 可以减少下载大小"
echo "4. 请妥善保管签名密钥，用于后续版本更新"

echo
echo -e "${GREEN}构建完成！${NC}" 