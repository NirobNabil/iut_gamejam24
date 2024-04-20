extends Node2D

signal entered_area(ing_node)
signal selected_ing(ing_node)

@export var texture: Texture2D
@export var ing_name: String

var obj_name = ing_name
var obj_type: String = "ing"

# Called when the node enters the scene tree for the first time.
func _ready():
	#get_node("sprite").texture = texture
	pass # Replace with function body.

func init(res: ing_res):
	ing_name = res.ing_name
	obj_name = ing_name ## bad naming fix later
	get_node("sprite").texture = res.texture
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func put(item):
	return true

func _on_area_2d_area_entered(area):
	entered_area.emit(self)

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event.is_pressed():
		selected_ing.emit(self)

