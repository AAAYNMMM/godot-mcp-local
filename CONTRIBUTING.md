# Contributing

English | [简体中文](CONTRIBUTING.zh-CN.md)

Thanks for contributing to `godot-mcp-local`.

## Project scope

This repository is the **local-only** Godot MCP variant. The supported production topology is:

```text
local MCP client -> 127.0.0.1 Streamable HTTP MCP -> Godot Editor
```

Do not reintroduce a public relay, remote tunnel, API-key flow, account login, or credential store without a separate architecture proposal. Remote connectivity is intentionally out of scope.

## Development environment

Primary validation target:

- Godot 4.7.2 Standard x64
- Windows x64
- GDScript
- Streamable HTTP MCP on loopback

The main addon lives at:

```text
addons/godot_mcp_local/
```

The diagnostics helper source lives at:

```text
tools/run-helper/
```

## Before making changes

1. Read [Architecture](docs/ARCHITECTURE.md).
2. Read [Security](SECURITY.md) for the loopback/project boundaries.
3. Inspect the live public tool schema before changing names or required arguments.
4. Keep unrelated changes out of the patch.

## Public tool design

The project deliberately keeps a compact MCP surface. Prefer extending an existing domain/rollup tool or internal command where that produces a clearer client experience. Do not expose hundreds of one-off tools without strong justification.

Tool changes should include:

- a bounded input schema;
- correct read-only/destructive annotations;
- clear error codes/messages;
- project/path validation;
- regression coverage;
- documentation changes when the public contract changes.

The live `tools/list` result is the authoritative schema.

## Local transport rules

Changes to the transport must preserve these defaults unless an approved design says otherwise:

- bind to `127.0.0.1` only;
- stable `/mcp` path;
- configurable local port;
- serialized editor mutation dispatch;
- JSON and SSE compatibility;
- browser-origin request rejection;
- no remote authentication because no remote listening is supported.

Never silently widen the listener to LAN/public interfaces.

## File and runtime boundaries

- Keep project file operations bounded by the existing `res://` rules.
- Do not add generic arbitrary shell execution.
- Keep screenshot capture limited to supported Godot views.
- Runtime tools should use the debugger/runtime bridge rather than opening extra public listeners.
- Preserve Undo/Redo for editor mutations where the existing command design supports it.

## Diagnostics helper

If `tools/run-helper/` changes:

1. build `godot-mcp-runner.exe` for Windows;
2. place it under `addons/godot_mcp_local/bin/windows/`;
3. verify `diagnostics.run_capture` still returns bounded structured output;
4. record the test in the change notes.

## Minimum validation

For transport/addon changes, run at least:

1. GDScript load/parse check for the addon scripts;
2. real Godot Editor plugin load;
3. verify loopback listener;
4. MCP `initialize`;
5. MCP `tools/list` and public-tool uniqueness;
6. representative read-only call such as `godot.get_status`;
7. JSON response path;
8. SSE response path;
9. browser-origin rejection;
10. `git diff --check`.

For command changes, also run representative behavior tests for the affected domain.

Do not claim a test passed unless it was actually executed.

## Commit hygiene

- Keep generated Godot `.godot/` data out of Git.
- Do not commit temporary smoke-test projects or logs.
- Do not commit unrelated local game/demo content.
- Keep binary additions intentional and documented.
- Use focused commit messages.

## Pull requests / issues

Useful reports include:

- Godot version and OS;
- exact reproduction steps;
- MCP tool/request involved;
- expected versus actual behavior;
- relevant non-sensitive logs;
- whether the problem is editor-time, runtime, transport, screenshot, diagnostics, or custom-tool related.

For security issues, follow [SECURITY.md](SECURITY.md).