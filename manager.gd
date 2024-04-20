extends Node2D

var target: Node2D
var target_reached: bool


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print("Target: ", target)
	#print("Reached: ", target_reached)
	if target_reached:
		handle_target_reached()
		target_reached = false

func handle_target_reached():
	print(target.obj_type)
	if target.obj_type == "ing":
		handle_ing_action(target)
	elif target.obj_type == "pot":
		handle_pot_action(target)
	elif target.obj_type == "bin":
		handle_bin_action(target)

func handle_pot_action(pot):
	if $Player.carrying != null:
		var status = pot.addIng($Player.carrying)
		if status == "success":
			$Player.drop_obj()
		else :
			$Player.set_info(status)
	else:
		$Player.set_info("Not carrying any ingredient")

func handle_ing_action(ing):
	var status: String = $Player.carry_obj(ing)
	if status != "success":
		$Player.set_info(status)

func handle_bin_action(bin):
	print("came to bin")
	var status = $Player.drop_obj()
	if status != "success":
		$Player.set_info( status )
		

func set_target(node: Node2D):
	target_reached = false
	target = node
	
func check_and_set_reached(node: Node2D):
	if node == target:
		target_reached = true
	else:
		target_reached = false


func _on_ingredient_table_ing_area_entered(ing_node):
	check_and_set_reached(ing_node)

func _on_pot_area_entered(pot_node):
	check_and_set_reached(pot_node)

func _on_bin_entered_area(bin_node):
	check_and_set_reached(bin_node)


func _on_ingredient_table_ing_selected(ing_node):
	set_target(ing_node)

func _on_pot_selected(pot_node):
	set_target(pot_node)

func _on_bin_selected_bin(bin_node):
	set_target(bin_node)

