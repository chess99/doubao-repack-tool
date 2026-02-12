# 豆包扩展重新打包工具 - 项目说明

## 📁 项目结构

```
./
├── README.md                      # 详细使用指南
├── PROJECT_INFO.md               # 本文件 - 项目说明
├── QUICK_START.md                # 快速开始
├── repack_doubao.sh              # 主脚本
├── doubao_repack_v1.36.0/        # 已打包版本
└── archived_scripts/             # 归档的调试脚本
```

## 🎯 项目目的

提供一个便捷的工具，用于重新打包豆包浏览器扩展，生成新的扩展 ID。

## 🚀 快速开始

### 当前可用版本

已打包好的版本：`doubao_repack_v1.36.0/`

安装步骤：
1. 打开 `chrome://extensions/`
2. 开启"开发者模式"
3. 点击"加载已解压的扩展程序"
4. 选择 `./doubao_repack_v1.36.0/`

### 重新打包新版本

```bash
cd .
./repack_doubao.sh
```

## 📝 主要文件说明

### repack_doubao.sh

主脚本功能：
- 自动查找已安装的豆包扩展
- 复制扩展文件
- 修改 manifest.json
- 生成新的扩展 ID

**用法：**
```bash
# 基础用法
./repack_doubao.sh

# 查看帮助
./repack_doubao.sh --help

# 自定义
./repack_doubao.sh -o ~/my_doubao -n "我的豆包" -v "2.0.0"
```

### README.md

完整的使用文档，包含：
- 参数说明
- 安装步骤
- 更新流程
- 故障排除

### archived_scripts/

调试过程中创建的脚本，已归档供参考。

## 🔍 技术说明

### 扩展 ID 生成

Chrome 扩展 ID 由 manifest.json 中的 `key` 字段决定：

```json
{
  "key": "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...",
  ...
}
```

- 有 `key`：ID 固定
- 无 `key`：Chrome 生成随机 ID

### 脚本操作

1. 查找扩展最新版本
2. 复制所有文件
3. 修改 manifest.json：
   - 移除 `key` 字段
   - 移除 `update_url`
   - 修改名称和版本
4. 生成安装说明

## ⚠️ 注意事项

### 优点
- ✅ 功能与原版相同
- ✅ 可以自定义配置
- ✅ 随时重新打包

### 限制
- ❌ 不会自动更新
- ❌ 需要开启开发者模式
- ❌ 扩展设置不会迁移

### 安全性
- ✅ 代码来自原版豆包
- ✅ 只修改元数据
- ✅ 无额外代码

## 🔄 更新流程

1. 更新原版豆包（从 Chrome 商店）
2. 运行脚本：`./repack_doubao.sh`
3. 在 Chrome 中移除旧版本
4. 加载新打包的版本

## 📚 相关资源

- [Chrome 扩展开发文档](https://developer.chrome.com/docs/extensions/)
- [Manifest V3 规范](https://developer.chrome.com/docs/extensions/mv3/manifest/)

## 🤝 维护

脚本位置：`./repack_doubao.sh`

如需修改或改进，直接编辑脚本即可。

## 📅 版本历史

- **v1.0.0** (2026-02-12)
  - 初始版本
  - 支持自动打包
  - 支持自定义参数
  - 包含完整文档

---

**创建日期**：2026-02-12
**最后更新**：2026-02-12
