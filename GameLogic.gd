# Logic usually separated from the display

extends Node

var random = RandomNumberGenerator.new()
var OperationHandler = load("res://OperationHandler.gd").new()

# Basic general variables, in the main screen order
var DateDay = 1
var DateMonth = 1
var DateYear = 2021
var Trust = 51
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
var BudgetFull = 100  # in thousands
var BudgetOngoingOperations = 0
# Staff
var StaffSkill = 10  # 0 to 100
var StaffSkillMonthsAgo = []  # array of 13 last values, furthest is the first
var StaffExperience = 0  # 0 to 100
var StaffExperienceMonthsAgo = []  # array of 13 last values, furthest is the first
var StaffTrust = 50  # 0 to 100
var StaffTrustMonthsAgo = []  # array of 13 last values, furthest is the first
var Technology = 5  # 0 to 100
var TechnologyMonthsAgo = []  # array of 13 last values, furthest is the first
# Operations
var Operations = []  # array of operation dictionaries
var Directions = []  # array of simple operation-like dicts
# Internal logic variables, always describe them
var AllWeeks = 0  # noting all weeks for later summary
var RecruitProgress = 0.0  # when reaches 1, a new officer arrives
var PreviousTrust = 0  # trust from previous week, to write show the change week to week
var AttackTicker = 0  # race against time in preventing a terrorist attack, shown if >0
var AttackTickerOp = {"Org":0,"Op":0}  # which organization and operation it is following
var UltimatumTicker = 0  # weeks to actual lay off if user doesn't bring back trust
var CurrentOpsAgainstHomeland = 0  # internal counter to not overwhelm user, simultaneous
var YearlyOpsAgainstHomeland = 0  # internal counter as well, yearly ops, zeroed on 01/01
var OpsLimit = 2  # max number of simulatenous ops against homeland, might be increased over time
var UniversalClearance = false  # with high trust, bureau can target anything they want
# Distance counters: block anything that happens more frequently than limit
var DistWalkinCounter = 0
var DistWalkinMin = 10  # minimum ten weeks between those events
var DistGovopCounter = 0
var DistGovopMin = 6
# Sort of constants but also internal, always describe them
var NewOfficerCost = 80  # thousands needed to spend on a new officer
var NewTechCost = 200  # thousands needed to spend on a new percent of technology
var SkillMaintenanceCost = 5  # thousands needed to maintain skills for an officer

func GiveDateWithYear():
	var dateString = ""
	if DateDay < 10: dateString += "0"
	dateString += str(DateDay) + "/"
	if DateMonth < 10: dateString += "0"
	dateString += str(DateMonth) + "/" + str(DateYear)
	return dateString
	
func GiveDateWithoutYear():
	var dateString = ""
	if DateDay < 10: dateString += "0"
	dateString += str(DateDay) + "/"
	if DateMonth < 10: dateString += "0"
	dateString += str(DateMonth)
	return dateString

func AddEvent(text):
	BureauEvents.push_front("[u][b]"+GiveDateWithoutYear()+"[/b] " + text + "[/u]")

func AddWorldEvent(text, past):
	if past == null:
		WorldEvents.push_front("[u][b]"+GiveDateWithYear()+"[/b] " + text + "[/u]")
	else:
		WorldEvents.push_front("[b]"+past+"[/b] " + text)

func FreeFundsWeekly():
	return (BudgetFull - (ActiveOfficers*4+ActiveOfficers*1+BudgetOngoingOperations)) / 4

func FreeFundsWeeklyWithoutOngoing():
	return (BudgetFull - (ActiveOfficers*4+ActiveOfficers*1)) / 4

func IntensityPercent(which):
	return int(which * 1.0 / (IntensityHiring + IntensityUpskill + IntensityTech) * 100)

# first ever call: proper initialization of vars
func _init():
	random.randomize()
	randomize()
	AddEvent("The bureau has opened")

func _ready():
	# past and current world situation
	WorldGenerator.NewGenerate()
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
				# change from false to criterions fulfilled
				WorldData.Methods[t][m].Available = true
	# initial change counters
	StaffSkillMonthsAgo.append(StaffSkill)
	StaffExperienceMonthsAgo.append(StaffExperience)
	StaffTrustMonthsAgo.append(StaffTrust)
	TechnologyMonthsAgo.append(Technology)

func NextWeek():
	############################################################################
	var doesItEndWithCall = false
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
				var budgetIncrease = GameLogic.BudgetFull*(0.01*GameLogic.Trust)
				if budgetIncrease > 200: budgetIncrease = 200
				BudgetFull += budgetIncrease
				AddEvent("New year budget increase: +€"+str(int(budgetIncrease))+"k")
				# other new-year game logic
				YearlyOpsAgainstHomeland = 0
	############################################################################
	# budget-based changes
	# hiring
	var freeFund = FreeFundsWeekly()
	RecruitProgress += freeFund * (IntensityPercent(IntensityHiring)*0.01) / NewOfficerCost
	if RecruitProgress >= 1.0 and FreeFundsWeekly() >= 4:
		# currently always plus one, sort of weekly onboarding limit
		# in the future expand that to a loop
		ActiveOfficers += 1
		OfficersInHQ += 1
		RecruitProgress -= 1.0
		StaffExperience -= 3
		StaffSkill -= 2
		StaffTrust = StaffTrust * 0.95
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
		AddEvent("New officer joined the bureau"+ifDirection)
	# upskilling
	var upskillDiff = (freeFund * (IntensityPercent(IntensityUpskill)*0.01)) - (SkillMaintenanceCost*ActiveOfficers)
	if upskillDiff > 0.5: upskillDiff = 0.5
	elif upskillDiff < -1: upskillDiff = -1
	if random.randi_range(1,2) == 2: StaffSkill += upskillDiff
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
				# network
				elif Directions[t].Type == 4:
					if WorldData.Countries[Directions[t].Country].Network > 0:
						WorldData.Countries[Directions[t].Country].Network *= (1.0 + Directions[t].Quality*0.01)
						AddEvent(str(Directions[t].Officers) + " officer(s) came back after expanding agent network in " + WorldData.Countries[Directions[t].Country].Name)
					else:
						WorldData.Countries[Directions[t].Country].Network = int(Directions[t].Quality)
						AddEvent(str(Directions[t].Officers) + " officer(s) came back after establishing agent network in " + WorldData.Countries[Directions[t].Country].Name)
				# station
				elif Directions[t].Type == 5:
					if WorldData.Countries[Directions[t].Country].Station > 0:
						WorldData.Countries[Directions[t].Country].Station *= (1.0 + Directions[t].Quality*0.01)
						AddEvent(str(Directions[t].Officers) + " officer(s) came back after expanding station in " + WorldData.Countries[Directions[t].Country].Name)
					else:
						WorldData.Countries[Directions[t].Country].Station = int(Directions[t].Quality)
						AddEvent(str(Directions[t].Officers) + " officer(s) came back after establishing station in " + WorldData.Countries[Directions[t].Country].Name)
	############################################################################
	# operations
	var ifCall = OperationHandler.ProgressOperations()
	if ifCall == true: doesItEndWithCall = true
	############################################################################
	# world changes
	ifCall = WorldNextWeek.Execute(null)
	if ifCall == true: doesItEndWithCall = true
	############################################################################
	# eventual government assigned operations
	if random.randi_range(1,40) == 30 and DistGovopCounter < 1:  # one every few months
		# choosing organization
		var whichOrg = -1
		if random.randi_range(1,4) == 1:
			# any government
			for f in range(0,4):  # max four attempts
				var check = random.randi_range(0, len(WorldData.Organizations)-1)
				if WorldData.Organizations[check].Type == WorldData.OrgType.GOVERNMENT:
					whichOrg = check
					break
			# or any techie
			if whichOrg == -1:
				for f in range(0,5):  # max six attempts
					var check = random.randi_range(0, len(WorldData.Organizations)-1)
					if WorldData.Organizations[check].Type == WorldData.OrgType.COMPANY or WorldData.Organizations[check].Type == WorldData.OrgType.UNIVERSITY:
						whichOrg = check
						break
		else:
			# diplomatic priorities
			var lowestVal = 50
			var lowestId = 0
			for g in range(1, len(WorldData.Countries)):
				if WorldData.DiplomaticRelations[0][g] < lowestVal:
					lowestVal = WorldData.DiplomaticRelations[0][g]
					lowestId = g
			for j in range(0, len(WorldData.Organizations)):
				if WorldData.Organizations[j].Type == WorldData.OrgType.GOVERNMENT or WorldData.Organizations[j].Type == WorldData.OrgType.INTEL or WorldData.Organizations[j].Type == WorldData.OrgType.COMPANY or WorldData.Organizations[j].Type == WorldData.OrgType.UNIVERSITY:
					if WorldData.Organizations[j].Countries[0] == lowestId:
						whichOrg = j
						break
		# assigning the operation
		if whichOrg != -1:
			var opType = OperationGenerator.Type.MORE_INTEL
			if WorldData.Organizations[whichOrg].IntelIdentified > 0 and random.randi_range(1,5) == 2:
				opType = OperationGenerator.Type.RECRUIT_SOURCE
			OperationGenerator.NewOperation(1, whichOrg, opType)
			# if possible, start fast
			if GameLogic.OfficersInHQ > 0:
				GameLogic.Operations[-1].AnalyticalOfficers = GameLogic.OfficersInHQ
				GameLogic.Operations[-1].Stage = OperationGenerator.Stage.PLANNING_OPERATION
				GameLogic.Operations[-1].Started = GameLogic.GiveDateWithYear()
				GameLogic.Operations[-1].Result = "ONGOING (PLANNING)"
			CallManager.CallQueue.append(
				{
					"Header": "Important Information",
					"Level": GameLogic.Operations[-1].Level,
					"Operation": GameLogic.Operations[-1].Name  + "\nagainst " + WorldData.Organizations[GameLogic.Operations[-1].Target].Name,
					"Content": "Homeland government designated a new operation.\n\nGoal:\n" + GameLogic.Operations[-1].GoalDescription,
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
	if random.randi_range(1,30) == 16 and DistWalkinCounter < 1:
		var whichOrg = random.randi_range(0, len(WorldData.Organizations)-1)
		var quality = random.randi_range(-65,65)
		var content = "A source, claiming to be close to " + WorldData.Organizations[whichOrg].Name + " (" + WorldData.Countries[WorldData.Organizatiions[whichOrg].Countries[0]].Name + ") walked in into one our embassies. "
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
				"Text1": "Interrogate",
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
				var localSummary = "- " + str(AllWeeks) + " weeks\n- " + str(len(Operations)) + " operations"  # expand in the future
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
						"Content": "Bringing back level of trust into acceptable territory convinced Government to keep you as the chief of Bureau. In recognition of past struggles, the budget was increased by €" + str(increase) + ",000.",
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
	# physical limits or bug patches
	if BudgetOngoingOperations < 0: BudgetOngoingOperations = 0
	if StaffExperience > 100: StaffExperience = 100
	if StaffSkill > 100: StaffSkill = 100
	if StaffTrust > 100: StaffTrust = 100
	if Trust > 100: Trust = 100
	if Technology > 100: Technology = 100
	# histories of certain variables
	if len(StaffSkillMonthsAgo) < 13:  # if this is under, all histories are under
		# building initial history
		StaffSkillMonthsAgo.append(StaffSkill)
		StaffExperienceMonthsAgo.append(StaffExperience)
		StaffTrustMonthsAgo.append(StaffTrust)
		TechnologyMonthsAgo.append(Technology)
	else:
		# first out, last in
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


# Below: callbacks called after decision screen

func ImplementAbroad(thePlan):
	# in the meantime, situation could change, so we need to be sure about numbers
	if OfficersInHQ >= thePlan.Officers:
		if thePlan.Remote == false:
			AddEvent(Operations[thePlan.OperationId].Name + ": "+str(thePlan.Officers)+" officer(s) departed to "+thePlan.Country)
		else:
			AddEvent(Operations[thePlan.OperationId].Name + ": "+str(thePlan.Officers)+" officer(s) began operation")
		# operation update
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
			AddEvent(Operations[i].Name + ": "+str(Operations[i].AbroadPlan.Officers)+" officer(s) returned to homeland")
	PursuedOperations -= 1
	if Operations[i].Source == 1:
		Trust = Trust*0.5  # huge loss of trust if calling off gov op
	AddEvent("Bureau called off operation "+GameLogic.Operations[i].Name)

func ImplementOfficerRescue(adictionary):
	var i = adictionary.Operation
	# debriefing variables
	PursuedOperations -= 1
	Operations[i].Stage = OperationGenerator.Stage.FAILED
	Operations[i].Result = "FAILED, " + str(GameLogic.Operations[i].AbroadPlan.Officers) + " officers arrested"
	OfficersAbroad -= Operations[i].AbroadPlan.Officers
	BudgetOngoingOperations -= Operations[i].AbroadPlan.Cost
	# choice-based changes
	# "engaging government will return officers, but significantly decrease government's trust"
	if adictionary.Choice == 1:
		AddEvent(Operations[i].Name + ": "+str(Operations[i].AbroadPlan.Officers)+" officer(s) returned to homeland after being arrested")
		OfficersInHQ += Operations[i].AbroadPlan.Officers
		StaffTrust *= 1.1
		StaffSkill *= 1.01
		StaffExperience *= 1.03
		var trustLoss = Trust * 0.4
		if trustLoss < 20: trustLoss = 20
		if trustLoss > Trust: trustLoss = Trust
		Trust -= trustLoss
		WorldData.DiplomaticRelations[0][Operations[i].Country] -= random.randi_range(5,15)
		WorldData.DiplomaticRelations[Operations[i].Country][0] -= GameLogic.random.randi_range(5,15)
	# "expelling will happen between intelligence services only, but these officers will never be allowed to enter this country again"
	elif adictionary.Choice == 2:
		AddEvent(Operations[i].Name + ": "+str(Operations[i].AbroadPlan.Officers)+" officer(s) returned to homeland after being arrested")
		OfficersInHQ += Operations[i].AbroadPlan.Officers
		StaffTrust *= 1.08
		StaffSkill *= 1.01
		StaffExperience *= 1.03
		WorldData.Countries[Operations[i].Country].Expelled += Operations[i].AbroadPlan.Officers
	# "denying affiliation will result in officer imprisonment and their de facto loss, affecting internal trust, but not affecting any external instituions"
	elif adictionary.Choice == 3:
		ActiveOfficers -= Operations[i].AbroadPlan.Officers
		AddEvent(Operations[i].Name + ": "+str(Operations[i].AbroadPlan.Officers)+" officer(s) arrested and imprisoned for many years")
		StaffTrust *= 0.4
		StaffSkill *= 0.8
		StaffExperience *= 0.8
	# "exfiltration is a risky, covert rescue operation performed by the rest of the officers (" +str(GameLogic.OfficersInHQ) + " available), which returns officers intact in case of success but leads to both huge trust loss and expulsion in case of failure"
	else:
		AddEvent(Operations[i].Name + ": "+str(Operations[i].AbroadPlan.Officers)+" officer(s) returned to homeland after being arrested")
		StaffTrust *= 1.09
		StaffSkill *= 1.02
		StaffExperience *= 1.02
		var involvedInExf = OfficersInHQ
		if involvedInExf > 15: involvedInExf = GameLogic.random.randi_range(14,18)
		var content = ""
		if random.randi_range(0, Operations[i].AbroadPlan.Officers) < involvedInExf and random.randi_range(1,3) < 3:  # second condition to ensure variability even if we sent 100 officers
			# successful
			content = "Exfiltration was successful. "+str(Operations[i].AbroadPlan.Officers)+" officer(s) returned to Homeland."
			OfficersInHQ += Operations[i].AbroadPlan.Officers
		elif random.randi_range(0, 50) < WorldData.Countries[Operations[i].Country].Network:
			# successful
			content = "Exfiltration was successful, largely due to support of local agent network. "+str(Operations[i].AbroadPlan.Officers)+" officer(s) returned to Homeland."
			OfficersInHQ += Operations[i].AbroadPlan.Officers
		else:
			# unsuccessful
			var trustLoss = Trust * 0.5
			if trustLoss < 25: trustLoss = 25
			if trustLoss > Trust: trustLoss = Trust
			Trust -= trustLoss
			WorldData.Countries[Operations[i].Country].Expelled += Operations[i].AbroadPlan.Officers + involvedInExf
			content = "Exfiltration failed. Government officials of Homeland and " + WorldData.Countries[Operations[i].Country].Name + " learned about the situation. "+str(Operations[i].AbroadPlan.Officers)+" officer(s) returned, but bureau lost " + str(int(trustLoss)) + "% of trust. In addition, " + int(Operations[i].AbroadPlan.Officers + involvedInExf) + " were deemed persona non grata in " + WorldData.Countries[Operations[i].Country].Name + "."
			WorldData.DiplomaticRelations[0][Operations[i].Country] -= random.randi_range(5,15)
			WorldData.DiplomaticRelations[Operations[i].Country][0] -= GameLogic.random.randi_range(5,15)
			OfficersInHQ += Operations[i].AbroadPlan.Officers
		# user debriefing
		CallManager.CallQueue.append(
			{
				"Header": "Important Information",
				"Level": GameLogic.Operations[i].Level,
				"Operation": GameLogic.Operations[i].Name  + "\nagainst " + WorldData.Organizations[GameLogic.Operations[i].Target].Name,
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
		var content = adict.Content
		WorldIntel.GatherOnOrg(adict.Whichorg, adict.Quality, GiveDateWithYear())
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

func ImplementDirectionDevelopment(aDict):
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
	elif aDict.Choice == 5:
		# establishing a new station or expanding existing one
		quality = (WorldData.Countries[aDict.Country].KnowhowCustoms + WorldData.Countries[aDict.Country].KnowhowLanguage) * 0.4 + (StaffSkill + Technology) * 0.6
		if WorldData.Countries[aDict.Country].Station == 0 and quality > 8:
			quality = random.randi_range(7,10)
		if quality < 2: quality = 2
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
	BudgetOngoingOperations += aDict.Cost * 4
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

func FinalQuit(anyArgument):
	get_tree().quit()

func EmptyFunc(anyArgument):
	pass  # nothing happens
