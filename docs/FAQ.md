# FAQ

English | [简体中文](FAQ.zh-CN.md)

## Does this need OpenAI Secure MCP Tunnel?

No. This repository is the local-only variant. Godot hosts the Streamable HTTP MCP endpoint directly on `127.0.0.1`.

## Does it need an API key, OpenAI account login, or OAuth?

No. The addon has no remote transport and no credential store. Access is limited by loopback binding and the local-machine trust boundary.

## What is the default MCP URL?

```text
http://127.0.0.1:39050/mcp
```

The port can be changed in the **MCP Local** bottom panel.

## How do I connect Codex?

```powershell
codex mcp add godot --url http://127.0.0.1:39050/mcp
```

Then use `codex mcp list` to confirm the registration.

## Does the plugin launch Codex?

No. It only exposes the current Godot Editor as an MCP server. Codex remains a separate client/process.

## Does the plugin need Node.js or Python?

No for normal use. The MCP server itself is GDScript inside the Godot Editor. The Windows diagnostics helper is a small bundled executable built from Go source in `tools/run-helper/`.

## Why use a fixed port instead of a random port?

A stable local URL makes Codex configuration persistent and simple. The server still binds only to loopback. If the port conflicts with another process, choose another port in the panel.

## Why is the path `/mcp` fixed?

The original tunnel-oriented build used a random path because a child tunnel runtime consumed the endpoint. A local MCP client benefits more from a stable URL, so the local edition uses `/mcp`.

## Is there authentication?

No. The server cannot bind to LAN/public interfaces through the normal plugin flow; it listens only on `127.0.0.1`. Do not expose it with a reverse proxy, port forward, or public tunnel.

## Can a website call the local MCP server from my browser?

The server rejects requests carrying browser-origin headers such as `Origin` or `Sec-Fetch-Site`. This is defense-in-depth for the localhost design; it is not a replacement for authentication if remote access is ever added.

## How many tools are exposed?

The current default public catalogue contains 47 tools. The exact `tools/list` response is authoritative because enabled custom tools can alter the live catalogue.

## Can Codex edit scripts directly instead of using MCP?

Yes. A good workflow is to let Codex use normal repository/file editing when that is simplest, then use Godot MCP for editor/runtime truth, screenshots, scene-tree manipulation, diagnostics, and verification.

## Do runtime changes persist to disk?

Not automatically. Runtime tools operate on the live running SceneTree. Persisting a change to a scene/resource requires a corresponding editor/project save operation.

## Why is `diagnostics.run_capture` Windows-only?

The current bundled helper is packaged for Windows. Other editor and MCP tools are not inherently tied to that helper. A cross-platform replacement can be added later without changing the local transport architecture.

## Can multiple local clients connect?

The HTTP server can accept local connections, but editor mutations are serialized. For predictable development, avoid having multiple agents concurrently mutate the same Godot project.

## The server says the port is in use. What do I do?

Choose another port in the **MCP Local** panel and restart the server. Then update Codex with the new URL.

## The plugin loads but Codex sees no tools.

Verify:

1. the panel shows `Status: listening`;
2. the Codex MCP URL exactly matches the panel;
3. Godot is still running;
4. `codex mcp list` shows the server enabled;
5. the local firewall/security product is not interfering with loopback traffic.

## Is the old `godot-mcp-chatgpt` addon compatible side-by-side?

Do not enable both variants in the same project unless you have a specific testing reason. They share much of the command/runtime design and can compete over debugger/autoload responsibilities. For Codex local use, install only `addons/godot_mcp_local/`.