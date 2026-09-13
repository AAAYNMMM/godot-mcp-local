@tool
extends VBoxContainer

var _server: Node
var _editor_settings: EditorSettings
var _port_setting := "godot_mcp_local/port"
var _endpoint_edit: LineEdit
var _port_spin: SpinBox
var _toggle_button: Button
var _restart_button: Button
var _copy_button: Button
var _status_label: Label
var _command_label: Label
var _log_label: Label

func _ready() -> void:
	_build_ui()
	_refresh()

func set_server(server: Node, editor_settings: EditorSettings, port_setting: String) -> void:
	_server = server
	_editor_settings = editor_settings
	_port_setting = port_setting
	if _server != null:
		_server.state_changed.connect(_on_state_changed)
		_server.log_message.connect(_on_log_message)
	if is_node_ready():
		_refresh()

func _build_ui() -> void:
	custom_minimum_size = Vector2(460, 0)

	var title := Label.new()
	title.text = "Godot MCP Local"
	title.add_theme_font_size_override("font_size", 18)
	add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Loopback Streamable HTTP MCP for Codex and other local MCP clients"
	subtitle.modulate.a = 0.72
	add_child(subtitle)
	add_child(HSeparator.new())

	var endpoint_label := Label.new()
	endpoint_label.text = "Local MCP endpoint"
	add_child(endpoint_label)
	_endpoint_edit = LineEdit.new()
	_endpoint_edit.editable = false
	_endpoint_edit.selecting_enabled = true
	add_child(_endpoint_edit)

	var port_row := HBoxContainer.new()
	var port_label := Label.new()
	port_label.text = "Port"
	port_row.add_child(port_label)
	_port_spin = SpinBox.new()
	_port_spin.min_value = 1024
	_port_spin.max_value = 65535
	_port_spin.step = 1
	_port_spin.allow_greater = false
	_port_spin.allow_lesser = false
	_port_spin.custom_minimum_size.x = 130
	port_row.add_child(_port_spin)
	add_child(port_row)

	var buttons := HBoxContainer.new()
	_toggle_button = Button.new()
	_toggle_button.text = "Stop"
	_toggle_button.pressed.connect(_on_toggle_pressed)
	buttons.add_child(_toggle_button)
	_restart_button = Button.new()
	_restart_button.text = "Restart on Port"
	_restart_button.pressed.connect(_on_restart_pressed)
	buttons.add_child(_restart_button)
	_copy_button = Button.new()
	_copy_button.text = "Copy Codex Command"
	_copy_button.pressed.connect(_on_copy_pressed)
	buttons.add_child(_copy_button)
	add_child(buttons)

	_status_label = Label.new()
	_status_label.text = "Status: starting"
	add_child(_status_label)

	_command_label = Label.new()
	_command_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_command_label.modulate.a = 0.82
	add_child(_command_label)

	_log_label = Label.new()
	_log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_log_label.modulate.a = 0.72
	add_child(_log_label)

	var hint := Label.new()
	hint.text = "No tunnel, account login, API key, or public relay is used. The server binds only to 127.0.0.1."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.modulate.a = 0.62
	add_child(hint)

func _refresh() -> void:
	if _server == null or _endpoint_edit == null:
		return
	var desired_port: int = int(_server.get_port())
	if desired_port <= 0 and _editor_settings != null and _editor_settings.has_setting(_port_setting):
		desired_port = int(_editor_settings.get_setting(_port_setting))
	if desired_port <= 0:
		desired_port = int(_server.get_default_port())
	_port_spin.value = desired_port
	_on_state_changed(_server.get_state())

func _on_toggle_pressed() -> void:
	if _server == null:
		return
	if _server.is_listening():
		_server.stop_server()
	else:
		_start_on_selected_port()

func _on_restart_pressed() -> void:
	if _server == null:
		return
	_server.stop_server()
	_start_on_selected_port()

func _start_on_selected_port() -> void:
	var port := int(_port_spin.value)
	if _editor_settings != null:
		_editor_settings.set_setting(_port_setting, port)
	var result: Dictionary = _server.start_server(port)
	if not bool(result.get("ok", false)):
		_on_log_message(str(result.get("error", "Unable to start local MCP server")))
	_refresh()

func _on_copy_pressed() -> void:
	if _server == null:
		return
	var endpoint: String = str(_server.endpoint())
	if endpoint.is_empty():
		return
	DisplayServer.clipboard_set("codex mcp add godot --url %s" % endpoint)
	_on_log_message("Copied Codex MCP command to clipboard.")

func _on_state_changed(state: String) -> void:
	if _status_label == null:
		return
	var endpoint: String = str(_server.endpoint()) if _server != null else ""
	_status_label.text = "Status: %s" % state
	_endpoint_edit.text = endpoint
	_toggle_button.text = "Stop" if state == "listening" else "Start"
	_copy_button.disabled = endpoint.is_empty()
	var display_endpoint := endpoint
	if display_endpoint.is_empty() and _port_spin != null:
		display_endpoint = "http://127.0.0.1:%d/mcp" % int(_port_spin.value)
	_command_label.text = "Codex: codex mcp add godot --url %s" % display_endpoint

func _on_log_message(message: String) -> void:
	if _log_label != null:
		_log_label.text = message
