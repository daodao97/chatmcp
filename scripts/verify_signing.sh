#!/bin/bash

# 脚本用于验证Android签名配置
# 使用方法: ./scripts/verify_signing.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}ChatMcp Android 签名配置验证工具${NC}"
echo "=============================================="

# 检查必要工具
echo -e "${YELLOW}检查必要工具...${NC}"

if ! command -v keytool &> /dev/null; then
    echo -e "${RED}❌ keytool 未找到。请确保已安装 Java JDK。${NC}"
    exit 1
else
    echo -e "${GREEN}✅ keytool 已安装${NC}"
fi

if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter 未找到。请确保已安装 Flutter SDK。${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Flutter 已安装${NC}"
    flutter --version | head -1
fi

# 检查签名配置文件
echo -e "\n${YELLOW}检查签名配置...${NC}"

if [ -f "android/signing.env" ]; then
    echo -e "${GREEN}✅ 找到签名配置文件: android/signing.env${NC}"
    
    # 读取配置
    source android/signing.env
    
    if [ -n "$SIGNING_STORE_PATH" ] && [ -n "$SIGNING_KEY_ALIAS" ]; then
        echo -e "${GREEN}✅ 签名配置变量已设置${NC}"
        echo "   - 密钥库路径: $SIGNING_STORE_PATH"
        echo "   - 密钥别名: $SIGNING_KEY_ALIAS"
        
        # 检查密钥库文件
        KEYSTORE_FULL_PATH="android/app/$SIGNING_STORE_PATH"
        if [ -f "$KEYSTORE_FULL_PATH" ]; then
            echo -e "${GREEN}✅ 密钥库文件存在: $KEYSTORE_FULL_PATH${NC}"
            
            # 验证密钥库
            if [ -n "$SIGNING_STORE_PASSWORD" ]; then
                echo -e "${YELLOW}验证密钥库...${NC}"
                if keytool -list -keystore "$KEYSTORE_FULL_PATH" -storepass "$SIGNING_STORE_PASSWORD" -alias "$SIGNING_KEY_ALIAS" &>/dev/null; then
                    echo -e "${GREEN}✅ 密钥库验证成功${NC}"
                    
                    # 显示证书信息
                    echo -e "\n${BLUE}证书信息:${NC}"
                    keytool -list -v -keystore "$KEYSTORE_FULL_PATH" -storepass "$SIGNING_STORE_PASSWORD" -alias "$SIGNING_KEY_ALIAS" | grep -E "(别名|Owner|有效期|证书指纹|Alias|Owner|Valid|Certificate fingerprints)"
                else
                    echo -e "${RED}❌ 密钥库验证失败，请检查密码或别名${NC}"
                fi
            else
                echo -e "${YELLOW}⚠️  未设置密钥库密码，跳过验证${NC}"
            fi
        else
            echo -e "${RED}❌ 密钥库文件不存在: $KEYSTORE_FULL_PATH${NC}"
        fi
    else
        echo -e "${RED}❌ 签名配置变量未完整设置${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  未找到签名配置文件，将使用 debug 签名${NC}"
    echo "   运行 ./scripts/create_keystore.sh 来创建签名配置"
fi

# 检查 gradle 配置
echo -e "\n${YELLOW}检查 Gradle 配置...${NC}"

if grep -q "signingConfigs" android/app/build.gradle.kts; then
    echo -e "${GREEN}✅ Gradle 签名配置已添加${NC}"
else
    echo -e "${RED}❌ Gradle 签名配置未找到${NC}"
fi

# 检查 .gitignore
echo -e "\n${YELLOW}检查 .gitignore 配置...${NC}"

if grep -q "android/app/keystore/" .gitignore; then
    echo -e "${GREEN}✅ 密钥库目录已添加到 .gitignore${NC}"
else
    echo -e "${YELLOW}⚠️  建议将 android/app/keystore/ 添加到 .gitignore${NC}"
fi

if grep -q "android/signing.env" .gitignore; then
    echo -e "${GREEN}✅ 签名配置文件已添加到 .gitignore${NC}"
else
    echo -e "${YELLOW}⚠️  建议将 android/signing.env 添加到 .gitignore${NC}"
fi

# 测试构建（可选）
echo -e "\n${YELLOW}是否要测试构建 APK？(y/N): ${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${BLUE}开始测试构建...${NC}"
    
    # 设置环境变量
    if [ -f "android/signing.env" ]; then
        export $(cat android/signing.env | grep -v '^#' | xargs)
    fi
    
    # 构建 APK
    if flutter build apk --release; then
        echo -e "${GREEN}✅ APK 构建成功${NC}"
        
        # 检查输出文件
        APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
        if [ -f "$APK_PATH" ]; then
            echo -e "${GREEN}✅ APK 文件已生成: $APK_PATH${NC}"
            
            # 显示 APK 信息
            echo -e "\n${BLUE}APK 信息:${NC}"
            ls -lh "$APK_PATH"
            
            # 验证签名
            echo -e "\n${BLUE}验证 APK 签名:${NC}"
            if jarsigner -verify "$APK_PATH" &>/dev/null; then
                echo -e "${GREEN}✅ APK 签名验证成功${NC}"
            else
                echo -e "${RED}❌ APK 签名验证失败${NC}"
            fi
        else
            echo -e "${RED}❌ APK 文件未找到${NC}"
        fi
    else
        echo -e "${RED}❌ APK 构建失败${NC}"
    fi
fi

echo -e "\n${BLUE}验证完成！${NC}"
echo -e "${YELLOW}如需帮助，请查看文档: docs/android-signing.md${NC}" 