extends Panel

func _ready():
	for g in GameLogic.Operations:
		var desc = g.Started + " " + g.Name
		if g.Stage == OperationGenerator.Stage.FINISHED:
			desc += " (finished)"
		$M/R/ItemList.add_item(desc)

func _on_Return_pressed():
	get_tree().change_scene("res://main.tscn")

func _on_ItemList_item_selected(index):
	var desc = "Operation " + GameLogic.Operations[index].Name + "\n" \
		+ "Goal: " + GameLogic.Operations[index].GoalDescription + "\n"
	if GameLogic.Operations[index].AbroadPlan != null:
		desc += GameLogic.Operations[index].AbroadPlan.Description
	desc += "Result: " + GameLogic.Operations[index].Result
	$M/R/ItemDetails.text = desc
