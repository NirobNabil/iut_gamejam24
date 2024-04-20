extends Node2D

class_name Table

signal area_entered(table_node)
signal selected(table_node)
signal score_obtained(score)

var obj_type: String = "table"
var food: Node2D = null
var requested_spice_level = null

# Called when the node enters the scene tree for the first time.
func _ready():
	initiate_customer_request()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass

func initiate_customer_request():
	$Timer.start(2)

var block_size = 20
func quantized_equal(a:int, b:int):
	if a > b+block_size/2 || a < b-block_size/2:
		return false
	return true

func put_food(food_node):
	if food_node.obj_type != "food":
		return "You can only server cooked foods"
	food = food_node
	if quantized_equal( food_node.spice_level, requested_spice_level ):
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
	requested_spice_level = rng.randi_range(0, 100)
	$CustomerRequest.text = "Biryani " + str(requested_spice_level) + " spice"
