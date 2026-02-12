# 豆包扩展重新打包工具

> ⚠️ **注意**：本仓库不包含已打包的扩展文件（文件太大）。请运行脚本自行生成。

## 📦 简介

这是一个自动化脚本，用于重新打包豆包浏览器扩展，生成新的扩展 ID。

## 🚀 快速开始

### 第一次使用

```bash
# 1. 克隆仓库
git clone https://github.com/chess99/doubao-repack-tool.git
cd doubao-repack-tool

# 2. 确保已安装原版豆包扩展
# 从 Chrome 商店安装：https://chrome.google.com/webstore/

# 3. 运行脚本生成自定义版本
./repack_doubao.sh
```

这将会：
- 自动查找已安装的豆包扩展
- 复制到 `./doubao_custom/`（脚本所在目录）
- 生成新的扩展 ID
- 版本号自动 +0.0.1

### 高级用法

```bash
# 指定输出目录
./repack_doubao.sh -o ~/my_doubao

# 自定义名称和版本
./repack_doubao.sh -n "我的豆包" -v "2.0.0"

# 查看帮助
./repack_doubao.sh --help
```

## 📝 参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `-h, --help` | 显示帮助信息 | - |
| `-o, --output DIR` | 指定输出目录 | `./doubao_custom`（脚本所在目录） |
| `-n, --name NAME` | 自定义扩展名称 | `豆包助手 (自定义版)` |
| `-v, --version VERSION` | 自定义版本号 | 原版本 +0.0.1 |
| `--keep-update` | 保留自动更新 URL | false（默认移除）|

## 📥 安装重新打包的扩展

1. **打开 Chrome 扩展页面**
   - 访问 `chrome://extensions/`

2. **开启开发者模式**
   - 点击右上角的"开发者模式"开关

3. **加载扩展**
   - 点击"加载已解压的扩展程序"
   - 选择脚本生成的输出目录（默认：`./doubao_custom/`）

4. **完成**
   - 扩展将以新的 ID 加载

## 🔄 更新流程

当豆包官方发布新版本时：

1. 在 Chrome 中更新原版豆包
2. 运行重新打包脚本：`./repack_doubao.sh`
3. 在 Chrome 中移除旧版本
4. 加载新打包的版本

## 🛠️ 技术说明

### 主要修改

脚本会修改 `manifest.json` 文件：

1. **移除 `key` 字段** - Chrome 将生成新的扩展 ID
2. **移除 `update_url`** - 防止自动更新
3. **修改名称和版本** - 便于识别

### 扩展 ID 生成

- 有 `key` 字段：ID 固定
- 无 `key` 字段：Chrome 生成随机 ID

## ⚠️ 注意事项

### 优点
- ✅ 功能与原版完全相同
- ✅ 可以自定义配置
- ✅ 随时可以重新打包

### 限制
- ❌ 不会自动更新
- ❌ 需要开启开发者模式
- ❌ 扩展设置不会迁移

### 安全性
- ✅ 所有代码来自原版豆包
- ✅ 只修改元数据（名称、ID）
- ✅ 无任何额外代码

## 🔍 故障排除

### 问题 1：脚本报错"未找到豆包扩展"

**解决**：
```bash
# 检查扩展是否存在
ls -la ~/Library/Application\ Support/Google/Chrome/Default/Extensions/ | grep dbji
```

先从 Chrome 商店安装原版豆包。

### 问题 2：加载扩展时报错

**解决**：
```bash
# 重新运行脚本
./repack_doubao.sh -o ~/doubao_new

# 检查 manifest.json
cat ~/doubao_new/manifest.json | python3 -m json.tool
```

### 问题 3：扩展功能异常

**解决**：
- 查看控制台错误（F12 → Console）
- 清除扩展数据重新配置
- 确认原版扩展功能正常

## 📚 相关资源

- [Chrome 扩展开发文档](https://developer.chrome.com/docs/extensions/)
- [Manifest V3 规范](https://developer.chrome.com/docs/extensions/mv3/manifest/)

## 🤝 贡献

欢迎改进和优化！

## 📄 许可

本工具仅供学习和个人使用。请遵守豆包扩展的使用条款。

---

**最后更新**：2026-02-12
**版本**：1.0.0
