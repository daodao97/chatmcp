#!/bin/bash

# 脚本用于诊断构建问题
# 使用方法: ./scripts/diagnose_build_issues.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}ChatMcp 构建问题诊断工具${NC}"
echo "=============================================="

# 1. 检查Flutter环境
echo -e "\n${YELLOW}1. 检查Flutter环境...${NC}"
flutter --version
echo

# 2. 检查Android配置对其他平台的影响
echo -e "${YELLOW}2. 检查Android配置...${NC}"

if [ -f "android/app/build.gradle.kts" ]; then
    echo "✅ 找到Android构建配置"
    
    # 检查是否有可能影响其他平台的配置
    if grep -q "flutter.compileSdkVersion" android/app/build.gradle.kts; then
        echo "✅ 使用Flutter标准配置"
    else
        echo "⚠️  可能使用了自定义配置"
    fi
else
    echo "❌ 未找到Android构建配置"
fi

# 3. 检查pubspec.yaml
echo -e "\n${YELLOW}3. 检查依赖配置...${NC}"
if grep -q "platform" pubspec.yaml; then
    echo "ℹ️  发现平台特定配置:"
    grep -A 5 -B 5 "platform" pubspec.yaml || true
fi

# 4. 模拟GitHub Actions环境
echo -e "\n${YELLOW}4. 模拟GitHub Actions环境测试...${NC}"

# 4.1 测试无Android环境的构建
echo -e "\n${BLUE}4.1 测试无Android环境时的行为...${NC}"
unset ANDROID_HOME
unset ANDROID_SDK_ROOT
unset JAVA_HOME

# 清理并重新获取依赖
echo "清理项目..."
flutter clean > /dev/null 2>&1
echo "获取依赖..."
flutter pub get > /dev/null 2>&1

# 检查可用的构建目标
echo -e "\n可用的构建目标:"
flutter build --help | grep -A 10 "Available subcommands:" | grep "^  " || true

# 4.2 测试Web构建（所有平台都支持）
echo -e "\n${BLUE}4.2 测试Web构建...${NC}"
if flutter build web --release > /tmp/web_build.log 2>&1; then
    echo "✅ Web构建成功"
else
    echo "❌ Web构建失败"
    echo "错误信息:"
    tail -10 /tmp/web_build.log
fi

# 5. 检查GitHub Actions配置
echo -e "\n${YELLOW}5. 检查GitHub Actions配置...${NC}"
if [ -f ".github/workflows/build.yml" ]; then
    echo "✅ 找到GitHub Actions配置"
    
    # 检查Linux构建配置
    if grep -q "ubuntu-latest" .github/workflows/build.yml; then
        echo "✅ 包含Linux构建配置"
        
        # 检查Android签名步骤是否正确隔离
        if grep -A 5 -B 5 "Setup Android Signing" .github/workflows/build.yml | grep -q "matrix.apk_build"; then
            echo "✅ Android签名配置已正确隔离到Android构建"
        else
            echo "⚠️  Android签名配置可能影响其他平台"
        fi
    else
        echo "❌ 未找到Linux构建配置"
    fi
else
    echo "❌ 未找到GitHub Actions配置"
fi

# 6. 检查潜在的配置冲突
echo -e "\n${YELLOW}6. 检查潜在的配置冲突...${NC}"

# 检查是否有全局的Android配置影响
if [ -f "android/gradle.properties" ]; then
    echo "ℹ️  Android gradle.properties内容:"
    grep -v "^#" android/gradle.properties | grep -v "^$" || true
    
    # 检查是否有可能影响其他平台的配置
    if grep -q "systemProp" android/gradle.properties; then
        echo "⚠️  发现系统属性配置，可能影响其他构建"
    fi
fi

# 7. 生成诊断报告
echo -e "\n${BLUE}7. 诊断总结${NC}"
echo "=============================================="

# 检查可能的问题
ISSUES_FOUND=0

if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter未正确安装"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

if [ ! -f ".github/workflows/build.yml" ]; then
    echo "❌ 缺少GitHub Actions配置"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ 未发现明显的配置问题${NC}"
    echo
    echo "如果Linux构建在GitHub Actions中失败，请："
    echo "1. 检查GitHub Actions的构建日志"
    echo "2. 确认所有GitHub Secrets已正确配置"
    echo "3. 验证依赖版本兼容性"
else
    echo -e "${RED}❌ 发现 $ISSUES_FOUND 个问题需要解决${NC}"
fi

echo
echo -e "${YELLOW}如需进一步诊断，请提供以下信息：${NC}"
echo "- GitHub Actions构建失败的具体错误日志"
echo "- 失败发生在哪个构建步骤"
echo "- 是否只有Linux构建失败，还是所有平台都失败" 