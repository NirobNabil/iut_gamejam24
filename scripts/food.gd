extends Node2D

class_name Food

var spice_level: float = 0
var hotness: float = 0

var obj_name = "cooked food"
var obj_type = "food"

var base_type = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init( new_base_type: String, hotness: float, spice_level: float ):
	base_type = new_base_type
	obj_name = "Cooked " + new_base_type
	set_hotness(hotness)
	set_spice_level(spice_level)
	disable_area2d()

func set_spice_level(lvl: float):
	spice_level = lvl
	$SpiceLevelBar.value = lvl

func set_hotness(lvl: float):
	hotness = lvl
	$HotnessBar.value = lvl

func disable_area2d():
	$Area2D.monitorable = false
	$Area2D.monitoring = false

func disable_food_sprite():
	$sprite.visible = false

func disable_visibility():
	visible = false

func enable_everything():
	$sprite.visible = true
	visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
