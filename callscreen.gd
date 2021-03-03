extends Control

func LoadFirstFromQueue():
	if len(CallManager.CallQueue) > 0:
		$C/M/R/CHeader/R/D/Label.text = CallManager.CallQueue[0].Header
		$C/M/R/T/Level.text = "Clearance: " + CallManager.CallQueue[0].Level
		$C/M/R/T/Operation.text = "Operation " + CallManager.CallQueue[0].Operation
		$C/M/R/Content.bbcode_text = CallManager.CallQueue[0].Content
		$C/M/R/CButtons/Decision1/C/Label.text = CallManager.CallQueue[0].Text1
		$C/M/R/CButtons/Decision1.disabled = !CallManager.CallQueue[0].Show1
		$C/M/R/CButtons/Decision2/C/Label.text = CallManager.CallQueue[0].Text2
		$C/M/R/CButtons/Decision2.disabled = !CallManager.CallQueue[0].Show2
		$C/M/R/CButtons2/Decision3/C/Label.text = CallManager.CallQueue[0].Text3
		$C/M/R/CButtons2/Decision3.disabled = !CallManager.CallQueue[0].Show3
		$C/M/R/CButtons2/Decision4/C/Label.text = CallManager.CallQueue[0].Text4
		$C/M/R/CButtons2/Decision4.disabled = !CallManager.CallQueue[0].Show4

# Called when the node enters the scene tree for the first time.
func _ready():
	LoadFirstFromQueue()

func EmptyFunc():
	pass

func _on_Decision1_pressed():
	# call performs logic only
	CallManager.CallQueue[0].Decision1Callback.call_func(
		CallManager.CallQueue[0].Decision1Argument
	)
	# then we decide if we pick up a next call or do we return to the main screen
	CallManager.CallQueue.remove(0)
	if len(CallManager.CallQueue) == 0:
		get_tree().change_scene("res://main.tscn")
	else:
		LoadFirstFromQueue()

func _on_Decision2_pressed():
	# call performs logic only
	CallManager.CallQueue[0].Decision2Callback.call_func(
		CallManager.CallQueue[0].Decision2Argument
	)
	# then we decide if we pick up a next call or do we return to the main screen
	CallManager.CallQueue.remove(0)
	if len(CallManager.CallQueue) == 0:
		get_tree().change_scene("res://main.tscn")
	else:
		LoadFirstFromQueue()

func _on_Decision3_pressed():
	# call performs logic only
	CallManager.CallQueue[0].Decision3Callback.call_func(
		CallManager.CallQueue[0].Decision3Argument
	)
	# then we decide if we pick up a next call or do we return to the main screen
	CallManager.CallQueue.remove(0)
	if len(CallManager.CallQueue) == 0:
		get_tree().change_scene("res://main.tscn")
	else:
		LoadFirstFromQueue()

func _on_Decision4_pressed():
	# call performs logic only
	CallManager.CallQueue[0].Decision4Callback.call_func(
		CallManager.CallQueue[0].Decision4Argument
	)
	# then we decide if we pick up a next call or do we return to the main screen
	CallManager.CallQueue.remove(0)
	if len(CallManager.CallQueue) == 0:
		get_tree().change_scene("res://main.tscn")
	else:
		LoadFirstFromQueue()
