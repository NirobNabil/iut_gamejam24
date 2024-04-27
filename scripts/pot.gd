extends Node2D

class_name Pot

signal area_entered(pot_node)
signal selected(pot_node)
signal spell_activated()
signal misspelled()

@export var pot_name: String
var obj_type: String = "pot"

@export var cooking_texture: Texture2D
@export var idle_texture: Texture2D

const cooking_time: float = 35.0

var spell: String
var contains: Array[Ing]
var isCooking: bool = false
var isCooked: bool = false
var cookedFood: Food = null
var initial_scale: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	initial_scale = $sprite.scale
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if isCooking:
		$ProgressBar.visible = true
		$ProgressBar.value = ( cooking_time - $Timer.time_left)/cooking_time * 100
	else:
		$ProgressBar.visible = false
	pass




#### Handle cooking
func start_cooking(tex: Texture2D):
	initialize_new_spell()
	isCooking = true;
	$Timer.start(cooking_time)
	$sprite.texture = cooking_texture
	
	for part in $Smoke.get_children():
		part.emitting = true

func get_base_type():
	for ing in contains:
		if ing.ing_name in Super.bases:
			return ing.ing_name

func set_food_ready():
	if cookedFood != null:
		return
	var food: Food = load("res://prefabs/food.tscn").instantiate()
	food.init( get_base_type(), 100, 0 )
	for ing in contains:
		food.set_spice_level( food.spice_level + ing.spice_level )  
	cookedFood = food
	add_child(cookedFood)
	#cookedFood.get_node("sprite").texture = $sprite.texture
	$StatusLabel.text = "food ready"
	$sprite.texture = idle_texture
	
	deinitialize_spell()

func stop_cooking():
	deinitialize_spell()
	contains = []
	isCooking = false
	$sprite.texture = idle_texture
	#$sprite.scale = initial_scale
	
	for part in $Smoke.get_children():
		part.emitting = false
	
func pickup_food():
	var food = cookedFood
	cookedFood = null
	remove_child(food)
	$StatusLabel.text = ""
	stop_cooking()
	return food


#### handle ingredient adding


func check_ing_already_exists(ing_node):
	for ing in contains:
		if ing.ing_name == ing_node.ing_name:
			return true
	return false

func update_ingredient_effects():
	print("Ingredients in pot: ", contains)

func check_if_base(ing_node):
	return ing_node.ing_name in Super.bases

func addBase(ing_node):
	if contains.size() != 0:
		return "rice/meat can only be the first ingredient"
	elif isCooking:
		return "rice/meat can only be added once"
	else:
		contains.append(ing_node)
		start_cooking(ing_node.get_node("sprite").texture)
		return "success"
		
func addSpice(ing_node):
	if contains.size() == 0:
		return "spice can only be added after rice/meat"
	#elif check_ing_already_exists(ing_node):
		#return "same ingredient can't be added twice"
	else:
		contains.append(ing_node)
		return "success"
	
func addIng(ing_node):
	if cookedFood != null:
		return "Cannot add ingredient to cooked food"
	var status: String;
	if not ing_node is Ing:
		return "Can only put ingredients inside pot"
	if check_if_base(ing_node):
		status = addBase(ing_node)
	else:
		status = addSpice(ing_node)
	update_ingredient_effects()
	return status
	
	
#### signal emitters
func _on_area_2d_area_entered(area):
	area_entered.emit(self)

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event.is_pressed():
		selected.emit(self)

var rng = RandomNumberGenerator.new()
func initialize_new_spell():
	var spell_collection = get_tree().get_nodes_in_group("manager")[0].spell_collection
	spell = spell_collection[rng.randi_range(0, spell_collection.size()-1)] 
	write_spell( "", spell )
	return spell
	
func deinitialize_spell():
	spell = ""
	write_spell( "", spell )
	

func write_spell(matched:String, unmatched: String):
	$RichTextLabel.text = "[center][color=green]" + matched + "[/color]" + unmatched + "[/center]"

const spell_time = 20
func activate_spell():
	if $Timer.time_left >= spell_time: 
		$Timer.start( $Timer.time_left - spell_time )
		spell = initialize_new_spell()
	else:
		$Timer.stop()
		_on_timer_timeout()
		
	spell_activated.emit()

func _on_world_typed_spell_sig(typed_spell):
	
	if spell == "":
		misspelled.emit()
		return
	
	var matched = ""
	var unmatched = spell
	if spell.substr(0, typed_spell.length()) == typed_spell:
		matched = typed_spell
		unmatched = spell.substr(typed_spell.length(), spell.length()-typed_spell.length()+1)
	else:
		misspelled.emit()
		
	write_spell( matched, unmatched )
	
	if unmatched == "":
		activate_spell()



func _on_timer_timeout():
	set_food_ready()
	$ProgressBar.visible = false


func _on_penalty_activated():
	if not $Timer.is_stopped():
		$Timer.start( min( cooking_time, $Timer.time_left + 20 ) )
		
	
