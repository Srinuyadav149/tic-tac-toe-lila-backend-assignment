extends Node

var client:NakamaClient
var server_key = "default_key"
var host = "127.0.0.1"
var port = 7350
var scheme = "http"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	client = Nakama.create_client("default_key", "127.0.0.1", 7350, "http")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
