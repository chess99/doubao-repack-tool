#!/bin/bash

echo "=== 豆包扩展修复测试脚本 ==="
echo ""

# 1. 关闭 Chrome
echo "1. 关闭 Chrome..."
killall "Google Chrome" 2>/dev/null
killall "Google Chrome Canary" 2>/dev/null
sleep 2

# 2. 修复扩展状态
echo "2. 修复扩展状态..."
python3 << 'PYTHON_EOF'
import json
import os

secure_pref_file = '$HOME/Library/Application Support/Google/Chrome/Default/Secure Preferences'
pref_file = '$HOME/Library/Application Support/Google/Chrome/Default/Preferences'

# 修复 Secure Preferences
if os.path.exists(secure_pref_file):
    with open(secure_pref_file, 'r') as f:
        prefs = json.load(f)

    if 'extensions' in prefs and 'settings' in prefs['extensions']:
        doubao = prefs['extensions']['settings'].get('dbjibobgilijgolhjdcbdebjhejelffo', {})
        doubao['disable_reasons'] = []
        doubao['active_bit'] = True
        if 'account_extension_type' in doubao:
            del doubao['account_extension_type']
        if 'state' in doubao:
            doubao['state'] = 1  # ENABLED

    with open(secure_pref_file, 'w') as f:
        json.dump(prefs, f)
    print("✓ 已修复 Secure Preferences")

# 修复 Preferences
if os.path.exists(pref_file):
    with open(pref_file, 'r') as f:
        prefs = json.load(f)

    # 移除监督模式
    if 'profile' in prefs:
        if 'managed' in prefs['profile']:
            del prefs['profile']['managed']
        if 'managed_user_id' in prefs['profile']:
            del prefs['profile']['managed_user_id']

    with open(pref_file, 'w') as f:
        json.dump(prefs, f)
    print("✓ 已修复 Preferences")

PYTHON_EOF

# 3. 设置文件为只读（防止被修改）
echo "3. 设置配置文件为只读..."
chmod 444 "$HOME/Library/Application Support/Google/Chrome/Default/Secure Preferences"
chmod 444 "$HOME/Library/Application Support/Google/Chrome/Default/Preferences"
echo "✓ 配置文件已设置为只读"

# 4. 启动 Chrome
echo "4. 启动 Chrome..."
open -a "Google Chrome"

echo ""
echo "=== 完成 ==="
echo "请检查豆包扩展是否可以启用"
echo ""
echo "如果还是不行，5秒后将恢复文件权限..."
sleep 5

# 恢复文件权限
chmod 644 "$HOME/Library/Application Support/Google/Chrome/Default/Secure Preferences"
chmod 644 "$HOME/Library/Application Support/Google/Chrome/Default/Preferences"
echo "✓ 已恢复文件权限"
