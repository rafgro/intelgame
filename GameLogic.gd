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

# first ever call: proper initialization of vars
func _init():
	random.randomize()
	randomize()
	AddEvent("The bureau has opened")

func _ready():
	WorldGenerator.NewGenerate()

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
	# new operation given by the government
	"""
	if DateDay == 8 or random.randi_range(1,20) == 5:
		OperationGenerator.NewOperation()
		CallManager.CallQueue.append(
			{
				"Header": "Important Information",
				"Level": Operations[-1].Level,
				"Operation": Operations[-1].Name,
				"Content": "Government designated a new operation. Goal:\n"
					+ Operations[-1].GoalDescription + ".\n"
					+ "Find the target, execute operation, return with results.",
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
	"""
	# operations
	var ifCall = OperationHandler.ProgressOperations()
	if ifCall == true: doesItEndWithCall = true
	# world changes
	WorldData.WorldNextWeek(null)
	# call to action
	if doesItEndWithCall == true:
		get_tree().change_scene("res://call.tscn")
	# finish

func ImplementAbroad(thePlan):
	AddEvent(Operations[thePlan.OperationId].Name + ": "+str(thePlan.Officers)+" officer(s) departed to "+thePlan.Country)
	PursuedOperations += 1
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

func EmptyFunc(anyArgument):
	pass  # nothing happens
