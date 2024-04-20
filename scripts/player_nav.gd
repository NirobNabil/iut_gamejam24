extends CharacterBody2D


@export var movement_speed: float = 600
@export var navigation_agent: NavigationAgent2D

var movement_target: Vector2

func _input(event):
	if event is InputEventMouseButton:
		movement_target = event.position
		navigation_agent.set_target_position(movement_target) 

# Called when the node enters the scene tree for the first time.
func _ready():
	navigation_agent.set_path_desired_distance(15.0)
	navigation_agent.set_target_desired_distance(15.0)
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))

	#call_deferred("actor_setup")	

func actor_setup():
	await get_tree().physics_frame
	
	set_movement_target(movement_target)
	
func set_movement_target(movement_target: Vector2):
	pass

var g: float = 0.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(NavigationServer2D.map_get_path(navigation_agent.get_navigation_map(), global_position, movement_target, false))
	#print(movement_target)
	#print(navigation_agent.get_next_path_position())
	#print(global_position)
	if carrying != null:
		$carrying_label.text = carrying.obj_name
	else:
		$carrying_label.text = "empty hand"
	pass

func _physics_process(delta):
	
	if navigation_agent.is_navigation_finished():
		return

	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * movement_speed
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)
	
func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
	move_and_slide()


func set_info(note):
	$instruction_label.text = note

var carrying: Node2D = null

func carry_obj(obj):
	if carrying == null:
		carrying = obj
		print(carrying)
		return "success"
	else:
		return "Cannot carry more than one item"

func drop_obj():
	if carrying == null:
		return "Not carrying any item"
	else:
		carrying = null
		return "success"
