# godot-mcp-local

**让 Codex 或其他本地 MCP 客户端直接控制当前打开的 Godot Editor。**

`godot-mcp-local` 是一个面向 Godot 4.7 的项目级 Editor 插件。它在本机回环地址上直接提供 Streamable HTTP MCP Server，并保留原有紧凑 Godot 工具面，可用于场景、脚本、资源、运行时、截图、诊断、测试、批处理和 Custom Tool 等操作。

不需要 OpenAI Tunnel、不需要 API Key、不需要账号登录、不需要公网 Relay，也不需要额外启动 Node/Python MCP Server。

English: [README.md](README.md)

## 架构

```text
Codex / 本地 MCP Client
        |
        | Streamable HTTP MCP
        | http://127.0.0.1:39050/mcp
        v
Godot MCP Local 插件
        |
        v
CommandRegistry / Public Tool Surface
        |
        v
Godot Editor + Running Project
```

Server 只绑定 `127.0.0.1`。默认端口为 `39050`，可以在 Godot 底部 **MCP Local** 面板修改。

## 当前能力

- 已使用 **Godot 4.7.2 Standard x64** 验证。
- 默认 **47 个 Public MCP Tools**，继续复用紧凑的内部命令层。
- Project、Scene、Node、Script、Resource、ClassDB、Editor 操作。
- Runtime SceneTree、属性、方法、输入注入。
- Editor / Running Game Screenshot，并以 MCP Image Content 返回。
- Logs、Diagnostics、Tests、Batch、Transaction。
- TileMap/TileSet、GridMap、CSG、Animation、UI/Resource Authoring 等高层能力。
- 第三方 Custom Tool 注册、启停和调用。

完整名称与用法见 [工具参考](docs/TOOL_REFERENCE.zh-CN.md)。

## 安装

把下面目录复制到目标 Godot 项目：

```text
addons/godot_mcp_local/
```

然后在：

```text
项目 -> 项目设置 -> 插件
```

启用 **Godot MCP Local**。

插件启用后会自动启动本地 MCP Server，底部 **MCP Local** 面板会显示准确 Endpoint。

## 连接 Codex

Godot 已打开且插件启用后，在终端执行：

```powershell
codex mcp add godot --url http://127.0.0.1:39050/mcp
```

确认：

```powershell
codex mcp list
```

如果你在 Godot 中修改了端口，就使用面板显示的新地址。面板也提供 **Copy Codex Command** 按钮。

Codex 的第一条安全测试可以写：

```text
使用 Godot MCP 工具检查当前项目，告诉我项目名、Godot 版本和当前场景，不要修改任何内容。
```

## 本地安全边界

这个 MCP Endpoint 明确设计为纯本地：

- 只监听 `127.0.0.1`；
- 不使用 API Key，因为根本不支持远程连接；
- 带浏览器 `Origin` / `Sec-Fetch-*` 头的请求会直接拒绝；
- 文件和工程修改仍受 Godot 命令层约束，主要限制在 `res://`；
- 破坏性、写入型操作继续保留 Schema 校验与 Tool Annotation。

不要直接把这个端口转发或代理到其他机器。若以后要远程访问，必须重新设计认证和威胁模型。详见 [SECURITY.zh-CN.md](SECURITY.zh-CN.md)。

## 已完成验证

本地版已通过 Godot 4.7.2 真实 Editor Plugin 链路测试：

```text
插件加载                    PASS
127.0.0.1:39050 监听        PASS
MCP initialize              PASS
MCP tools/list              PASS（47 tools）
godot.get_status            PASS
JSON Response               PASS
SSE Response                PASS
浏览器 Origin 拒绝          PASS（403）
GDScript 加载检查            PASS（29 scripts / 0 failures）
```

`diagnostics.run_capture` 仍保留一个很小的本地 Windows Runner，源码位于 `tools/run-helper/`，与 Tunnel 无关。

## 开发说明

本仓库已经删除旧 Secure MCP Tunnel Transport、凭据保存、Tunnel Runtime、Control Plane 测试 Server 和 Tunnel Installer。当前只维护一种正式拓扑：**本地 Godot Editor <-> 本地 MCP Client**。

文档：

- [快速开始](docs/QUICKSTART.zh-CN.md)
- [架构](docs/ARCHITECTURE.zh-CN.md)
- [FAQ](docs/FAQ.zh-CN.md)
- [工具参考](docs/TOOL_REFERENCE.zh-CN.md)
- [开发流程](docs/DEVELOPMENT_WORKFLOW.zh-CN.md)

## 许可证

MIT，见 [LICENSE](LICENSE)。