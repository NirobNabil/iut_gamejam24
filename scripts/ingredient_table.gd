extends StaticBody2D

signal ing_area_entered(ing_node)
signal ing_selected(ing_node)

@export var ing_markers: Array[Marker2D] 
@export var ing_resources: Array[ing_res] 

var ing1: Node
var ing2: Node
var ing3: Node

var start_from: int = 4

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for i in range(start_from):
		create_ing( ing_markers[i], ing_resources[i] )
	
	generate_ingredients()
	
	pass # Replace with function body.

func generate_ingredients():
	for i in range(start_from, ing_markers.size()):
		create_ing( ing_markers[i], ing_resources[ rng.randi_range(start_from, ing_resources.size()-1) ] )
		

func regenerate_ingredients():
	for node in get_children():
		if node is Ing:
			if node.ing_name in Super.bases:
				continue
			node.visible = false
			node.queue_free()
	generate_ingredients()

func create_ing(marker: Marker2D, res: ing_res):
	var ing_prefab = preload("res://prefabs/ingredient.tscn")
	var ing = ing_prefab.instantiate()
	ing.init(res)
	ing.transform.origin = marker.transform.origin
	add_child(ing)
	
	ing.connect( "entered_area", _handle_ing_area_entered_signal )
	ing.connect( "selected_ing", _handle_ing_area_selected_signal )
	#print(ing.is_connected("selected_ing", _handle_ing_area_selected_signal))
	

func _handle_ing_area_entered_signal(ing_node):
	print("entered " + ing_node.ing_name )
	ing_area_entered.emit(ing_node)
	
func _handle_ing_area_selected_signal(ing_node):
	print("selected " + ing_node.ing_name )
	ing_selected.emit(ing_node)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_ingredients_regenerate_timer_timeout():
	regenerate_ingredients()
