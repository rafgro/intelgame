extends Control

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
				# special case: expired
				if GameLogic.DateYear > WorldData.Methods[t][m].EndYear:
					desc += " (expired)"
				# special case: future
				elif GameLogic.DateYear < WorldData.Methods[t][m].StartYear:
					desc = "--- (will be discovered in the future)"
				else:
					desc += " (unavailable)"
			$C/M/R/ItemList.add_item(desc)
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
		var intelDesc = "none"
		if WorldData.Methods[t][m].MinimalIntel > 50: intelDesc = "very deep"
		elif WorldData.Methods[t][m].MinimalIntel > 30: intelDesc = "deep"
		elif WorldData.Methods[t][m].MinimalIntel > 10: intelDesc = "medium"
		elif WorldData.Methods[t][m].MinimalIntel > 0: intelDesc = "basic"
		elif WorldData.Methods[t][m].MinimalIntel > -20: intelDesc = "negligible"
		desc += "Required amount of intel beforehand: " + intelDesc + "\n"
		var localDesc = "none"
		if WorldData.Methods[t][m].MinimalIntel > 85: localDesc = "native"
		elif WorldData.Methods[t][m].MinimalIntel > 70: localDesc = "perfect"
		elif WorldData.Methods[t][m].MinimalIntel > 45: localDesc = "great"
		elif WorldData.Methods[t][m].MinimalIntel > 20: localDesc = "basic"
		elif WorldData.Methods[t][m].MinimalIntel > 3: localDesc = "negligible"
		desc += "Required language and local custom knowledge: " + localDesc + "\n"
	else:
		# special case: expired
		if GameLogic.DateYear > WorldData.Methods[t][m].EndYear:
			desc += "This method is expired due to world technological progress."
		# special case: future
		elif GameLogic.DateYear < WorldData.Methods[t][m].StartYear:
			desc = "This method will be discovered in the future."
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
			if GameLogic.Technology < WorldData.Methods[t][m].MinimalTech:
				desc += "Minimal technology level required: " + str(WorldData.Methods[t][m].MinimalTech) + "%"
				desc += " (" + str(int(WorldData.Methods[t][m].MinimalTech-GameLogic.Technology)) + "% more required)\n"
	$C/M/R/Details.text = desc
