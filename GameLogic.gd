# Logic usually separated from the display

extends Node

var random = RandomNumberGenerator.new()
var OperationHandler = load("res://OperationHandler.gd").new()

# Basic general variables, in the main screen order
var DateDay = 1
var DateMonth = 1
var DateYear = 2021
var Trust = 51
var ActiveOfficers = 3
var OfficersInHQ = 3
var OfficersAbroad = 0
var PursuedOperations = 0
var BureauEvents = []
var WorldEvents = []
# Budget screen
var BudgetFull = 100  # in thousands
var BudgetSalaries = 12
var BudgetOffice = 5
var BudgetRecruitment = 5
var BudgetUpskilling = 5
var BudgetSecurity = 5
var BudgetOngoingOperations = 0
# Staff screen
var StaffSkill = 10  # 0 to 100
var StaffExperience = 0  # 0 to 100
var StaffTrust = 50  # 0 to 100
# Operations
var Operations = []  # array of operation dictionaries
# Internal logic variables, always describe them
var RecruitProgress = 0.0  # when reaches 1, a new officer arrives
# Sort of constants but also internal, always describe them
var NewOfficerCost = 80  # thousands needed to spend on a new officer
var SkillMaintenanceCost = 1  # thousands needed to maintain skills for an officer
var SecurityMaintenanceCost = 1  # thousands needed to maintain security per officer

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
	return (BudgetFull - (BudgetSalaries+BudgetOffice+BudgetRecruitment \
		+BudgetUpskilling+BudgetSecurity+BudgetOngoingOperations)) / 4

func FreeFundsWeeklyWithoutOngoing():
	return (BudgetFull - (BudgetSalaries+BudgetOffice+BudgetRecruitment \
		+BudgetUpskilling+BudgetSecurity)) / 4

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
				# change from false to criterions fulfilled
				WorldData.Methods[t][m].Available = true

func NextWeek():
	var doesItEndWithCall = false
	# clearing u-tags in events
	var i = 0
	while i < min(len(BureauEvents), 10):
		if "[u]" in BureauEvents[i]:
			BureauEvents[i] = BureauEvents[i].substr(3, len(BureauEvents[i])-7)
		if "[u]" in WorldEvents[i]:
			WorldEvents[i] = WorldEvents[i].substr(3, len(WorldEvents[i])-7)
		i += 1
	# moving seven days forward
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
	# budget-based staff changes
	# recruitment
	RecruitProgress += BudgetRecruitment / 4 / NewOfficerCost
	if RecruitProgress >= 1.0:
		# currently always plus one, sort of weekly onboarding limit
		# in the future expand that to a loop
		ActiveOfficers += 1
		OfficersInHQ += 1
		RecruitProgress -= 1.0
		StaffExperience -= 3
		StaffSkill -= 2
		StaffTrust = StaffTrust * 0.95
		AddEvent("New officer joined the bureau")
	# upskilling
	var upskillDiff = BudgetUpskilling-(SkillMaintenanceCost*ActiveOfficers)
	if upskillDiff > 0.5: upskillDiff = 0.5
	elif upskillDiff < -1: upskillDiff = -1
	StaffSkill += upskillDiff
	# security and trust, breaches in the future
	var trustDiff = BudgetSecurity-(SecurityMaintenanceCost*ActiveOfficers)
	if trustDiff > 1: trustDiff = 1
	elif trustDiff < -2: trustDiff = -2
	StaffTrust += trustDiff
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
				# change from false to criterions fulfilled
				WorldData.Methods[t][m].Available = true
				AddEvent("New craft is available: " + WorldData.Methods[t][m].Name)
	# operations
	var ifCall = OperationHandler.ProgressOperations()
	if ifCall == true: doesItEndWithCall = true
	# world changes
	ifCall = WorldData.WorldNextWeek(null)
	if ifCall == true: doesItEndWithCall = true
	# eventual government assigned operations
	if random.randi_range(1,10) == 6:  # one every ~3 months
		# choosing organization
		var whichOrg = -1
		for f in range(0,5):  # max five attempts
			var check = random.randi_range(0, len(WorldData.Organizations)-1)
			if WorldData.Organizations[check].Type == WorldData.OrgType.GOVERNMENT:
				whichOrg = check
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
			doesItEndWithCall = true
	# call to action
	if doesItEndWithCall == true:
		get_tree().change_scene("res://call.tscn")
	# finish


# Below: callbacks called after decision screen

func ImplementAbroad(thePlan):
	AddEvent(Operations[thePlan.OperationId].Name + ": "+str(thePlan.Officers)+" officer(s) departed to "+thePlan.Country)
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
	# debug
	print('DEBUG:')
	print(Operations[thePlan.OperationId].AbroadPlan)

func ImplementCallOff(i):
	Operations[i].Stage = OperationGenerator.Stage.CALLED_OFF
	Operations[i].Result = "CALLED OFF"
	if Operations[i].AbroadPlan != null:
		OfficersInHQ += Operations[i].AbroadPlan.Officers
		OfficersAbroad -= Operations[i].AbroadPlan.Officers
		BudgetOngoingOperations -= Operations[i].AbroadPlan.Cost
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
		Trust *= 0.6
		WorldData.DiplomaticRelations[0][WorldData.Organizations[Operations[i].Target].Countries[0]] -= random.randi_range(5,15)
		WorldData.DiplomaticRelations[WorldData.Organizations[Operations[i].Target].Countries[0]][0] -= GameLogic.random.randi_range(5,15)
	# "expelling will happen between intelligence services only, but these officers will never be allowed to enter this country again"
	elif adictionary.Choice == 2:
		AddEvent(Operations[i].Name + ": "+str(Operations[i].AbroadPlan.Officers)+" officer(s) returned to homeland after being arrested")
		OfficersInHQ += Operations[i].AbroadPlan.Officers
		StaffTrust *= 1.08
		StaffSkill *= 1.01
		StaffExperience *= 1.03
		# todo: expelling mechanism
	# "denying affiliation will result in officer imprisonment and their de facto loss, affecting internal trust, but not affecting any external instituions"
	elif adictionary.Choice == 3:
		ActiveOfficers -= Operations[i].AbroadPlan.Officers
		AddEvent(Operations[i].Name + ": "+str(Operations[i].AbroadPlan.Officers)+" officer(s) arrested and imprisoned for many years")
		StaffTrust *= 0.4
		StaffSkill *= 0.8
		StaffExperience *= 0.8
	# "bribing can return officers intact, but often does not succeed and instead lead to large diplomatic scandal"
	else:
		AddEvent(Operations[i].Name + ": "+str(Operations[i].AbroadPlan.Officers)+" officer(s) returned to homeland after being arrested")
		OfficersInHQ += Operations[i].AbroadPlan.Officers
		StaffTrust *= 1.09
		StaffSkill *= 1.02
		StaffExperience *= 1.02
		var content = ""
		if random.randi_range(1,2) == 1:
			# successful
			content = "Bribing was successful. "+str(Operations[i].AbroadPlan.Officers)+" officer(s) returned to Homeland."
		else:
			# unsuccessful
			content = "Bribing failed. Government officials of Homeland and " + WorldData.Countries[WorldData.Organizations[Operations[i].Target].Countries[0]].Name + " learned about the situation. "+str(Operations[i].AbroadPlan.Officers)+" officer(s) returned, but bureau lost " + str(int(Trust*0.6)) + "% of trust."
			Trust *= 0.4
			WorldData.DiplomaticRelations[0][WorldData.Organizations[Operations[i].Target].Countries[0]] -= random.randi_range(5,15)
			WorldData.DiplomaticRelations[WorldData.Organizations[Operations[i].Target].Countries[0]][0] -= GameLogic.random.randi_range(5,15)
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

func EmptyFunc(anyArgument):
	pass  # nothing happens
