extends StaticBody2D

signal ing_area_entered(ing_node)
signal ing_selected(ing_node)

@export var ing_markers: Array[IngMarker] 
@export var ing_resources: Array[ing_res] 

var base_markers: Array[IngMarker]
var spice_markers: Array[IngMarker]
var ing1: Node
var ing2: Node
var ing3: Node
var blocked_ings: Array[int] = []
var spices: Array[Ing]
var meats: Array[Ing]

var base_markers_count: int = 4

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	base_markers = ing_markers.slice(0, base_markers_count)
	create_ing( ing_markers[0], ing_resources[0] )
	meats = generate_meats()
	
	spice_markers = ing_markers.slice(base_markers_count)
	spices = generate_spices()
	
	pass # Replace with function body.
	
func generate_meats():
	var meats: Array[Ing] = []
	var meat_resources = ing_resources.slice(1, base_markers_count).duplicate()
	meat_resources.shuffle()
	for i in range(1, base_markers_count):
		meats.append( create_ing( ing_markers[i], meat_resources[i - 1] ) )
	return meats

func regenerate_meats():
	for i in range(meats.size()):
		var node: Ing = meats[i]
		node.visible = false
		node.queue_free()
	meats = generate_meats()
	
func generate_spices():
	var spices: Array[Ing] = []
	for i in range(base_markers_count, ing_markers.size()):
		spices.append( create_ing( ing_markers[i], ing_resources[ rng.randi_range(base_markers_count, ing_resources.size()-1) ] ) )
	return spices

func regenerate_spices():
	for i in range(spices.size()):
		var node: Ing = spices[i]
		node.visible = false
		node.queue_free()
	spices = generate_spices()

func create_ing(marker: IngMarker, res: ing_res):
	var ing_prefab = preload("res://prefabs/ingredient.tscn")
	var ing = ing_prefab.instantiate()
	ing.init(res)
	ing.transform.origin = marker.transform.origin
	if marker.blocked:
		ing.block()
	add_child(ing)
	
	ing.connect( "entered_area", _handle_ing_area_entered_signal )
	ing.connect( "selected_ing", _handle_ing_area_selected_signal )
	return ing
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
	regenerate_spices()

func _on_meats_regenerate_timer_timeout():
	regenerate_meats()

func _on_penalty_activated():
	var rand: int = rng.randi_range(0, spices.size()-1)
	var block_count: int = 0
	for spice_marker in spice_markers:
		if spice_marker.blocked:
			block_count += 1
	
	# cant block any spice marker if all are already blocked
	if block_count == spice_markers.size():
		return
		
	while( spice_markers[rand].blocked ):
		rand = rng.randi_range(0, spices.size()-1)
	spices[rand].block()
	spice_markers[rand].activate_penalty()


func _on_ing_marker_unblocked(marker):
	for i in range(spice_markers.size()):
		if spice_markers[i] == marker:
			spices[i].unblock()
	
	


