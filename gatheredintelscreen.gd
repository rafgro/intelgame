extends Control

var mapOfCountries = []
var lastMapOfOrgs = []
var countryChoiceActive = false
var lastSelectedCountry = -1
var lastSelectedOrg = -1
var selectedTab = 0

class MyCustomSorter2:
	static func sort_ascending(a, b):
		var farFetched = [a.Name, b.Name]
		farFetched.sort()
		if farFetched[0] == a.Name:
			return true
		return false

func _ready():
	$C/M/R/Tabs.set_tab_title(2, "Amount of Intel")
	$C/M/R/Tabs.set_tab_title(1, "Organization Type")
	$C/M/R/Tabs.set_tab_title(0, "Host Country")
	# basic list setup
	$C/M/R/Tabs/Amount/List.clear()
	$C/M/R/Tabs/Amount/List.add_item("No Intel")
	$C/M/R/Tabs/Amount/List.add_item("Minimal Knowledge")
	$C/M/R/Tabs/Amount/List.add_item("Known Organizations")
	$C/M/R/Tabs/Amount/List.add_item("Organizations with Sources Inside")
	$C/M/R/Tabs/Type/List.clear()
	$C/M/R/Tabs/Type/List.add_item("Governments")
	$C/M/R/Tabs/Type/List.add_item("International Organizations")
	$C/M/R/Tabs/Type/List.add_item("Intelligence Agencies")
	$C/M/R/Tabs/Type/List.add_item("Scientific Institutions")
	$C/M/R/Tabs/Type/List.add_item("Corporations")
	$C/M/R/Tabs/Type/List.add_item("Movements")
	$C/M/R/Tabs/Type/List.add_item("Criminal Organizations")
	mapOfCountries.clear()
	var sortedCountries = []
	for c in range(1, len(WorldData.Countries)):
		if WorldData.Countries[c].Size == 0: continue
		var desc = WorldData.Countries[c].Name
		if WorldData.DiplomaticRelations[0][c] < -30:
			desc += " (hostile country)"
		sortedCountries.append({"Name": desc, "Id": c})
	sortedCountries.sort_custom(MyCustomSorter2, "sort_ascending")
	for d in sortedCountries:
		$C/M/R/Tabs/Countries/List.add_item(d.Name)
		mapOfCountries.append(d.Id)

func _on_Return_pressed():
	get_tree().change_scene("res://main.tscn")

func _on_Tabs_tab_changed(tab):
	$C/M/R/Organizations.clear()

func _on_AmountList_item_selected(index):
	countryChoiceActive = false
	lastMapOfOrgs.clear()
	$C/M/R/Organizations.clear()
	for o in range(0, len(WorldData.Organizations)):
		if WorldData.Organizations[o].Known == true and WorldData.Organizations[o].Active == true:
			if index == 0:  # no intel
				if len(WorldData.Organizations[o].IntelDescription) == 0:
					lastMapOfOrgs.append(o)
					$C/M/R/Organizations.add_item(WorldData.Organizations[o].Name)
			elif index == 1:  # minimal knowledge
				if len(WorldData.Organizations[o].IntelDescription) > 0 and  WorldData.Organizations[o].IntelValue < 10 and len(WorldData.Organizations[o].IntelSources) == 0:
					lastMapOfOrgs.append(o)
					$C/M/R/Organizations.add_item(WorldData.Organizations[o].Name)
			elif index == 2:  # known organizations
				if len(WorldData.Organizations[o].IntelDescription) > 0 and  WorldData.Organizations[o].IntelValue >= 10 and len(WorldData.Organizations[o].IntelSources) == 0:
					lastMapOfOrgs.append(o)
					$C/M/R/Organizations.add_item(WorldData.Organizations[o].Name)
			elif index == 3:  # sources inside
				if len(WorldData.Organizations[o].IntelDescription) > 0 and len(WorldData.Organizations[o].IntelSources) > 0:
					lastMapOfOrgs.append(o)
					$C/M/R/Organizations.add_item(WorldData.Organizations[o].Name)

func _on_TypeList_item_selected(index):
	countryChoiceActive = false
	lastMapOfOrgs.clear()
	$C/M/R/Organizations.clear()
	var whichType = [WorldData.OrgType.GOVERNMENT]
	if index == 1: whichType = [WorldData.OrgType.INTERNATIONAL]
	elif index == 2: whichType = [WorldData.OrgType.INTEL]
	elif index == 3: whichType = [WorldData.OrgType.UNIVERSITY, WorldData.OrgType.UNIVERSITY_OFFENSIVE]
	elif index == 4: whichType = [WorldData.OrgType.COMPANY]
	elif index == 5: whichType = [WorldData.OrgType.MOVEMENT]
	elif index == 6: whichType = [WorldData.OrgType.GENERALTERROR, WorldData.OrgType.ARMTRADER]
	for o in range(0, len(WorldData.Organizations)):
		if WorldData.Organizations[o].Type in whichType and WorldData.Organizations[o].Known == true and WorldData.Organizations[o].Active == true:
			lastMapOfOrgs.append(o)
			$C/M/R/Organizations.add_item(WorldData.Organizations[o].Name)

func _on_CountriesList_item_selected(index):
	countryChoiceActive = true
	lastMapOfOrgs.clear()
	$C/M/R/Organizations.clear()
	lastSelectedCountry = mapOfCountries[index]
	for o in range(0, len(WorldData.Organizations)):
		if mapOfCountries[index] in WorldData.Organizations[o].Countries and WorldData.Organizations[o].Known == true and WorldData.Organizations[o].Active == true:
			lastMapOfOrgs.append(o)
			var desc = WorldData.Organizations[o].Name
			$C/M/R/Organizations.add_item(desc)

func _on_Organizations_item_selected(index):
	if index <= len(lastMapOfOrgs):
		var o = lastMapOfOrgs[index]
		lastSelectedOrg = o
		var desc = "Details on " + WorldData.Organizations[o].Name + ":\n"
		if len(WorldData.Organizations[o].IntelDescription) == 0:
			desc += "No intel gathered."
		else:
			desc += WorldData.Organizations[o].IntelDescType + " | " + str(int(WorldData.Organizations[o].IntelIdentified)) + " identified members"
			if len(WorldData.Organizations[o].IntelSources) > 0:
				desc += " | " + str(len(WorldData.Organizations[o].IntelSources)) + " sources inside"
			if WorldData.Organizations[o].IntelValue < -10: desc += "\nunknown precise location"
			elif WorldData.Organizations[o].IntelValue < 0: desc += "\nlow intel awareness"
			var orgCountries = []
			for c in WorldData.Organizations[o].Countries:
				orgCountries.append(WorldData.Countries[c].Name)
			desc += "\ncountries: " + PoolStringArray(orgCountries).join(", ")
			desc += "\n" + PoolStringArray(WorldData.Organizations[o].IntelDescription).join("\n")
		$C/M/R/Details.bbcode_text = desc
		$C/M/R/H/Gather.disabled = false
		if WorldData.Organizations[o].IntelIdentified > 0 or len(WorldData.Organizations[o].IntelSources) > 0: $C/M/R/H/Recruit.disabled = false
		else: $C/M/R/H/Recruit.disabled = true
		if WorldData.Organizations[o].OffensiveClearance == true or GameLogic.UniversalClearance == true or WorldData.Organizations[o].KnownKidnapper == true: $C/M/R/H/Offensive.disabled = false
		else: $C/M/R/H/Offensive.disabled = true
		if WorldData.Organizations[o].KnownKidnapper == true: $C/M/R/H/Offensive.text = "Rescue Op"
		else: $C/M/R/H/Offensive.text = "Offensive Op"
		if len(WorldData.Organizations[o].IntelSources) > 0: $C/M/R/H/Recruit.text = "Sources"

func _on_Gather_pressed():
	if lastSelectedOrg != -1:
		var countryId = WorldData.Organizations[lastSelectedOrg].Countries[randi() % WorldData.Organizations[lastSelectedOrg].Countries.size()]
		if countryChoiceActive == true: countryId = lastSelectedCountry
		OperationGenerator.NewOperation(0, lastSelectedOrg, countryId, OperationGenerator.Type.MORE_INTEL)
		# if possible, start fast
		if GameLogic.OfficersInHQ > 0:
			GameLogic.Operations[-1].AnalyticalOfficers = GameLogic.OfficersInHQ
			GameLogic.Operations[-1].Stage = OperationGenerator.Stage.PLANNING_OPERATION
			GameLogic.Operations[-1].Started = GameLogic.GiveDateWithYear()
			GameLogic.Operations[-1].Result = "ONGOING (PLANNING)"
		get_tree().change_scene("res://main.tscn")

func _on_Recruit_pressed():
	if lastSelectedOrg != -1:
		if len(WorldData.Organizations[lastSelectedOrg].IntelSources) > 0:
			# multiple options
			var planCost = 1*5*2
			var planShow = true
			var planAvailability = ""
			if (planCost*1.0/2) > GameLogic.FreeFundsWeeklyWithoutOngoing():
				planShow = false
				planAvailability = " Currently, it is financially unavailable."
			var content = ""
			if len(WorldData.Organizations[lastSelectedOrg].IntelSources) == 1:
				content += "There is a single source inside " + WorldData.Organizations[lastSelectedOrg].Name + ". Bureau can work with them or recruit other people."
			else:
				content += "There are " + str(len(WorldData.Organizations[lastSelectedOrg].IntelSources)) + " sources inside " + WorldData.Organizations[lastSelectedOrg].Name + ". Bureau can work with them or recruit other people."
			content += "\n\n[b]Plan A[/b]\n€" + str(int(planCost)) + ",000 | 1 officer | 2 weeks\nrequest immediate intel\n\n[b]Plan B[/b]\n€" + str(int(planCost)) + ",000 | 1 officer | 2 weeks\nhandle sources: verify, increase trust, train\n\n[b]Plan C[/b]\ndetails depend on plan design\nrecruit a new source"
			if GameLogic.OfficersInHQ < 1:
				planShow = false
				content = "Currently, there are no officers to execute any operations."
			# call
			CallManager.CallQueue.append(
				{
					"Header": "Decision",
					"Level": "Secret",
					"Operation": "-//-",
					"Content": content,
					"Show1": planShow,
					"Show2": planShow,
					"Show3": planShow,
					"Show4": true,
					"Text1": "Plan A",
					"Text2": "Plan B",
					"Text3": "Plan C",
					"Text4": "Cancel",
					"Decision1Callback": funcref(GameLogic, "ImplementDirectionDevelopment"),
					"Decision1Argument": {"Choice":6, "Cost": planCost, "Length": 2, "Officers": 1, "Country": WorldData.Organizations[lastSelectedOrg].Countries[0], "Org": lastSelectedOrg},
					"Decision2Callback": funcref(GameLogic, "ImplementDirectionDevelopment"),
					"Decision2Argument": {"Choice":7, "Cost": planCost, "Length": 2, "Officers": 1, "Country": WorldData.Organizations[lastSelectedOrg].Countries[0], "Org": lastSelectedOrg},
					"Decision3Callback": funcref(GameLogic, "ImplementDirectionDevelopment"),
					"Decision3Argument": {"Choice":8, "Cost": planCost, "Length": 2, "Officers": 1, "Country": WorldData.Organizations[lastSelectedOrg].Countries[0], "Org": lastSelectedOrg},
					"Decision4Callback": funcref(GameLogic, "EmptyFunc"),
					"Decision4Argument": null,
				}
			)
			get_tree().change_scene("res://call.tscn")
		else:
			# just recruiting
			var countryId = WorldData.Organizations[lastSelectedOrg].Countries[randi() % WorldData.Organizations[lastSelectedOrg].Countries.size()]
			if countryChoiceActive == true: countryId = lastSelectedCountry
			OperationGenerator.NewOperation(0, lastSelectedOrg, countryId, OperationGenerator.Type.RECRUIT_SOURCE)
			# if possible, start fast
			if GameLogic.OfficersInHQ > 0:
				GameLogic.Operations[-1].AnalyticalOfficers = GameLogic.OfficersInHQ
				GameLogic.Operations[-1].Stage = OperationGenerator.Stage.PLANNING_OPERATION
				GameLogic.Operations[-1].Started = GameLogic.GiveDateWithYear()
				GameLogic.Operations[-1].Result = "ONGOING (PLANNING)"
			get_tree().change_scene("res://main.tscn")

func _on_Offensive_pressed():
	if lastSelectedOrg != -1:
		var countryId = WorldData.Organizations[lastSelectedOrg].Countries[randi() % WorldData.Organizations[lastSelectedOrg].Countries.size()]
		if countryChoiceActive == true: countryId = lastSelectedCountry
		if WorldData.Organizations[lastSelectedOrg].KnownKidnapper == false:
			OperationGenerator.NewOperation(0, lastSelectedOrg, countryId, OperationGenerator.Type.OFFENSIVE)
			# if possible, start fast
			if GameLogic.OfficersInHQ > 0:
				GameLogic.Operations[-1].AnalyticalOfficers = GameLogic.OfficersInHQ
				GameLogic.Operations[-1].Stage = OperationGenerator.Stage.PLANNING_OPERATION
				GameLogic.Operations[-1].Started = GameLogic.GiveDateWithYear()
				GameLogic.Operations[-1].Result = "ONGOING (PLANNING)"
		else:
			# special rescue operation
			OperationGenerator.NewOperation(0, lastSelectedOrg, countryId, OperationGenerator.Type.RESCUE)
			# if possible, start fast
			if GameLogic.OfficersInHQ > 0:
				GameLogic.Operations[-1].AnalyticalOfficers = GameLogic.OfficersInHQ
				GameLogic.Operations[-1].Stage = OperationGenerator.Stage.PLANNING_OPERATION
				GameLogic.Operations[-1].Started = GameLogic.GiveDateWithYear()
				GameLogic.Operations[-1].Result = "ONGOING (PLANNING)"
		get_tree().change_scene("res://main.tscn")
