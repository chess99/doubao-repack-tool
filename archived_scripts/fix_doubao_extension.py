#!/usr/bin/env python3
"""
持续修复豆包扩展被禁用的问题
这个脚本会监控 Chrome 配置文件并自动移除禁用状态
"""

import json
import time
import os
import signal
import sys

CHROME_PROFILE = '$HOME/Library/Application Support/Google/Chrome/Default'
SECURE_PREF_FILE = f'{CHROME_PROFILE}/Secure Preferences'
PREF_FILE = f'{CHROME_PROFILE}/Preferences'
EXTENSION_ID = 'dbjibobgilijgolhjdcbdebjhejelffo'

def signal_handler(sig, frame):
    print('\n脚本已停止')
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)

def fix_extension():
    """修复扩展状态"""
    try:
        # 读取 Secure Preferences
        with open(SECURE_PREF_FILE, 'r') as f:
            secure_prefs = json.load(f)

        # 检查扩展状态
        if 'extensions' in secure_prefs and 'settings' in secure_prefs['extensions']:
            ext_settings = secure_prefs['extensions']['settings']

            if EXTENSION_ID in ext_settings:
                doubao = ext_settings[EXTENSION_ID]

                # 检查是否需要修复
                needs_fix = False

                if doubao.get('disable_reasons', []):
                    doubao['disable_reasons'] = []
                    needs_fix = True

                if not doubao.get('active_bit', False):
                    doubao['active_bit'] = True
                    needs_fix = True

                if 'account_extension_type' in doubao:
                    del doubao['account_extension_type']
                    needs_fix = True

                if needs_fix:
                    # 保存修改
                    with open(SECURE_PREF_FILE, 'w') as f:
                        json.dump(secure_prefs, f)
                    print(f'[{time.strftime("%H:%M:%S")}] 已修复扩展状态')
                    return True

        return False

    except Exception as e:
        print(f'错误: {e}')
        return False

def remove_supervised_mode():
    """移除监督模式配置"""
    try:
        with open(PREF_FILE, 'r') as f:
            prefs = json.load(f)

        needs_fix = False

        if 'profile' in prefs:
            if 'managed' in prefs['profile']:
                del prefs['profile']['managed']
                needs_fix = True

            if 'managed_user_id' in prefs['profile']:
                del prefs['profile']['managed_user_id']
                needs_fix = True

        if needs_fix:
            with open(PREF_FILE, 'w') as f:
                json.dump(prefs, f)
            print(f'[{time.strftime("%H:%M:%S")}] 已移除监督模式配置')
            return True

        return False

    except Exception as e:
        print(f'错误: {e}')
        return False

def main():
    print('豆包扩展修复脚本已启动')
    print('按 Ctrl+C 停止')
    print('-' * 50)

    # 首次修复
    fix_extension()
    remove_supervised_mode()

    # 持续监控
    while True:
        time.sleep(2)  # 每 2 秒检查一次

        fixed_ext = fix_extension()
        fixed_supervised = remove_supervised_mode()

        if not fixed_ext and not fixed_supervised:
            # 没有需要修复的，静默等待
            pass

if __name__ == '__main__':
    main()
