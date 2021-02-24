extends Node

func ProgressOperations():
	var doesItEndWithCall = false
	var i = 0
	while i < len(GameLogic.Operations):
		GameLogic.Operations[i].WeeksPassed += 1
		###########################################################################
		if GameLogic.Operations[i].Stage == OperationGenerator.Stage.NOT_STARTED:
			# looking for free officers
			if GameLogic.OfficersInHQ > 0:
				#GameLogic.Operations[i].Stage = OperationGenerator.Stage.FINDING_LOCATION
				GameLogic.Operations[i].AnalyticalOfficers = GameLogic.OfficersInHQ
				GameLogic.Operations[i].Stage = OperationGenerator.Stage.PLANNING_OPERATION
				GameLogic.Operations[i].Started = GameLogic.GiveDateWithYear()
				GameLogic.Operations[i].Result = "ONGOING (PLANNING)"
		#  used elif on purpose here: at least one week break after starting
		###########################################################################
		elif GameLogic.Operations[i].Stage == OperationGenerator.Stage.PLANNING_OPERATION and GameLogic.OfficersInHQ > 0:
			# designing possible approaches, three plus waiting another week
			# differring by parameters: officers on the ground, cost of methods,
			# quality of operation, risk of failure
			var which = GameLogic.Operations[i].Target
			var minOfficers = 1
			var maxOfficers = GameLogic.OfficersInHQ
			var localPlans = []
			var j = 0
			while j < 6:  # six tries but will present only first three
				var totalCost = 0
				var predictedLength = 3  # in weeks, randomize later, should affect quality
				var usedOfficers = minOfficers
				# finding methods to use in the operation
				var noOfMethods = GameLogic.random.randi_range(1, len(WorldData.Methods[GameLogic.Operations[i].Type]))
				var theMethods = []
				var safetyCounter = 0
				while len(theMethods) < noOfMethods and safetyCounter < noOfMethods*4:
					safetyCounter += 1
					var methodId = randi() % WorldData.Methods[GameLogic.Operations[i].Type].size()
					if methodId in theMethods:
						continue  # avoid duplications
					if WorldData.Methods[GameLogic.Operations[i].Type][methodId].Available == false:
						continue
					theMethods.append(methodId)
					# adjust to methods
					if WorldData.Methods[GameLogic.Operations[i].Type][methodId].OfficersRequired > usedOfficers:
						usedOfficers = WorldData.Methods[GameLogic.Operations[i].Type][methodId].OfficersRequired
				# adjusting number of officers
				usedOfficers = GameLogic.random.randi_range(usedOfficers, maxOfficers)
				# calculating cost and checking if it's possible
				var singleOfficerCost = WorldData.Countries[WorldData.Organizations[which].Countries[0]].LocalCost \
					+ (WorldData.Countries[WorldData.Organizations[which].Countries[0]].TravelCost / predictedLength / 2)
				totalCost += singleOfficerCost * usedOfficers * predictedLength
				for m in theMethods:
					totalCost += WorldData.Methods[GameLogic.Operations[i].Type][m].Cost * predictedLength
				if totalCost > GameLogic.FreeFundsWeekly()*predictedLength:
					continue
				if usedOfficers > GameLogic.OfficersInHQ:
					continue
				# calculating total operation parameters: clash of location and methods
				# in the future also modify it by time
				# quality
				var whichCountry = WorldData.Organizations[GameLogic.Operations[i].Target].Countries[0]
				var totalQuality = 0
				for m in theMethods:
					totalQuality += WorldData.Methods[GameLogic.Operations[i].Type][m].Quality
				totalQuality *= ((WorldData.Countries[whichCountry].IntelFriendliness)/100.0)
				totalQuality *= (0.5+(GameLogic.StaffSkill/100.0))
				var qualityDesc = "poor"
				if totalQuality >= 90: qualityDesc = "great"
				elif totalQuality >= 60: qualityDesc = "good"
				elif totalQuality >= 40: qualityDesc = "medium"
				elif totalQuality >= 10: qualityDesc = "low"
				# risk
				var totalRisk = 0
				for m in theMethods:
					totalRisk += WorldData.Methods[GameLogic.Operations[i].Type][m].Risk
				#totalRisk += WorldData.Countries[whichCountry].Hostility/2
				totalRisk += (-1)*WorldData.DiplomaticRelations[0][whichCountry]/2
				totalRisk *= (WorldData.Organizations[which].Counterintelligence/100.0)
				totalRisk *= (120.0-GameLogic.StaffExperience)/100.0
				if GameLogic.StaffTrust < 50: totalRisk += (50.0-GameLogic.StaffTrust)/5.0
				elif GameLogic.StaffTrust > 50: totalRisk -= (GameLogic.StaffTrust-50.0)/20.0
				var riskDesc = "no"
				if totalRisk >= 90: riskDesc = "extreme"
				elif totalRisk >= 60: riskDesc = "high"
				elif totalRisk >= 40: riskDesc = "medium"
				elif totalRisk >= 10: riskDesc = "low"
				# saving and describing
				var theDescription = "€"+str(totalCost)+",000 | "+str(usedOfficers)+" officers | " \
					+str(predictedLength)+" weeks | "+qualityDesc+" quality, "+riskDesc+" risk\n"
				for m in theMethods:
					theDescription += WorldData.Methods[GameLogic.Operations[i].Type][m].Name+"\n"
				localPlans.append(
					{
						"OperationId": i,
						"Country": WorldData.Countries[WorldData.Organizations[which].Countries[0]].Name,
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
						"Level": GameLogic.Operations[i].Level,
						"Operation": GameLogic.Operations[i].Name,
						"Content": "Officers tried to design a plan for ground operation.\n" \
								 + "However, given current staff and budget, they could not\n" \
								 + "create any realistic plans.",
						"Show1": false,
						"Show2": false,
						"Show3": true,
						"Show4": true,
						"Text1": "",
						"Text2": "",
						"Text3": "Call off operation",
						"Text4": "Understood",
						"Decision1Callback": funcref(GameLogic, "EmptyFunc"),
						"Decision1Argument": null,
						"Decision2Callback": funcref(GameLogic, "EmptyFunc"),
						"Decision2Argument": null,
						"Decision3Callback": funcref(GameLogic, "ImplementCallOff"),
						"Decision3Argument": i,
						"Decision4Callback": funcref(GameLogic, "EmptyFunc"),
						"Decision4Argument": null,
					}
				)
			else:
				var wholeContent = "Officers designed following ground operation plans\n" \
					+ "to be executed in "+localPlans[0].Country+".\n\n"
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
				wholeContent += "Choose appropriate plan or wait for new plans."
				# setting the call for player
				CallManager.CallQueue.append(
					{
						"Header": "Urgent Decision",
						"Level": GameLogic.Operations[i].Level,
						"Operation": GameLogic.Operations[i].Name,
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
		###########################################################################
		elif GameLogic.Operations[i].Stage == OperationGenerator.Stage.ABROAD_OPERATION:
			# operation progressing or not
			if GameLogic.random.randi_range(0, 100) > GameLogic.Operations[i].AbroadPlan.Risk:
				GameLogic.Operations[i].AbroadProgress -= GameLogic.Operations[i].AbroadRateOfProgress
				if GameLogic.Operations[i].AbroadProgress > 0:  # check to avoid doubling events
					GameLogic.AddEvent(GameLogic.Operations[i].Name + ": ground operation continues")
			else:
				# many shades of _something went wrong_
				var whatHappened = GameLogic.random.randi_range(0, 100)
				# base p=10/100
				#if whatHappened <= 20:
				#	pass  # probably something like catching or killing an officer
				# base p=30/100
				if whatHappened <= 20+30:
					GameLogic.AddEvent(GameLogic.Operations[i].Name + ": officers on the ground were caught and fled to homeland")
					# internal debriefing
					GameLogic.Operations[i].Stage = OperationGenerator.Stage.PLANNING_OPERATION
					GameLogic.OfficersInHQ += GameLogic.Operations[i].AbroadPlan.Officers
					GameLogic.OfficersAbroad -= GameLogic.Operations[i].AbroadPlan.Officers
					GameLogic.BudgetOngoingOperations -= GameLogic.Operations[i].AbroadPlan.Cost
					GameLogic.Operations[i].AbroadPlan = null
					GameLogic.Operations[i].Result = "ONGOING (PLANNING)"
					# world taking notice of our failure
					WorldData.Organizations[GameLogic.Operations[i].Target].Counterintelligence *= 1.05
					GameLogic.StaffTrust -= 5
					GameLogic.StaffExperience = GameLogic.StaffExperience*1.07
					GameLogic.Trust -=5
					WorldData.DiplomaticRelations[0][WorldData.Organizations[GameLogic.Operations[i].Target].Countries[0]] -= 5
				# base p=60/100
				else:
					GameLogic.AddEvent(GameLogic.Operations[i].Name + ": counterintelligence slowed down ground operation")
					GameLogic.StaffSkill = GameLogic.StaffSkill*1.01
					GameLogic.StaffExperience = GameLogic.StaffExperience*1.02
			# operation finish
			if GameLogic.Operations[i].AbroadProgress <= 0:
				# operation finished
				if GameLogic.Operations[i].Type == OperationGenerator.Type.MORE_INTEL:
					WorldIntel.GatherOnOrg(
						GameLogic.Operations[i].Target,
						GameLogic.Operations[i].AbroadPlan.Quality,
						GameLogic.GiveDateWithYear()
					)
				# debriefing variables
				GameLogic.Operations[i].Stage = OperationGenerator.Stage.FINISHED
				GameLogic.OfficersInHQ += GameLogic.Operations[i].AbroadPlan.Officers
				GameLogic.OfficersAbroad -= GameLogic.Operations[i].AbroadPlan.Officers
				GameLogic.BudgetOngoingOperations -= GameLogic.Operations[i].AbroadPlan.Cost
				GameLogic.PursuedOperations -= 1
				# quality as the main outcome
				var qualityDiff = (0.0 + GameLogic.Operations[i].AbroadPlan.Quality - GameLogic.Operations[i].ExpectedQuality) / GameLogic.Operations[i].ExpectedQuality
				if qualityDiff > 2.0: qualityDiff = 2.0
				var content = ""
				# debriefing user and results of the intel
				if GameLogic.Operations[i].Source == 0:
					content = "Operation was sucessfully finished.\n"
					content += "Intel gathered on " + WorldData.Organizations[GameLogic.Operations[i].Target].Name + ":\n" + WorldData.Organizations[GameLogic.Operations[i].Target].IntelDescription[0].substr(18)
					GameLogic.Operations[i].Result = "SUCCESS"
				# debriefing government and effect on the user
				elif GameLogic.Operations[i].Source == 1:
					var govFeedback = 0  # from -100 to 100, usually -20 to 20
					var weekDiff = (0.0 + GameLogic.Operations[i].WeeksPassed - GameLogic.Operations[i].ExpectedWeeks) / GameLogic.Operations[i].ExpectedWeeks
					govFeedback += weekDiff * 20  # -2 for being 10% late
					govFeedback += qualityDiff * 10  # +1 for 10% better quality
					if govFeedback > 0: govFeedback *= 0.5  # positive trust more difficult to gather
					govFeedback = int(govFeedback)
					GameLogic.Trust += govFeedback
					var govFeedbackDesc = "negatively rated its execution.\nThe bureau lost "+str((-1)*govFeedback)+"% of trust."
					GameLogic.Operations[i].Result = "COMPLETED, negative feedback"
					if govFeedback > 0:
						var budgetIncrease = GameLogic.BudgetFull*(0.01*govFeedback)
						GameLogic.BudgetFull += budgetIncrease
						govFeedbackDesc = "positively rated its execution.\nThe bureau gained "+str(govFeedback)+"% of trust. As a confirmation,\ngovernment increased bureau's budget by €"+str(int(budgetIncrease))+",000.\n"
						GameLogic.Operations[i].Result = "SUCCESS, positive feedback"
					content = "Operation was sucessfully finished.\nGovernment " + govFeedbackDesc
				# debriefing user
				GameLogic.AddEvent(GameLogic.Operations[i].Name + ": "+str(GameLogic.Operations[i].AbroadPlan.Officers)+" officer(s) returned to homeland")
				GameLogic.AddEvent("Bureau finished operation "+GameLogic.Operations[i].Name)
				CallManager.CallQueue.append(
					{
						"Header": "Important Information",
						"Level": GameLogic.Operations[i].Level,
						"Operation": GameLogic.Operations[i].Name,
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
				# internal debriefing
				GameLogic.StaffExperience += GameLogic.Operations[i].AbroadPlan.Officers
				GameLogic.StaffSkill += qualityDiff
				GameLogic.StaffTrust = GameLogic.StaffTrust*1.1
		i += 1
	return doesItEndWithCall
