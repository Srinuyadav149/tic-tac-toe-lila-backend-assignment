extends Control

@onready var cells = [
	$CenterContainer/VBoxContainer/GridContainer/cell_0,
	$CenterContainer/VBoxContainer/GridContainer/cell_1,
	$CenterContainer/VBoxContainer/GridContainer/cell_2,
	$CenterContainer/VBoxContainer/GridContainer/cell_3,
	$CenterContainer/VBoxContainer/GridContainer/cell_4,
	$CenterContainer/VBoxContainer/GridContainer/cell_5,
	$CenterContainer/VBoxContainer/GridContainer/cell_6,
	$CenterContainer/VBoxContainer/GridContainer/cell_7,
	$CenterContainer/VBoxContainer/GridContainer/cell_8,
]

const images = [
	"res://assets/empty.png",
	"res://assets/cross.png",
	"res://assets/circle.png",
]

const options = [0,0,0,0,0,0,0,0,0]

var current_match_id: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(cells.size()):
		cells[i].texture_normal = load(images[options[i]])
		cells[i].texture_pressed = load(images[options[i]])
		cells[i].texture_hover = load(images[options[i]])
		cells[i].pressed.connect(_on_cell_clicked.bind(i))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_cell_clicked(cell_index):
	if current_match_id.is_empty():
		print("Error, match id not set. Cannot send Move.")
		return
	
	NakamaService._send_match_move(current_match_id, 1, {"position": cell_index})
