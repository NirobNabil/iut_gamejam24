extends Node2D

class_name Pot

signal area_entered(pot_node)
signal selected(pot_node)

@export var pot_name: String
var obj_type: String = "pot"

@export var cooking_texture: Texture2D
@export var idle_texture: Texture2D

const cooking_time: float = 1.0

var contains: Array[Ing]
var isCooking: bool = false
var isCooked: bool = false
var cookedFood: Food = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if isCooking:
		$ProgressBar.visible = true
		if $Timer.time_left == 0:
			set_food_ready()
			$ProgressBar.visible = false
		else:
			print($Timer.time_left)
			$ProgressBar.value = ( cooking_time - $Timer.time_left)/cooking_time * 100
	else:
		$ProgressBar.visible = false
	pass


#### Handle cooking

func start_cooking():
	isCooking = true;
	$Timer.start(cooking_time)
	$sprite.texture = cooking_texture


func set_food_ready():
	if cookedFood != null:
		return
	var food: Food = load("res://prefabs/food.tscn").instantiate()
	food.set_hotness(100)
	food.disable_area2d()
	for ing in contains:
		food.set_spice_level( food.spice_level + ing.spice_level )  
	cookedFood = food
	print(cookedFood)
	add_child(cookedFood) 
	$StatusLabel.text = "food ready"
	#$sprite.texture = idle_texture

func stop_cooking():
	contains = []
	isCooking = false
	$sprite.texture = idle_texture
	
	
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
	return ing_node.ing_name == "rice" || ing_node.ing_name == "meat"

func addBase(ing_node):
	if contains.size() != 0:
		return "rice/meat can only be the first ingredient"
	elif isCooking:
		return "rice/meat can only be added once"
	else:
		contains.append(ing_node)
		start_cooking()
		return "success"
		
func addSpice(ing_node):
	if contains.size() == 0:
		return "spice can only be added after rice/meat"
	elif check_ing_already_exists(ing_node):
		return "same ingredient can't be added twice"
	else:
		contains.append(ing_node)
		return "success"
	
func addIng(ing_node):
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
