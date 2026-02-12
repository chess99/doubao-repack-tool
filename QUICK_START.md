# 豆包扩展重新打包工具 - 快速开始

## 🎯 一句话说明

这个工具可以重新打包豆包扩展，生成新的扩展 ID。

## ⚡ 最快使用方式

### 第一步：生成扩展

```bash
cd .
./repack_doubao.sh
```

### 第二步：安装扩展

1. 打开 Chrome：`chrome://extensions/`
2. 开启"开发者模式"（右上角开关）
3. 点击"加载已解压的扩展程序"
4. 选择生成的目录：`./doubao_custom/`
5. 完成！

## 📁 目录结构

```
./
├── QUICK_START.md            ← 你在这里
├── README.md                 ← 详细文档
├── PROJECT_INFO.md           ← 项目说明
├── repack_doubao.sh          ← 主脚本
├── doubao_custom/            ← 生成的扩展（运行脚本后）
├── .shellrc                  ← Shell 别名配置
└── archived_scripts/         ← 调试脚本（归档）
```

## 🔧 常用命令

```bash
# 进入工具目录
cd .

# 查看帮助
./repack_doubao.sh --help

# 重新打包（使用默认设置）
./repack_doubao.sh

# 自定义名称和版本
./repack_doubao.sh -n "我的豆包" -v "2.0.0"

# 指定输出目录
./repack_doubao.sh -o ~/my_doubao
```

## 🚀 添加快捷命令（可选）

在 `~/.zshrc` 或 `~/.bashrc` 中添加：

```bash
source ./.shellrc
```

然后就可以在任何地方使用：
- `repack-doubao` - 重新打包
- `doubao-tool` - 打开工具目录
- `doubao-help` - 查看帮助

## ❓ 常见问题

### Q: 为什么要重新打包？
A: 生成新的扩展 ID，用于自定义配置或解决兼容性问题。

### Q: 会影响功能吗？
A: 不会，功能完全相同。

### Q: 豆包更新了怎么办？
A: 重新运行 `./repack_doubao.sh` 即可。

### Q: 安全吗？
A: 安全，所有代码都来自原版豆包，只修改了名称和 ID。

## 📚 更多信息

- 详细使用指南：`README.md`
- 项目说明：`PROJECT_INFO.md`
- 在线帮助：`./repack_doubao.sh --help`

---

**快速联系**：遇到问题查看 README.md 的故障排除部分
