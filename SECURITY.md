# Security Policy

English | [简体中文](SECURITY.zh-CN.md)

`godot-mcp-local` gives a local MCP client substantial control over a live Godot project. Treat the MCP endpoint as a privileged local development interface.

## Trust model

The supported deployment is:

```text
local MCP client
      |
      | 127.0.0.1 only
      v
Godot MCP Local
      |
      v
current Godot project/editor/runtime
```

Security assumptions:

- the MCP client runs on the same computer as Godot;
- the listener remains bound to loopback;
- the user trusts local development tools that can connect to that port;
- command-layer path, schema, and destructive-operation checks remain enabled.

There is no remote authentication because remote connectivity is intentionally out of scope.

## Network boundary

The MCP server:

- binds only to `127.0.0.1`;
- defaults to port `39050` and path `/mcp`;
- rejects browser-origin requests carrying `Origin` or `Sec-Fetch-*` style headers;
- does not contain a public relay, reverse proxy, tunnel client, API key, OAuth flow, or credential store.

**Do not** change the bind address to `0.0.0.0`, expose the port through LAN/WAN forwarding, publish it through a tunnel, or place it behind a reverse proxy without first adding a new authenticated remote-access design.

Loopback binding is a local boundary, not a substitute for authentication on a remote network.

## Godot/project boundary

The tool layer continues to validate project-relative paths and structured arguments. Project and resource mutations are intended to remain inside the current Godot project, primarily `res://`.

Do not add generic arbitrary-shell or unrestricted filesystem tools to the public MCP surface without a separate review.

## Browser-to-localhost defense

Localhost services can be targeted by malicious websites. The server therefore rejects requests that present browser-origin headers. This reduces drive-by browser access to the fixed local endpoint.

This check is defense-in-depth. If the endpoint ever becomes remotely reachable, use real authentication and authorization instead of relying on header checks.

## Tool safety

Public tools retain read-only/destructive annotations where available and validate their input schema before invoking internal commands. Mutation commands should:

- stay scoped to the current project;
- preserve Undo/Redo where the existing Godot integration supports it;
- validate node/resource paths and expected types;
- keep output and image capture bounded;
- avoid arbitrary process execution.

## Runtime bridge

Runtime control travels through Godot's debugger channel and the reserved `GodotMCPLocalRuntime` autoload. Runtime mutations can change the live game immediately and may cause crashes if a caller invokes unsafe project methods.

The runtime API should remain explicit and bounded. Do not expose arbitrary native memory access or host process APIs.

## Diagnostics helper

The bundled Windows diagnostics runner can launch the current Godot executable with bounded arguments and captures stdout/stderr. Its implementation is intentionally narrow:

- executable is resolved from the running Godot installation;
- scene paths are validated within `res://`;
- timeout and output size are capped;
- user arguments have count/length limits;
- it is not a general shell command tool.

Source is in `tools/run-helper/`.

## Screenshots and data exposure

Screenshot tools return selected Godot editor/game image content, not arbitrary desktop capture. Logs and project inspection may still contain sensitive project data; only connect local clients you trust.

## Custom tools

Third-party Custom Tools execute inside the Godot editor process. Enabling one expands the effective MCP capability surface. Review custom addon code before enabling it.

## Reporting a vulnerability

For a security issue, avoid posting exploit details, private project contents, or secrets in a public issue. Provide the smallest reproducible description possible and state:

- affected version/commit;
- Godot version and OS;
- whether the issue crosses the loopback/project boundary;
- exact tool or endpoint involved;
- expected versus actual behavior.

## Security-sensitive changes

Changes to any of the following require explicit review and regression testing:

- bind address or transport;
- browser-origin filtering;
- path validation outside `res://`;
- arbitrary process execution;
- runtime debugger bridge;
- screenshot scope;
- custom-tool trust boundary;
- destructive tool annotations/validation.