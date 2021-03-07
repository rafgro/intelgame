extends Node

# current 06/03/2021 file structure
# lines of json:
# 0 - GameLogic vars in dict
# 1 - WorldData Countries
# 2 - WorldData DiplomaticRelations
# 3 - WorldData Organizations
# 4 - WorldData Methods
# 5 - WorldData Wars

var GameLogicNames = ["DateDay", "DateMonth", "DateYear", "Trust", "TrustMonthsAgo", "Use", "UseMonthsAgo", "SoftPowerMonthsAgo", "ActiveOfficers", "OfficersInHQ", "OfficersAbroad", "PursuedOperations", "BureauEvents", "WorldEvents", "IntensityHiring", "IntensityUpskill", "IntensityTech", "BudgetFull", "BudgetOngoingOperations", "BudgetExtras", "StaffSkill", "StaffSkillMonthsAgo", "StaffExperience", "StaffExperienceMonthsAgo", "StaffTrust", "StaffTrustMonthsAgo", "Technology", "TechnologyMonthsAgo", "PriorityGovernments", "PriorityTerrorism", "PriorityTech", "PriorityWMD", "PriorityPublic", "PriorityTargetCountries", "PriorityOfflimitCountries", "Operations", "Directions", "Investigations", "AllWeeks", "RecruitProgress", "PreviousTrust", "AttackTicker", "AttackTickerOp", "AttackTickerText", "UltimatumTicker", "CurrentOpsAgainstHomeland", "YearlyOpsAgainstHomeland", "OpsLimit", "UniversalClearance", "InternalMoles", "YearlyWars", "YearlyHiring", "DistWalkinCounter", "DistWalkinMin", "DistGovopCounter", "DistGovopMin", "DistSourcecheckCounter", "DistSourcecheckMin", "DistMolesearchCounter", "DistMolesearchMin", "NewOfficerCost", "ExistingOfficerCost", "NewTechCost", "SkillMaintenanceCost", "TurnOnTerrorist", "IncreaseTerror", "TurnOnWars", "TurnOnWMD", "TurnOnInfiltration", "YearlyNetworks", "YearlyStations"]

func SaveGame():
	var save_file = File.new()
	save_file.open("user://savefile.save", File.WRITE)
	var GLarr = []
	for z in range(0, len(GameLogicNames)): GLarr.append(GameLogic.get(GameLogicNames[z]))
	save_file.store_line(to_json(GLarr))
	save_file.store_line(to_json(WorldData.Countries))
	save_file.store_line(to_json(WorldData.DiplomaticRelations))
	save_file.store_line(to_json(WorldData.Organizations))
	save_file.store_line(to_json(WorldData.Methods))
	save_file.store_line(to_json(WorldData.Wars))
	save_file.close()

func LoadGame():
	var save_file = File.new()
	if not save_file.file_exists("user://savefile.save"):
		return
	save_file.open("user://savefile.save", File.READ)
	var data = parse_json(save_file.get_line())
	for d in range(0,len(data)):
		if data[d] is Array or data[d] is Dictionary:
			GameLogic[GameLogicNames[d]] = data[d].duplicate(true)
		else:
			GameLogic[GameLogicNames[d]] = data[d]
	WorldData.Countries = parse_json(save_file.get_line())
	WorldData.DiplomaticRelations = parse_json(save_file.get_line())
	WorldData.Organizations = parse_json(save_file.get_line())
	WorldData.Methods = parse_json(save_file.get_line())
	WorldData.Wars = parse_json(save_file.get_line())
	save_file.close()
