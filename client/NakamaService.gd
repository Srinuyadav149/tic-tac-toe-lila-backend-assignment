extends Node

const SERVER_KEY = "defaultkey"
const HOST = "127.0.0.1"
const PORT = 7350
const SCHEME = "http"

var _nakama_client: NakamaClient = null
var _nakama_session: NakamaSession = null
var _username: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_nakama_client = Nakama.create_client(SERVER_KEY, HOST, PORT, SCHEME)
	pass # Replace with function body.

func _authenticate_or_create_user(username):
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

func _get_active_session():
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
	else:
		_nakama_session = null
		return {
			"success": false,
			"message": "Refresh Failed",
			"session": null
		}
