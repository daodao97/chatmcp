#!/bin/bash

# 脚本用于创建Android应用签名密钥
# 使用方法: ./scripts/create_keystore.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}ChatMcp Android 签名密钥生成工具${NC}"
echo "=============================================="

# 检查是否安装了keytool
if ! command -v keytool &> /dev/null; then
    echo -e "${RED}错误: keytool 未找到。请确保已安装 Java JDK。${NC}"
    exit 1
fi

# 默认值
DEFAULT_KEYSTORE_NAME="chatmcp-release-key.jks"
DEFAULT_KEY_ALIAS="chatmcp"
DEFAULT_VALIDITY="10000"

# 获取用户输入
echo -e "${YELLOW}请输入以下信息（直接回车使用默认值）:${NC}"
echo

read -p "密钥库文件名 [${DEFAULT_KEYSTORE_NAME}]: " KEYSTORE_NAME
KEYSTORE_NAME=${KEYSTORE_NAME:-$DEFAULT_KEYSTORE_NAME}

read -p "密钥别名 [${DEFAULT_KEY_ALIAS}]: " KEY_ALIAS
KEY_ALIAS=${KEY_ALIAS:-$DEFAULT_KEY_ALIAS}

read -p "有效期（天数）[${DEFAULT_VALIDITY}]: " VALIDITY
VALIDITY=${VALIDITY:-$DEFAULT_VALIDITY}

read -s -p "密钥库密码: " STORE_PASSWORD
echo
read -s -p "确认密钥库密码: " STORE_PASSWORD_CONFIRM
echo

if [ "$STORE_PASSWORD" != "$STORE_PASSWORD_CONFIRM" ]; then
    echo -e "${RED}错误: 密码不匹配！${NC}"
    exit 1
fi

read -s -p "密钥密码 [与密钥库密码相同]: " KEY_PASSWORD
echo
if [ -z "$KEY_PASSWORD" ]; then
    KEY_PASSWORD=$STORE_PASSWORD
fi

echo
echo -e "${YELLOW}请输入证书信息:${NC}"
read -p "您的姓名 [ChatMcp]: " CN
CN=${CN:-"ChatMcp"}

read -p "组织单位 [IT Department]: " OU
OU=${OU:-"IT Department"}

read -p "组织名称 [ChatMcp Team]: " O
O=${O:-"ChatMcp Team"}

read -p "城市或地区 [Beijing]: " L
L=${L:-"Beijing"}

read -p "省份 [Beijing]: " ST
ST=${ST:-"Beijing"}

read -p "国家代码 [CN]: " C
C=${C:-"CN"}

# 创建密钥库目录
KEYSTORE_DIR="android/app/keystore"
mkdir -p $KEYSTORE_DIR

KEYSTORE_PATH="$KEYSTORE_DIR/$KEYSTORE_NAME"

echo
echo -e "${GREEN}正在生成密钥库...${NC}"

# 生成密钥库
keytool -genkey \
    -v \
    -keystore "$KEYSTORE_PATH" \
    -alias "$KEY_ALIAS" \
    -keyalg RSA \
    -keysize 2048 \
    -validity "$VALIDITY" \
    -storepass "$STORE_PASSWORD" \
    -keypass "$KEY_PASSWORD" \
    -dname "CN=$CN, OU=$OU, O=$O, L=$L, ST=$ST, C=$C"

echo
echo -e "${GREEN}密钥库创建成功！${NC}"
echo "文件位置: $KEYSTORE_PATH"
echo

# 创建环境变量配置文件
ENV_FILE="android/signing.env"
echo -e "${YELLOW}创建环境变量配置文件: $ENV_FILE${NC}"

cat > "$ENV_FILE" << EOF
# Android 应用签名配置
# 注意：这个文件包含敏感信息，不应该提交到版本控制系统

SIGNING_STORE_PATH=keystore/$KEYSTORE_NAME
SIGNING_KEY_ALIAS=$KEY_ALIAS
SIGNING_STORE_PASSWORD=$STORE_PASSWORD
SIGNING_KEY_PASSWORD=$KEY_PASSWORD
EOF

echo
echo -e "${GREEN}配置完成！${NC}"
echo -e "${YELLOW}重要提示:${NC}"
echo "1. 请将 android/signing.env 添加到 .gitignore 文件中"
echo "2. 请安全保存密钥库文件和密码"
echo "3. 在 GitHub Secrets 中添加以下变量："
echo "   - SIGNING_KEY_ALIAS: $KEY_ALIAS"
echo "   - SIGNING_STORE_PASSWORD: [您的密钥库密码]"
echo "   - SIGNING_KEY_PASSWORD: [您的密钥密码]"
echo "   - SIGNING_KEYSTORE: [密钥库文件的 base64 编码]"
echo
echo -e "${YELLOW}生成密钥库的 base64 编码:${NC}"
echo "base64 -i $KEYSTORE_PATH | pbcopy  # macOS"
echo "base64 -w 0 $KEYSTORE_PATH | xclip -selection clipboard  # Linux"
echo "certutil -encode $KEYSTORE_PATH temp.base64 && type temp.base64 | clip && del temp.base64  # Windows"
echo

# 添加到gitignore
if ! grep -q "android/signing.env" .gitignore 2>/dev/null; then
    echo "android/signing.env" >> .gitignore
    echo -e "${GREEN}已添加 android/signing.env 到 .gitignore${NC}"
fi

if ! grep -q "android/app/keystore/" .gitignore 2>/dev/null; then
    echo "android/app/keystore/" >> .gitignore
    echo -e "${GREEN}已添加 android/app/keystore/ 到 .gitignore${NC}"
fi

echo -e "${GREEN}安装完成！${NC}" 