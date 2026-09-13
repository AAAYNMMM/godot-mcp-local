# Architecture

English | [简体中文](ARCHITECTURE.zh-CN.md)

## Production topology

`godot-mcp-local` intentionally uses one local-only topology:

```text
Codex / local MCP client
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
        +--> Godot Editor APIs
        +--> Editor debugger bridge
        +--> running project runtime bridge
```

There is no public relay, tunnel process, API key, credential store, or separate MCP daemon.

## Local MCP transport

`addons/godot_mcp_local/transport/local_mcp_server.gd` is a small Streamable HTTP MCP server implemented with Godot `TCPServer` / `StreamPeerTCP`.

Properties:

- bind address: `127.0.0.1` only;
- default port: `39050`;
- stable path: `/mcp`;
- configurable port through Godot `EditorSettings` and the **MCP Local** panel;
- maximum request body size;
- serialized request dispatch so editor mutations do not race;
- JSON and SSE response forms;
- no authentication because non-loopback listening is not supported;
- requests carrying browser-origin headers are rejected.

Supported MCP methods include:

- `server/discover`
- `initialize`
- `ping`
- `tools/list`
- `tools/call`
- no-ID notifications
- HTTP `DELETE` acknowledgement

## Tool surface

The addon exposes a compact public surface instead of hundreds of flat commands. The current default catalogue contains 47 public tools backed by the existing internal command registry.

Domains include project/input, scene/node, scripts/resources, ClassDB, editor, diagnostics, runtime/debugger, screenshots, animation, UI/resource authoring, world authoring, batch/transaction, tests, logs, and custom tools.

The exact live schema returned by `tools/list` is authoritative. See [TOOL_REFERENCE.md](TOOL_REFERENCE.md).

## Runtime path

Runtime tools use Godot's own debugger channel rather than opening a second network listener:

```text
MCP runtime.* / debugger.*
 -> RuntimeDebuggerManager
 -> EditorDebuggerPlugin / EditorDebuggerSession
 -> Godot remote-debug channel
 -> EngineDebugger
 -> GodotMCPLocalRuntime autoload
 -> live SceneTree
```

Runtime edits affect the running process unless a separate editor command persists changes to the saved scene.

## Screenshots

Screenshot commands return bounded MCP image content. They can capture supported editor views, Camera3D/cinematic views, and running-game output without exposing arbitrary desktop capture.

## Diagnostics helper

`diagnostics.run_capture` uses a small Windows helper at:

```text
addons/godot_mcp_local/bin/windows/godot-mcp-runner.exe
```

Its source is in `tools/run-helper/`. It launches a bounded child Godot process, captures stdout/stderr separately, enforces timeout/output limits, and returns structured JSON. It has no tunnel or credential behavior.

## Security boundary

The local server is not a remote administration service. Its security assumptions are:

1. the MCP client runs on the same machine as Godot;
2. the listener remains on loopback;
3. command-layer path and schema validation remain enabled;
4. the endpoint is not exposed through port forwarding, reverse proxying, LAN binding, or public tunneling.

If remote access is ever added, authentication, authorization, replay protection, origin handling, rate limits, and a separate threat model are required first.

## Non-goals

- public MCP hosting;
- OpenAI Secure MCP Tunnel compatibility;
- API-key or OAuth management inside the addon;
- MCP client auto-configuration;
- general shell/desktop automation;
- arbitrary filesystem access outside the command-layer scope;
- replacing Git or a coding agent.