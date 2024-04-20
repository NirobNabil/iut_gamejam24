extends Node2D

signal area_entered(pot_node)
signal selected(pot_node)

@export var pot_name: String
var obj_type: String = "pot"

@export var cooking_texture: Texture2D
@export var idle_texture: Texture2D

const cooking_time: float = 5.0

var contains: Array[String]
var isCooking: bool = false
var isCooked: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if isCooking:
		$ProgressBar.visible = true
		if $Timer.time_left == 0:
			stop_cooking()
			$ProgressBar.visible = false
		else:
			print($Timer.time_left)
			$ProgressBar.value = ( cooking_time - $Timer.time_left)/cooking_time * 100
	else:
		$ProgressBar.visible = false
	pass

func start_cooking():
	isCooking = true;
	$Timer.start(cooking_time)
	$sprite.texture = cooking_texture
	
func stop_cooking():
	isCooking = true;
	$sprite.texture = idle_texture
	

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
		contains.append(ing_node.ing_name)
		start_cooking()
		return "success"
		
func addSpice(ing_node):
	if contains.size() == 0:
		return "spice can only be added after rice/meat"
	elif contains.has(ing_node.ing_name):
		return "same ingredient can't be added twice"
	else:
		contains.append(ing_node.ing_name)
		return "success"
	
	
func addIng(ing_node):
	var status: String;
	if check_if_base(ing_node):
		status = addBase(ing_node)
	else:
		status = addSpice(ing_node)
	update_ingredient_effects()
	return status
	
func _on_area_2d_area_entered(area):
	area_entered.emit(self)


func _on_area_2d_input_event(viewport, event, shape_idx):
	if event.is_pressed():
		print("clicked")
		selected.emit(self)
