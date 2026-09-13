# 架构

[English](ARCHITECTURE.md) | 简体中文

## 正式拓扑

`godot-mcp-local` 只维护一种纯本地架构：

```text
Codex / 本地 MCP Client
        |
        | Streamable HTTP MCP
        | 127.0.0.1:<port>/mcp
        v
local_mcp_server.gd
        |
        v
PublicToolSurface
        |
        v
CommandRegistry
        |
        +--> Godot Editor API
        +--> Editor Debugger Bridge
        +--> Running Project Runtime Bridge
```

没有公网 Relay、Tunnel 子进程、API Key、Credential Store，也没有独立 MCP Daemon。

## 本地 MCP Transport

`addons/godot_mcp_local/transport/local_mcp_server.gd` 使用 Godot `TCPServer` / `StreamPeerTCP` 实现 Streamable HTTP MCP。

特性：

- 只绑定 `127.0.0.1`；
- 默认端口 `39050`；
- 固定路径 `/mcp`；
- 可通过 Godot `EditorSettings` 和底部 **MCP Local** 面板修改端口；
- 请求体大小上限；
- 请求串行调度，避免 Editor 写操作竞争；
- 支持 JSON 与 SSE Response；
- 因为不支持非本机连接，所以不做 API Key 认证；
- 带浏览器 Origin 类请求头的请求会被拒绝。

支持的 MCP 方法包括：

- `server/discover`
- `initialize`
- `ping`
- `tools/list`
- `tools/call`
- 无 ID Notification
- HTTP `DELETE` 确认

## Tool Surface

插件继续使用紧凑 Public Surface，而不是暴露数百个扁平命令。当前默认 Catalogue 为 47 个 Public Tools，后端复用现有 Internal Command Registry。

覆盖 Project/Input、Scene/Node、Script/Resource、ClassDB、Editor、Diagnostics、Runtime/Debugger、Screenshot、Animation、UI/Resource Authoring、World Authoring、Batch/Transaction、Tests、Logs 与 Custom Tools。

实时 `tools/list` 返回的 Schema 是最终权威，见 [TOOL_REFERENCE.zh-CN.md](TOOL_REFERENCE.zh-CN.md)。

## Runtime 路径

Runtime Tool 不再开第二个网络端口，而是使用 Godot 自己的 Debugger Channel：

```text
MCP runtime.* / debugger.*
 -> RuntimeDebuggerManager
 -> EditorDebuggerPlugin / EditorDebuggerSession
 -> Godot remote-debug channel
 -> EngineDebugger
 -> GodotMCPLocalRuntime autoload
 -> live SceneTree
```

Runtime 修改默认只影响当前运行实例；只有额外执行 Editor 持久化操作时才会写回场景文件。

## Screenshot

Screenshot 以有边界的 MCP Image Content 返回，可覆盖支持的 Editor View、Camera3D/Cinematic View 和 Running Game，不提供任意桌面截图。

## Diagnostics Helper

`diagnostics.run_capture` 使用一个很小的 Windows Helper：

```text
addons/godot_mcp_local/bin/windows/godot-mcp-runner.exe
```

源码位于 `tools/run-helper/`。它只负责启动有边界的 Godot 子进程、分别捕获 stdout/stderr、限制超时和输出大小，并返回结构化 JSON；完全不涉及 Tunnel 或凭据。

## 安全边界

这个本地 Server 不是远程管理服务。安全前提是：

1. MCP Client 与 Godot 在同一台机器；
2. Listener 始终只在 Loopback；
3. Command Layer 的路径限制和 Schema 校验保持启用；
4. 不通过端口转发、反向代理、LAN 绑定或公网 Tunnel 暴露 Endpoint。

若未来增加远程连接，必须先重新设计认证、授权、防重放、Origin、限流和独立威胁模型。

## 非目标

- 公网 MCP Hosting；
- OpenAI Secure MCP Tunnel 兼容；
- 插件内 API Key / OAuth 管理；
- 自动配置 MCP Client；
- 通用 Shell / Desktop Automation；
- 绕过命令层限制的任意文件系统访问；
- 替代 Git 或 Coding Agent。