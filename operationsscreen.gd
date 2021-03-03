extends Control

var lastSelected = -1

func _ready():
	for g in GameLogic.Operations:
		var desc = g.Started + " " + g.Name
		if g.Stage != OperationGenerator.Stage.FINISHED and g.Stage != OperationGenerator.Stage.CALLED_OFF and g.Stage != OperationGenerator.Stage.FAILED:
			desc += " (ongoing)"
		$C/M/R/ItemList.add_item(desc)

func _on_Return_pressed():
	get_tree().change_scene("res://main.tscn")

func _on_ItemList_item_selected(index):
	var desc = "Operation " + GameLogic.Operations[index].Name + "\n" \
		+ "Goal: " + GameLogic.Operations[index].GoalDescription + "\n"
	if GameLogic.Operations[index].AbroadPlan != null:
		desc += GameLogic.Operations[index].AbroadPlan.Description
	desc += "Result: " + GameLogic.Operations[index].Result
	lastSelected = index
	if GameLogic.Operations[index].Stage == OperationGenerator.Stage.FINISHED or GameLogic.Operations[index].Stage == OperationGenerator.Stage.CALLED_OFF or GameLogic.Operations[index].Stage == OperationGenerator.Stage.FAILED:
		$C/M/R/CReturn/CallOff.disabled = true
	else:
		$C/M/R/CReturn/CallOff.disabled = false
	$C/M/R/ItemDetails.text = desc

func _on_CallOff_pressed():
	if lastSelected != -1:
		GameLogic.ImplementCallOff(lastSelected)
		get_tree().change_scene("res://main.tscn")
