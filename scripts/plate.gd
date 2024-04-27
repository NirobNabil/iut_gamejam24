extends Node2D

class_name Plate

signal entered_area(plate_node)
signal selected_plate(plate_node)

@export var rice_texture: Texture2D
@export var meat_texture: Texture2D
@export var mutton_texture: Texture2D
@export var chicken_texture: Texture2D
@export var rice_meat_texture: Texture2D
@export var empty_texture: Texture2D

var contains: Array[Food]
var readyFood: Food = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$sprite.texture = empty_texture
	#get_node("sprite").texture = texture
	pass # Replace with function body.

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func combine_food():
	var food: Food = load("res://prefabs/food.tscn").instantiate()
	var new_base_type = ""
	var new_spice_level = 0
	var new_hotness = 0
	for containing_food in contains:
		new_base_type += "_" + containing_food.base_type
		new_spice_level += containing_food.spice_level
		new_hotness = max( new_hotness, containing_food.hotness )
		
	#### spice level is avg of total
	new_spice_level = new_spice_level / contains.size()
	food.init( new_base_type, new_hotness, new_spice_level, true )
	food.disable_food_sprite()
	add_child(food)
	readyFood = food
	contains.clear()

func update_sprite():
	print("update  sprite ", contains.size())
	var tex_size = -1
	var factor = .2
	var y = 0
	var scale_y = -1
	
	if readyFood == null and contains.size() == 0:
		$FoodSprite.texture = null
		return
	
	if readyFood != null:
		factor = .2
		$FoodSprite.texture = rice_meat_texture
	#elif contains.size() == 0:
		#tex_size = 740
		#$FoodSprite.texture = empty_texture
	elif contains.size() == 1:
		print(contains[0].base_type)
		if contains[0].base_type == "rice":
			factor = 0.15
			y = -19.318
			scale_y = .2
			$FoodSprite.texture = rice_texture
		elif contains[0].base_type == "meat":
			tex_size = 740
			$FoodSprite.texture = meat_texture
		elif contains[0].base_type == "mutton":
			tex_size = 740
			$FoodSprite.texture = mutton_texture
		elif contains[0].base_type == "beef":
			tex_size = 740
			$FoodSprite.texture = meat_texture
		elif contains[0].base_type == "chicken":
			factor = .2
			$FoodSprite.texture = chicken_texture
	elif contains.size() == 2:
		tex_size = 740
		$FoodSprite.texture = rice_meat_texture

	$FoodSprite.transform.origin = Vector2(0, y)
	$FoodSprite.scale = Vector2(factor, factor)
	if scale_y != -1:
		$FoodSprite.scale = Vector2($FoodSprite.scale.x, scale_y)

func put_food(item: Food):
	if not item is Food:
		return "Can only place cooked foods"
	
	if contains.size() != 0 and item.combined:
		return "cannot add cooked food"
	
	if readyFood == null:
		for food in contains:
			print("contains food ", food.base_type)
			if food.base_type == item.base_type:
				return "Cannot combine two food of same base"
		print("putting item  ", item)
		contains.append(item)
		update_sprite()
		#print("Plate ", contains.size())
		#item.enable_everything()
		item.visible = false
		add_child(item)
		if contains.size() == 2:
			combine_food()
		return "success"
		
	return "Plate already contains food"

func pickup_food():
	if readyFood != null:
		var food:Food = readyFood
		readyFood = null
		update_sprite()
		remove_child(food)
		return food
	return null
		

func _on_area_2d_area_entered(area):
	entered_area.emit(self)

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event.is_pressed():
		selected_plate.emit(self)

