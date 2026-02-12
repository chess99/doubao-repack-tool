#!/bin/bash

# 豆包扩展一键重新打包脚本
# 用途：解决兼容性问题，生成新的扩展 ID
# 作者：Claude
# 日期：2026-02-12

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# 显示帮助信息
show_help() {
    cat << EOF
豆包扩展一键重新打包脚本
========================

用途：
  将豆包扩展重新打包，生成新的扩展 ID，解决兼容性问题限制

用法：
  $0 [选项]

选项：
  -h, --help              显示此帮助信息
  -o, --output DIR        指定输出目录（默认：./doubao_custom）
  -n, --name NAME         自定义扩展名称（默认：豆包助手 (自定义版)）
  -v, --version VERSION   自定义版本号（默认：在原版本基础上 +0.0.1）
  --keep-update          保留自动更新（默认：移除）

示例：
  $0                                          # 使用默认设置
  $0 -o ~/my_doubao                 # 指定输出目录
  $0 -n "我的豆包" -v "2.0.0"                  # 自定义名称和版本

EOF
}

# 默认配置
CHROME_EXT_DIR="$HOME/Library/Application Support/Google/Chrome/Default/Extensions"
DOUBAO_EXT_ID="dbjibobgilijgolhjdcbdebjhejelffo"
OUTPUT_DIR="$(cd "$(dirname "$0")" && pwd)/doubao_custom"
CUSTOM_NAME="豆包助手 (自定义版)"
CUSTOM_VERSION=""
KEEP_UPDATE=false

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -n|--name)
            CUSTOM_NAME="$2"
            shift 2
            ;;
        -v|--version)
            CUSTOM_VERSION="$2"
            shift 2
            ;;
        --keep-update)
            KEEP_UPDATE=true
            shift
            ;;
        *)
            print_error "未知选项: $1"
            echo "使用 -h 或 --help 查看帮助"
            exit 1
            ;;
    esac
done

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║        豆包扩展一键重新打包工具                            ║"
echo "║        Doubao Extension Repackager                         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# 1. 检查豆包扩展是否存在
print_info "正在查找豆包扩展..."
DOUBAO_PATH="$CHROME_EXT_DIR/$DOUBAO_EXT_ID"

if [ ! -d "$DOUBAO_PATH" ]; then
    print_error "未找到豆包扩展！"
    print_info "请确保已安装豆包扩展，或者扩展 ID 已更改"
    print_info "扩展目录: $DOUBAO_PATH"
    exit 1
fi

# 2. 查找最新版本
print_info "正在查找最新版本..."
LATEST_VERSION=$(ls -t "$DOUBAO_PATH" | head -1)

if [ -z "$LATEST_VERSION" ]; then
    print_error "未找到扩展版本目录！"
    exit 1
fi

SOURCE_PATH="$DOUBAO_PATH/$LATEST_VERSION"
print_success "找到版本: $LATEST_VERSION"
print_info "源路径: $SOURCE_PATH"

# 3. 检查 manifest.json
MANIFEST_PATH="$SOURCE_PATH/manifest.json"
if [ ! -f "$MANIFEST_PATH" ]; then
    print_error "未找到 manifest.json 文件！"
    exit 1
fi

# 4. 读取原始版本号
ORIGINAL_VERSION=$(python3 << EOF
import json
try:
    with open('$MANIFEST_PATH', 'r') as f:
        manifest = json.load(f)
    print(manifest.get('version', '1.0.0'))
except:
    print('1.0.0')
EOF
)

print_info "原始版本号: $ORIGINAL_VERSION"

# 5. 计算新版本号（如果未指定）
if [ -z "$CUSTOM_VERSION" ]; then
    CUSTOM_VERSION=$(python3 << EOF
version = '$ORIGINAL_VERSION'
parts = version.split('.')
if len(parts) >= 3:
    parts[2] = str(int(parts[2]) + 1)
else:
    parts.append('1')
print('.'.join(parts))
EOF
)
fi

print_info "新版本号: $CUSTOM_VERSION"

# 6. 创建输出目录
print_info "正在创建输出目录..."
if [ -d "$OUTPUT_DIR" ]; then
    print_warning "输出目录已存在: $OUTPUT_DIR"
    read -p "是否覆盖? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "已取消操作"
        exit 0
    fi
    rm -rf "$OUTPUT_DIR"
fi

mkdir -p "$OUTPUT_DIR"
print_success "已创建输出目录: $OUTPUT_DIR"

# 7. 复制扩展文件
print_info "正在复制扩展文件..."
cp -r "$SOURCE_PATH/"* "$OUTPUT_DIR/"
print_success "文件复制完成"

# 8. 删除元数据目录
if [ -d "$OUTPUT_DIR/_metadata" ]; then
    rm -rf "$OUTPUT_DIR/_metadata"
    print_success "已删除 _metadata 目录"
fi

# 9. 修改 manifest.json
print_info "正在修改 manifest.json..."

python3 << EOF
import json
import sys

manifest_path = '$OUTPUT_DIR/manifest.json'

try:
    # 读取原始 manifest
    with open(manifest_path, 'r', encoding='utf-8') as f:
        manifest = json.load(f)

    # 移除 key（生成新的扩展 ID）
    if 'key' in manifest:
        del manifest['key']
        print('  ✓ 已移除 "key" 字段（将生成新的扩展 ID）')

    # 移除 update_url（防止自动更新）
    if not $KEEP_UPDATE:
        if 'update_url' in manifest:
            del manifest['update_url']
            print('  ✓ 已移除 "update_url" 字段（防止自动更新）')

    # 修改名称
    manifest['name'] = '$CUSTOM_NAME'
    print('  ✓ 已修改名称为: $CUSTOM_NAME')

    # 修改描述
    manifest['description'] = '豆包 AI 助手 - 自定义重新打包版本'
    print('  ✓ 已修改描述')

    # 修改版本号
    manifest['version'] = '$CUSTOM_VERSION'
    print('  ✓ 已修改版本号为: $CUSTOM_VERSION')

    # 保存修改
    with open(manifest_path, 'w', encoding='utf-8') as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)

    print('  ✓ manifest.json 修改完成')

except Exception as e:
    print(f'错误: {e}', file=sys.stderr)
    sys.exit(1)
EOF

if [ $? -ne 0 ]; then
    print_error "修改 manifest.json 失败！"
    exit 1
fi

print_success "manifest.json 修改完成"

# 10. 创建安装说明
print_info "正在创建安装说明..."

cat > "$OUTPUT_DIR/README.txt" << EOF
豆包助手 - 自定义重新打包版本
==========================================

这是豆包浏览器 AI 助手的重新打包版本，用于解决兼容性问题限制。

基本信息：
---------
扩展名称: $CUSTOM_NAME
版本号: $CUSTOM_VERSION
原始版本: $ORIGINAL_VERSION
打包时间: $(date '+%Y-%m-%d %H:%M:%S')
原扩展 ID: $DOUBAO_EXT_ID (已移除，将生成新 ID)

关键修改：
---------
✓ 移除了 "key" 字段 - Chrome 将生成新的扩展 ID
$(if [ "$KEEP_UPDATE" = false ]; then echo "✓ 移除了 \"update_url\" - 防止自动更新回原版"; fi)
✓ 修改了名称和描述 - 便于识别
✓ 更新了版本号

安装步骤：
---------
1. 打开 Chrome 浏览器
2. 访问 chrome://extensions/
3. 打开右上角的 "开发者模式" 开关
4. 点击 "加载已解压的扩展程序"
5. 选择这个文件夹：$OUTPUT_DIR
6. 扩展将会以新的 ID 安装，不受原有使用限制

注意事项：
---------
• 新扩展 ID 将会不同于原版
$(if [ "$KEEP_UPDATE" = false ]; then echo "• 不会自动更新，需要手动更新"; fi)
• 可以与原版共存（如果需要）
• 所有功能应该正常工作

更新方法：
---------
当豆包官方有新版本时，重新运行打包脚本即可：
  $0

如果遇到问题：
-------------
• 确保开发者模式已开启
• 检查是否有错误提示
• 可以打开开发者工具查看控制台错误

技术支持：
---------
这是一个自动化脚本生成的重新打包版本。
如需重新打包，请运行：$0
EOF

print_success "安装说明已创建"

# 11. 显示摘要
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                    打包完成！                              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
print_success "扩展已成功重新打包！"
echo ""
echo "📦 打包信息："
echo "   原始版本: $ORIGINAL_VERSION"
echo "   新版本号: $CUSTOM_VERSION"
echo "   扩展名称: $CUSTOM_NAME"
echo ""
echo "📁 输出位置："
echo "   $OUTPUT_DIR"
echo ""
echo "📝 安装步骤："
echo "   1. 打开 Chrome 浏览器"
echo "   2. 访问 chrome://extensions/"
echo "   3. 开启 '开发者模式'"
echo "   4. 点击 '加载已解压的扩展程序'"
echo "   5. 选择上述输出目录"
echo ""
echo "🎯 优势："
echo "   • 新的扩展 ID，不受使用限制"
echo "   • 功能完全相同"
echo "   • 可以随时重新打包新版本"
echo ""

# 12. 询问是否打开目录
read -p "是否打开输出目录? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    open "$OUTPUT_DIR"
    print_success "已打开输出目录"
fi

echo ""
print_success "完成！祝使用愉快 🎉"
echo ""
