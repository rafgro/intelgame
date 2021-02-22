extends Panel

# Called when the node enters the scene tree for the first time.
func _ready():
	$M/R/Level.text = CallManager.Level
	$M/R/Operation.text = CallManager.Operation
	$M/R/Content.text = CallManager.Content

func _on_Decision1_pressed():
	CallManager.Decision1Callback.call_func()
