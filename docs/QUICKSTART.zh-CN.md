# 快速开始

[English](QUICKSTART.md) | 简体中文

## 环境要求

- Godot 4.7.x（Windows 下已验证 4.7.2 Standard x64）。
- Codex CLI，或其他支持 Streamable HTTP 的本地 MCP Client。
- 目标 Godot 项目已在 Editor 中打开。

不需要 OpenAI Tunnel、API Key、浏览器 Connector、Node Server 或 Python Server。

## 1. 安装插件

### 推荐：Windows 一键安装器

从 GitHub Release 下载 `godot-mcp-local-v0.1.2-windows-x64-installer.exe`，运行后选择目标项目的 `project.godot`。安装器会自动安装/升级插件并启用 **Godot MCP Local**，同时保留项目里其他已启用插件。

安装或替换插件文件前先关闭 Godot，完成后重新打开项目。不要通过正在运行的 MCP 请求热重载传输脚本本身。

### 手动安装

把：

```text
addons/godot_mcp_local/
```

复制到目标 Godot 项目，然后在：

```text
项目 -> 项目设置 -> 插件
```

启用 **Godot MCP Local**。

## 2. 查看本地 Endpoint

打开底部 **MCP Local** 面板。默认地址：

```text
http://127.0.0.1:39050/mcp
```

插件启用后自动监听。如果 `39050` 已被占用，在面板修改端口后点击 **Restart on Port**。

## 3. 添加到 Codex

执行：

```powershell
codex mcp add godot --url http://127.0.0.1:39050/mcp
```

也可以直接点击 Godot 面板里的 **Copy Codex Command**，再粘贴到终端。

确认：

```powershell
codex mcp list
```

## 4. 第一条安全测试

对 Codex 说：

```text
使用 Godot MCP 工具检查当前项目，告诉我项目名、Godot 版本、当前场景和顶层场景树，不要修改任何内容。
```

正常情况下会发现完整 Tool Catalogue，包括 `godot.get_status`、Project/Scene、Runtime、Screenshot、Logs、Tests、Batch/Transaction 和 Authoring Tools。

## 5. 推荐开发闭环

```text
Codex 适合直接修改文件时直接改项目文件
        +
Godot MCP 负责 Editor / Runtime 真实状态
        +
Godot CLI 或 diagnostics.run_capture 做验证
        +
Git 保存已通过基线
```

涉及 SceneTree、Inspector、Screenshot、Runtime、Input Injection、Animation/Resource、Undo/Redo、测试证据时，优先使用 MCP。

## 修改端口

选择的端口保存在 Godot `EditorSettings`：

```text
godot_mcp_local/port
```

端口变化后 MCP URL 也会变化。必要时重新配置 Codex：

```powershell
codex mcp remove godot
codex mcp add godot --url http://127.0.0.1:<新端口>/mcp
```

## 排障

### Codex 连不上

按顺序检查：

1. Godot Editor 是否仍在运行。
2. **Godot MCP Local** 是否启用。
3. 面板是否显示 `Status: listening`。
4. Codex 使用的地址是否和面板完全一致。
5. 端口是否被别的程序占用。

Windows 下可检查默认端口：

```powershell
Get-NetTCPConnection -LocalPort 39050 -State Listen
```

### 插件无法加载

查看 Godot Output，并确认文件存在：

```text
res://addons/godot_mcp_local/plugin.cfg
```

不要再安装到旧 `addons/godot_mcp_chatgpt/` 路径。

### Runtime Tool 不可用

Runtime Inspection 需要项目真实运行且 Debugger Session 可用。没有运行游戏时，Editor-time Tool 仍然可以正常使用。

### `diagnostics.run_capture` 提示 Runner 缺失

Windows 版本必须包含：

```text
addons/godot_mcp_local/bin/windows/godot-mcp-runner.exe
```

源码在 `tools/run-helper/`。

## 安全说明

Server 明确只供本机使用。不要改成 `0.0.0.0`、LAN 监听、端口转发、反向代理或公网 Tunnel；当前纯本地设计没有远程认证层。
