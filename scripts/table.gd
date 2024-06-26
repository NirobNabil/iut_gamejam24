extends Node2D

class_name Table

signal area_entered(table_node)
signal selected(table_node)
signal score_obtained(score)
signal reputation_loss()
@export var order_soundtracks: Array[AudioStreamWAV]
@export var waiting_soundtracks: Array[AudioStreamWAV]
@export var happy_soundtracks: Array[AudioStreamWAV]
@export var angry_soundtracks: Array[AudioStreamWAV]



var obj_type: String = "table"
var food: Food = null
var requested_spice_level: int
var requested_hotness_level: int
var requested_biriyani_type: String

const SPICE_LEVELS = Super.SPICE_LEVELS
const HOTNESS_LEVELS = [0, 25, 50, 100]
const BIRIYANI_TYPES = ["Chicken", "Beef", "Mutton"]

const patience_time_arr = [ 200, 175, 150, 125, 100 ]
var patience_time_prob = [ 200, 175, 150, 125, 100 ]
var current_patience_time: float = 0.0

const progress_timer_rel = {
	10: [ 0.6, 0.1, 0.1, 0.1, 0.1 ],
	40: [ 0.5, 0.2, 0.1, 0.1, 0.1 ],
	80: [ 0.3, 0.2, 0.2, 0.2, 0.1 ],
}


# Called when the node enters the scene tree for the first time.
func _ready():
	$ExclaimSprite.visible = false
	$Timer.start(randf_range(0, 4))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print($PatienceTimer.time_left)
	$PatienceBar.value = $PatienceTimer.time_left
	

func initiate_customer_request():
	$Timer.start(rng.randi_range(0,4))

func get_random_time():
	var rand: float = rng.randf()
	var vals = []
	var pp = patience_time_prob.duplicate()
	#print("pp unosrted: ", pp)
	pp.sort()
	#print("pp: ", pp)
	for val in pp:
		if vals.size() == 0:
			vals.append(val)
		else:
			vals.append(vals[-1] + val)
	#print("vals arr: ", vals)
	var val_found = -1
	for i in range(vals.size()):
		if vals[i] > rand:
			val_found = vals[i]
			break
			
	#print("rand: ", rand)
	#print("val_found: ", val_found)
	
	var idx = vals.find( val_found )
	#print("patience_time_arr: ", patience_time_arr)
	#print("patience time: ", patience_time_arr[idx])
	return patience_time_arr[idx]
	

var block_size = 20
func quantized_equal(a:int, b:int, c: int, d: int, e: String, f: String):
	if (a in range(b-20, b+20)) and (c in range(d-20, d+20)) and (f.to_lower() in e.split("_")): return true
	return false

func put_food(food_node):
	$PatienceTimer.stop()
	print("put food called")
	if food_node.obj_type != "food":
		return "You can only server cooked foods"
	food = food_node
	var food_bases = food.obj_name.split('_').slice(1)
	var rice_exist = false
	var meat_exist = false
	
	for base in food_bases:
		if base in Super.rice_bases:
			rice_exist = true
		if base in Super.meat_bases:
			meat_exist = true
	
	if not rice_exist or not meat_exist:
		return "You can only serve foods containing both rice and meat" 
	
	if quantized_equal( food_node.spice_level, requested_spice_level, food_node.hotness, requested_hotness_level, food.obj_name, requested_biriyani_type ):
		score_obtained.emit(50)
		$AudioStreamPlayer2D.stream = happy_soundtracks[rng.randi_range(0, happy_soundtracks.size()-1)]
		$CustomerRequest.text = "thank you"
	else:
		score_obtained.emit(10)
		$AudioStreamPlayer2D.stream = angry_soundtracks[rng.randi_range(0, angry_soundtracks.size()-1)]
		$CustomerRequest.text = "vodox rante ashse"
	initiate_customer_request()

	$AudioStreamPlayer2D.play()
	$ExclaimSprite.visible = true
	await $AudioStreamPlayer2D.finished
	$ExclaimSprite.visible = false


	return "success"

	
#### signal emitters
func _on_area_2d_area_entered(area):
	area_entered.emit(self)

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event.is_pressed():
		selected.emit(self)

var rng = RandomNumberGenerator.new()
func _on_timer_timeout():
	var rand = get_random_time()
	$PatienceTimer.start( rand )
	$PatienceBar.max_value = rand
	requested_spice_level = SPICE_LEVELS[rng.randi_range(0, SPICE_LEVELS.size() - 1)]
	requested_hotness_level = HOTNESS_LEVELS[rng.randi_range(0, HOTNESS_LEVELS.size() - 1)]
	var biryani_type = BIRIYANI_TYPES[rng.randi_range(0, BIRIYANI_TYPES.size() - 1)]
	requested_biriyani_type = biryani_type
	
	if biryani_type == "Beef":
		$AudioStreamPlayer2D.stream = order_soundtracks[rng.randi_range(2, order_soundtracks.size()-1)]
	else:
		$AudioStreamPlayer2D.stream = order_soundtracks[rng.randi_range(0, 1)]
	
	$RageTimer.start( rand - rand*rng.randf_range(0.6, 0.05) )
	$CustomerRequest.text = requested_biriyani_type + " Biryani\n" + str(requested_spice_level) + "% spicy\n" + str(requested_hotness_level) + "% hot"
	$AudioStreamPlayer2D.play()
	$ExclaimSprite.visible = true
	await $AudioStreamPlayer2D.finished
	$ExclaimSprite.visible = false
	

func _on_score_obtained(score):
	#TODO: here the total_score is obtained before updaing the score in manager
	#fix this later
	var total_score = get_tree().get_nodes_in_group("manager")[0].score
	for rel_score in progress_timer_rel.keys():
		if rel_score >= total_score:
			patience_time_prob = progress_timer_rel[rel_score]
			break
	


func _on_patience_timer_timeout():
	
	reputation_loss.emit()
	$CustomerRequest.text = "shalar sharadin lage rante"
	initiate_customer_request()


func _on_rage_timer_timeout():
	$ExclaimSprite.visible = true
	$AudioStreamPlayer2D.stream = waiting_soundtracks[rng.randi_range(0, waiting_soundtracks.size()-1)]
	$AudioStreamPlayer2D.play()
	await $AudioStreamPlayer2D.finished
	$ExclaimSprite.visible = false
	
