# Quick Start

English | [简体中文](QUICKSTART.zh-CN.md)

## Requirements

- Godot 4.7.x (validated on 4.7.2 Standard x64 on Windows).
- Codex CLI or another local MCP client that supports Streamable HTTP.
- The target Godot project open in the editor.

No OpenAI tunnel, API key, browser connector, Node server, or Python server is required.

## 1. Install the addon

### Recommended: Windows one-click installer

Download `godot-mcp-local-v0.1.1-windows-x64-installer.exe` from the GitHub Release, run it, and select the target `project.godot`. It installs/upgrades the addon and enables **Godot MCP Local** automatically while preserving other enabled plugins.

If the project is already open in Godot, reopen it after the installer finishes.

### Manual install

Copy:

```text
addons/godot_mcp_local/
```

into the target Godot project.

Enable **Godot MCP Local** under:

```text
Project -> Project Settings -> Plugins
```

## 2. Check the local endpoint

Open the bottom **MCP Local** panel. The default endpoint is:

```text
http://127.0.0.1:39050/mcp
```

The addon starts the server automatically. If port `39050` is already in use, choose another port in the panel and press **Restart on Port**.

## 3. Add it to Codex

Run:

```powershell
codex mcp add godot --url http://127.0.0.1:39050/mcp
```

Or press **Copy Codex Command** in the Godot panel and paste the generated command into a terminal.

Verify:

```powershell
codex mcp list
```

## 4. First safe test

Ask Codex:

```text
Use the Godot MCP tools to inspect the current project. Report the project name, Godot version, current scene, and top-level scene tree. Do not modify anything.
```

The server should expose the current tool catalogue, including `godot.get_status`, scene/project tools, runtime tools, screenshots, logs, tests, batch/transaction, and authoring helpers.

## 5. Normal development workflow

A practical loop is:

```text
Codex edits project files when direct file editing is simplest
        +
Godot MCP manipulates/inspects editor and runtime state
        +
Godot CLI or diagnostics.run_capture validates code
        +
Git saves known-good baselines
```

Use the MCP for operations where editor/runtime truth matters: scene tree, Inspector state, screenshots, live runtime, input injection, animation/resources, Undo/Redo, and test/diagnostic evidence.

## Port changes

The selected port is stored in Godot `EditorSettings` under:

```text
godot_mcp_local/port
```

Changing the port changes the MCP URL. Update the Codex registration by removing/re-adding it if necessary:

```powershell
codex mcp remove godot
codex mcp add godot --url http://127.0.0.1:<new-port>/mcp
```

## Troubleshooting

### Codex cannot connect

Check, in order:

1. Godot Editor is still running.
2. **Godot MCP Local** is enabled.
3. The panel says `Status: listening`.
4. Codex uses the exact endpoint shown in the panel.
5. No other process owns the selected port.

On Windows you can check the default port with:

```powershell
Get-NetTCPConnection -LocalPort 39050 -State Listen
```

### The plugin fails to load

Check the Godot Output panel and confirm the addon exists at:

```text
res://addons/godot_mcp_local/plugin.cfg
```

Do not install it under the old `addons/godot_mcp_chatgpt/` path.

### Runtime tools are unavailable

Runtime inspection requires a debuggable running project and Godot's debugger session. Editor-time tools can still work when no game is running.

### `diagnostics.run_capture` says the runner is missing

The Windows package/source checkout must include:

```text
addons/godot_mcp_local/bin/windows/godot-mcp-runner.exe
```

The helper source is under `tools/run-helper/`.

## Security note

The server is intentionally loopback-only. Do not expose it through `0.0.0.0`, LAN binding, port forwarding, a reverse proxy, or a public tunnel. The local design has no remote-authentication layer.