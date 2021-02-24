extends Panel

var mapOfCountries = []
var lastMapOfOrgs = []
var lastSelectedOrg = -1

func _ready():
	# mapping countries to their ids - to allow sorting, by hostility by default
	mapOfCountries.clear()
	$M/R/Countries.clear()
	var descs = []
	for c in range(1, len(WorldData.Countries)):
		var desc = WorldData.Countries[c].Name
		if WorldData.DiplomaticRelations[0][c] < -30:
			desc += " (hostile country)"
			descs.push_front(desc)
			mapOfCountries.push_front(c)
		elif WorldData.DiplomaticRelations[0][c] > 30:
			desc += " (friendly country)"
			descs.append(desc)
			mapOfCountries.append(c)
		else:
			descs.append(desc)
			mapOfCountries.append(c)
	for d in descs:
		$M/R/Countries.add_item(d)

func _on_Return_pressed():
	get_tree().change_scene("res://main.tscn")

func _on_Countries_item_selected(index):
	lastMapOfOrgs.clear()
	$M/R/Organizations.clear()
	for o in range(0, len(WorldData.Organizations)):
		if mapOfCountries[index] in WorldData.Organizations[o].Countries and WorldData.Organizations[o].Known == true:
			lastMapOfOrgs.append(o)
			var desc = WorldData.Organizations[o].Name
			$M/R/Organizations.add_item(desc)

func _on_Organizations_item_selected(index):
	if index <= len(lastMapOfOrgs):
		var o = lastMapOfOrgs[index]
		lastSelectedOrg = o
		var desc = "Details on " + WorldData.Organizations[o].Name + ":\n"
		if len(WorldData.Organizations[o].IntelDescription) == 0:
			desc += "No intel gathered."
		else:
			desc += WorldData.Organizations[o].IntelDescType + " | " + str(WorldData.Organizations[o].IntelIdentified) + " identified members"
			desc += "\n" + PoolStringArray(WorldData.Organizations[o].IntelDescription).join("\n")
		$M/R/Details.bbcode_text = desc
		$M/R/H/Gather.disabled = false

func _on_Gather_pressed():
	if lastSelectedOrg != -1:
		OperationGenerator.NewOperation(0, lastSelectedOrg, OperationGenerator.Type.MORE_INTEL)
		# if possible, start fast
		if GameLogic.OfficersInHQ > 0:
			GameLogic.Operations[-1].AnalyticalOfficers = GameLogic.OfficersInHQ
			GameLogic.Operations[-1].Stage = OperationGenerator.Stage.PLANNING_OPERATION
			GameLogic.Operations[-1].Started = GameLogic.GiveDateWithYear()
			GameLogic.Operations[-1].Result = "ONGOING (PLANNING)"
		get_tree().change_scene("res://main.tscn")

func _on_Recruit_pressed():
	pass # Replace with function body.
