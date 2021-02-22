extends Panel

func LoadLastFromQueue():
	$M/R/CHeader/R/D/Label.text = CallManager.CallQueue[-1].Header
	$M/R/T/Level.text = "Clearance: " + CallManager.CallQueue[-1].Level
	$M/R/T/Operation.text = "Operation " + CallManager.CallQueue[-1].Operation
	$M/R/Content.bbcode_text = CallManager.CallQueue[-1].Content
	$M/R/CButtons/Decision1/C/Label.text = CallManager.CallQueue[-1].Text1
	$M/R/CButtons/Decision1.disabled = !CallManager.CallQueue[-1].Show1
	$M/R/CButtons/Decision2/C/Label.text = CallManager.CallQueue[-1].Text2
	$M/R/CButtons/Decision2.disabled = !CallManager.CallQueue[-1].Show2
	$M/R/CButtons2/Decision3/C/Label.text = CallManager.CallQueue[-1].Text3
	$M/R/CButtons2/Decision3.disabled = !CallManager.CallQueue[-1].Show3
	$M/R/CButtons2/Decision4/C/Label.text = CallManager.CallQueue[-1].Text4
	$M/R/CButtons2/Decision4.disabled = !CallManager.CallQueue[-1].Show4

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
	CallManager.CallQueue.remove(len(CallManager.CallQueue)-1)
	if len(CallManager.CallQueue) == 0:
		get_tree().change_scene("res://main.tscn")
	else:
		LoadLastFromQueue()

func _on_Decision2_pressed():
	# call performs logic only
	CallManager.CallQueue[-1].Decision2Callback.call_func(
		CallManager.CallQueue[-1].Decision2Argument
	)
	# then we decide if we pick up a next call or do we return to the main screen
	CallManager.CallQueue.remove(len(CallManager.CallQueue)-1)
	if len(CallManager.CallQueue) == 0:
		get_tree().change_scene("res://main.tscn")
	else:
		LoadLastFromQueue()

func _on_Decision3_pressed():
	# call performs logic only
	CallManager.CallQueue[-1].Decision3Callback.call_func(
		CallManager.CallQueue[-1].Decision3Argument
	)
	# then we decide if we pick up a next call or do we return to the main screen
	CallManager.CallQueue.remove(len(CallManager.CallQueue)-1)
	if len(CallManager.CallQueue) == 0:
		get_tree().change_scene("res://main.tscn")
	else:
		LoadLastFromQueue()

func _on_Decision4_pressed():
	# call performs logic only
	CallManager.CallQueue[-1].Decision4Callback.call_func(
		CallManager.CallQueue[-1].Decision4Argument
	)
	# then we decide if we pick up a next call or do we return to the main screen
	CallManager.CallQueue.remove(len(CallManager.CallQueue)-1)
	if len(CallManager.CallQueue) == 0:
		get_tree().change_scene("res://main.tscn")
	else:
		LoadLastFromQueue()
