# Development Workflow

English | [简体中文](DEVELOPMENT_WORKFLOW.zh-CN.md)

## Goal

Keep `godot-mcp-local` reproducible as a local Godot Editor MCP integration. Every change should be validated against the actual editor/runtime path that it affects.

## Working loop

```text
inspect current behavior
-> make one focused change
-> run static/GDScript validation
-> run real Godot editor validation
-> run MCP smoke/regression for affected tools
-> inspect Git diff
-> document factual results
-> commit
```

## Source of truth

- Public MCP schema: live `tools/list`.
- Godot-side behavior: actual editor/runtime execution.
- Project files: repository working tree.
- Release/validation claims: only tests actually run in the current change.

Never promote an unrun test to PASS.

## Transport changes

When changing `transport/local_mcp_server.gd` or connection UI, verify:

- bind is still `127.0.0.1`;
- configured port is honored;
- `/mcp` endpoint works;
- `initialize`, `ping`, `tools/list`, `tools/call` work;
- JSON response works;
- SSE response works;
- browser-origin requests are rejected;
- editor mutations remain serialized;
- no remote/tunnel credential path has been introduced.

With the editor plugin running, execute the stdlib-only regression check:

```sh
python tools/test_transport.py --url http://127.0.0.1:39050/mcp
```

The check verifies the exact JSON type of numeric and string request IDs in JSON/SSE success and error responses. Checking only HTTP 200 or numeric equality would miss `0` being changed to `0.0`, which breaks Codex's MCP client.

After replacing the transport script, restart the editor before testing. Do not reload the active transport from its own MCP request.

## Tool changes

For a changed tool/domain:

1. validate schema;
2. verify read-only/destructive annotations;
3. test a normal successful case;
4. test at least one invalid-input/error case;
5. verify project/path bounds;
6. verify Undo/Redo if the tool promises editor Undo/Redo;
7. run regression for adjacent tools when shared helpers changed.

## Runtime changes

When changing runtime/debugger code, test both:

- no game running;
- a debuggable project running.

Verify teardown after stopping the game and disabling/reloading the plugin.

## Screenshot changes

Verify at least one real image return and confirm resolution/output bounds. Do not substitute a metadata-only response for screenshot validation.

## Diagnostics helper changes

Rebuild the Windows runner from `tools/run-helper/`, copy it to the addon bin path, then verify:

- normal child-process completion;
- stdout/stderr capture;
- timeout behavior;
- output truncation limit;
- invalid scene/path handling.

## Repository hygiene

Before commit:

```text
git status --short
git diff --check
git diff --stat
```

Confirm no `.godot/`, temporary test assets, logs, unrelated demo/game content, or local configuration files are staged.

## Validation record

For non-trivial changes, summarize exactly what was run, for example:

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

If something is unsupported or not run, state that explicitly instead of calling it PASS.
