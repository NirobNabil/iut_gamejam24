extends Node2D

class_name Ing

signal entered_area(ing_node)
signal selected_ing(ing_node)

@export var texture: Texture2D
@export var ing_name: String

var obj_name = ing_name
var obj_type: String = "ing"
var spice_level: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	#get_node("sprite").texture = texture
	pass # Replace with function body.

func init(res: ing_res):
	ing_name = res.ing_name
	obj_name = ing_name ## bad naming fix later
	spice_level = res.spice_level
	$SpiceLevelIndicator.value = spice_level
	get_node("sprite").texture = res.texture
	

func clone():
	var clone = self.duplicate()
	clone.ing_name = self.ing_name
	clone.obj_name = self.obj_name
	clone.texture = self.texture
	clone.spice_level = self.spice_level
	
	return clone
	
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

