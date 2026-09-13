# FAQ

[English](FAQ.md) | 简体中文

## 还需要 OpenAI Secure MCP Tunnel 吗？

不需要。这个仓库就是纯本地版本，由 Godot 直接在 `127.0.0.1` 提供 Streamable HTTP MCP。

## 需要 API Key、OpenAI 登录或 OAuth 吗？

不需要。插件没有远程 Transport，也没有 Credential Store。安全边界就是本机 Loopback。

## 默认 MCP 地址是什么？

```text
http://127.0.0.1:39050/mcp
```

端口可以在底部 **MCP Local** 面板修改。

## 怎么接 Codex？

```powershell
codex mcp add godot --url http://127.0.0.1:39050/mcp
```

然后用 `codex mcp list` 确认。

## 插件会启动 Codex 吗？

不会。插件只把当前 Godot Editor 暴露为 MCP Server，Codex 仍是独立 Client / Process。

## 正常使用需要 Node.js 或 Python 吗？

不需要。MCP Server 本身是运行在 Godot Editor 内的 GDScript。Windows 的 Diagnostics Helper 是一个很小的本地可执行文件，Go 源码在 `tools/run-helper/`。

## 为什么改成固定端口？

固定本地 URL 可以让 Codex 配置长期有效、使用更简单。Server 仍只绑定 Loopback。如果端口冲突，在面板换一个即可。

## 为什么路径固定为 `/mcp`？

旧 Tunnel 版本使用随机路径是为了给 Tunnel 子进程消费；纯本地 Client 更适合稳定 URL，因此改为 `/mcp`。

## 有认证吗？

没有。正常插件流程只能监听 `127.0.0.1`，不会监听 LAN / 公网。不要通过反向代理、端口转发或公网 Tunnel 把它暴露出去。

## 网页能不能从浏览器访问这个 localhost MCP？

Server 会拒绝带 `Origin`、`Sec-Fetch-Site` 等浏览器来源头的请求。这属于本地设计的额外防护；如果未来做远程访问，仍必须加入真正认证。

## 有多少工具？

当前默认 Public Catalogue 为 47 个 Tool。实时 `tools/list` 才是最终权威，因为启用 Custom Tool 后 Catalogue 可以变化。

## Codex 可以不用 MCP，直接改 GDScript 吗？

可以，而且这是推荐工作流的一部分。文件修改简单时让 Codex 直接操作仓库；需要 Editor / Runtime 真实状态、Screenshot、SceneTree、Diagnostics 和验证时再使用 Godot MCP。

## Runtime 修改会自动保存到磁盘吗？

不会。Runtime Tool 默认只修改正在运行的 SceneTree。要持久化仍需额外执行 Editor / Resource 保存操作。

## 为什么 `diagnostics.run_capture` 目前只支持 Windows？

当前 Bundled Helper 是 Windows 版本。其他 MCP / Editor Tool 本身并不依赖这个 Helper；以后可以单独补跨平台实现而不改变本地 MCP 架构。

## 可以多个本地 Client 同时连接吗？

HTTP Server 可以接收本地连接，但 Editor Mutation 会串行执行。为了避免互相覆盖，不建议多个 Agent 同时修改同一个 Godot 项目。

## 提示端口被占用怎么办？

在 **MCP Local** 面板换一个端口并 Restart，然后把 Codex MCP URL 更新为新地址。

## 插件正常，但 Codex 看不到工具

依次检查：

1. 面板是否为 `Status: listening`；
2. Codex 地址是否与面板完全一致；
3. Godot 是否还在运行；
4. `codex mcp list` 是否显示 Server 已启用；
5. 本机安全软件是否干扰 Loopback。

## 能同时启用旧 `godot-mcp-chatgpt` 吗？

除非专门做测试，否则不要。两个版本复用了大量命令和 Runtime / Debugger 设计，可能争用 Autoload 或 Debugger 状态。Codex 本地使用只安装 `addons/godot_mcp_local/`。