extends Panel

# Called when the node enters the scene tree for the first time.
func _ready():
	$M/R/Trust.text = "Current Trust: " + str(GameLogic.Trust) + "%"

func _on_Return_pressed():
	get_tree().change_scene("res://main.tscn")
