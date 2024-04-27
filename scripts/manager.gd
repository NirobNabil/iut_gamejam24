extends Node2D

signal typed_spell_sig(typed_spell: String)
signal penalty_activated()

var score: int = 0
var reputation: int = 10

var target: Node2D
var target_reached: bool

var spell_states = {}
var typed_spell = ""
var misspell_count: int

var spell_collection = ["ZEST", "VAR", "VET", "STRESS", "TRES", "TREE", "WREC", "XVED", "XCAY", "VREX", "DEAD", "WAS", "RAGE", "WAR", "RAVEN", "ABYSS", "DECAY", "CURSE", "WRATH"]

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
		
	if reputation <= 0:
		print("game over")
		
	#for pot in spell_states.keys():
		#print(spell_states[pot]["spell"])

# spell handling mechanisms

func _input(event):
	if not event is InputEventKey:
		return
		
	if event.pressed:
		misspell_count = 0
		typed_spell += char(event.keycode)
		typed_spell_sig.emit(typed_spell)
	


var rng = RandomNumberGenerator.new()
func set_spell_state(pot, state):
	var spell = spell_collection[rng.randi_range(0, spell_collection.size())]
	print(spell)
	spell_states[pot] = {
		"state": state,
		"spell": spell
	}


func handle_target_reached():
	print("reached ", target)
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
	elif target is Plate:
		handle_plate_action(target)
	target = null

func handle_plate_action(plate: Plate):
	if $Player.carrying != null:
		if not $Player.carrying is Food:
			return "Only cooked food can be placecd"
		var status = plate.put_food($Player.carrying)
		if status == "success":
			$Player.drop_obj()
		else :
			$Player.set_info(status)
	else:
		if plate.readyFood != null:
			$Player.carry_obj( plate.pickup_food() )
		else:
			$Player.set_info("Biryani combination not ready")

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
	if obj == null:
		$Player.set_info("Not carrying any food")
		return
	
	if obj != null and obj.obj_type != "food":
		$Player.set_info("Only cooked food can be served")
		return
	var status: String  = table.put_food(obj)
	if status != "success":
		$Player.set_info(status)
		return
	status = $Player.drop_obj()
	if status != "success":
		$Player.set_info(status)
		return

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
	var ret_arr: Array = ing.carry()
	var status = ret_arr[0]
	if status == "success":
		$Player.carry_obj( ret_arr[1] )
	#var status: String = ing.clone())
	if status != "success":
		$Player.set_info(status)

func handle_bin_action(bin: Bin):
	var status = $Player.drop_obj()
	if status != "success":
		$Player.set_info( status )
		

func set_target(node: Node2D):
	target = node
	if( node.get_node("Area2D").overlaps_area($Player/Area2D)  ):
		## this checks if the player is already inside the target
		target_reached = true
		handle_target_reached()
	else:
		target_reached = false
	
func check_and_set_reached(node: Node2D):
	if node == target:
		target_reached = true
	else:
		target_reached = false

func game_over():
	$GameOver.visible = true


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

func _on_plate_entered_area(plate_node):
	check_and_set_reached(plate_node)


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

func _on_plate_selected_plate(plate_node):
	set_target(plate_node)



func _on_table_score_obtained(_score):
	print("score called")
	score += _score
	$Hud/ScoreContainer.text = str( int(score) )


func _on_pot_spell_activated():
	typed_spell = ""


func misspell_penalty():
	penalty_activated.emit()
	#health -= 1
	print("activated penalty")

func _on_pot_misspelled():
	misspell_count += 1
	if misspell_count == 4:
		if typed_spell.length() > 1:
			misspell_penalty()
		typed_spell = ""

func _on_table_reputation_loss():
	print("called on repitaton loss ", reputation)
	reputation -= 1


func _on_texture_button_pressed():
	get_tree().change_scene_to_file("res://world.tscn")
