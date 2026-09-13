# 贡献指南

[English](CONTRIBUTING.md) | 简体中文

感谢参与 `godot-mcp-local`。

## 项目范围

本仓库是 **纯本地** Godot MCP 版本，正式拓扑只有：

```text
本地 MCP Client -> 127.0.0.1 Streamable HTTP MCP -> Godot Editor
```

不要在没有独立架构方案的情况下重新加入公网 Relay、远程 Tunnel、API Key、账号登录或 Credential Store。远程连接明确不属于当前范围。

## 开发环境

主要验证目标：

- Godot 4.7.2 Standard x64
- Windows x64
- GDScript
- Loopback Streamable HTTP MCP

主 Addon：

```text
addons/godot_mcp_local/
```

Diagnostics Helper 源码：

```text
tools/run-helper/
```

## 开发前

1. 阅读 [架构](docs/ARCHITECTURE.zh-CN.md)。
2. 阅读 [安全策略](SECURITY.zh-CN.md)。
3. 修改 Public Tool 前先检查实时 Schema。
4. 不要把无关改动混入 Patch。

## Public Tool 设计

本项目故意保持紧凑 MCP Surface。能放入现有 Domain / Rollup Tool 或 Internal Command 的能力，优先不要新增大量扁平 Tool。

Tool 修改应具备：

- 有边界的 Input Schema；
- 正确 Read-only / Destructive Annotation；
- 明确 Error Code / Message；
- Project / Path Validation；
- 回归覆盖；
- Public Contract 变化时同步文档。

实时 `tools/list` 是最终权威。

## 本地 Transport 规则

除非经过明确设计评审，否则必须保持：

- 只绑定 `127.0.0.1`；
- 固定 `/mcp` Path；
- 本地 Port 可配置；
- Editor Mutation 串行；
- JSON / SSE 兼容；
- 拒绝 Browser-origin Request；
- 因为不支持远程 Listener，所以不做远程认证。

绝不能静默扩大到 LAN / Public Listener。

## 文件与 Runtime 边界

- Project 文件操作继续受现有 `res://` 限制。
- 不增加任意 Shell Execution。
- Screenshot 只覆盖支持的 Godot View。
- Runtime Tool 使用 Debugger / Runtime Bridge，不新开额外公网服务。
- 已有支持 Undo/Redo 的 Editor Mutation 应继续保留。

## Diagnostics Helper

如果修改 `tools/run-helper/`：

1. 重新 Build Windows `godot-mcp-runner.exe`；
2. 放到 `addons/godot_mcp_local/bin/windows/`；
3. 验证 `diagnostics.run_capture` 仍返回有边界的结构化结果；
4. 在变更记录中写明实际测试。

## 最低验证要求

Transport / Addon 改动至少执行：

1. Addon GDScript Load / Parse；
2. 真实 Godot Editor Plugin Load；
3. Loopback Listener；
4. MCP `initialize`；
5. MCP `tools/list` 与 Tool Name 唯一性；
6. 代表性只读调用，例如 `godot.get_status`；
7. JSON Response；
8. SSE Response；
9. Browser-origin Reject；
10. `git diff --check`。

Command 改动还要补对应 Domain 的代表性行为测试。

没有真实执行过的测试不能写 PASS。

## Git 整洁

- `.godot/` 不进入 Git。
- 临时 Smoke Project / Log 不提交。
- 不把无关游戏 Demo 内容提交进来。
- Binary 必须是明确需要且有说明的。
- Commit Message 保持聚焦。

## Issue / PR

高质量报告应包含：

- Godot Version / OS；
- 准确复现步骤；
- 涉及的 MCP Tool / Request；
- Expected / Actual；
- 非敏感日志；
- 问题属于 Editor、Runtime、Transport、Screenshot、Diagnostics 还是 Custom Tool。

安全问题按 [SECURITY.zh-CN.md](SECURITY.zh-CN.md) 处理。