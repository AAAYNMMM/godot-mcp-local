# godot-mcp-local

**Control the currently open Godot Editor directly from Codex or another local MCP client.**

`godot-mcp-local` is a project-scoped Godot 4.7 editor addon. It exposes the editor through a loopback-only Streamable HTTP MCP server and keeps the existing compact Godot tool surface for editing scenes, scripts, resources, runtime state, screenshots, diagnostics, tests, batch operations, and custom tools.

No OpenAI tunnel, API key, account login, public relay, or separate Node/Python MCP server is required.

中文说明：[README.zh-CN.md](README.zh-CN.md)

## Architecture

```text
Codex / local MCP client
        |
        | Streamable HTTP MCP
        | http://127.0.0.1:39050/mcp
        v
Godot MCP Local addon
        |
        v
CommandRegistry / public tool surface
        |
        v
Godot Editor + running project
```

The server binds only to `127.0.0.1`. The default port is `39050` and can be changed from the **MCP Local** bottom panel.

## Current surface

- Godot **4.7.2 Standard x64** validated.
- **47 default public MCP tools** backed by the existing compact internal command layer.
- Project, scene, node, script, resource, ClassDB and editor operations.
- Runtime tree/property/method access and input injection.
- Editor/running-game screenshots as MCP image content.
- Logs, diagnostics, tests, batch and transaction workflows.
- TileMap/TileSet, GridMap, CSG, animation, UI/resource authoring and other high-level authoring helpers.
- Third-party custom tool registration and invocation.

See [Tool Reference](docs/TOOL_REFERENCE.md).

## Install

### Windows one-click installer

Download `godot-mcp-local-v0.1.1-windows-x64-installer.exe` from the GitHub Release and double-click it. Select the target project's `project.godot` file. The installer:

- installs or upgrades `addons/godot_mcp_local/`;
- enables **Godot MCP Local** in `project.godot`;
- preserves other enabled Godot plugins;
- can be run again to upgrade the addon in place.

If the project is already open in Godot, close/reopen it after installation so the new plugin files load cleanly.

### Manual install

Copy this folder into the target Godot project:

```text
addons/godot_mcp_local/
```

Then enable **Godot MCP Local** in:

```text
Project -> Project Settings -> Plugins
```

The addon starts the local MCP server automatically. The bottom **MCP Local** panel shows the exact endpoint.

## Connect Codex

With Godot open and the plugin enabled:

```powershell
codex mcp add godot --url http://127.0.0.1:39050/mcp
```

Check the registration:

```powershell
codex mcp list
```

If you changed the port in Godot, use the endpoint shown in the panel. The panel also has **Copy Codex Command**.

A useful first request in Codex is:

```text
Use the Godot MCP tools to inspect the current project and report the open scene, project name, and Godot version. Do not modify anything.
```

## Local security model

The MCP endpoint is intentionally local-only:

- listener: `127.0.0.1` only;
- no API key or remote authentication because remote access is not supported;
- browser-originated requests carrying `Origin` / `Sec-Fetch-*` headers are rejected;
- project file operations remain bounded by the Godot-side command rules, primarily `res://`;
- destructive and mutating operations retain tool annotations and validation.

Do not port-forward or proxy the endpoint to another machine unless you add a proper authentication and threat model first. See [SECURITY.md](SECURITY.md).

## Validation

The local conversion has been tested with Godot 4.7.2 using the real editor plugin path:

```text
plugin load                  PASS
loopback listen :39050       PASS
MCP initialize               PASS
MCP tools/list               PASS (47 tools)
godot.get_status             PASS
JSON response                PASS
SSE response                 PASS
browser Origin rejection     PASS (403)
GDScript load check          PASS (29 scripts / 0 failures)
Windows installer build       PASS
installer install/upgrade E2E PASS
```

The `diagnostics.run_capture` helper is kept as a small bundled local Windows executable and is built from `tools/run-helper/`.

## Development

The repository intentionally removes the old Secure MCP Tunnel transport, credential storage, tunnel runtime, control-plane test harness, and tunnel installer. Development now targets a single topology: local Godot Editor <-> local MCP client.

Relevant docs:

- [Quick Start](docs/QUICKSTART.md)
- [Architecture](docs/ARCHITECTURE.md)
- [FAQ](docs/FAQ.md)
- [Tool Reference](docs/TOOL_REFERENCE.md)
- [Development Workflow](docs/DEVELOPMENT_WORKFLOW.md)

## License

MIT. See [LICENSE](LICENSE).