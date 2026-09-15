# 开发流程

[English](DEVELOPMENT_WORKFLOW.md) | 简体中文

## 目标

让 `godot-mcp-local` 始终保持可复现的本地 Godot Editor MCP Integration。每次改动都要在它真正影响的 Editor / Runtime 链路上验证。

## 工作循环

```text
检查当前行为
-> 做一个聚焦修改
-> 静态 / GDScript 验证
-> 真实 Godot Editor 验证
-> 对受影响 MCP Tool 做 Smoke / Regression
-> 检查 Git Diff
-> 只记录真实执行结果
-> Commit
```

## 权威来源

- Public MCP Schema：实时 `tools/list`。
- Godot 行为：真实 Editor / Runtime 执行。
- Project File：Git Working Tree。
- 测试 / 发布结论：本次真实执行的测试。

没有跑过的测试不能写 PASS。

## Transport 修改

修改 `transport/local_mcp_server.gd` 或 Connection UI 时至少验证：

- 仍只绑定 `127.0.0.1`；
- 配置 Port 生效；
- `/mcp` Endpoint 正常；
- `initialize`、`ping`、`tools/list`、`tools/call` 正常；
- JSON Response 正常；
- SSE Response 正常；
- Browser-origin Request 被拒绝；
- Editor Mutation 仍串行；
- 没有重新引入远程 / Tunnel Credential Path。

编辑器插件运行时，执行只依赖 Python 标准库的回归检查：

```sh
python tools/test_transport.py --url http://127.0.0.1:39050/mcp
```

检查覆盖 JSON / SSE 成功与错误响应中数字及字符串请求 ID 的精确类型。仅检查 HTTP 200 或数字相等会漏掉 `0` 变成 `0.0` 的问题，这会导致 Codex MCP 客户端无法握手。

替换传输脚本后，重新启动编辑器再测试。不要通过正在运行的 MCP 请求重新加载传输脚本本身。

## Tool 修改

对受影响 Tool / Domain：

1. 校验 Schema；
2. 检查 Read-only / Destructive Annotation；
3. 测正常成功路径；
4. 至少测一个 Invalid Input / Error Path；
5. 验证 Project / Path Boundary；
6. 声称支持 Undo/Redo 的 Tool 必须真实验证；
7. Shared Helper 变化时回归相邻 Tool。

## Runtime 修改

Runtime / Debugger 代码至少验证：

- 游戏未运行；
- 可调试项目正在运行。

还要验证停止游戏和禁用 / Reload Plugin 后能正确清理。

## Screenshot 修改

必须至少真实返回一次 Image Content，并检查 Resolution / Output Bound。仅返回 Metadata 不能算 Screenshot PASS。

## Diagnostics Helper 修改

从 `tools/run-helper/` 重新 Build Windows Runner，放到 Addon Bin 路径，然后验证：

- 正常完成；
- stdout/stderr 分离捕获；
- Timeout；
- Output Truncation；
- Invalid Scene / Path。

## Git 整洁

Commit 前：

```text
git status --short
git diff --check
git diff --stat
```

确认没有 `.godot/`、临时 Test Asset、Log、无关游戏 Demo 内容或本地配置进入 Staging。

## 验证记录

较大修改应准确记录实际结果，例如：

```text
Godot 4.7.2 script load: PASS
Editor plugin load: PASS
MCP initialize: PASS
47-tool catalogue uniqueness: PASS
godot.get_status: PASS
SSE response: PASS
Origin rejection: PASS
git diff --check: PASS
```

未支持或未执行的项目必须明确写出，不能伪装成 PASS。
