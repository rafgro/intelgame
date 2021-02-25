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
			# tracing reasons for lack of any plan
			var noPlanReasonTradecraft = 0
			var noPlanReasonMinIntel = 0
			var noPlanReasonCost = 0
			var noPlanReasonStaff = 0
			# actual method planning
			var j = 0
			while j < 6:  # six tries but will present only first three
				j += 1  # in the beginning to allow early continue commands
				var totalCost = 0
				var predictedLength = 3+GameLogic.random.randi_range(-2,2)  # in weeks
				if GameLogic.Operations[i].Type == OperationGenerator.Type.RECRUIT_SOURCE:
					predictedLength *= 2
				var usedOfficers = minOfficers
				# finding methods to use in the operation
				var mt = GameLogic.Operations[i].Type
				var noOfMethods = GameLogic.random.randi_range(1, len(WorldData.Methods[mt]))
				var theMethods = []
				var safetyCounter = 0
				var countUnavailable = 0
				var countMinIntel = 0
				while len(theMethods) < noOfMethods and safetyCounter < noOfMethods*4:
					safetyCounter += 1
					var methodId = randi() % WorldData.Methods[mt].size()
					# avoid duplications
					if methodId in theMethods:
						continue
					# do not use unavailable methods
					if WorldData.Methods[mt][methodId].Available == false:
						countUnavailable += 1
						continue
					# do not use methods not applicable here
					if WorldData.Organizations[which].IntelValue < WorldData.Methods[mt][methodId].MinimalIntel:
						countMinIntel += 1
						continue
					theMethods.append(methodId)
					# adjust to methods
					if WorldData.Methods[mt][methodId].OfficersRequired > usedOfficers:
						usedOfficers = WorldData.Methods[mt][methodId].OfficersRequired
				# no methods
				if len(theMethods) == 0:
					if countUnavailable > noOfMethods*2:  # over half of failures
						noPlanReasonTradecraft += 1
					if countMinIntel > noOfMethods*2:  # over half of failures
						noPlanReasonMinIntel += 1
					continue
				# adjusting number of officers
				usedOfficers = GameLogic.random.randi_range(usedOfficers, maxOfficers)
				# calculating cost and checking if it's possible
				var singleOfficerCost = WorldData.Countries[WorldData.Organizations[which].Countries[0]].LocalCost \
					+ (WorldData.Countries[WorldData.Organizations[which].Countries[0]].TravelCost / predictedLength / 2)
				totalCost += singleOfficerCost * usedOfficers * predictedLength
				for m in theMethods:
					totalCost += WorldData.Methods[GameLogic.Operations[i].Type][m].Cost * predictedLength
				if totalCost > GameLogic.FreeFundsWeekly()*predictedLength:
					noPlanReasonCost += 1
					continue
				if usedOfficers > GameLogic.OfficersInHQ:
					noPlanReasonStaff += 1
					continue
				# calculating total operation parameters: clash of location and methods
				# quality
				var whichCountry = WorldData.Organizations[GameLogic.Operations[i].Target].Countries[0]
				var totalQuality = 0
				for m in theMethods:
					totalQuality += WorldData.Methods[GameLogic.Operations[i].Type][m].Quality
				totalQuality *= ((WorldData.Countries[whichCountry].IntelFriendliness)/100.0)
				totalQuality *= (0.5+(GameLogic.StaffSkill/100.0))
				totalQuality *= 0.8+(predictedLength*0.5*0.2)  # 2->4w = 1.0->1.2
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
				totalRisk *= 0.8+(predictedLength*0.5*0.2)  # 2->4w = 1.0->1.2
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
				if GameLogic.Operations[i].Type == OperationGenerator.Type.RECRUIT_SOURCE:
					theDescription += "approach and recruit selected asset\n"
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
			if len(localPlans) == 0:
				var noPlanReasonsArr = []
				if noPlanReasonMinIntel > 1: noPlanReasonsArr.append("intel about " + WorldData.Organizations[GameLogic.Operations[i].Target].Name)
				if noPlanReasonStaff > 1: noPlanReasonsArr.append("human resources")
				if noPlanReasonCost > 1: noPlanReasonsArr.append("financial resources")
				if noPlanReasonTradecraft > 1: noPlanReasonsArr.append("tradecraft skills")
				if len(noPlanReasonsArr) == 0: noPlanReasonsArr.append("resources")
				var noPlanReasons = ""
				if len(noPlanReasonsArr) > 1:
					noPlanReasons = PoolStringArray(noPlanReasonsArr.slice(0,len(noPlanReasonsArr)-1)).join(", ") + ", and " + noPlanReasonsArr[-1] + " to approach this target. "
				else:
					noPlanReasons = noPlanReasonsArr[0] + " to approach this target."
				CallManager.CallQueue.append(
					{
						"Header": "Important Information",
						"Level": GameLogic.Operations[i].Level,
						"Operation": GameLogic.Operations[i].Name + "\nagainst " + WorldData.Organizations[GameLogic.Operations[i].Target].Name,
						"Content": "Officers tried to design a plan for ground operation. " \
								 + "However, given current staff and budget, they could not " \
								 + "create any realistic plans. The bureau lacks " + noPlanReasons,
						"Show1": false,
						"Show2": false,
						"Show3": true,
						"Show4": true,
						"Text1": "",
						"Text2": "",
						"Text3": "Call off operation",
						"Text4": "Try again in the next week",
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
				var wholeContent = "Officers designed following ground operation plans " \
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
						"Operation": GameLogic.Operations[i].Name + "\nagainst " + WorldData.Organizations[GameLogic.Operations[i].Target].Name,
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
				# base p=20/100
				if whatHappened <= 30:
					GameLogic.AddEvent(GameLogic.Operations[i].Name + ": officers on the ground had to fled to homeland")
					# internal debriefing
					GameLogic.Operations[i].Stage = OperationGenerator.Stage.PLANNING_OPERATION
					GameLogic.OfficersInHQ += GameLogic.Operations[i].AbroadPlan.Officers
					GameLogic.OfficersAbroad -= GameLogic.Operations[i].AbroadPlan.Officers
					GameLogic.BudgetOngoingOperations -= GameLogic.Operations[i].AbroadPlan.Cost
					GameLogic.Operations[i].AbroadPlan = null
					GameLogic.Operations[i].Result = "ONGOING (PLANNING)"
					# world taking notice of our failure
					WorldData.Organizations[GameLogic.Operations[i].Target].Counterintelligence *= 1.02
					GameLogic.StaffTrust -= 5
					GameLogic.StaffExperience = GameLogic.StaffExperience*1.07
					WorldData.DiplomaticRelations[0][WorldData.Organizations[GameLogic.Operations[i].Target].Countries[0]] -= 2
					if (GameLogic.Countries[0].PoliticsIntel+GameLogic.random.randi_range(-15,15)) > 50:
						# changing only if government cares
						GameLogic.Trust -= 5
				# base p=80/100
				else:
					GameLogic.AddEvent(GameLogic.Operations[i].Name + ": counterintelligence slowed down ground operation")
					GameLogic.StaffSkill = GameLogic.StaffSkill*1.01
					GameLogic.StaffExperience = GameLogic.StaffExperience*1.02
			####################################################################
			# operation finish: MORE_INTEL type
			if GameLogic.Operations[i].AbroadProgress <= 0 and GameLogic.Operations[i].Type == OperationGenerator.Type.MORE_INTEL:
				# operation finishes with intel gathering
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
					content = "Operation was sucessfully executed. "
					content += "Intel gathered on " + WorldData.Organizations[GameLogic.Operations[i].Target].Name + ":\n" + WorldData.Organizations[GameLogic.Operations[i].Target].IntelDescription[0].substr(18)
					GameLogic.Operations[i].Result = "SUCCESS"
					if (GameLogic.Countries[0].PoliticsIntel+GameLogic.random.randi_range(-15,15)) > 50:
						# increasing after own operation only if government cares
						GameLogic.Trust += qualityDiff*2
				# debriefing government and effect on the user
				elif GameLogic.Operations[i].Source == 1:
					var govFeedback = 0  # from -100 to 100, usually -20 to 20
					var weekDiff = (0.0 + GameLogic.Operations[i].WeeksPassed - GameLogic.Operations[i].ExpectedWeeks) / GameLogic.Operations[i].ExpectedWeeks
					govFeedback += weekDiff * 20  # -2 for being 10% late
					govFeedback += qualityDiff * 10  # +1 for 10% better quality
					if govFeedback > 0: govFeedback *= GameLogic.Countries[0].PoliticsIntel*0.01
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
				doesItEndWithCall = true
				# internal debriefing
				GameLogic.StaffExperience += GameLogic.Operations[i].AbroadPlan.Officers
				GameLogic.StaffSkill += qualityDiff
				GameLogic.StaffTrust = GameLogic.StaffTrust*1.1
			####################################################################
			# operation finish: RECRUIT_SOURCE type
			elif GameLogic.Operations[i].AbroadProgress <= 0 and GameLogic.Operations[i].Type == OperationGenerator.Type.RECRUIT_SOURCE:
				# don't DRY here: later it will be evolved into a different, call-based code!
				# operation finishes with success or failure now
				var sourceLevel = WorldIntel.RecruitInOrg(
					GameLogic.Operations[i].Target,
					GameLogic.Operations[i].AbroadPlan.Quality,
					GameLogic.GiveDateWithYear()
				)  # where 0 means no source
				# debriefing variables
				GameLogic.Operations[i].Stage = OperationGenerator.Stage.FINISHED
				GameLogic.OfficersInHQ += GameLogic.Operations[i].AbroadPlan.Officers
				GameLogic.OfficersAbroad -= GameLogic.Operations[i].AbroadPlan.Officers
				GameLogic.BudgetOngoingOperations -= GameLogic.Operations[i].AbroadPlan.Cost
				GameLogic.PursuedOperations -= 1
				# debriefing user and results of the intel
				var difficulty = WorldData.Organizations[GameLogic.Operations[i].Target].Counterintelligence
				var content = ""
				if GameLogic.Operations[i].Source == 0:
					if sourceLevel == 0:
						content = "Operation failed. Officers gathered some intel on " + WorldData.Organizations[GameLogic.Operations[i].Target].Name + ", but they did not recruit a source in or near the organization.\n"
						GameLogic.Operations[i].Result = "FAILURE"
						GameLogic.StaffSkill += 2
						GameLogic.StaffTrust = GameLogic.StaffTrust*0.95
						if (GameLogic.Countries[0].PoliticsIntel+GameLogic.random.randi_range(-15,15)) > 50:
							# changing after own operation only if government cares
							GameLogic.Trust *= 0.98
					else:
						var wordLevel = "low"
						if sourceLevel > 70: wordLevel = "high"
						elif sourceLevel > 30: wordLevel = "medium"
						content = "Operation was successfully executed. A new, " +wordLevel+ "-level source in " + WorldData.Organizations[GameLogic.Operations[i].Target].Name + " will regularly provide new intel.\n"
						GameLogic.Operations[i].Result = "Success"
						GameLogic.StaffSkill += GameLogic.random.randi_range(3,6)
						GameLogic.StaffTrust = GameLogic.StaffTrust*(1.05+difficulty*0.0025)
						if (GameLogic.Countries[0].PoliticsIntel+GameLogic.random.randi_range(-15,15)) > 50:
							# increasing after own operation only if government cares
							GameLogic.Trust *= 1.0 + difficulty*0.0025
				# debriefing government and effect on the user
				elif GameLogic.Operations[i].Source == 1:
					var govFeedback = sourceLevel*(1.0+(difficulty*0.05))
					if sourceLevel == 0:
						govFeedback = GameLogic.random.randi_range(-40,-10)*(1.0-(difficulty*0.05))
					if govFeedback > 0: govFeedback *= GameLogic.Countries[0].PoliticsIntel*0.01
					govFeedback = int(govFeedback)
					GameLogic.Trust += govFeedback
					var govFeedbackDesc = "Officers failed at acquiring a new source in an organization indicated by the government. Bureau lost "+str((-1)*govFeedback)+"% of trust."
					GameLogic.Operations[i].Result = "COMPLETED, negative feedback"
					if govFeedback > 0:
						var budgetIncrease = GameLogic.BudgetFull*(0.01*govFeedback)
						GameLogic.BudgetFull += budgetIncrease
						govFeedbackDesc = "Officers acquired a new source in an organization indicated by the government. Bureau gained "+str(govFeedback)+"% of trust. As a confirmation, government increases bureau's budget by €"+str(int(budgetIncrease))+",000.\n"
						GameLogic.Operations[i].Result = "SUCCESS, positive feedback"
					content = "Operation has been finished. " + govFeedbackDesc
				# debriefing user
				if sourceLevel > 0:
					GameLogic.AddEvent(GameLogic.Operations[i].Name + ": bureau acquired a new source")
				GameLogic.AddEvent(GameLogic.Operations[i].Name + ": "+str(GameLogic.Operations[i].AbroadPlan.Officers)+" officer(s) returned to homeland")
				GameLogic.AddEvent("Bureau finished operation "+GameLogic.Operations[i].Name)
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
				doesItEndWithCall = true
				# internal debriefing
				GameLogic.StaffExperience += GameLogic.Operations[i].AbroadPlan.Officers
		i += 1
	return doesItEndWithCall
