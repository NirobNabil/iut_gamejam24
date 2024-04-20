extends Node2D

class_name Fan

signal entered_area(fan_node)
signal selected_fan(fan_node)

@export var texture: Texture2D
var contains: Node2D = null

const cooldown_time = 20.0

# Called when the node enters the scene tree for the first time.
func _ready():
	#get_node("sprite").texture = texture
	pass # Replace with function body.

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if contains != null:
		contains.set_hotness( max( 0, contains.hotness - calc_hotness_delta(delta) ) )
	pass


func calc_hotness_delta(time_delta):
	return time_delta * ( 100 / cooldown_time )

func put_food(item: Food):
	
	if contains == null:
		print(item.spice_level)
		contains = item
		contains.enable_everything()
		contains.disable_area2d()
		add_child(contains)
		return "success"
	return "cannot cool multiple items"

func pickup_food():
	var food:Food = contains
	contains = null
	remove_child(food)
	return food
		

func _on_area_2d_area_entered(area):
	entered_area.emit(self)

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event.is_pressed():
		selected_fan.emit(self)

