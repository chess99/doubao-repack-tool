#!/bin/bash

echo "=== 监控 Chrome 配置文件修改 ==="
echo "按 Ctrl+C 停止监控"
echo ""

PREF_FILE="$HOME/Library/Application Support/Google/Chrome/Default/Secure Preferences"

# 使用 fswatch 监控文件变化
if ! command -v fswatch &> /dev/null; then
    echo "正在安装 fswatch..."
    if command -v brew &> /dev/null; then
        brew install fswatch
    else
        echo "错误: 需要安装 Homebrew 或手动安装 fswatch"
        exit 1
    fi
fi

echo "开始监控: $PREF_FILE"
echo ""

fswatch -0 "$PREF_FILE" | while read -d "" event; do
    echo "[$(date '+%H:%M:%S')] 文件被修改！"

    # 查找哪个进程在访问这个文件
    echo "正在查找访问进程..."
    lsof "$PREF_FILE" 2>/dev/null | grep -v COMMAND

    # 检查扩展状态
    python3 << 'PYTHON_EOF'
import json
try:
    with open('$HOME/Library/Application Support/Google/Chrome/Default/Secure Preferences', 'r') as f:
        prefs = json.load(f)
    doubao = prefs.get('extensions', {}).get('settings', {}).get('dbjibobgilijgolhjdcbdebjhejelffo', {})
    print(f"  disable_reasons: {doubao.get('disable_reasons', [])}")
    print(f"  active_bit: {doubao.get('active_bit', False)}")
except Exception as e:
    print(f"  错误: {e}")
PYTHON_EOF

    echo ""
done
