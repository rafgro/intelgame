extends Panel

func LoadLastFromQueue():
	$M/R/Level.text = CallManager.CallQueue[-1].Level
	$M/R/Operation.text = CallManager.CallQueue[-1].Operation
	$M/R/Content.text = CallManager.CallQueue[-1].Content

# Called when the node enters the scene tree for the first time.
func _ready():
	LoadLastFromQueue()

func EmptyFunc():
	pass

func _on_Decision1_pressed():
	# call performs logic only
	CallManager.CallQueue[-1].Decision1Callback.call_func(
		CallManager.CallQueue[-1].Decision1Argument
	)
	# then we decide if we pick up a next call or do we return to the main screen
