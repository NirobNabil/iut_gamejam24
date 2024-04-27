extends Node2D

class_name Table

signal area_entered(table_node)
signal selected(table_node)
signal score_obtained(score)
@export var order_soundtracks: Array[AudioStreamWAV]
@export var waiting_soundtracks: Array[AudioStreamWAV]
@export var happy_soundtracks: Array[AudioStreamWAV]
@export var angry_soundtracks: Array[AudioStreamWAV]



var obj_type: String = "table"
var food: Node2D = null
var requested_spice_level: int
var requested_hotness_level: int
var requested_biriyani_type: String

const SPICE_LEVELS = Super.SPICE_LEVELS
const HOTNESS_LEVELS = [0, 25, 50, 100]
const BIRIYANI_TYPES = ["Chicken", "Beef", "Mutton"]

# Called when the node enters the scene tree for the first time.
func _ready():
	initiate_customer_request()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass

func initiate_customer_request():
	$Timer.start(2)

var block_size = 20
func quantized_equal(a:int, b:int, c: int, d: int, e: String, f: String):
	if (a in range(b-10, b+10)) and (c in range(d-10, d+10)) and (f.to_lower() in e.split("_")): return true
	return false

func put_food(food_node):
	if food_node.obj_type != "food":
		return "You can only server cooked foods"
	food = food_node
	if quantized_equal( food_node.spice_level, requested_spice_level, food_node.hotness, requested_hotness_level, food.obj_name, requested_biriyani_type ):
		score_obtained.emit(50)
		$CustomerRequest.text = "thank you"
	else:
		score_obtained.emit(10)
		$CustomerRequest.text = "vodox rante ashse"
	initiate_customer_request()
	return "success"

	
#### signal emitters
func _on_area_2d_area_entered(area):
	area_entered.emit(self)

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event.is_pressed():
		selected.emit(self)

var rng = RandomNumberGenerator.new()
func _on_timer_timeout():
	requested_spice_level = SPICE_LEVELS[rng.randi_range(0, SPICE_LEVELS.size() - 1)]
	requested_hotness_level = HOTNESS_LEVELS[rng.randi_range(0, HOTNESS_LEVELS.size() - 1)]
	requested_biriyani_type = BIRIYANI_TYPES[rng.randi_range(0, BIRIYANI_TYPES.size() - 1)]
	$CustomerRequest.text = requested_biriyani_type + " Biryani\n" + str(requested_spice_level) + "% spicy\n" + str(requested_hotness_level) + "% hot"
