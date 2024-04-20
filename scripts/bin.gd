extends Node2D

class_name Bin

signal entered_area(bin_node)
signal selected_bin(bin_node)

@export var texture: Texture2D
@export var ing_name: String

var obj_name = ing_name
var obj_type: String = "bin"

# Called when the node enters the scene tree for the first time.
func _ready():
	#get_node("sprite").texture = texture
	pass # Replace with function body.

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func put(item):
	return true

func _on_area_2d_area_entered(area):
	entered_area.emit(self)

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event.is_pressed():
		selected_bin.emit(self)

