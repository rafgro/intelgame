extends Node

# imports
var OperationGenerator = load("res://OperationGenerator.gd").new()

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
# Budget screen
var BudgetFull = 100  # in thousands
var BudgetSalaries = 12
var BudgetOffice = 5
var BudgetRecruitment = 0
var BudgetUpskilling = 0
var BudgetSecurity = 0
# Operations
var Operations = []  # array of operation dictionaries
# Internal logic variables, always describe them
var RecruitProgress = 0.0  # when reaches 1, a new officer arrives
# Sort of constants but also internal, always describe them
var NewOfficerCost = 80  # thousands needed to spend on a new officer

func AddEvent(text):
	var localDate = ""
	if DateDay < 10: localDate += "0"
	localDate += str(DateDay) + "/"
	if DateMonth < 10: localDate += "0"
	localDate += str(DateMonth)
	BureauEvents.push_front("[u][b]"+localDate+"[/b] " + text + "[/u]")

# first ever call: proper initialization of vars
func _init():
	AddEvent("The bureau has opened")

func NextWeek():
	# clearing u-tags in events
	var i = 0
	while i < len(BureauEvents):
		if "[u]" in BureauEvents[i]:
			BureauEvents[i] = BureauEvents[i].substr(3, len(BureauEvents[i])-7)
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
	# budget-based officer recruitment
	RecruitProgress += BudgetRecruitment / 4 / NewOfficerCost
	if RecruitProgress >= 1.0:
		# currently always plus one, sort of weekly onboarding limit
		# in the future expand that to a loop
		ActiveOfficers += 1
		OfficersInHQ += 1
		RecruitProgress -= 1.0
		AddEvent("New officer joined the bureau")
	# new operation given by the government
	if 1 == 2:
		Operations.append(OperationGenerator.NewOperation())
		AddEvent("Government designated a new operation: " + Operations[-1].name)
	# call to action
	if 1 == 1:
		get_tree().change_scene("res://call.tscn")
	# finish
