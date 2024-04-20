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
	if target is Ing:
		handle_ing_action(target)
	elif target is Pot:
		handle_pot_action(target)
	elif target is Bin:
		handle_bin_action(target)
	elif target is Table:
		handle_table_action(target)
	elif target is Fan:
		handle_fan_action(target)


func handle_pot_action(pot: Pot):
	if $Player.carrying != null:
		var status = pot.addIng($Player.carrying)
		if status == "success":
			$Player.drop_obj()
		else :
			$Player.set_info(status)
	else:
		if pot.cookedFood != null:
			$Player.carry_obj( pot.pickup_food() )
		else:
			$Player.set_info("Not carrying any ingredient")


## this func is a mess
func handle_table_action(table: Table):
	var obj = $Player.carrying
	if obj != null and obj.obj_type != "food":
		$Player.set_info("Only cooked food can be served")
		return
	var status: String = $Player.drop_obj()
	if status != "success":
		$Player.set_info(status)
		return
	status = table.put_food(obj)

func handle_fan_action(fan: Fan):
	print("came fan action")
	var obj = $Player.carrying
	if obj == null:
		var food: Food = fan.pickup_food()
		if food != null:
			$Player.carry_obj(food)
			return
			
		$Player.set_info("Nothing to cool")
		return
	elif not obj is Food:
		$Player.set_info("Only cooked food can be cooled")
		return
		
	var status: String = fan.put_food(obj)
	print(status)
	if status != "success":
		$Player.set_info(status)
		return
	status = $Player.drop_obj()
	if status != "success":
		###TODO: undo put food
		$Player.set_info(status)
		return
	

func handle_ing_action(ing: Ing):
	var status: String = $Player.carry_obj(ing.clone())
	if status != "success":
		$Player.set_info(status)

func handle_bin_action(bin: Bin):
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
	
func _on_table_area_entered(table_node):
	check_and_set_reached(table_node)

func _on_fan_entered_area(fan_node):
	check_and_set_reached(fan_node)



func _on_ingredient_table_ing_selected(ing_node):
	set_target(ing_node)

func _on_pot_selected(pot_node):
	set_target(pot_node)

func _on_bin_selected_bin(bin_node):
	set_target(bin_node)
	
func _on_table_selected(table_node):
	set_target(table_node)
	
func _on_fan_selected_fan(fan_node):
	set_target(fan_node)



func _on_table_score_obtained(score):
	$Hud/ScoreContainer.text = str( int($Hud/ScoreContainer.text) + int(score) )

