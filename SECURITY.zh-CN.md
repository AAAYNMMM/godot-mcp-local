# 安全策略

[English](SECURITY.md) | 简体中文

`godot-mcp-local` 会让本地 MCP Client 获得对真实 Godot 项目的较强控制能力，因此应把 MCP Endpoint 当作高权限本地开发接口。

## 信任模型

支持的正式拓扑：

```text
本地 MCP Client
      |
      | 仅 127.0.0.1
      v
Godot MCP Local
      |
      v
当前 Godot Project / Editor / Runtime
```

安全前提：

- MCP Client 与 Godot 在同一台机器；
- Listener 始终只绑定 Loopback；
- 用户信任能够连接该本地端口的开发工具；
- Command Layer 的路径、Schema 和破坏性操作检查保持启用。

因为远程连接明确不在当前范围内，所以没有远程认证系统。

## 网络边界

MCP Server：

- 只绑定 `127.0.0.1`；
- 默认端口 `39050`、路径 `/mcp`；
- 拒绝带 `Origin` 或 `Sec-Fetch-*` 等浏览器来源头的请求；
- 不包含公网 Relay、Reverse Proxy、Tunnel Client、API Key、OAuth 或 Credential Store。

**不要**改成 `0.0.0.0`、LAN/WAN 监听、端口转发、公网 Tunnel 或反向代理，除非先重新设计并实现真正的远程认证和授权。

Loopback 只适合作为本机边界，不能代替远程网络中的认证。

## Godot / Project 边界

Tool Layer 继续校验 Project-relative Path 和结构化参数。Project / Resource Mutation 设计为限制在当前 Godot 项目，主要是 `res://`。

不要在没有单独安全评审的情况下，把任意 Shell 或无限制文件系统工具加入 Public MCP Surface。

## Browser-to-localhost 防护

恶意网页可能攻击本地服务。因此 Server 会拒绝带浏览器来源头的请求，以降低网页直接访问固定 Localhost Endpoint 的风险。

这只是 Defense-in-depth。若 Endpoint 未来可以远程访问，必须使用真正认证 / 授权，而不是依赖 Header 检查。

## Tool 安全

Public Tool 在可用时保留 Read-only / Destructive Annotation，并在进入 Internal Command 前做 Input Schema 校验。写入操作应：

- 限制在当前项目；
- 在已有 Godot Integration 支持时保留 Undo/Redo；
- 校验 Node / Resource Path 与类型；
- 限制输出和 Image Capture 大小；
- 避免任意进程执行。

## Runtime Bridge

Runtime Control 通过 Godot Debugger Channel 和保留的 `GodotMCPLocalRuntime` Autoload 实现。Runtime Mutation 会立即影响正在运行的游戏；若调用项目自身不安全的方法，也可能导致崩溃。

Runtime API 必须保持显式和有边界，不能暴露任意 Native Memory 或 Host Process API。

## Diagnostics Helper

Bundled Windows Diagnostics Runner 只能以有边界方式启动当前 Godot，并捕获 stdout/stderr：

- Godot Executable 从当前运行的 Godot 安装解析；
- Scene Path 必须在 `res://`；
- Timeout 与 Output Size 有上限；
- User Args 有数量 / 长度限制；
- 它不是通用 Shell Tool。

源码位于 `tools/run-helper/`。

## Screenshot 与数据

Screenshot Tool 返回选定 Godot Editor / Game Image Content，不提供任意 Desktop Capture。Logs 和 Project Inspection 仍可能包含项目敏感信息，因此只连接你信任的本地 Client。

## Custom Tool

第三方 Custom Tool 在 Godot Editor 进程内执行。启用它就等于扩大 MCP 实际能力边界，因此启用前应先审查对应 Addon 代码。

## 安全问题报告

不要在公开 Issue 中提交完整 Exploit、私有项目内容或敏感数据。请尽量给最小复现，并说明：

- 受影响版本 / Commit；
- Godot 版本与 OS；
- 是否突破 Loopback / Project 边界；
- 涉及的 Tool / Endpoint；
- 期望行为与实际行为。

## 需要额外评审的修改

以下修改必须单独做安全评审和回归：

- Bind Address / Transport；
- Browser Origin Filtering；
- `res://` 之外的 Path Access；
- 任意进程执行；
- Runtime Debugger Bridge；
- Screenshot Scope；
- Custom Tool Trust Boundary；
- Destructive Tool Annotation / Validation。