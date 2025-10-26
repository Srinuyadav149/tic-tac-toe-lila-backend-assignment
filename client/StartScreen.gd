extends Control

@onready var button = $CenterContainer/VBoxContainer/start
@onready var username = $CenterContainer/VBoxContainer/name
@onready var error = $CenterContainer/VBoxContainer/error
var error_message = "Please enter your name to continue"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.connect("pressed", _on_button_pressed)
	pass # Replace with function body.

func _on_button_pressed():
	if not username.text.strip_edges().is_empty():
		var nakama_result = await NakamaService._authenticate_or_create_user(username.text)
		print(nakama_result)
	else:
		error.text = error_message
	pass
