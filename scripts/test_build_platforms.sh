#!/bin/bash

# 脚本用于测试不同平台的构建
# 使用方法: ./scripts/test_build_platforms.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}ChatMcp 多平台构建测试${NC}"
echo "=============================================="

# 获取当前平台
PLATFORM=$(uname -s)
echo "当前平台: $PLATFORM"

# 清理构建缓存
echo -e "\n${YELLOW}清理构建缓存...${NC}"
flutter clean
flutter pub get

# 测试可用的构建目标
echo -e "\n${YELLOW}检查可用的构建目标...${NC}"
flutter build --help | grep "Available subcommands:" -A 20

echo -e "\n${BLUE}开始平台构建测试...${NC}"

# 根据平台测试不同的构建目标
case $PLATFORM in
  "Darwin")
    echo -e "\n${YELLOW}测试 macOS 构建...${NC}"
    if flutter build macos --release --no-tree-shake-icons; then
        echo -e "${GREEN}✅ macOS 构建成功${NC}"
    else
        echo -e "${RED}❌ macOS 构建失败${NC}"
    fi
    
    echo -e "\n${YELLOW}测试 iOS 构建...${NC}"
    if flutter build ios --release --no-tree-shake-icons --no-codesign; then
        echo -e "${GREEN}✅ iOS 构建成功${NC}"
    else
        echo -e "${RED}❌ iOS 构建失败${NC}"
    fi
    ;;
    
  "Linux")
    echo -e "\n${YELLOW}测试 Linux 构建...${NC}"
    if flutter build linux --release --no-tree-shake-icons; then
        echo -e "${GREEN}✅ Linux 构建成功${NC}"
    else
        echo -e "${RED}❌ Linux 构建失败${NC}"
    fi
    ;;
    
  "MINGW"* | "CYGWIN"* | "MSYS"*)
    echo -e "\n${YELLOW}测试 Windows 构建...${NC}"
    if flutter build windows --release --no-tree-shake-icons; then
        echo -e "${GREEN}✅ Windows 构建成功${NC}"
    else
        echo -e "${RED}❌ Windows 构建失败${NC}"
    fi
    ;;
esac

# 测试 Web 构建（所有平台都支持）
echo -e "\n${YELLOW}测试 Web 构建...${NC}"
if flutter build web --release --no-tree-shake-icons; then
    echo -e "${GREEN}✅ Web 构建成功${NC}"
else
    echo -e "${RED}❌ Web 构建失败${NC}"
fi

# 测试 Android 构建（如果环境支持）
if command -v java &> /dev/null && [ -n "$ANDROID_SDK_ROOT" ] || [ -n "$ANDROID_HOME" ]; then
    echo -e "\n${YELLOW}测试 Android 构建...${NC}"
    
    # 检查是否有签名配置
    if [ -f "android/signing.env" ]; then
        echo -e "${GREEN}发现签名配置，设置环境变量...${NC}"
        export $(cat android/signing.env | grep -v '^#' | xargs)
    else
        echo -e "${YELLOW}未发现签名配置，使用 debug 签名...${NC}"
    fi
    
    if flutter build apk --release --no-tree-shake-icons; then
        echo -e "${GREEN}✅ Android APK 构建成功${NC}"
    else
        echo -e "${RED}❌ Android APK 构建失败${NC}"
    fi
    
    if flutter build appbundle --release --no-tree-shake-icons; then
        echo -e "${GREEN}✅ Android AAB 构建成功${NC}"
    else
        echo -e "${RED}❌ Android AAB 构建失败${NC}"
    fi
else
    echo -e "\n${YELLOW}跳过 Android 构建（Java 或 Android SDK 未配置）${NC}"
fi

echo -e "\n${BLUE}构建测试完成！${NC}"

# 显示构建产物大小
echo -e "\n${YELLOW}构建产物信息:${NC}"
if [ -d "build" ]; then
    find build -name "*.apk" -o -name "*.aab" -o -name "*.app" -o -name "*.exe" -o -name "*.dmg" -o -name "*.tar.gz" -o -name "*.zip" 2>/dev/null | while read file; do
        if [ -f "$file" ]; then
            size=$(du -h "$file" | cut -f1)
            echo "  $file: $size"
        fi
    done
else
    echo "  无构建产物"
fi 