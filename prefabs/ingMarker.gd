extends Marker2D

class_name IngMarker

signal unblocked(marker)

var blocked: bool = false
var block_time = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func activate_penalty():
	print("activated penalty")
	blocked = true
	$BlockedTimer.start(block_time)

func _on_blocked_timer_timeout():
	print("deactivate penalty")
	blocked = false
	unblocked.emit(self)
