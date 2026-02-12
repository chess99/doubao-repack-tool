#!/bin/bash

echo "=== 捕获恶意进程 ==="
echo "这个脚本会在文件被修改时立即捕获所有进程快照"
echo ""

PREF_FILE="$HOME/Library/Application Support/Google/Chrome/Default/Secure Preferences"
LOG_FILE="$HOME/malicious_process_log.txt"

echo "开始监控: $PREF_FILE" | tee -a "$LOG_FILE"
echo "日志文件: $LOG_FILE" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 安装 fswatch（如果需要）
if ! command -v fswatch &> /dev/null; then
    echo "正在安装 fswatch..."
    brew install fswatch 2>/dev/null || {
        echo "错误: 无法安装 fswatch，请手动安装: brew install fswatch"
        exit 1
    }
fi

# 监控文件修改
fswatch -0 "$PREF_FILE" | while read -d "" event; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$TIMESTAMP] 文件被修改！" | tee -a "$LOG_FILE"

    # 立即捕获所有进程（排除系统进程）
    echo "=== 进程快照 ===" | tee -a "$LOG_FILE"
    ps aux | grep -v "^_" | grep -v "^root" | grep -v "grep" | tee -a "$LOG_FILE"

    # 捕获最近执行的进程（通过 CPU 使用率排序）
    echo "" | tee -a "$LOG_FILE"
    echo "=== 最近活跃的进程（按 CPU 排序）===" | tee -a "$LOG_FILE"
    ps aux | sort -rk 3 | head -20 | tee -a "$LOG_FILE"

    # 检查是否有 Chrome 相关进程在写入
    echo "" | tee -a "$LOG_FILE"
    echo "=== Chrome 相关进程 ===" | tee -a "$LOG_FILE"
    ps aux | grep -i chrome | grep -v grep | tee -a "$LOG_FILE"

    # 检查是否有美团相关进程
    echo "" | tee -a "$LOG_FILE"
    echo "=== 美团相关进程 ===" | tee -a "$LOG_FILE"
    ps aux | grep -i meituan | grep -v grep | tee -a "$LOG_FILE"
    ps aux | grep -i moa | grep -v grep | tee -a "$LOG_FILE"

    # 检查扩展状态
    echo "" | tee -a "$LOG_FILE"
    echo "=== 扩展状态 ===" | tee -a "$LOG_FILE"
    python3 << 'PYTHON_EOF' | tee -a "$LOG_FILE"
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

    echo "========================================" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
done
