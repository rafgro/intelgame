extends Panel

var mapOfMethods = []  # maps to 2d array to with [first index, second index]

func _ready():
	for t in range(0,len(WorldData.Methods)):
		for m in range(0,len(WorldData.Methods[t])):
			var desc = ""
			if t == 0: desc += "intel: "
			elif t == 1: desc += "recruitment: "
			elif t == 2: desc += "offensive: "
			desc += WorldData.Methods[t][m].Name
			if WorldData.Methods[t][m].Available == false:
				desc += " (unavailable)"
			$M/R/ItemList.add_item(desc)
			mapOfMethods.append([t,m])

func _on_Return_pressed():
	get_tree().change_scene("res://main.tscn")

func _on_ItemList_item_selected(index):
	var t = mapOfMethods[index][0]
	var m = mapOfMethods[index][1]
	var desc = "Craft: " + WorldData.Methods[t][m].Name + "\n" + "Quality: " + str(WorldData.Methods[t][m].Quality) + "/100 | Risk: " + str(WorldData.Methods[t][m].Risk) + "/100\n"
	if WorldData.Methods[t][m].Available == true:
		desc += "Cost: €" + str(WorldData.Methods[t][m].Cost) + ",000 weekly\n"
		desc += "Officers involved: " + str(WorldData.Methods[t][m].OfficersRequired) + "\n"
	else:
		desc += "Cost: €" + str(WorldData.Methods[t][m].Cost) + ",000 weekly"
		if GameLogic.FreeFundsWeeklyWithoutOngoing() < WorldData.Methods[t][m].Cost:
			desc += " (€" + str(int(WorldData.Methods[t][m].Cost-GameLogic.FreeFundsWeeklyWithoutOngoing())) + "k more to enable)"
		desc += "\nOfficers involved: " + str(WorldData.Methods[t][m].OfficersRequired)
		if GameLogic.ActiveOfficers < WorldData.Methods[t][m].OfficersRequired:
			desc += " (" + str(int(WorldData.Methods[t][m].OfficersRequired-GameLogic.ActiveOfficers)) + " officers more to enable)"
		desc += "\nMinimal skill required: " + str(WorldData.Methods[t][m].MinimalSkill) + "%"
		if GameLogic.StaffSkill < WorldData.Methods[t][m].MinimalSkill:
			desc += " (" + str(int(WorldData.Methods[t][m].MinimalSkill-GameLogic.StaffSkill)) + "% more required)\n"
		if WorldData.Methods[t][m].MinimalTrust > 0 and WorldData.Methods[t][m].MinimalTrust > GameLogic.Trust:
			desc += "Minimal government trust required: " + str(WorldData.Methods[t][m].MinimalTrust) + "%"
			desc += " (" + str(int(WorldData.Methods[t][m].MinimalTrust-GameLogic.Trust)) + "% more required)\n"
	$M/R/Details.text = desc
