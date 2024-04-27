extends CanvasLayer


func _ready():
	pass # Replace with function body.


func _process(delta):
	pass

func show_buttons():
	$Buttons.visible = true


func _on_play_button_down(button):
	get_node(button).position.y += 5


func _on_play_button_up(button):
	get_node(button).position.y -= 5


func _on_play_pressed():
	get_tree().change_scene_to_file("res://world.tscn")


func _on_tuto_pressed():
	$Tutorial.modulate = Color(1, 1, 1, 1)
	$Tutorial.mouse_filter = 0

func _on_go_back_pressed():
	$Tutorial.modulate = Color(0, 0, 0, 0)
	$Tutorial.mouse_filter = 1
