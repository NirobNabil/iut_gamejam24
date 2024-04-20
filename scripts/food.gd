extends Node2D

class_name Food

var spice_level: float = 0
var hotness: float = 0

var obj_name = "cooked_food"
var obj_type = "food"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_spice_level(lvl: float):
	spice_level = lvl
	$SpiceLevelBar.value = lvl

func set_hotness(lvl: float):
	hotness = lvl
	$HotnessBar.value = lvl

func disable_area2d():
	$Area2D.monitorable = false
	$Area2D.monitoring = false

func disable_visibility():
	visible = false

func enable_everything():
	visible = true
	$Area2D.monitorable = true
	$Area2D.monitoring = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
