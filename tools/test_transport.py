"""Exercise the running editor's MCP transport using only Python's standard library."""

import argparse
import json
import urllib.error
import urllib.request


def http(url, payload=None, accept="application/json", headers=None, method="POST"):
    data = json.dumps(payload).encode() if payload is not None else None
    request = urllib.request.Request(
        url, data=data, method=method,
        headers={"Content-Type": "application/json", "Accept": accept, **(headers or {})},
    )
    try:
        response = urllib.request.urlopen(request, timeout=10)
    except urllib.error.HTTPError as error:
        response = error
    with response:
        return response.status, response.headers.get_content_type(), response.read().decode()


def rpc(url, method, request_id, params=None, accept="application/json"):
    status, content_type, body = http(url, {
        "jsonrpc": "2.0", "id": request_id, "method": method, "params": params or {},
    }, accept)
    assert status == 200, (method, status, body)
    if "text/event-stream" in accept:
        assert content_type == "text/event-stream", content_type
        assert body.endswith("\n\n"), "Incomplete SSE event"
        body = "\n".join(line[6:] for line in body.splitlines() if line.startswith("data: "))
    else:
        assert content_type == "application/json", content_type
    response = json.loads(body)
    assert response["jsonrpc"] == "2.0", response
    # Equality alone misses Godot's 1 -> 1.0 conversion, rejected by Rust MCP clients.
    assert type(response["id"]) is type(request_id), (method, request_id, body)
    assert response["id"] == request_id, (method, request_id, body)
    return response


def run(url):
    count = 0
    for accept in ["application/json", "application/json, text/event-stream"]:
        for request_id in [0, 1, -1, 2**31, 2**53 - 1, "request-1", "1"]:
            initialized = rpc(url, "initialize", request_id, {
                "protocolVersion": "2025-11-25", "capabilities": {},
                "clientInfo": {"name": "transport-regression", "version": "1.0"},
            }, accept)
            assert initialized["result"]["protocolVersion"] == "2025-11-25"
            assert initialized["result"]["serverInfo"]["name"] == "godot-mcp-local"
            assert rpc(url, "ping", request_id, accept=accept)["result"] == {}
            error = rpc(url, "unknown.regression.method", request_id, accept=accept)
            assert error["error"]["code"] == -32601, error
            count += 3
        status, _, body = http(url, {"jsonrpc": "2.0", "method": "notifications/initialized"}, accept)
        assert status == 202 and body == "", (status, body)
        tools = rpc(url, "tools/list", 2, accept=accept)["result"]["tools"]
        names = [tool["name"] for tool in tools]
        assert len(names) == len(set(names)) and "godot.get_status" in names, names
        status = rpc(url, "tools/call", 3, {
            "name": "godot.get_status", "arguments": {},
        }, accept)["result"]
        assert not status.get("isError", False), status
        editor = json.loads(status["content"][0]["text"])
        assert editor["editor"] is True, editor
        print(f"PASS {accept}: {len(names)} unique tools; {editor}")
        count += 3
    for headers in [{"Origin": "https://example.com"}, {"Sec-Fetch-Site": "cross-site"}]:
        assert http(url, {"jsonrpc": "2.0", "id": 1, "method": "ping"}, headers=headers)[0] == 403
        count += 1
    assert http(url, method="GET")[0] == 405
    assert http(url, method="DELETE")[0] == 204
    print(f"TRANSPORT: {count + 2} checks passed")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--url", default="http://127.0.0.1:39050/mcp")
    run(parser.parse_args().url)
