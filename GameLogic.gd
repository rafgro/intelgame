# Logic usually separated from the display

extends Node

var random = RandomNumberGenerator.new()

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
var BudgetOngoingOperations = 0
# Operations
var Operations = []  # array of operation dictionaries
var ImmediatePlans = []
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

func FreeFundsWeekly():
	return (BudgetFull - (BudgetSalaries+BudgetOffice+BudgetRecruitment \
		+BudgetUpskilling+BudgetSecurity+BudgetOngoingOperations)) / 4

# first ever call: proper initialization of vars
func _init():
	randomize()
	AddEvent("The bureau has opened")

func NextWeek():
	var doesItEndWithCall = false
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
	if DateDay == 8:
		Operations.append(OperationGenerator.NewOperation())
		AddEvent("Government designated a new operation: " + Operations[-1].Name)
		CallManager.CallQueue.append(
			{
				"Header": "Important Information",
				"Level": Operations[-1].Level,
				"Operation": Operations[-1].Name,
				"Content": "Government designated a new operation. Goal:\n" \
					+ Operations[-1].GoalDescription + ".\n" \
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
	# operation proceedings
	i = 0
	while i < len(Operations):
		if Operations[i].Stage == OperationGenerator.Stage.NOT_STARTED:
			# looking for free officers
			if OfficersInHQ > 0:
				Operations[i].AnalyticalOfficers = OfficersInHQ
				Operations[i].Stage = OperationGenerator.Stage.FINDING_LOCATION
		# didn't use elif on purpose here: possible to find location under a week
		if Operations[i].Stage == OperationGenerator.Stage.FINDING_LOCATION:
			# search progress
			var which = Operations[i].Target
			WorldData.Targets[which].LocationSecrecyProgress -= WorldData.Targets[which].LocationOpenness * Operations[i].AnalyticalOfficers
			if WorldData.Targets[which].LocationSecrecyProgress <= 0:
				WorldData.Targets[which].LocationIsKnown = true
				Operations[i].Stage = OperationGenerator.Stage.PLANNING_OPERATION
				AddEvent(Operations[i].Name + ": Officers found location of the target")
		# but used elif on purpose here: one week break after finding location
		elif Operations[i].Stage == OperationGenerator.Stage.PLANNING_OPERATION and OfficersInHQ > 0:
			# designing possible approaches, three plus waiting another week
			# differring by parameters: officers on the ground, cost of methods,
			# quality of operation, risk of failure
			var which = Operations[i].Target
			var minOfficers = 1
			var maxOfficers = OfficersInHQ
			var localPlans = []
			var j = 0
			while j < 6:  # six tries but will present only first three
				var totalCost = 0
				var predictedLength = 3  # in weeks, randomize later, should affect quality
				var usedOfficers = minOfficers
				# finding methods to use in the operation
				var noOfMethods = random.randi_range(1, len(WorldData.Targets[which].AvailableDMethods))
				var theMethods = []
				var safetyCounter = 0
				while len(theMethods) < noOfMethods and safetyCounter < noOfMethods*2:
					safetyCounter += 1
					var methodId = WorldData.Targets[which].AvailableDMethods[randi() % WorldData.Targets[which].AvailableDMethods.size()]
					if methodId in theMethods:
						continue  # avoid duplications
					theMethods.append(methodId)
					if WorldData.Methods[methodId].OfficersRequired > usedOfficers:
						usedOfficers = WorldData.Methods[methodId].OfficersRequired  # adjust to methods
				# adjusting number of officers
				usedOfficers = random.randi_range(usedOfficers, maxOfficers)
				# calculating cost and checking if it's possible
				var singleOfficerCost = WorldData.Countries[WorldData.Targets[which].Country].LocalCost \
					+ (WorldData.Countries[WorldData.Targets[which].Country].TravelCost / predictedLength / 2)
				totalCost += singleOfficerCost * usedOfficers * predictedLength
				for m in theMethods:
					totalCost += WorldData.Methods[m].Cost * predictedLength
				if totalCost > FreeFundsWeekly()*predictedLength:
					continue
				# calculating total operation parameters: clash of location and methods
				# in the future also modify it by time
				# quality
				var totalQuality = 0
				for m in theMethods:
					totalQuality += WorldData.Methods[m].Quality
				totalQuality *= ((100-WorldData.Targets[Operations[i].Target].DiffOfObservation)/100.0)
				var qualityDesc = "poor"
				if totalQuality >= 90: qualityDesc = "great"
				elif totalQuality >= 60: qualityDesc = "good"
				elif totalQuality >= 40: qualityDesc = "medium"
				elif totalQuality >= 10: qualityDesc = "weak"
				# risk
				var totalRisk = 0
				for m in theMethods:
					totalRisk += WorldData.Methods[m].Risk
				totalRisk *= (WorldData.Targets[Operations[i].Target].RiskOfCounterintelligence/100.0)
				var riskDesc = "no"
				if totalRisk >= 90: riskDesc = "extreme"
				elif totalRisk >= 60: riskDesc = "high"
				elif totalRisk >= 40: riskDesc = "medium"
				elif totalRisk >= 10: riskDesc = "low"
				# saving and describing
				var theDescription = "€"+str(totalCost)+",000 | "+str(usedOfficers)+" officers | " \
					+str(predictedLength)+" weeks | "+qualityDesc+" quality, "+riskDesc+" risk\n"
				for m in theMethods:
					theDescription += WorldData.Methods[m].Name+"\n"
				localPlans.append(
					{
						"OperationId": i,
						"Country": WorldData.Countries[WorldData.Targets[which].Country].Name,
						"Street": WorldData.Targets[which].LocationPrecise,
						"Officers": usedOfficers,
						"Cost": totalCost,
						"Length": predictedLength,
						"Risk": totalRisk,
						"Quality": totalQuality,
						"Methods": theMethods,
						"Description": theDescription,
					}
				)
				j += 1
			if len(localPlans) == 0:
				CallManager.CallQueue.append(
					{
						"Header": "Important Information",
						"Level": Operations[i].Level,
						"Operation": Operations[i].Name,
						"Content": "Officers tried to design a plan for abroad operation.\n" \
								 + "However, given current staff and budget, they could not\n" \
								 + "create any realistic plans.",
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
			else:
				var wholeContent = "Officers designed following abroad operation plans\n" \
					+ "to be executed in "+localPlans[0].Street+", "+localPlans[0].Country+".\n\n"
				var sh2 = true
				var sh3 = true
				if len(localPlans) == 1:
					wholeContent += "[b]Plan A[/b]\n" + localPlans[0].Description+"\n"
					sh2 = false
					sh3 = false
					localPlans.append(null)
					localPlans.append(null)
				elif len(localPlans) <= 2:
					wholeContent += "[b]Plan A[/b]\n" + localPlans[0].Description+"\n[b]Plan B[/b]\n" \
						+ localPlans[1].Description+"\n"
					sh3 = false
					localPlans.append(null)
				else:
					wholeContent += "[b]Plan A[/b]\n" + localPlans[0].Description+"\n[b]Plan B[/b]\n" \
						+ localPlans[1].Description+"\n[b]Plan C[/b]\n"+localPlans[2].Description+"\n"
				wholeContent += "\n\nChoose appropriate plan or wait for new plans."
				# setting the call for player
				CallManager.CallQueue.append(
					{
						"Header": "Urgent Decision",
						"Level": Operations[i].Level,
						"Operation": Operations[i].Name,
						"Content": wholeContent,
						"Show1": true,
						"Show2": sh2,
						"Show3": sh3,
						"Show4": true,
						"Text1": "Plan A",
						"Text2": "Plan B",
						"Text3": "Plan C",
						"Text4": "Return in the next week\nwith new plans",
						"Decision1Callback": funcref(GameLogic, "ImplementAbroad"),
						"Decision1Argument": localPlans[0],
						"Decision2Callback": funcref(GameLogic, "ImplementAbroad"),
						"Decision2Argument": localPlans[1],
						"Decision3Callback": funcref(GameLogic, "ImplementAbroad"),
						"Decision3Argument": localPlans[2],
						"Decision4Callback": funcref(GameLogic, "EmptyFunc"),
						"Decision4Argument": null,
					}
				)
			doesItEndWithCall = true
		i += 1
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
	Operations[thePlan.OperationId].AbroadRateOfProgress = 100.0/thePlan.Length
	# moving officers
	OfficersInHQ -= thePlan.Officers
	OfficersAbroad += thePlan.Officers
	# moving budget
	BudgetOngoingOperations += thePlan.Cost

func EmptyFunc(anyArgument):
	pass  # nothing happens
