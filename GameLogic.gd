# Logic usually separated from the display

extends Node

var random = RandomNumberGenerator.new()
var OperationHandler = load("res://OperationHandler.gd").new()

# Basic general variables, in the main screen order
var DateDay = 1
var DateMonth = 1
var DateYear = 2021
var Trust = 51
var TrustMonthsAgo = []  # array of 13 last values, furthest is the first
var Use = 0  # usefulness of intel for gov
var UseMonthsAgo = []  # array of 13 last values, furthest is the first
var SoftPowerMonthsAgo = []  # array of 13 last values, furthest is the first
var ActiveOfficers = 5
var OfficersInHQ = 5
var OfficersAbroad = 0
var PursuedOperations = 0
var BureauEvents = []
var WorldEvents = []
# Bureau screen
var IntensityHiring = 5
var IntensityUpskill = 10
var IntensityTech = 5
var BudgetFull = 150  # in thousands, monthly
var BudgetOngoingOperations = 0
var BudgetExtras = 0  # sources, stations
# Staff
var StaffSkill = 10  # 0 to 100
var StaffSkillMonthsAgo = []  # array of 13 last values, furthest is the first
var StaffExperience = 0  # 0 to 100
var StaffExperienceMonthsAgo = []  # array of 13 last values, furthest is the first
var StaffTrust = 50  # 0 to 100
var StaffTrustMonthsAgo = []  # array of 13 last values, furthest is the first
var Technology = 5  # 0 to 100
var TechnologyMonthsAgo = []  # array of 13 last values, furthest is the first
# Government-assigned priorities, 0 to 100
# Usually directly translated to trust increase/decrease (e.g. 50->+50% after ideal op)
var PriorityGovernments = 0  # targeting other governments, always very high
var PriorityTerrorism = 0  # chasing criminal orgs and preventing terrorist attacks
var PriorityTech = 0  # stealing non-wmd technology
var PriorityWMD = 0  # stealing or at least getting to know about WMD
var PriorityPublic = 0  # public reception, influences by loud events (e.g. deaths)
var PriorityTargetCountries = []  # ids of countries treated as important targets
var PriorityOfflimitCountries = []  # ids of countries where gov doesn't want targeting
# Operations
var Operations = []  # array of operation dictionaries
var Directions = []  # array of simple operation-like dicts
var Investigations = []  # array of simple operation-like dicts
# Internal logic variables, always describe them
var AllWeeks = 0  # weeks passed for summaries and increasng difficulty
var RecruitProgress = 0.0  # when reaches 1, a new officer arrives
var PreviousTrust = 0  # trust from previous week, to write show the change week to week
var AttackTicker = 0  # race against time in preventing a terrorist attack, shown if >0
var AttackTickerOp = {"Org":0,"Op":0}  # which organization and operation it is following
var AttackTickerText = ""  # text shown next to the number
var UltimatumTicker = 0  # weeks to actual lay off if user doesn't bring back trust
var CurrentOpsAgainstHomeland = 0  # internal counter to not overwhelm user, simultaneous
var YearlyOpsAgainstHomeland = 0  # internal counter as well, yearly ops, zeroed on 01/01
var OpsLimit = 0  # max number of terror ops against homeland,  increased over time
var UniversalClearance = false  # with high trust, bureau can target anything they want
var InternalMoles = 0  # counter of officers that are passing info to other intel agencies
var YearlyWars = 0  # internal counter, ensuring that there's no more than 1 war per year
var YearlyHiring = 0  # internal counter, limiting a number of new officers for later stages
var YearlyNetworks = 0  # internal counter instead of budget limit
var Achievements = []  # listed in the finish screen, things not covered by op descriptions
# Distance counters: block anything that happens more frequently than limit
var DistWalkinCounter = 0
var DistWalkinMin = 16  # minimum four months between those events
var DistGovopCounter = 0
var DistGovopMin = 8
var DistSourcecheckCounter = 0
var DistSourcecheckMin = 20
var DistMolesearchCounter = 0
var DistMolesearchMin = 12
# Sort of constants but also internal, always describe them
var NewOfficerCost = 50  # thousands needed to spend on a new officer, increasing over time
var ExistingOfficerCost = 4  # monthly wage, increasing with skill over time
var NewTechCost = 25  # thousands needed to spend on a new percent of technology
var SkillMaintenanceCost = 0.5  # thousands needed to maintain skills for an officer
# Options
var TurnOnTerrorist = true
var IncreaseTerror = 52*2  # possible +1 terror ops every x weeks
var TurnOnWars = true
var TurnOnWMD = true
var TurnOnInfiltration = true
var FrequencyAttacks = 1.0
var Onboarding = false
var WhenAllowAttacks = 26

func GiveDateWithYear():
	var dateString = ""
	if DateDay < 10: dateString += "0"
	dateString += str(int(DateDay)) + "/"
	if DateMonth < 10: dateString += "0"
	dateString += str(int(DateMonth)) + "/" + str(int(DateYear))
	return dateString
	
func GiveDateWithoutYear():
	var dateString = ""
	if DateDay < 10: dateString += "0"
	dateString += str(DateDay) + "/"
	if DateMonth < 10: dateString += "0"
	dateString += str(DateMonth)
	return dateString

class MyCustomSorter:
	static func sort_descending(a, b):
		if a[0] > b[0]:
			return true
		return false

func AddEvent(text):
	BureauEvents.push_front("[u][b]"+GiveDateWithoutYear()+"[/b] " + text + "[/u]")

func AddWorldEvent(text, past):
	if past == null:
		WorldEvents.push_front("[u][b]"+GiveDateWithYear()+"[/b] " + text + "[/u]")
	else:
		WorldEvents.push_front("[b]"+past+"[/b] " + text)

func FreeFundsWeekly():
	return (BudgetFull - (ActiveOfficers*ExistingOfficerCost + BudgetOngoingOperations+BudgetExtras)) / 4

func FreeFundsWeeklyWithoutOngoing():
	return (BudgetFull - (ActiveOfficers*ExistingOfficerCost + BudgetExtras)) / 4

func IntensityPercent(which):
	return int(which * 1.0 / (IntensityHiring + IntensityUpskill + IntensityTech) * 100)

# first ever call: proper initialization of vars
func _init():
	random.randomize()
	randomize()

func StartAll():
	AddEvent("The bureau has opened")
	# initial craft availabililty
	for t in range(0, len(WorldData.Methods)):
		for m in range(0, len(WorldData.Methods[t])):
			if WorldData.Methods[t][m].Available == false:
				if FreeFundsWeeklyWithoutOngoing() < WorldData.Methods[t][m].Cost:
					continue
				if ActiveOfficers < WorldData.Methods[t][m].OfficersRequired:
					continue
				if StaffSkill < WorldData.Methods[t][m].MinimalSkill:
					continue
				if Trust < WorldData.Methods[t][m].MinimalTrust:
					continue
				if Technology < WorldData.Methods[t][m].MinimalTech:
					continue
				if DateYear < WorldData.Methods[t][m].StartYear:
					continue
				if DateYear > WorldData.Methods[t][m].EndYear:
					continue
				# change from false to criterions fulfilled
				WorldData.Methods[t][m].Available = true
	# initial change counters
	TrustMonthsAgo.append(Trust)
	UseMonthsAgo.append(Use)
	StaffSkillMonthsAgo.append(StaffSkill)
	StaffExperienceMonthsAgo.append(StaffExperience)
	StaffTrustMonthsAgo.append(StaffTrust)
	TechnologyMonthsAgo.append(Technology)

func NextWeek():
	var forceGovOpOrder = false
	var doesItEndWithCall = false
	############################################################################
	# scaling difficulty
	if int(AllWeeks) == 0:  # new things to happen after first next week click
		forceGovOpOrder = true
	if int(AllWeeks) == int(WhenAllowAttacks):
		OpsLimit = 1
	if int(AllWeeks) % 52 == 0 and int(AllWeeks) != 0:  # roughly a year
		YearlyOpsAgainstHomeland = 0
		OpsLimit = random.randi_range(1, 1+int(AllWeeks*1.0/IncreaseTerror))
		YearlyWars = 0
		YearlyHiring = 0
		YearlyNetworks = 0
	if Onboarding == true:
		OnboardingIsOn(AllWeeks+1)
		doesItEndWithCall = true
	############################################################################
	# date proceedings
	# clearing u-tags in events
	var i = 0
	while i < min(len(BureauEvents), 10):
		if "[u]" in BureauEvents[i]:
			BureauEvents[i] = BureauEvents[i].substr(3, len(BureauEvents[i])-7)
		i += 1
	i = 0
	while i < min(len(WorldEvents), 20):
		if "[u]" in WorldEvents[i]:
			WorldEvents[i] = WorldEvents[i].substr(3, len(WorldEvents[i])-7)
		i += 1
	# moving seven days forward
	AllWeeks += 1
	DateDay += 7
	# moving a month forward if needed
	if DateDay >= 28:
		var maxNumber = 31  # max number of days in a month
		if DateMonth == 2:
			maxNumber = 28
		elif DateMonth == 4 or DateMonth == 6 or DateMonth == 9 or DateMonth == 11:
			maxNumber = 30
		if DateDay > maxNumber:
			DateDay -= maxNumber  # eg 35-31=4th
			DateMonth += 1
			if DateMonth == 13:
				DateMonth = 1
				DateYear += 1
				# new-year budget increase
				var budgetIncrease = 30 + Trust*0.7
				if budgetIncrease > 100: budgetIncrease = random.randi_range(97,103)
				BudgetFull += budgetIncrease
				AddEvent("New year budget increase: +€"+str(int(budgetIncrease))+"k")
		# monthly updated game logic
		ExistingOfficerCost = 6 + (10*StaffSkill*0.01 + 16*StaffExperience*0.01)  # max 30
		NewOfficerCost = 50 + (150*StaffSkill*0.01) + ActiveOfficers*4  # ~max 250
		if NewOfficerCost > 250: NewOfficerCost = 250
	############################################################################
	# budget-based changes
	# hiring
	var freeFund = FreeFundsWeekly()
	if freeFund < 0: freeFund = 0
	RecruitProgress += freeFund * (IntensityPercent(IntensityHiring)*0.01) / NewOfficerCost
	if RecruitProgress >= 1.0 and FreeFundsWeekly() >= 4 and YearlyHiring < 4:
		# currently always plus one, sort of weekly onboarding limit
		# in the future expand that to a loop
		ActiveOfficers += 1
		OfficersInHQ += 1
		RecruitProgress -= 1.0
		StaffExperience -= 3
		StaffSkill -= 2
		StaffTrust -= 5
		var ifDirection = ""
		if ActiveOfficers < 10:
			if random.randi_range(1,2) == 1:
				var chosenC = random.randi_range(1, len(WorldData.Countries)-1)
				WorldData.Countries[chosenC].KnowhowLanguage += random.randi_range(20,55)
				WorldData.Countries[chosenC].KnowhowCustoms += random.randi_range(5,25)
				ifDirection = " and brought in some knowledge about " + WorldData.Countries[chosenC].Name
		else:
			if random.randi_range(1,5) == 1:
				var chosenC = random.randi_range(1, len(WorldData.Countries)-1)
				WorldData.Countries[chosenC].KnowhowLanguage += random.randi_range(10,35)
				WorldData.Countries[chosenC].KnowhowCustoms += random.randi_range(5,15)
				ifDirection = " and brought in some knowledge about " + WorldData.Countries[chosenC].Name
		AddEvent("New officer joined Bureau"+ifDirection)
		YearlyHiring += 1
	# random officer events
	if random.randi_range(0,100) == 50:
		if random.randi_range(0,100) < ActiveOfficers and OfficersInHQ > 0:
			StaffTrust -= 5
			StaffSkill *= 1.0-(1/ActiveOfficers)
			StaffExperience *= 1.0-(1/ActiveOfficers)
			ActiveOfficers -= 1
			OfficersInHQ -= 1
			AddEvent("Bureau lost an officer due to resignation")
	# upskilling
	var upskillDiff = (freeFund * (IntensityPercent(IntensityUpskill)*0.01)) - (SkillMaintenanceCost*ActiveOfficers)
	if upskillDiff > 0.5: upskillDiff = 0.5
	elif upskillDiff < -0.5: upskillDiff = -0.5
	StaffSkill += upskillDiff*0.5
	# trust naturally increases over time
	StaffTrust += 0.25  # +12.5% over year
	# tech increase, slowing down with higher tech level to achieve
	var techDiff = (freeFund * (IntensityPercent(IntensityTech)*0.01)) / NewTechCost
	if Technology < 10: Technology += techDiff
	elif Technology < 25:
		if random.randi_range(1,2) == 2: Technology += techDiff
	elif Technology < 40:
		if random.randi_range(1,3) == 2: Technology += techDiff
	elif Technology < 55:
		if random.randi_range(1,4) == 2: Technology += techDiff*0.5
	elif Technology < 75:
		if random.randi_range(1,5) == 2: Technology += techDiff*0.2
	elif Technology < 95:
		if random.randi_range(1,6) == 2: Technology += techDiff*0.1
	elif Technology < 100:
		if random.randi_range(1,8) == 2: Technology += techDiff*0.05
	############################################################################
	# craft availability changes
	for t in range(0, len(WorldData.Methods)):
		for m in range(0, len(WorldData.Methods[t])):
			if WorldData.Methods[t][m].Available == false:
				if FreeFundsWeeklyWithoutOngoing() < WorldData.Methods[t][m].Cost:
					continue
				if ActiveOfficers < WorldData.Methods[t][m].OfficersRequired:
					continue
				if StaffSkill < WorldData.Methods[t][m].MinimalSkill:
					continue
				if Trust < WorldData.Methods[t][m].MinimalTrust:
					continue
				if Technology < WorldData.Methods[t][m].MinimalTech:
					continue
				# change from false to criterions fulfilled
				WorldData.Methods[t][m].Available = true
				AddEvent("New craft is available: " + WorldData.Methods[t][m].Name)
	############################################################################
	# training or working in a general direction
	for t in range(0, len(Directions)):
		# { Active, MonthlyCost, Length, LengthCounter, Officers, Country, LanguageEffect, CustomsEffect, CovertEffect }
		if Directions[t].Active == true:
			Directions[t].LengthCounter -= 1
			if Directions[t].LengthCounter <= 0:
				# finish
				Directions[t].Active = false
				BudgetOngoingOperations -= Directions[t].MonthlyCost
				OfficersInHQ += Directions[t].Officers
				OfficersAbroad -= Directions[t].Officers
				WorldData.Countries[Directions[t].Country].KnowhowLanguage += Directions[t].LanguageEffect
				WorldData.Countries[Directions[t].Country].KnowhowCustoms += Directions[t].CustomsEffect
				WorldData.Countries[Directions[t].Country].CovertTravel += Directions[t].CovertEffect
				# training
				if Directions[t].Type <= 3:
					AddEvent(str(Directions[t].Officers) + " officer(s) came back with improved knowledge about " + WorldData.Countries[Directions[t].Country].Name)
					StaffTrust += 2
				# network
				elif Directions[t].Type == 4:
					if WorldData.Countries[Directions[t].Country].Network > 0:
						WorldData.Countries[Directions[t].Country].Network *= (1.0 + Directions[t].Quality*0.01)
						AddEvent(str(Directions[t].Officers) + " officer(s) came back after expanding agent network in " + WorldData.Countries[Directions[t].Country].Name)
						StaffTrust += 0.5
					else:
						WorldData.Countries[Directions[t].Country].Network = int(Directions[t].Quality)
						AddEvent(str(Directions[t].Officers) + " officer(s) came back after establishing agent network in " + WorldData.Countries[Directions[t].Country].Name)
						StaffTrust += 1
					WorldData.Countries[Directions[t].Country].NetworkWork = false
				# station
				elif Directions[t].Type == 5:
					if WorldData.Countries[Directions[t].Country].Station > 0:
						WorldData.Countries[Directions[t].Country].Station += 1
						AddEvent(WorldData.Countries[Directions[t]].Adjective + " intelligence station is expanded to " + str(int(WorldData.Countries[Directions[t].Country].Station)) + " officers")
						StaffTrust += 1
					else:
						WorldData.Countries[Directions[t].Country].Station = 1
						AddEvent("Bureau intelligence station starts work in " + WorldData.Countries[Directions[t].Country].Name)
						StaffTrust += 3
					WorldData.Countries[Directions[t].Country].StationWork = false
	############################################################################
	# operations
	var ifCall = OperationHandler.ProgressOperations()
	if ifCall == true: doesItEndWithCall = true
	############################################################################
	# world changes
	ifCall = WorldNextWeek.Execute(null)
	if ifCall == true: doesItEndWithCall = true
	############################################################################
	# eventual government assigned operations, one every few months
	if (random.randi_range(1,20) == 11 and DistGovopCounter < 1) or forceGovOpOrder == true:
		# choosing organization
		var whichOrg = -1
		if random.randi_range(1,2) == 1:
			# any government
			for f in range(0,20):  # twenty attempts
				var check = random.randi_range(0, len(WorldData.Organizations)-1)
				if WorldData.Organizations[check].Type == WorldData.OrgType.GOVERNMENT:
					whichOrg = check
					break
			# or any techie
			if whichOrg == -1 and PriorityTech > 40:
				for f in range(0,20):  # max twenty attempts
					var check = random.randi_range(0, len(WorldData.Organizations)-1)
					if WorldData.Organizations[check].Type == WorldData.OrgType.COMPANY or WorldData.Organizations[check].Type == WorldData.OrgType.UNIVERSITY or WorldData.Organizations[check].Type == WorldData.OrgType.UNIVERSITY_OFFENSIVE:
						whichOrg = check
						break
		else:
			# country from target list
			for j in range(0, len(WorldData.Organizations)):
				if WorldData.Organizations[j].Type == WorldData.OrgType.GOVERNMENT or WorldData.Organizations[j].Type == WorldData.OrgType.INTEL:
					if WorldData.Organizations[j].Countries[0] in PriorityTargetCountries:
						if random.randi_range(1,2) == 1:
							whichOrg = j
							break
		if whichOrg == -1:
			# worst diplomatic enemy
			var lowestVal = 50
			var lowestId = 0
			for g in range(1, len(WorldData.Countries)):
				if WorldData.DiplomaticRelations[0][g] < lowestVal:
					lowestVal = WorldData.DiplomaticRelations[0][g]
					lowestId = g
			for j in range(0, len(WorldData.Organizations)):
				if WorldData.Organizations[j].Type == WorldData.OrgType.GOVERNMENT:
					if WorldData.Organizations[j].Countries[0] == lowestId:
						if random.randi_range(1,3) <= 2:
							whichOrg = j
							break
		# assigning the operation
		if whichOrg != -1:
			var opType = OperationGenerator.Type.MORE_INTEL
			if WorldData.Organizations[whichOrg].IntelIdentified > 0 and random.randi_range(1,5) == 2:
				opType = OperationGenerator.Type.RECRUIT_SOURCE
			var countryId = WorldData.Organizations[whichOrg].Countries[0]
			OperationGenerator.NewOperation(1, whichOrg, countryId, opType)
			# if possible, start fast
			if OfficersInHQ > 0:
				Operations[-1].AnalyticalOfficers = OfficersInHQ
				Operations[-1].Stage = OperationGenerator.Stage.PLANNING_OPERATION
				Operations[-1].Started = GiveDateWithYear()
				Operations[-1].Result = "ONGOING (PLANNING)"
			CallManager.CallQueue.append(
				{
					"Header": "Important Information",
					"Level": Operations[-1].Level,
					"Operation": Operations[-1].Name  + "\nagainst " + WorldData.Organizations[Operations[-1].Target].Name,
					"Content": "Homeland government designated a new operation.\n\nGoal:\n" + Operations[-1].GoalDescription,
					"Show1": false,
					"Show2": false,
					"Show3": false,
					"Show4": true,
					"Text1": "",
					"Text2": "",
					"Text3": "",
					"Text4": "Understood",
					"Decision1Callback": funcref(GameLogic, "EmptyFunc"),
					"Decision1Argument": null,
					"Decision2Callback": funcref(GameLogic, "EmptyFunc"),
					"Decision2Argument": null,
					"Decision3Callback": funcref(GameLogic, "EmptyFunc"),
					"Decision3Argument": null,
					"Decision4Callback": funcref(GameLogic, "EmptyFunc"),
					"Decision4Argument": null,
				}
			)
			DistGovopCounter = DistGovopMin
			doesItEndWithCall = true
	############################################################################
	# walk-ins or whistleblowers
	if random.randi_range(1,40) == 16 and DistWalkinCounter < 1:
		var whichOrg = random.randi_range(0, len(WorldData.Organizations)-1)
		var quality = random.randi_range(-65,65)
		var content = "A source, claiming to be close to " + WorldData.Organizations[whichOrg].Name + " (" + WorldData.Countries[WorldData.Organizations[whichOrg].Countries[0]].Name + ") walked in into one our embassies. "
		if WorldData.Organizations[whichOrg].IntelValue < 20 or WorldData.Organizations[whichOrg].IntelIdentified < 1:
			content += "Due to lack of intelligence about the organization, officers cannot verify this story. "
		else:
			var pOfDetecting = StaffSkill*2
			if random.randi_range(0,100) > pOfDetecting:
				# not detected
				if random.randi_range(1,2) == 2:
					content += "Officers verified this story as probably unreliable."
				else: content += "Officers verified this story as probably credible."
			else:
				# detected
				if quality < 0: content += "Officers verified this story as probably unreliable."
				else: content += "Officers verified this story as probably credible."
		CallManager.CallQueue.append(
			{
				"Header": "Urgent Decision",
				"Level": "Secret",
				"Operation": "-//-",
				"Content": content,
				"Show1": false,
				"Show2": false,
				"Show3": true,
				"Show4": true,
				"Text1": "",
				"Text2": "",
				"Text3": "Reject intel",
				"Text4": "Accept intel",
				"Decision1Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision1Argument": null,
				"Decision2Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision2Argument": null,
				"Decision3Callback": funcref(GameLogic, "ImplementWalkin"),
				"Decision3Argument": {"Choice":1},
				"Decision4Callback": funcref(GameLogic, "ImplementWalkin"),
				"Decision4Argument": {"Choice":2,"Content":content,"Whichorg":whichOrg,"Quality":quality},
			}
		)
		DistWalkinCounter = DistWalkinMin
		doesItEndWithCall = true
	############################################################################
	# close to losing game or losing game
	if UltimatumTicker == 0 and Trust <= 10:
		UltimatumTicker = 13
		CallManager.CallQueue.append(
			{
				"Header": "Important Information",
				"Level": "Confidential",
				"Operation": "-//-",
				"Content": "Government almost lost faith in you as the Bureau's Chief. As a result, they give an ultimatum: bring back trust level over 10% in three months or face contract termination.",
				"Show1": false,
				"Show2": false,
				"Show3": false,
				"Show4": true,
				"Text1": "",
				"Text2": "",
				"Text3": "",
				"Text4": "Understood",
				"Decision1Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision1Argument": null,
				"Decision2Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision2Argument": null,
				"Decision3Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision3Argument": null,
				"Decision4Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision4Argument": null,
			}
		)
		doesItEndWithCall = true
	# noting ultimatum
	if UltimatumTicker != 0:
		UltimatumTicker -= 1
		if UltimatumTicker == 0:
			# make or break
			if Trust < 10:
				var localSummary = "- " + str(int(AllWeeks)) + " weeks\n- " + str(len(Operations)) + " operations"
				var mostSuccessfulOps = []
				for o in Operations:
					if o.Stage != OperationGenerator.Stage.FINISHED: continue
					if o.AbroadPlan == null: continue
					var localQuality = 0
					if o.Type == OperationGenerator.Type.RESCUE: localQuality = 100
					elif o.Type == OperationGenerator.Type.OFFENSIVE:
						localQuality = 50 + 0.5*o.AbroadPlan.Quality
					elif o.Type == OperationGenerator.Type.RECRUIT_SOURCE:
						localQuality = 40 + 0.6*o.AbroadPlan.Quality
					elif o.Type == OperationGenerator.Type.MORE_INTEL:
						localQuality = 10 + 0.5*o.AbroadPlan.Quality
					var localContent = "'" + o.Name + "' against " + WorldData.Organizations[o.Target].Name + " via "
					var methodNames = []
					for j in o.AbroadPlan.Methods: methodNames.append(WorldData.Methods[o.Type][j].Name)
					localContent += PoolStringArray(methodNames).join(", ")
					mostSuccessfulOps.append([localQuality, localContent])
				if len(mostSuccessfulOps) > 0:
					mostSuccessfulOps.sort_custom(MyCustomSorter, "sort_descending")
					if len(mostSuccessfulOps) > 5: mostSuccessfulOps = mostSuccessfulOps.slice(0,4)
					var isolated = []
					for k in mostSuccessfulOps: isolated.append(isolated[1])
					localSummary += "\n- most successful: " + PoolStringArray(isolated).join("|")
				if len(Achievements) > 0:
					localSummary += "\n- other achievements: " + PoolStringArray(Achievements).join(", ")
				CallManager.CallQueue.append(
					{
						"Header": "Important Information",
						"Level": "Confidential",
						"Operation": "-//-",
						"Content": "As a result of prolonged period of low trust between Bureau and Government, your contract was terminated.\n\nSummary of your tenure as the chief:\n" + localSummary,
						"Show1": false,
						"Show2": false,
						"Show3": false,
						"Show4": true,
						"Text1": "",
						"Text2": "",
						"Text3": "",
						"Text4": "Game Over",
						"Decision1Callback": funcref(GameLogic, "EmptyFunc"),
						"Decision1Argument": null,
						"Decision2Callback": funcref(GameLogic, "EmptyFunc"),
						"Decision2Argument": null,
						"Decision3Callback": funcref(GameLogic, "EmptyFunc"),
						"Decision3Argument": null,
						"Decision4Callback": funcref(GameLogic, "FinalQuit"),
						"Decision4Argument": null,
					}
				)
				doesItEndWithCall = true
			else:
				var increase = int(BudgetFull*0.3)
				if increase > 100: increase = 100
				BudgetFull += increase
				CallManager.CallQueue.append(
					{
						"Header": "Important Information",
						"Level": "Confidential",
						"Operation": "-//-",
						"Content": "Bringing back level of trust into acceptable territory convinced Government to keep you as the chief of Bureau. In recognition of past struggles, the budget was increased by €" + str(int(increase)) + ",000.",
						"Show1": false,
						"Show2": false,
						"Show3": false,
						"Show4": true,
						"Text1": "",
						"Text2": "",
						"Text3": "",
						"Text4": "Understood",
						"Decision1Callback": funcref(GameLogic, "EmptyFunc"),
						"Decision1Argument": null,
						"Decision2Callback": funcref(GameLogic, "EmptyFunc"),
						"Decision2Argument": null,
						"Decision3Callback": funcref(GameLogic, "EmptyFunc"),
						"Decision3Argument": null,
						"Decision4Callback": funcref(GameLogic, "EmptyFunc"),
						"Decision4Argument": null,
					}
				)
				doesItEndWithCall = true
	############################################################################
	# investigations
	for e in range(0, len(Investigations)):
		if Investigations[e].FinishCounter > 0:
			Investigations[e].FinishCounter -= 1
			if Investigations[e].FinishCounter == 0:
				# investigation finished, time to present results
				var content = "Final Report after Investigation into:\n"
				var org = Investigations[e].Organization
				var op = Investigations[e].Operation
				# investigation after firing a mole
				if Investigations[e].Type == WorldData.ExtOpType.COUNTERINTEL:
					content += "Possible Informant in Bureau\n\n"
					# either successfully detected
					if Investigations[e].Success == true:
						content += "Investigation team concluded that fired officer have been leaking confidential information to " + WorldData.Organizations[org].Name + " for " + str(int(WorldData.Organizations[org].OpsAgainstHomeland[op].InvestigationData.Length)) + " weeks. As a result:\n"
						if WorldData.Organizations[org].OpsAgainstHomeland[op].InvestigationData.CovertDamage > 0:
							content += "- " + str(int(WorldData.Organizations[org].OpsAgainstHomeland[op].InvestigationData.CovertDamage)) + "% of covert travel know how and operations in " + WorldData.Countries[WorldData.Organizations[org].Countries[0]].Name + " were affected (some of the know how has to be rebuilt)\n\n"
						if WorldData.Organizations[org].OpsAgainstHomeland[op].InvestigationData.NetworkDamage > 0:
							content += "- " + str(int(WorldData.Organizations[org].OpsAgainstHomeland[op].InvestigationData.NetworkDamage)) + " agents in " + WorldData.Countries[WorldData.Organizations[org].Countries[0]].Adjective + " were compromised (in response, whole network was dissolved)\n\n"
							WorldData.Countries[WorldData.Organizations[org].Countries[0]].Network = 0
						if WorldData.Organizations[org].OpsAgainstHomeland[op].InvestigationData.TurnedSources > 0:
							content += str(int(WorldData.Organizations[org].OpsAgainstHomeland[op].InvestigationData.NetworkDamage)) + " " + WorldData.Countries[WorldData.Organizations[org].Countries[0]].Adjective + " sources were turned into providing false intel (work continues on uncovering them)"
					# or failure
					else:
						content += "Investigation team concluded that fired officer did not leak confidential information. "
						if InternalMoles > 0:
							content += "However, there are signals that the information is leaked by other officers. Bureau will continue the search for the mole."
						else:
							content += "It is highly likely that Bureau is currently not targeted by external organizations."
				# investigation with content already provided
				if Investigations[e].Type == 100:
					content += Investigations[e].Content
				# debriefing user
				CallManager.CallQueue.append(
					{
						"Header": "Important Information",
						"Level": "Secret",
						"Operation": "Purgatory",
						"Content": content,
						"Show1": false,
						"Show2": false,
						"Show3": false,
						"Show4": true,
						"Text1": "",
						"Text2": "",
						"Text3": "",
						"Text4": "Understood",
						"Decision1Callback": funcref(GameLogic, "EmptyFunc"),
						"Decision1Argument": null,
						"Decision2Callback": funcref(GameLogic, "EmptyFunc"),
						"Decision2Argument": null,
						"Decision3Callback": funcref(GameLogic, "EmptyFunc"),
						"Decision3Argument": null,
						"Decision4Callback": funcref(GameLogic, "EmptyFunc"),
						"Decision4Argument": null,
					}
				)
				doesItEndWithCall = true
	############################################################################
	# homeland-level stuff
	Use *= 0.99  # -40% per year when starting from 100%
	if Use > 0 and random.randi_range(1,3) == 2:
		WorldData.Countries[0].SoftPower += Use*0.01  # 60% use -> +0.6% every 3rd week -> +10% in year
	############################################################################
	# final variable maintenance
	# ticker label change
	if AttackTicker != 0:
		var upd = WorldData.Organizations[AttackTickerOp.Org].OpsAgainstHomeland[AttackTickerOp.Op].FinishCounter
		if upd != AttackTicker:
			AttackTicker = upd
		if WorldData.Organizations[AttackTickerOp.Org].OpsAgainstHomeland[AttackTickerOp.Op].Active == false:
			AttackTicker = 0
	# distance counters
	DistWalkinCounter -= 1
	DistGovopCounter -= 1
	DistSourcecheckCounter -= 1
	DistMolesearchCounter -= 1
	# physical limits or bug patches
	if BudgetOngoingOperations < 0: BudgetOngoingOperations = 0
	if StaffExperience > 100: StaffExperience = 100
	elif StaffExperience < 1: StaffExperience = 1
	if StaffSkill > 100: StaffSkill = 100
	elif StaffSkill < 1: StaffSkill = 1
	if StaffTrust > 100: StaffTrust = 100
	elif StaffTrust < 1: StaffTrust = 1
	if Trust > 100: Trust = 100
	elif Trust < 0: Trust = 0
	if Technology > 100: Technology = 100
	elif Technology < 0: Technology = 0
	if Use > 100: Use = 100
	elif Use < 0: Use = 0
	if BudgetExtras < 0: BudgetExtras = 0
	if ActiveOfficers != (OfficersAbroad+OfficersInHQ):
		OfficersInHQ = ActiveOfficers - OfficersAbroad
	if ActiveOfficers < 0: ActiveOfficers = 0
	if OfficersInHQ < 0: OfficersInHQ = 0
	if OfficersAbroad < 0: OfficersAbroad = 0
	# histories of certain variables
	if len(StaffSkillMonthsAgo) < 26:  # if this is under, all histories are under
		# building initial history
		TrustMonthsAgo.append(Trust)
		UseMonthsAgo.append(Use)
		StaffSkillMonthsAgo.append(StaffSkill)
		StaffExperienceMonthsAgo.append(StaffExperience)
		StaffTrustMonthsAgo.append(StaffTrust)
		TechnologyMonthsAgo.append(Technology)
	else:
		# first out, last in
		TrustMonthsAgo.remove(0)
		TrustMonthsAgo.append(Trust)
		UseMonthsAgo.remove(0)
		UseMonthsAgo.append(Use)
		SoftPowerMonthsAgo.remove(0)
		SoftPowerMonthsAgo.append(WorldData.Countries[0].SoftPower)
		StaffSkillMonthsAgo.remove(0)
		StaffSkillMonthsAgo.append(StaffSkill)
		StaffExperienceMonthsAgo.remove(0)
		StaffExperienceMonthsAgo.append(StaffExperience)
		StaffTrustMonthsAgo.remove(0)
		StaffTrustMonthsAgo.append(StaffTrust)
		TechnologyMonthsAgo.remove(0)
		TechnologyMonthsAgo.append(Technology)
	############################################################################
	# call to action
	if doesItEndWithCall == true:
		get_tree().change_scene("res://call.tscn")
	# finish


# Below: useful game logic funcs

func SetUpNewPriorities(completelyNew):
	if completelyNew == true:
		PriorityGovernments = random.randi_range(70,100)
		PriorityTerrorism = random.randi_range(5,100)
		PriorityTech = random.randi_range(5,100)
		PriorityWMD = random.randi_range(5,100)
		PriorityPublic = random.randi_range(5,100)
		PriorityTargetCountries.clear()
		PriorityOfflimitCountries.clear()
		for x in range(1, len(WorldData.DiplomaticRelations[0])):
			if WorldData.DiplomaticRelations[0][x] < -30:
				PriorityTargetCountries.append(x)
			elif WorldData.DiplomaticRelations[0][x] > 30:
				if random.randi_range(1,3) == 2:
					PriorityOfflimitCountries.append(x)
			else:
				if random.randi_range(1,8) == 3:
					PriorityTargetCountries.append(x)
	else:
		PriorityGovernments += random.randi_range(-5,5)
		PriorityTerrorism += random.randi_range(-15,15)
		PriorityTech += random.randi_range(-15,15)
		PriorityWMD += random.randi_range(-15,15)
		PriorityPublic += random.randi_range(-15,15)
		for x in range(1, len(WorldData.DiplomaticRelations[0])):
			if WorldData.DiplomaticRelations[0][x] < -30 and !(x in PriorityTargetCountries):
				PriorityTargetCountries.append(x)
		if PriorityGovernments < 1: PriorityGovernments = 1
		if PriorityGovernments > 100: PriorityGovernments = 100
		if PriorityTerrorism < 1: PriorityTerrorism = 1
		if PriorityTerrorism > 100: PriorityTerrorism = 100
		if PriorityTech < 1: PriorityTech = 1
		if PriorityTech > 100: PriorityTech = 100
		if PriorityWMD < 1: PriorityWMD = 1
		if PriorityWMD > 100: PriorityWMD = 100
		if PriorityPublic < 1: PriorityPublic = 1
		if PriorityPublic > 100: PriorityPublic = 100
	if TurnOnTerrorist == false: PriorityTerrorism = 50
	if TurnOnWMD == false: PriorityWMD = 50

func ListPriorities(delimeter):
	# why func? to provide nice semi-sorted list
	# sorted priorities
	var options = [[PriorityGovernments, "gathering intelligence on other governments (" + str(int(PriorityGovernments)) + "%)"], [PriorityTech, "technological and industrial espionage (" + str(int(PriorityTech)) + "%)"], [PriorityPublic, "public opinion (" + str(PriorityPublic) + "%)"]]
	if TurnOnTerrorist == true: options.append([PriorityTerrorism, "war on terrorism (" + str(int(PriorityTerrorism)) + "%)"])
	if TurnOnWMD == true: options.append([PriorityWMD, "proliferation of weapons of mass destruction (" + str(int(PriorityWMD)) + "%)"])
	options.sort_custom(MyCustomSorter, "sort_descending")
	var toPool = []
	for p in options: toPool.append(p[1])
	# country priorities
	var targetedNames = []
	for t in PriorityTargetCountries: targetedNames.append(WorldData.Countries[t].Name)
	var targeted = "important targets: " + PoolStringArray(targetedNames).join(" | ")
	if len(PriorityTargetCountries) > 0: toPool.append(targeted)
	var offlimitedNames = []
	for t in PriorityOfflimitCountries: offlimitedNames.append(WorldData.Countries[t].Name)
	var offlimited = "off-limits countries: " + PoolStringArray(offlimitedNames).join(" | ")
	if len(PriorityOfflimitCountries) > 0: toPool.append(offlimited)
	# joining all
	return PoolStringArray(toPool).join(delimeter)

# Below: callbacks called after decision screen

func ImplementAbroad(thePlan):
	# in the meantime, situation could change, so we need to be sure about numbers
	if OfficersInHQ >= thePlan.Officers:
		if thePlan.Remote == false:
			AddEvent(Operations[thePlan.OperationId].Name + ": "+str(thePlan.Officers)+" officer(s) departed to "+thePlan.Country)
		else:
			AddEvent(Operations[thePlan.OperationId].Name + ": "+str(thePlan.Officers)+" officer(s) began operation")
		# operation update
		Operations[thePlan.OperationId].AbroadProgress = 100
		Operations[thePlan.OperationId].Stage = OperationGenerator.Stage.ABROAD_OPERATION
		Operations[thePlan.OperationId].AbroadPlan = thePlan
		Operations[thePlan.OperationId].AbroadRateOfProgress = 99.0/thePlan.Length
		Operations[thePlan.OperationId].Result = "ONGOING (GROUND)"
		# moving officers
		OfficersInHQ -= thePlan.Officers
		OfficersAbroad += thePlan.Officers
		Operations[thePlan.OperationId].AnalyticalOfficers -= thePlan.Officers
		Operations[thePlan.OperationId].OperationalOfficers += thePlan.Officers
		# moving budget
		BudgetOngoingOperations += thePlan.Cost
		#print('DEBUG:')
		#print(Operations[thePlan.OperationId].AbroadPlan)

func ImplementCallOff(i):
	Operations[i].Stage = OperationGenerator.Stage.CALLED_OFF
	Operations[i].Result = "CALLED OFF"
	if Operations[i].AbroadPlan != null:
		OfficersInHQ += Operations[i].AbroadPlan.Officers
		OfficersAbroad -= Operations[i].AbroadPlan.Officers
		BudgetOngoingOperations -= Operations[i].AbroadPlan.Cost
		if Operations[i].AbroadPlan.Remote == false:
			AddEvent(Operations[i].Name + ": "+str(Operations[i].AbroadPlan.Officers)+" officer(s) returned to Homeland")
	PursuedOperations -= 1
	if Operations[i].Source == 1:
		Trust = Trust*0.67  # huge loss of trust if calling off gov op
	AddEvent("Bureau called off operation "+Operations[i].Name)

func ImplementOfficerRescue(adictionary):
	var i = adictionary.Operation
	# debriefing variables
	PursuedOperations -= 1
	Operations[i].Stage = OperationGenerator.Stage.FAILED
	Operations[i].Result = "FAILED, " + str(int(Operations[i].AbroadPlan.Officers)) + " officers arrested"
	OfficersAbroad -= Operations[i].AbroadPlan.Officers
	BudgetOngoingOperations -= Operations[i].AbroadPlan.Cost
	# choice-based changes
	# "engaging government will return officers, but significantly decrease government's trust"
	if adictionary.Choice == 1:
		AddEvent(WorldData.Countries[Operations[i].Country].Name + " (" + Operations[i].Name + "): "+str(Operations[i].AbroadPlan.Officers)+" officer(s) returned to Homeland after being arrested")
		OfficersInHQ += Operations[i].AbroadPlan.Officers
		StaffTrust *= 1.1
		StaffSkill *= 1.01
		StaffExperience *= 1.03
		var trustLoss = Trust * 0.4 * PriorityPublic*0.01
		if Operations[i].Country in PriorityTargetCountries: trustLoss *= 0.5
		elif Operations[i].Country in PriorityOfflimitCountries: trustLoss += 10
		if trustLoss < (20*PriorityPublic*0.01): trustLoss = 20*PriorityPublic*0.01
		if trustLoss > Trust: trustLoss = Trust
		Trust -= trustLoss
		WorldData.DiplomaticRelations[0][Operations[i].Country] -= random.randi_range(5,15)
		WorldData.DiplomaticRelations[Operations[i].Country][0] -= random.randi_range(5,15)
	# "expelling will happen between intelligence services only, but these officers will never be allowed to enter this country again"
	elif adictionary.Choice == 2:
		AddEvent(WorldData.Countries[Operations[i].Country].Name + " (" + Operations[i].Name + "): "+str(Operations[i].AbroadPlan.Officers)+" officer(s) returned to Homeland after being arrested")
		OfficersInHQ += Operations[i].AbroadPlan.Officers
		StaffTrust *= 1.08
		StaffSkill *= 1.01
		StaffExperience *= 1.03
		WorldData.Countries[Operations[i].Country].Expelled += Operations[i].AbroadPlan.Officers
	# "denying affiliation will result in officer imprisonment and their de facto loss, affecting internal trust, but not affecting any external instituions"
	elif adictionary.Choice == 3:
		ActiveOfficers -= Operations[i].AbroadPlan.Officers
		AddEvent(WorldData.Countries[Operations[i].Country].Name + " (" + Operations[i].Name + "): "+str(Operations[i].AbroadPlan.Officers)+" officer(s) arrested and imprisoned for many years")
		StaffTrust *= 0.4
		StaffSkill *= 0.8
		StaffExperience *= 0.8
	# "exfiltration is a risky, covert rescue operation performed by the rest of the officers (" +str(GameLogic.OfficersInHQ) + " available), which returns officers intact in case of success but leads to both huge trust loss and expulsion in case of failure"
	else:
		AddEvent(WorldData.Countries[Operations[i].Country].Name + " (" + Operations[i].Name + "): "+str(Operations[i].AbroadPlan.Officers)+" officer(s) returned to Homeland after being arrested")
		StaffTrust *= 1.09
		StaffSkill *= 1.02
		StaffExperience *= 1.02
		var involvedInExf = OfficersInHQ
		if involvedInExf > 15: involvedInExf = random.randi_range(14,18)
		var content = ""
		if !(("successfully exfiltrated officers from "+WorldData.Countries[Operations[i].Country].Name) in Achievements):
			Achievements.append("successfully exfiltrated officers from "+WorldData.Countries[Operations[i].Country].Name)
		if random.randi_range(0, Operations[i].AbroadPlan.Officers) < involvedInExf and random.randi_range(1,3) < 3:  # second condition to ensure variability even if we sent 100 officers
			# successful
			content = "Exfiltration was successful. "+str(Operations[i].AbroadPlan.Officers)+" officer(s) returned to Homeland."
			OfficersInHQ += Operations[i].AbroadPlan.Officers
		elif random.randi_range(0, 50) < (WorldData.Countries[Operations[i].Country].Network - WorldData.Countries[Operations[i].Country].NetworkBlowup):
			# successful
			content = "Exfiltration was successful, largely due to support of local agent network. "+str(Operations[i].AbroadPlan.Officers)+" officer(s) returned to Homeland."
			OfficersInHQ += Operations[i].AbroadPlan.Officers
		else:
			# unsuccessful
			var trustLoss = Trust * 0.5 * PriorityPublic*0.01
			if Operations[i].Country in PriorityTargetCountries: trustLoss *= 0.5
			elif Operations[i].Country in PriorityOfflimitCountries: trustLoss += 10
			if trustLoss < (25*PriorityPublic*0.01): trustLoss = 25*PriorityPublic*0.01
			if trustLoss > Trust: trustLoss = Trust
			Trust -= trustLoss
			WorldData.Countries[Operations[i].Country].Expelled += Operations[i].AbroadPlan.Officers + involvedInExf
			content = "Exfiltration failed. Government officials of Homeland and " + WorldData.Countries[Operations[i].Country].Name + " learned about the situation. "+str(Operations[i].AbroadPlan.Officers)+" officer(s) returned, but bureau lost " + str(int(trustLoss)) + "% of trust. In addition, " + str(int(Operations[i].AbroadPlan.Officers + involvedInExf)) + " officer(s) were deemed persona non grata in " + WorldData.Countries[Operations[i].Country].Name + "."
			WorldData.DiplomaticRelations[0][Operations[i].Country] -= random.randi_range(5,15)
			WorldData.DiplomaticRelations[Operations[i].Country][0] -= random.randi_range(5,15)
			OfficersInHQ += Operations[i].AbroadPlan.Officers
		# user debriefing
		CallManager.CallQueue.append(
			{
				"Header": "Important Information",
				"Level": Operations[i].Level,
				"Operation": Operations[i].Name  + "\nagainst " + WorldData.Organizations[Operations[i].Target].Name,
				"Content": content,
				"Show1": false,
				"Show2": false,
				"Show3": false,
				"Show4": true,
				"Text1": "",
				"Text2": "",
				"Text3": "",
				"Text4": "Understood",
				"Decision1Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision1Argument": null,
				"Decision2Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision2Argument": null,
				"Decision3Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision3Argument": null,
				"Decision4Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision4Argument": null,
			}
		)

func ImplementWalkin(adict):
	# reject
	if adict.Choice == 1:
		pass
	# accept
	elif adict.Choice == 2:
		# {"Choice", "Content", "Whichorg", "Quality",}
		var content = adict.Content
		WorldIntel.GatherOnOrg(adict.Whichorg, adict.Quality, GiveDateWithYear(), false)
		content += "\n\nProvided intel:\n" + WorldData.Organizations[adict.Whichorg].IntelDescription[0].substr(18)
		CallManager.CallQueue.append(
			{
				"Header": "Urgent Decision",
				"Level": "Secret",
				"Operation": "-//-",
				"Content": content,
				"Show1": false,
				"Show2": false,
				"Show3": false,
				"Show4": true,
				"Text1": "",
				"Text2": "",
				"Text3": "",
				"Text4": "Understood",
				"Decision1Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision1Argument": null,
				"Decision2Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision2Argument": null,
				"Decision3Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision3Argument": null,
				"Decision4Callback": funcref(GameLogic, "EmptyFunc"),
				"Decision4Argument": null,
			}
		)
		var invDetail = "Investigation team concluded that intel provided by the source is highly credible and advances our knowledge about " + WorldData.Organizations[adict.Whichorg].Name + "."
		if adict.Quality < 0: invDetail = "Investigation team concluded that intel provided by the source is false and reduced our knowledge about " + WorldData.Organizations[adict.Whichorg].Name + "."
		Investigations.append(
			{
				"Type": 100,
				"FinishCounter": random.randi_range(2,3),
				"Organization": adict.Whichorg,
				"Operation": null,
				"Success": null,
				"Content": "Walk-in Source from " + WorldData.Organizations[adict.Whichorg].Name + "\n\n" + invDetail,
			}
		)

func ImplementDirectionDevelopment(aDict):
	# number of officers can always change in-between
	if OfficersInHQ >= aDict.Officers and aDict.Officers != 0:
		# {Choice, Cost, Length, Officers, Country}
		var languageEffect = 0
		var customsEffect = 0
		var covertEffect = 0
		var quality = 0  # unused in training
		if aDict.Choice == 1:
			# language training
			languageEffect = aDict.Officers * aDict.Length * (1.0+(random.randi_range(-3,3)*0.1))
			if WorldData.Countries[aDict.Country].KnowhowLanguage > 70: languageEffect *= 0.5
		elif aDict.Choice == 2 and WorldData.Countries[aDict.Country].DiplomaticTravel == true:
			# embassy residency, language immersion, engagement with local culture
			languageEffect = aDict.Officers * aDict.Length * (1.0+(random.randi_range(-2,5)*0.1))
			if WorldData.Countries[aDict.Country].KnowhowLanguage > 90: languageEffect *= 0.3
			elif WorldData.Countries[aDict.Country].KnowhowLanguage > 70: languageEffect *= 0.6
			customsEffect = aDict.Officers * aDict.Length * (1.0+(random.randi_range(-2,5)*0.1))
			if WorldData.Countries[aDict.Country].KnowhowCustoms > 90: customsEffect *= 0.3
			elif WorldData.Countries[aDict.Country].KnowhowCustoms > 70: customsEffect *= 0.6
			if WorldData.Countries[aDict.Country].CovertTravel < 10: covertEffect = random.randi_range(5,10)
		elif aDict.Choice == 2 and WorldData.Countries[aDict.Country].DiplomaticTravel == false:
			# residency in closest possible country, acquitance with local emmigrants from targeted country
			languageEffect = aDict.Officers * aDict.Length * (1.0+(random.randi_range(-4,2)*0.1))
			if WorldData.Countries[aDict.Country].KnowhowLanguage > 90: languageEffect *= 0.3
			elif WorldData.Countries[aDict.Country].KnowhowLanguage > 70: languageEffect *= 0.6
			customsEffect = aDict.Officers * aDict.Length * (1.0+(random.randi_range(-2,5)*0.1))
			if WorldData.Countries[aDict.Country].KnowhowCustoms > 90: customsEffect *= 0.3
			elif WorldData.Countries[aDict.Country].KnowhowCustoms > 70: customsEffect *= 0.6
			if WorldData.Countries[aDict.Country].CovertTravel < 30: covertEffect = random.randi_range(5,10)
		elif aDict.Choice == 3 and WorldData.Countries[aDict.Country].CovertTravel <= 35:
			# develop passport forging system, test and correct covert travel procedures
			covertEffect = aDict.Officers * aDict.Length * (1.0+(random.randi_range(-2,4)*0.1))
		elif aDict.Choice == 3:
			# correct covert travel procedures, live as a covert local
			covertEffect = aDict.Officers * aDict.Length * (1.0+(random.randi_range(-5,5)*0.1))
			if WorldData.Countries[aDict.Country].CovertTravel > 80: covertEffect *= 0.3
			elif WorldData.Countries[aDict.Country].CovertTravel > 60: covertEffect *= 0.6
		elif aDict.Choice == 4:
			# establishing a new network or expanding existing one
			quality = (WorldData.Countries[aDict.Country].KnowhowCustoms + WorldData.Countries[aDict.Country].KnowhowLanguage + StaffSkill) * 0.3
			if WorldData.Countries[aDict.Country].Network == 0 and quality > 15:
				quality = random.randi_range(13,17)
			if quality < 2: quality = 2
			WorldData.Countries[aDict.Country].NetworkWork = true
			YearlyNetworks += 1
		elif aDict.Choice == 5:
			# establishing a new station or expanding existing one
			"""quality = (WorldData.Countries[aDict.Country].KnowhowCustoms + WorldData.Countries[aDict.Country].KnowhowLanguage) * 0.4 + (StaffSkill + Technology) * 0.6
			if WorldData.Countries[aDict.Country].Station == 0 and quality > 8:
				quality = random.randi_range(7,10)
			if quality < 2: quality = 2"""
			quality = 1  # always just one officer
			WorldData.Countries[aDict.Country].StationWork = true
			ActiveOfficers -= 1
			OfficersInHQ -= 1
		Directions.append(
			{
				"Active": true,
				"Type": aDict.Choice,
				"MonthlyCost": aDict.Cost * 4.0 / aDict.Length,
				"Length": aDict.Length,
				"LengthCounter": aDict.Length,
				"Officers": aDict.Officers,
				"Country": aDict.Country,
				"LanguageEffect": languageEffect,
				"CustomsEffect": customsEffect,
				"CovertEffect": covertEffect,
				"Quality": quality,
			}
		)
		BudgetOngoingOperations += aDict.Cost * 4.0 / aDict.Length
		if aDict.Choice != 5:
			OfficersInHQ -= aDict.Officers
			OfficersAbroad += aDict.Officers
		if aDict.Choice == 1:
			AddEvent(str(aDict.Officers) + " officer(s) departed to training center")
		elif aDict.Choice <= 3:
			AddEvent(str(aDict.Officers) + " officer(s) departed to " + WorldData.Countries[aDict.Country].Name + " to develop new skills")
		elif aDict.Choice == 4:
			if WorldData.Countries[aDict.Country].Network > 0:
				AddEvent(str(aDict.Officers) + " officer(s) departed to " + WorldData.Countries[aDict.Country].Name + " to expand Bureau's network")
			else:
				AddEvent(str(aDict.Officers) + " officer(s) departed to " + WorldData.Countries[aDict.Country].Name + " to establish a new network")
		elif aDict.Choice == 5:
			if WorldData.Countries[aDict.Country].Station > 0:
				AddEvent(str(aDict.Officers) + " officer(s) departed to " + WorldData.Countries[aDict.Country].Name + " to expand intelligence station")
			else:
				AddEvent(str(aDict.Officers) + " officer(s) departed to " + WorldData.Countries[aDict.Country].Name + " to establish a new intelligence station")
		if aDict.Country in PriorityTargetCountries: Trust += 1

func ImplementSourceTermination(aDict):
	# {"Org", "Source", "InvestigationDetails"}
	Investigations.append(
		{
			"Type": 100,
			"FinishCounter": random.randi_range(3,6),
			"Organization": aDict.Org,
			"Operation": null,
			"Success": null,
			"Content": "Source Loss in " + WorldData.Organizations[aDict.Org].Name + "\n\n" + aDict.InvestigationDetails,
		}
	)
	WorldData.Organizations[aDict.Org].IntelSources.remove(aDict.Source)

func ImplementMoleTermination(aDict):
	# {"Org", "Op"}
	var ifSuccess = false
	if WorldData.Organizations[aDict.Org].ActiveOpsAgainstHomeland > 0:
		ifSuccess = true
		InternalMoles -= 1
		WorldData.Organizations[aDict.Org].ActiveOpsAgainstHomeland -= 1
		for z in range(0,len(WorldData.Organizations[aDict.Org].OpsAgainstHomeland)):
			if WorldData.Organizations[aDict.Org].OpsAgainstHomeland[z].Active == true:
				WorldData.Organizations[aDict.Org].OpsAgainstHomeland[z].Active = false
		if WorldData.Organizations[aDict.Org].ActiveOpsAgainstHomeland == 0:
			WorldData.Organizations[aDict.Org].OpsAgainstHomeland[aDict.Op].InvestigationData.CovertDamage = WorldData.Countries[WorldData.Organizations[aDict.Org].Countries[0]].CovertTravelBlowup
			WorldData.Countries[WorldData.Organizations[aDict.Org].Countries[0]].CovertTravelBlowup = 0
			WorldData.Countries[WorldData.Organizations[aDict.Org].Countries[0]].CovertTravel *= 0.7
		else:
			WorldData.Organizations[aDict.Org].OpsAgainstHomeland[aDict.Op].InvestigationData.CovertDamage = WorldData.Countries[WorldData.Organizations[aDict.Org].Countries[0]].CovertTravelBlowup * 0.5
			WorldData.Countries[WorldData.Organizations[aDict.Org].Countries[0]].CovertTravelBlowup *= 0.5
		WorldData.Organizations[aDict.Org].OpsAgainstHomeland[aDict.Op].InvestigationData.NetworkDamage = WorldData.Countries[WorldData.Organizations[aDict.Org].Countries[0]].NetworkBlowup
	ActiveOfficers -= 1
	OfficersInHQ -= 1
	StaffSkill *= 0.9
	StaffExperience *= 0.9
	StaffTrust *= 0.8
	Investigations.append(
		{
			"Type": WorldData.ExtOpType.COUNTERINTEL,
			"FinishCounter": random.randi_range(5,10),
			"Organization": aDict.Org,
			"Operation": aDict.Op,
			"Success": ifSuccess,
		}
	)

func OnboardingIsOn(which):
	Onboarding = true
	var content = ""
	if which == 0:
		content = "Week 1: Big Picture\n\nIntelligence services are tightly connected to the government. Relationship between Bureau and Homeland government is predominantly summarized by [b]trust[/b] parameter, from 0% to 100%, displayed at the top of the main screen.\n\nTrust directly translates to budget and clearances. Successful activities increase trust, bonus points for alignment with government priorities. On the contrary, if anything goes wrong, trust falls accordingly. After prolonged period of extremely low trust (under [b]10%[/b]), you can lose your job as Bureau chief."
	elif which == 1:
		content = "Week 2: Operations\n\nCore activity of Bureau is divided into [b]operations[/b]. These are few-week stunts performed abroad by the officers, who achieve goals via methods of espionage tradecraft. Roughly, the main goals are: gathering intelligence (information), recruiting sources, or directly damaging adversary.\n\nOperations are sometimes requested by Homeland government. This should happen in this week. You can also start operations yourself in the 'Intelligence' screen. Proactivity and anticipation is the key to success.\n\nAfter initiating an operation, officers in HQ (if there are any) design possible plans over the next few days or a full week. You will receive three plans, differing in methods, staffing, quality, risk. By choosing one of them, ground section of the operation begins.\n\nSpeaking of [b]risk[/b], managing it is one of your most important tasks. Many things can go wrong: officers could be turned back at the border, forced to hide and extend the operation, or even be caught. When caught, travel via embassy usually gives them diplomatic immunity. However, when travelling covertly or targeting criminal organizations, they can be captured or even killed. The risk can be worth the hassle - covert action gives better results - but actual loss of officers may be a huge setback to Bureau skills and Government trust."
	elif which == 2:
		content = "Week 3: Intelligence Cycle\n\nNeeds -> Collection -> Dissemination\n\nYou decide which [b]organizations[/b] are most important from the perspective of national security. Bureau can target other governments and international organizations to gather intel useful for Homeland government; criminal organizations to monitor whether they are preparing an attack on Homeland; social movements to deepen knowledge about existing and future criminal organizations; scientific institutions and companies to steal technology and discover eventual WMD projects; finally, you can target other intelligence services to steal their tech, intel, and discover direct anti-Bureau operations.\n\n[b]Intel[/b] can be gathered in direct operations, via connections to other organizations, or indirectly by individuals other than officers. In the last category, intel can be regularly provided by sources recruited inside an organization, or by employees of local intelligence station, who survey all organizations in a country.\n\nAll informations are immediately [b]disseminated[/b] by officers in HQ, aiding future operations and allowing the use of more sophisticated methods against the target. Some informations are also passed on to other authorities. For instance, details about planned terrorist attack or identified members of criminal organization can be used by Homeland law enforcement forces to prevent terrorist attack from happenning. You can also interpret intel to guide your future choices. Be aware that some intel can be misleading. There is even possibility that recruited sources will become double agents, intentionally providing false information prepared by counterintelligence services."
	elif which >= 3:
		content = "Week 4: External World\n\nCritical information about other countries is summarized in [b]Directions[/b] screen. Officers can develop skills, acquire experience, build local infrastructure in specific countries, which in turn heavily influences results of local operations.\n\n[b]Organizations[/b] constantly expand or shrink, plan new actions, form new connections, some of them move between countries. New criminal organizations can emerge from social movements, from other criminal organizations, or out of thin air. Their existence may be unknown until they are discovered by other authorities or by Bureau itself.\n\n[b]Governments[/b] undergo election cycles, after which their approach to intelligence services and other countries may significantly change. Large deterioriation of diplomatic relations can lead to wars, including nuclear wars. Be aware that Homeland entering a war with a nation possessing weapons of mass destruction leads to mutual or one-sided annihilation. Intel gathered on WMD programs can prevent Homeland government from entering such conflict.\n\nOther [b]intelligence services[/b] can target Bureau. Eventual recruitment of one of the officers can lead to loss of covert abilities in the host country of adversary, reversal of the recruited sources, and loss of local agent network.\n\nThis is the last onboarding communicate. There is much more - for instance, offensive operations - but you can discover these mechanisms yourself at later stages. Good luck!"
		Onboarding = false
	CallManager.CallQueue.append(
		{
			"Header": "Onboarding",
			"Level": "Secret",
			"Operation": "-//-",
			"Content": content,
			"Show1": false,
			"Show2": false,
			"Show3": true,
			"Show4": true,
			"Text1": "",
			"Text2": "",
			"Text3": "Turn Off\nOnboarding",
			"Text4": "Understood",
			"Decision1Callback": funcref(GameLogic, "EmptyFunc"),
			"Decision1Argument": null,
			"Decision2Callback": funcref(GameLogic, "EmptyFunc"),
			"Decision2Argument": null,
			"Decision3Callback": funcref(GameLogic, "OnboardingTurnOff"),
			"Decision3Argument": null,
			"Decision4Callback": funcref(GameLogic, "EmptyFunc"),
			"Decision4Argument": null,
		}
	)

func OnboardingTurnOff(anyArgument):
	Onboarding = false

func FinalQuit(anyArgument):
	Testmodule.FinishSummary()
	get_tree().quit()

func EmptyFunc(anyArgument):
	pass  # nothing happens
