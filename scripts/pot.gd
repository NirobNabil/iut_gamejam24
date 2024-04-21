extends Node2D

class_name Pot

signal area_entered(pot_node)
signal selected(pot_node)

@export var pot_name: String
var obj_type: String = "pot"

@export var cooking_texture: Texture2D
@export var idle_texture: Texture2D

const cooking_time: float = 15.0

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
		if $Timer.time_left == 0:
			set_food_ready()
			$ProgressBar.visible = false
		else:
			$ProgressBar.value = ( cooking_time - $Timer.time_left)/cooking_time * 100
	else:
		$ProgressBar.visible = false
	pass


#### Handle cooking

func start_cooking(tex: Texture2D):
	isCooking = true;
	$Timer.start(cooking_time)
	$sprite.texture = cooking_texture

func get_base_type():
	for ing in contains:
		if ing.ing_name in Super.bases:
			return ing.ing_name

func set_food_ready():
	if cookedFood != null:
		return
	var food: Food = load("res://prefabs/food.tscn").instantiate()
	food.init( get_base_type(), 100, 0 )
	print("Food base ", food.base_type)
	for ing in contains:
		food.set_spice_level( food.spice_level + ing.spice_level )  
	cookedFood = food
	print(cookedFood)
	add_child(cookedFood)
	cookedFood.get_node("sprite").texture = $sprite.texture
	$StatusLabel.text = "food ready"
	#$sprite.texture = idle_texture

func stop_cooking():
	contains = []
	isCooking = false
	$sprite.texture = idle_texture
	$sprite.scale = initial_scale
	
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
	elif check_ing_already_exists(ing_node):
		return "same ingredient can't be added twice"
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
