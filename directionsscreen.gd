extends Panel

var mapOfCountries = [[],[],[]]  # hostile, neutral, friendly
var lastSelectedCategory = 0
var lastSelectedCountry = -1

func _ready():
	# list setup
	mapOfCountries.clear()
	mapOfCountries = [[],[],[]]
	for c in range(1, len(WorldData.Countries)):
		if WorldData.DiplomaticRelations[0][c] < -30:
			$M/R/Tabs/Hostile/List.add_item(WorldData.Countries[c].Name)
			mapOfCountries[0].append(c)
		elif WorldData.DiplomaticRelations[0][c] > 30:
			$M/R/Tabs/Friendly/List.add_item(WorldData.Countries[c].Name)
			mapOfCountries[2].append(c)
		else:
			$M/R/Tabs/Neutral/List.add_item(WorldData.Countries[c].Name)
			mapOfCountries[1].append(c)
	if len(mapOfCountries[0]) == 0:
		$M/R/Tabs.set_current_tab(1)

func _on_Return_pressed():
	get_tree().change_scene("res://main.tscn")

func _on_Tabs_tab_changed(tab):
	lastSelectedCategory = tab

func _on_List_item_selected(index):
	lastSelectedCountry = mapOfCountries[lastSelectedCategory][index]
	var c = lastSelectedCountry  # shortcut for readability
	var desc = "[b]" + WorldData.Countries[c].Name + "[/b]\npopulation of " + str(int(WorldData.Countries[c].Size)) + " millions | "
	if WorldData.Countries[c].SoftPower > 90: desc += "huge"
	elif WorldData.Countries[c].SoftPower > 70: desc += "large"
	elif WorldData.Countries[c].SoftPower > 40: desc += "average"
	elif WorldData.Countries[c].SoftPower > 20: desc += "low"
	else: desc += "minimal"
	desc += " soft power\n\n"
	if WorldData.Countries[c].DiplomaticTravel == true: desc += "Embassy present, "
	else: desc += "Diplomatic travel unavailable, "
	if WorldData.Countries[c].CovertTravel < 5: desc += "covert travel unavailable"
	elif WorldData.Countries[c].CovertTravel < 20: desc += "covert travel highly risky"
	elif WorldData.Countries[c].CovertTravel < 40: desc += "covert travel risky"
	elif WorldData.Countries[c].CovertTravel < 70: desc += "covert travel available"
	else: desc += "covert travel always available"
	if WorldData.Countries[c].Network > 0:
		desc += "\nNetwork of " + str(WorldData.Countries[c].Network) + " local agents present"
	if WorldData.Countries[c].Station > 0:
		desc += "\nIntelligence station with " + str(WorldData.Countries[c].Station) + " employees present"
	desc += "\nAverage travel cost per officer: €" + str(int(WorldData.Countries[c].TravelCost)) + ",000\n"
	desc += "Average cost of living per officer per week: €" + str(int(WorldData.Countries[c].LocalCost)) + ",000\n\n"
	desc += str(WorldData.Countries[c].OperationStats) + " operations inside performed to date\n"
	desc += "Familiarity with local language: " + str(int(WorldData.Countries[c].KnowhowLanguage)) + "%\n"
	desc += "Familiarity with local customs: " + str(int(WorldData.Countries[c].KnowhowCustoms)) + "%\n"
	if WorldData.Countries[c].Expelled > 0:
		desc += "\n" + str(WorldData.Countries[c].Expelled) + " officers were expelled and are persona non grata"
	$M/R/Details.bbcode_text = desc
	$M/R/H/Develop.disabled = false
	if WorldData.Countries[c].KnowhowLanguage > 25 and WorldData.Countries[c].KnowhowCustoms > 25:
		$M/R/H/Network.disabled = false
		if WorldData.Countries[c].Network > 0:
			$M/R/H/Network.text = "Expand Network"
	else:
		$M/R/H/Network.disabled = true
	if WorldData.Countries[c].KnowhowLanguage > 50 and WorldData.Countries[c].KnowhowCustoms > 50 and WorldData.Countries[c].DiplomaticTravel == true:
		$M/R/H/Station.disabled = false
		if WorldData.Countries[c].Station > 0:
			$M/R/H/Station.text = "Expand Station"
	else:
		$M/R/H/Station.disabled = true

func _on_Develop_pressed():
	if lastSelectedCountry > 0:
		var content = "Officers designed following plans concerning skill development into the direction of " + WorldData.Countries[lastSelectedCountry].Name + ".\n\n"
		# plan a
		var planAofficers = GameLogic.random.randi_range(1, GameLogic.OfficersInHQ)
		var planAlength = GameLogic.random.randi_range(1,8)
		var planAcost = planAofficers*5*planAlength
		content += "[b]Plan A[/b]\n€" + str(planAcost) + ",000 | " + str(planAofficers) + " officers | " + str(planAlength) + " weeks\nlanguage training"
		# plan b
		var planBofficers = GameLogic.random.randi_range(1, GameLogic.OfficersInHQ)
		var planBlength = GameLogic.random.randi_range(4,18)
		var planBcost = planBofficers*2*planBlength
		content += "\n\n[b]Plan B[/b]\n€" + str(planBcost) + ",000 | " + str(planBofficers) + " officers | " + str(planBlength) + " weeks\nembassy residency\nlanguage immersion\nengagement with local culture"
		if WorldData.Countries[lastSelectedCountry].DiplomaticTravel == false:
			planBofficers = GameLogic.random.randi_range(1, GameLogic.OfficersInHQ)
			planBlength = GameLogic.random.randi_range(6,26)
			planBcost = planBofficers*6*planBlength
			content += "\n\n[b]Plan B[/b]\n€" + str(planBcost) + ",000 | " + str(planBofficers) + " officers | " + str(planBlength) + " weeks\nresidency in closest possible country\nacquitance with local emmigrants from targeted country"
		# plan c
		var planCofficers = GameLogic.random.randi_range(1, GameLogic.OfficersInHQ)
		var planClength = GameLogic.random.randi_range(4,8)
		var planCcost = planCofficers*10*planClength
		content += "\n\n[b]Plan C[/b]\n€" + str(planCcost) + ",000 | " + str(planCofficers) + " officers | " + str(planClength) + " weeks\ndevelop passport forging system\ntest and correct covert travel procedures"
		if WorldData.Countries[lastSelectedCountry].CovertTravel > 35:
			planCofficers = GameLogic.random.randi_range(1, GameLogic.OfficersInHQ)
			planClength = GameLogic.random.randi_range(6,12)
			planCcost = planCofficers*5*planClength
			content += "\n\n[b]Plan C[/b]\n€" + str(planCcost) + ",000 | " + str(planCofficers) + " officers | " + str(planClength) + " weeks\ncorrect covert travel procedures\nlive as a covert local"
		content += "\n\nChoose appropriate plan or wait for new plans. Be aware that officers involved in these operations generally will not be in contact with the HQ, and therefore cannot be called off.\n"
		# call
		CallManager.CallQueue.append(
			{
				"Header": "Decision",
				"Level": "Confidential",
				"Operation": "-//-",
				"Content": content,
				"Show1": true,
				"Show2": true,
				"Show3": true,
				"Show4": true,
				"Text1": "Plan A",
				"Text2": "Plan B",
				"Text3": "Plan C",
				"Text4": "Cancel",
				"Decision1Callback": funcref(GameLogic, "ImplementDirectionDevelopment"),
				"Decision1Argument": {"Choice":1, "Cost": planAcost, "Length": planAlength, "Officers": planAofficers, "Country": lastSelectedCountry},
				"Decision2Callback": funcref(GameLogic, "ImplementDirectionDevelopment"),
				"Decision2Argument": {"Choice":2, "Cost": planBcost, "Length": planBlength, "Officers": planBofficers, "Country": lastSelectedCountry},
				"Decision3Callback": funcref(GameLogic, "ImplementDirectionDevelopment"),
				"Decision3Argument": {"Choice":3, "Cost": planCcost, "Length": planClength, "Officers": planCofficers, "Country": lastSelectedCountry},
				"Decision4Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision4Argument": null,
			}
		)
		get_tree().change_scene("res://call.tscn")
	
func _on_Network_pressed():
	if lastSelectedCountry > 0:
		var planOfficers = GameLogic.random.randi_range(1, GameLogic.OfficersInHQ)
		var planLength = GameLogic.random.randi_range(8,26)
		var planCost = planOfficers*5*planLength
		var content = "Establishing"
		if WorldData.Countries[lastSelectedCountry].Network > 0: content = "Expanding"
		content += " local agent network in " + WorldData.Countries[lastSelectedCountry].Name + " will require €" + str(planCost) + ",000 and " + str(planOfficers) + " officers. The operation will last " + str(planLength) + " weeks.\n\nNote that its effects are strictly correlated with familiarity with the country.\n\nConfirm if you want to start this operation."
		# call
		CallManager.CallQueue.append(
			{
				"Header": "Decision",
				"Level": "Secret",
				"Operation": "-//-",
				"Content": content,
				"Show1": false,
				"Show2": false,
				"Show3": true,
				"Show4": true,
				"Text1": "",
				"Text2": "",
				"Text3": "Approve",
				"Text4": "Cancel",
				"Decision1Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision1Argument": null,
				"Decision2Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision2Argument": null,
				"Decision3Callback": funcref(GameLogic, "ImplementDirectionDevelopment"),
				"Decision3Argument": {"Choice":4, "Cost": planCost, "Length": planLength, "Officers": planOfficers, "Country": lastSelectedCountry},
				"Decision4Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision4Argument": null,
			}
		)
		get_tree().change_scene("res://call.tscn")

func _on_Station_pressed():
	if lastSelectedCountry > 0:
		var planOfficers = GameLogic.random.randi_range(1, GameLogic.OfficersInHQ)
		var planLength = GameLogic.random.randi_range(8,26)
		var planCost = planOfficers*10*planLength
		var content = "Establishing"
		if WorldData.Countries[lastSelectedCountry].Network > 0: content = "Expanding"
		content += " intelligence station in " + WorldData.Countries[lastSelectedCountry].Name + " will require €" + str(planCost) + ",000 and " + str(planOfficers) + " officers. The operation will last " + str(planLength) + " weeks.\n\nConfirm if you want to start this operation."
		# call
		CallManager.CallQueue.append(
			{
				"Header": "Decision",
				"Level": "Top Secret",
				"Operation": "-//-",
				"Content": content,
				"Show1": false,
				"Show2": false,
				"Show3": true,
				"Show4": true,
				"Text1": "",
				"Text2": "",
				"Text3": "Approve",
				"Text4": "Cancel",
				"Decision1Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision1Argument": null,
				"Decision2Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision2Argument": null,
				"Decision3Callback": funcref(GameLogic, "ImplementDirectionDevelopment"),
				"Decision3Argument": {"Choice":5, "Cost": planCost, "Length": planLength, "Officers": planOfficers, "Country": lastSelectedCountry},
				"Decision4Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision4Argument": null,
			}
		)
		get_tree().change_scene("res://call.tscn")
