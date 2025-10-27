extends Node

const SERVER_KEY = "defaultkey"
const HOST = "127.0.0.1"
const PORT = 7350
const SCHEME = "http"

var _nakama_client: NakamaClient = null
var _nakama_session: NakamaSession = null
var _nakama_socket: NakamaSocket = null
var _username: String = ""

signal game_state_updated(data)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_nakama_client = Nakama.create_client(SERVER_KEY, HOST, PORT, SCHEME)

func _authenticate_or_create_user_async(username: String):
	var device_id = OS.get_unique_id()
	var nakama_result = await _nakama_client.authenticate_device_async(device_id, username, true)
	if nakama_result and not nakama_result.is_exception():
		_nakama_session = nakama_result
		_username = username
		return {
			"success": true,
			"message": "Authentication Successful for " + _username
		}
	var error_message = "Authentication Failed (Unknown or Network Error)"
	if nakama_result and nakama_result.is_exception():
		error_message = nakama_result.exception.message
		_nakama_session = null
	return {
		"success": false,
		"message": error_message,
	}

func _get_active_session_async():
	if _nakama_session == null:
		return {
			"success": false,
			"message": "Session not found and requires Authentication",
			"session": null
		}
	
	if not _nakama_session.is_expired():
		return {
			"success": true,
			"message": "Session is Active",
			"session": _nakama_session
		}
	
	if _nakama_session.is_refresh_expired():
		_nakama_session = null
		return {
			"success": false,
			"message": "Refresh Token expired and requires Authentication",
			"session": null
		}
	
	var _new_session = await _nakama_client.session_refresh_async(_nakama_session)
	if not _new_session.is_exception():
		_nakama_session = _new_session
		return {
			"success": true,
			"message": "Session is Successfully Refreshed",
			"session": _new_session
		}
	_nakama_session = null
	return {
		"success": false,
		"message": "Refresh Failed",
		"session": null
	}

func _connect_socket_async():
	var session_result = await _get_active_session_async()
	
	if not session_result.success:
		return {
			"success": false,
			"message": "Session is not Active. Authentication Failed"
		}
	
	_nakama_socket = Nakama.create_socket_from(_nakama_client)
	
	var connect_status = await _nakama_socket.connect_async(_nakama_session)
	
	if not connect_status.is_exception():
		_nakama_socket.received_match_state.connect(_on_raw_match_data_recieved)
		return {
			"success": true,
			"message": "Socket Connected"
		}
	
	_nakama_socket = null
	return {
			"success": false,
			"message": "Socket Connection Failed"
		}

func _on_raw_match_data_recieved(match_id: String, presences: Array, op_code: int, data: String):
	var json_parser = JSON.parse_string(data)
	
	if json_parser.error == OK:
		var game_state_data = json_parser.result
		game_state_updated.emit(game_state_data)
	else:
		print("Error parsing incoming match state data ", json_parser.error_string)

func _create_match_async():
	if _nakama_socket == null:
		return {
			"success": false,
			"match_id": null,
			"message": "Socket is not Connected"
		}
	
	var match_data = await _nakama_socket.create_match_async()
	
	if not match_data.is_exception():
		return {
			"success": true,
			"match_id": match_data.match_id,
			"message": "Successfully created Match"
		}
	
	return {
			"success": false,
			"match_id": null,
			"message": match_data.exception.message
		}

func _join_match_async(match_id: String):
	if _nakama_socket == null:
		return {
			"success": false,
			"match_id": null,
			"message": "Socket is not Connected"
		}
	
	var match_data = await _nakama_socket.join_match_async(match_id)
	
	if not match_data.is_exception():
		return {
			"success": true,
			"match_id": match_data.match_id,
			"message": "Successfully joined Match"
		}
	
	return {
			"success": false,
			"match_id": null,
			"message": match_data.exception.message
		}

func _send_match_move(match_id: String, op_code: int, data: Dictionary):
	if _nakama_socket == null:
		print("Error, Cannot send Move. Socket is not Connected")
		return
	
	var string_data = JSON.stringify(data)
	_nakama_socket.send_match_state_async(match_id, op_code, string_data)
