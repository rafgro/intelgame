extends Control

var ifFirstQuit = true

func _ready():
	ifFirstQuit = true

func _on_Decision3_pressed():
	$C/V/M/R/CHeader/R/D/Label.text = "saving game..."
	$C/V/M/R/CButtons2/Decision3.disabled = true
	Managestate.SaveGame()
	$C/V/M/R/CHeader/R/D/Label.text = "game saved"
	$C/V/M/R/CButtons2/Decision3.disabled = false

func _on_Decision4_pressed():
	get_tree().change_scene("res://main.tscn")

func _on_Quit_pressed():
	if ifFirstQuit == true:
		ifFirstQuit = false
		$C/V/M/R/CHeader/R/D/Label.text = "are you sure? press again to quit"
	elif ifFirstQuit == false:
		get_tree().quit()
