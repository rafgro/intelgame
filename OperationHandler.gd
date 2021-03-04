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
			var whichCountry = GameLogic.Operations[i].Country
			var minOfficers = 1
			var maxOfficers = GameLogic.OfficersInHQ
			var localPlans = []
			# tracing reasons for lack of any plan
			var noPlanReasonTradecraft = 0
			var noPlanReasonMinIntel = 0
			var noPlanReasonCost = 0
			var noPlanReasonStaff = 0
			var noPlanReasonLocal = 0
			var noPlanReasonTravel = 0
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
				var noOfMethods = GameLogic.random.randi_range(1,4)
				if GameLogic.random.randi_range(1,4) == 3: noOfMethods = GameLogic.random.randi_range(1,8)
				var theMethods = []
				var safetyCounter = 0
				var countUnavailable = 0
				var countMinIntel = 0
				var countMinLocal = 0
				if GameLogic.Operations[i].Type == OperationGenerator.Type.OFFENSIVE:
					# picking only one method at a time
					while safetyCounter < 10:
						safetyCounter += 1
						var methodId = randi() % WorldData.Methods[mt].size()
						# do not use unavailable methods
						if WorldData.Methods[mt][methodId].Available == false:
							countUnavailable += 1
							continue
						# do not use locally unavaialbe
						if WorldData.Methods[mt][methodId].MinimalLocal < ((WorldData.Countries[whichCountry].KnowhowLanguage + WorldData.Countries[whichCountry].KnowhowCustoms)*0.5):
							countMinLocal += 1
							continue
						# do not use methods not applicable here
						if WorldData.Organizations[which].IntelValue < WorldData.Methods[mt][methodId].MinimalIntel:
							countMinIntel += 1
							continue
						theMethods.append(methodId)
						# adjust to methods
						if WorldData.Methods[mt][methodId].OfficersRequired > usedOfficers:
							usedOfficers = WorldData.Methods[mt][methodId].OfficersRequired
						# take length from the method
						predictedLength = GameLogic.random.randi_range(WorldData.Methods[mt][methodId].MinLength, WorldData.Methods[mt][methodId].MaxLength)
						break
				else:
					# matching many methods
					while len(theMethods) < noOfMethods and safetyCounter < noOfMethods*10:
						safetyCounter += 1
						var methodId = randi() % WorldData.Methods[mt].size()
						# avoid duplications
						if methodId in theMethods:
							continue
						# do not use unavailable methods
						if WorldData.Methods[mt][methodId].Available == false:
							countUnavailable += 1
							continue
						# do not use locally unavaialbe
						if WorldData.Methods[mt][methodId].MinimalLocal > ((WorldData.Countries[whichCountry].KnowhowLanguage + WorldData.Countries[whichCountry].KnowhowCustoms)*0.5):
							countMinLocal += 1
							continue
						# do not use methods not applicable here
						if WorldData.Organizations[which].IntelValue < WorldData.Methods[mt][methodId].MinimalIntel:
							countMinIntel += 1
							continue
						theMethods.append(methodId)
						# adjust to methods
						if WorldData.Methods[mt][methodId].OfficersRequired > usedOfficers:
							usedOfficers = WorldData.Methods[mt][methodId].OfficersRequired
				# intel agencies and universities are currently off limits
				if GameLogic.Operations[i].Type == OperationGenerator.Type.OFFENSIVE:
					if WorldData.Organizations[which].Type == WorldData.OrgType.INTEL or WorldData.Organizations[which].Type == WorldData.OrgType.UNIVERSITY:
						theMethods.clear()
						noPlanReasonTradecraft = 10
				# no methods
				if len(theMethods) == 0:
					if countUnavailable > noOfMethods*2:  # over half of failures
						noPlanReasonTradecraft += 1
					if countMinIntel > noOfMethods*2:  # over half of failures
						noPlanReasonMinIntel += 1
					if countMinLocal > noOfMethods*2:  # over half of failures
						noPlanReasonLocal += 1
					continue
				# adjusting number of officers
				var proxyMaxOfficers = maxOfficers
				if (proxyMaxOfficers-usedOfficers) > 5:
					proxyMaxOfficers = usedOfficers + GameLogic.random.randi_range(1,5)
				usedOfficers = GameLogic.random.randi_range(usedOfficers, proxyMaxOfficers)
				# remote/nonremote
				var ifAllRemote = true
				for m in theMethods:
					if WorldData.Methods[GameLogic.Operations[i].Type][m].Remote == false:
						ifAllRemote = false
						break
				# calculating cost and checking if it's possible
				var ifDiplomaticTravel = WorldData.Countries[whichCountry].DiplomaticTravel
				if ifAllRemote == false:
					var singleOfficerCost = WorldData.Countries[GameLogic.Operations[i].Country].LocalCost + (WorldData.Countries[GameLogic.Operations[i].Country].TravelCost / predictedLength / 2)
					totalCost += singleOfficerCost * usedOfficers * predictedLength
					for m in theMethods:
						totalCost += WorldData.Methods[GameLogic.Operations[i].Type][m].Cost * predictedLength
					if totalCost > GameLogic.FreeFundsWeekly()*predictedLength:
						noPlanReasonCost += 1
						continue
					var expelled = WorldData.Countries[GameLogic.Operations[i].Country].Expelled
					if usedOfficers > (GameLogic.OfficersInHQ-expelled):
						noPlanReasonStaff += 1
						continue
					if WorldData.Countries[whichCountry].DiplomaticTravel == false and WorldData.Countries[whichCountry].CovertTravel < 5:
						noPlanReasonTravel += 1
						continue
					# means of travelling
					else:
						if WorldData.Countries[whichCountry].DiplomaticTravel == true and WorldData.Countries[whichCountry].CovertTravel >= 5:
							if GameLogic.random.randi_range(1,2) == 1:
								ifDiplomaticTravel = false
				else:
					var singleOfficerCost = 0
					totalCost += singleOfficerCost * usedOfficers * predictedLength
					for m in theMethods:
						totalCost += WorldData.Methods[GameLogic.Operations[i].Type][m].Cost * predictedLength
					if totalCost > GameLogic.FreeFundsWeekly()*predictedLength:
						noPlanReasonCost += 1
						continue
				# calculating total operation parameters: clash of location and methods
				# quality, slightly balanced
				var totalQuality = 0
				var methodQuality = 0
				var highestQuality = 0
				for m in theMethods:
					methodQuality += WorldData.Methods[GameLogic.Operations[i].Type][m].Quality
					if highestQuality < WorldData.Methods[GameLogic.Operations[i].Type][m].Quality:
						highestQuality = WorldData.Methods[GameLogic.Operations[i].Type][m].Quality
				methodQuality -= highestQuality
				# this one is clever: average of highest quality method and all other
				totalQuality += (highestQuality+(methodQuality*1.0/len(theMethods)))*0.8
				totalQuality *= 0.5+(1.0-WorldData.Organizations[which].Counterintelligence*0.01)
				var staffPercent = WorldData.Organizations[which].IntelIdentified*1.0 / WorldData.Organizations[which].Staff
				totalQuality += staffPercent * 30
				if ifDiplomaticTravel == false and ifAllRemote == false:
					totalQuality *= (1.0 + 0.002 * WorldData.Countries[whichCountry].CovertTravel)
				totalQuality = totalQuality*1.0/len(WorldData.Organizations[which].Countries)
				var officerFactor = 1.0 + usedOfficers*0.1
				if officerFactor > 2.1: officerFactor = 2.1
				totalQuality *= officerFactor
				var lengthFactor = 1.0 + predictedLength*0.1
				if lengthFactor > 1.8: lengthFactor = 1.8
				totalQuality *= lengthFactor
				var qualityDesc = "poor"
				if totalQuality >= 75: qualityDesc = "great"
				elif totalQuality >= 55: qualityDesc = "good"
				elif totalQuality >= 25: qualityDesc = "medium"
				elif totalQuality >= 10: qualityDesc = "low"
				# risk, slightly balanced
				var totalRisk = 0
				var methodRisk = 0
				var highestRisk = -1
				var highestRiskName = ""  # for eventual investigation into failures
				for m in theMethods:
					methodRisk += WorldData.Methods[GameLogic.Operations[i].Type][m].Risk
					if highestRisk < WorldData.Methods[GameLogic.Operations[i].Type][m].Risk:
						highestRisk = WorldData.Methods[GameLogic.Operations[i].Type][m].Risk
						highestRiskName = WorldData.Methods[GameLogic.Operations[i].Type][m].Name
				methodRisk -= highestRisk
				# this one is clever: average of highest risk method and all other
				totalRisk += (highestRisk+(methodRisk*1.0/len(theMethods)))*0.7
				totalRisk *= 0.2+WorldData.Organizations[which].Counterintelligence*0.02
				totalRisk -= WorldData.Organizations[GameLogic.Operations[i].Target].IntelValue*0.5
				totalRisk *= 0.5+(100.0-WorldData.Countries[whichCountry].IntelFriendliness)*0.01
				totalRisk -= GameLogic.StaffExperience*0.1
				var potentialHostiliy = (-1.0)*WorldData.DiplomaticRelations[0][whichCountry]*0.03
				if potentialHostiliy < 0: potentialHostiliy = 0
				totalRisk *= 1.0 + (potentialHostiliy*0.5)
				if WorldData.Countries[whichCountry].InStateOfWar == true: totalRisk += 30
				if ifDiplomaticTravel == false and ifAllRemote == false:
					if WorldData.Countries[whichCountry].InStateOfWar == false: totalRisk += 10
					if WorldData.Countries[whichCountry].CovertTravel < 20:
						totalRisk += 0.6 * (100-WorldData.Countries[whichCountry].CovertTravel + WorldData.Countries[whichCountry].CovertTravelBlowup)
					elif WorldData.Countries[whichCountry].CovertTravel < 40:
						totalRisk += 0.4 * (100-WorldData.Countries[whichCountry].CovertTravel + WorldData.Countries[whichCountry].CovertTravelBlowup)
					elif WorldData.Countries[whichCountry].CovertTravel < 70:
						totalRisk += 0.2 * (100-WorldData.Countries[whichCountry].CovertTravel + WorldData.Countries[whichCountry].CovertTravelBlowup)
				if totalRisk < 2: totalRisk = 2
				var riskVsTime = totalRisk * predictedLength
				var riskDesc = "no"
				if riskVsTime >= 100: riskDesc = "extreme"
				elif riskVsTime >= 70: riskDesc = "high"
				elif riskVsTime >= 40: riskDesc = "medium"
				elif riskVsTime >= 10: riskDesc = "low"
				# saving and describing
				var ifCovertTravel = false
				if ifDiplomaticTravel == false: ifCovertTravel = true
				var theDescription = "€"+str(totalCost)+",000 | "+str(usedOfficers)+" officers | " \
					+str(predictedLength)+" weeks | "+qualityDesc+" quality, "+riskDesc+" risk\n"
				if ifAllRemote == true: theDescription += "no travel\n"
				elif ifCovertTravel == true: theDescription += "covert travel\n"
				else: theDescription += "travel to embassy\n"
				for m in theMethods:
					theDescription += WorldData.Methods[GameLogic.Operations[i].Type][m].Name+"\n"
				if GameLogic.Operations[i].Type == OperationGenerator.Type.RECRUIT_SOURCE:
					theDescription += "approach and recruit selected asset\n"
				localPlans.append(
					{
						"OperationId": i,
						"Country": WorldData.Countries[GameLogic.Operations[i].Country].Name,
						"Officers": usedOfficers,
						"Cost": totalCost,
						"Length": predictedLength,
						"Risk": totalRisk,
						"Quality": totalQuality,
						"Methods": theMethods,
						"HighestRiskVal": highestRisk,
						"HighestRiskName": highestRiskName,
						"Description": theDescription,
						"Covert": ifCovertTravel,
						"Remote": ifAllRemote,
					}
				)
			if len(localPlans) == 0:
				var noPlanReasonsArr = []
				if noPlanReasonLocal > 1: noPlanReasonsArr.append("knowledge of local language and customs in " + WorldData.Countries[whichCountry].Name)
				if noPlanReasonLocal > 1: noPlanReasonsArr.append("acceptable means of travel to " + WorldData.Countries[whichCountry].Name)
				if noPlanReasonMinIntel > 1: noPlanReasonsArr.append("intel about " + WorldData.Organizations[GameLogic.Operations[i].Target].Name)
				if noPlanReasonStaff > 1: noPlanReasonsArr.append("human resources")
				if noPlanReasonCost > 1: noPlanReasonsArr.append("financial resources")
				if noPlanReasonTradecraft > 1: noPlanReasonsArr.append("tradecraft skills")
				if len(noPlanReasonsArr) == 0: noPlanReasonsArr.append("resources")
				var noPlanReasons = ""
				if len(noPlanReasonsArr) > 1:
					noPlanReasons = PoolStringArray(noPlanReasonsArr.slice(0,len(noPlanReasonsArr)-2)).join(", ") + ", and " + noPlanReasonsArr[-1] + " to approach this target. "
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
				var ifHostile = ""
				if WorldData.DiplomaticRelations[0][GameLogic.Operations[i].Country] < -30:
					ifHostile =" (hostile to Homeland, which contributes to the risk)"
				var ifNoknowhow = ""
				if noPlanReasonLocal > 1:
					ifNoknowhow = " Note that planning was constrained by unfamiliarity with local language and customs."
				var wholeContent = "Officers designed following ground operation plans " \
					+ "to be executed in "+localPlans[0].Country+ifHostile+"."+ifNoknowhow+"\n\n"
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
			if GameLogic.random.randi_range(0, 105) > GameLogic.Operations[i].AbroadPlan.Risk or GameLogic.Operations[i].AbroadPlan.Remote == true:
				GameLogic.Operations[i].AbroadProgress -= GameLogic.Operations[i].AbroadRateOfProgress
				if GameLogic.Operations[i].AbroadProgress > 0:  # check to avoid doubling events
					GameLogic.AddEvent(WorldData.Countries[GameLogic.Operations[i].Country].Name + " (" + GameLogic.Operations[i].Name + "): operation continues")
			# second chance with help of a network
			elif (WorldData.Countries[GameLogic.Operations[i].Country].Network - WorldData.Countries[GameLogic.Operations[i].Country].NetworkBlowup) > 0 and GameLogic.random.randi_range(0,GameLogic.Operations[i].AbroadPlan.Risk*2) < (WorldData.Countries[GameLogic.Operations[i].Country].Network - WorldData.Countries[GameLogic.Operations[i].Country].NetworkBlowup):
				GameLogic.Operations[i].AbroadProgress -= GameLogic.Operations[i].AbroadRateOfProgress
				if GameLogic.Operations[i].AbroadProgress > 0:  # check to avoid doubling events
					GameLogic.AddEvent(WorldData.Countries[GameLogic.Operations[i].Country].Name + " (" + GameLogic.Operations[i].Name + "): operation continues with support of local agent network")
			else:
				var which = GameLogic.Operations[i].Target
				# many shades of _something went wrong_
				var whatHappened = GameLogic.random.randi_range(0, 100)
				# first week - travel problems
				if GameLogic.Operations[i].AbroadProgress == GameLogic.Operations[i].AbroadPlan.Length and GameLogic.Operations[i].AbroadPlan.Covert == true and whatHappened < WorldData.Countries[GameLogic.Operations[i].Country].CovertTravel:
					GameLogic.AddEvent(WorldData.Countries[GameLogic.Operations[i].Country].Name + " (" + GameLogic.Operations[i].Name + "): covert travel did not succeed, officers were turned back at the border")
					# internal debriefing
					GameLogic.Operations[i].Stage = OperationGenerator.Stage.PLANNING_OPERATION
					GameLogic.OfficersInHQ += GameLogic.Operations[i].AbroadPlan.Officers
					GameLogic.OfficersAbroad -= GameLogic.Operations[i].AbroadPlan.Officers
					GameLogic.BudgetOngoingOperations -= GameLogic.Operations[i].AbroadPlan.Cost
					GameLogic.Operations[i].AbroadPlan = null
					GameLogic.Operations[i].Result = "ONGOING (PLANNING)"
					# world taking notice of our failure
					GameLogic.StaffTrust -= 5
					GameLogic.StaffExperience += 1
					WorldData.Countries[GameLogic.Operations[i].Country].CovertTravel -= 3
					if WorldData.Countries[GameLogic.Operations[i].Country].CovertTravel < 0:
						WorldData.Countries[GameLogic.Operations[i].Country].CovertTravel = 0
					if (WorldData.Countries[0].PoliticsIntel+GameLogic.random.randi_range(-15,15)) > 50:
						# changing only if government cares
						GameLogic.Trust -= 1
				# base p=10/100: arrest or shooting
				elif whatHappened <= 10:
					# prepare reasons for postmortem investigation, common for all failures
					var contentReasons = []
					contentReasons.append("- overall risk level of " + str(int(GameLogic.Operations[i].AbroadPlan.Risk)) + "%")
					if GameLogic.Operations[i].AbroadPlan.HighestRiskVal > 15:
						contentReasons.append("- use of a risky method (" + GameLogic.Operations[i].AbroadPlan.HighestRiskName + ")")
					elif GameLogic.Operations[i].AbroadPlan.HighestRiskVal > 30:
						contentReasons.append("- use of a high risk method (" + GameLogic.Operations[i].AbroadPlan.HighestRiskName + ")")
					elif GameLogic.Operations[i].AbroadPlan.HighestRiskVal > 45:
						contentReasons.append("- use of an extremely high risk method (" + GameLogic.Operations[i].AbroadPlan.HighestRiskName + ")")
					if (GameLogic.Operations[i].AbroadPlan.Length * GameLogic.Operations[i].AbroadPlan.Risk) > 70 and GameLogic.Operations[i].AbroadPlan.Length > 3:
						contentReasons.append("- long period of time abroad (" + str(GameLogic.Operations[i].AbroadPlan.Length) + " weeks)")
					if GameLogic.StaffExperience < 20:
						contentReasons.append("- low experience of officers")
					elif GameLogic.StaffExperience < 40:
						contentReasons.append("- not enough experience of officers")
					if WorldData.Organizations[which].Counterintelligence > 70:
						contentReasons.append("- significant counterintelligence efforts by " + WorldData.Organizations[which].Name)
					elif WorldData.Organizations[which].Counterintelligence > 30:
						contentReasons.append("- underestimating counterintelligence protection of " + WorldData.Organizations[which].Name)
					if WorldData.Organizations[which].IntelValue < 5:
						contentReasons.append("- almost no intel gathered on " + WorldData.Organizations[which].Name)
					elif WorldData.Organizations[which].IntelValue < 30:
						contentReasons.append("- not enough intel gathered on " + WorldData.Organizations[which].Name)
					if WorldData.Countries[GameLogic.Operations[i].Country].NetworkBlowup > 0:
						contentReasons.append("- compromised agents in local network (they were identified and removed)")
						WorldData.Countries[GameLogic.Operations[i].Country].NetworkBlowup = 0
					if WorldData.Countries[GameLogic.Operations[i].Country].IntelFriendliness < 30:
						contentReasons.append("- difficult theater of operation (" + WorldData.Countries[GameLogic.Operations[i].Country].Name + ")")
					if WorldData.DiplomaticRelations[0][GameLogic.Operations[i].Country] < -30:
						contentReasons.append("- hostile relations between Homeland and " + WorldData.Countries[GameLogic.Operations[i].Country].Name)
					if GameLogic.Operations[i].AbroadPlan.Covert == true:
						if WorldData.Countries[GameLogic.Operations[i].Country].CovertTravel < 20:
							contentReasons.append("- poor ability to travel and execute operations under cover in " + WorldData.Countries[GameLogic.Operations[i].Country].Name)
						elif WorldData.Countries[GameLogic.Operations[i].Country].CovertTravel < 40:
							contentReasons.append("- low ability to travel and execute operations under cover in " + WorldData.Countries[GameLogic.Operations[i].Country].Name)
						if WorldData.Countries[GameLogic.Operations[i].Country].CovertTravelBlowup > 0:
							contentReasons.append("- compromised means of covert actions in " + WorldData.Countries[GameLogic.Operations[i].Country].Name)
					# kill if cannot arrest and aggression*risk permits
					if WorldData.Countries[GameLogic.Operations[i].Country].InStateOfWar == true or (WorldData.Organizations[which].Type != WorldData.OrgType.GOVERNMENT and WorldData.Organizations[which].Type != WorldData.OrgType.INTEL and (WorldData.Organizations[which].Aggression > GameLogic.random.randi_range(50,70)) and (GameLogic.Operations[i].AbroadPlan.Risk > GameLogic.random.randi_range(75,95))):
						# debriefing variables
						var staffPerecent = GameLogic.ActiveOfficers * 1.0 / GameLogic.Operations[i].AbroadPlan.Officers
						GameLogic.PursuedOperations -= 1
						GameLogic.Operations[i].Stage = OperationGenerator.Stage.FAILED
						GameLogic.Operations[i].Result = "FAILED, " + str(GameLogic.Operations[i].AbroadPlan.Officers) + " officers lost"
						GameLogic.ActiveOfficers -= GameLogic.Operations[i].AbroadPlan.Officers
						GameLogic.OfficersAbroad -= GameLogic.Operations[i].AbroadPlan.Officers
						GameLogic.BudgetOngoingOperations -= GameLogic.Operations[i].AbroadPlan.Cost
						GameLogic.StaffTrust *= 0.2
						GameLogic.StaffSkill -= GameLogic.StaffSkill*staffPerecent
						GameLogic.StaffExperience -= GameLogic.StaffExperience*staffPerecent
						GameLogic.Trust *= (100-GameLogic.PriorityPublic)*0.01
						# diplomatic event
						var ifDipl = ""
						if (WorldData.Organizations[which].Type == WorldData.OrgType.GOVERNMENT or WorldData.Organizations[which].Type == WorldData.OrgType.INTEL or WorldData.Organizations[which].Type == WorldData.OrgType.UNIVERSITY or WorldData.Organizations[which].Type == WorldData.OrgType.UNIVERSITY_OFFENSIVE) and WorldData.Countries[GameLogic.Operations[i].Country].InStateOfWar == false:
							ifDipl = " In addition, diplomatic relations between Homeland and " + WorldData.Countries[GameLogic.Operations[i].Country].Name + " suffered due to evident attack on a national asset."
							WorldData.DiplomaticRelations[0][GameLogic.Operations[i].Country] -= GameLogic.random.randi_range(10,30)
							WorldData.DiplomaticRelations[GameLogic.Operations[i].Country][0] -= GameLogic.random.randi_range(10,30)
						# user briefing
						GameLogic.Investigations.append(
							{
								"Type": 100,
								"FinishCounter": GameLogic.random.randi_range(3,6),
								"Organization": which,
								"Operation": i,
								"Success": null,
								"Content": "Death of " + str(GameLogic.Operations[i].AbroadPlan.Officers) + " Officers in Operation " + str(GameLogic.Operations[i].Name) + "\n\nInvestigation team concluded that the operation failed due to:\n\n" + PoolStringArray(contentReasons).join("\n"),
							}
						)
						GameLogic.AddEvent(GameLogic.Operations[i].Name + " (" + WorldData.Countries[GameLogic.Operations[i].Country].Name + "): " + str(GameLogic.Operations[i].AbroadPlan.Officers) + " officers were caught and killed")
						CallManager.CallQueue.append(
							{
								"Header": "Important Information",
								"Level": GameLogic.Operations[i].Level,
								"Operation": GameLogic.Operations[i].Name + "\nagainst " + WorldData.Organizations[GameLogic.Operations[i].Target].Name,
								"Content": str(GameLogic.Operations[i].AbroadPlan.Officers) + " officers executing the operation were fatally wounded. Bureau lost expertise, experience, and huge part of homeland government's trust." + ifDipl + "\n\nBureau launched internal investigation in the causes of failure. Its results will be present in a few weeks.",
								"Show1": false,
								"Show2": false,
								"Show3": false,
								"Show4": true,
								"Text1": "",
								"Text2": "",
								"Text3": "",
								"Text4": "Rest In Peace",
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
						# also, if this was gov op, then we loose trust in hard negative, not only fraction
						if GameLogic.Operations[i].Source == 1:
							GameLogic.Trust -= GameLogic.random.randi_range(5,15)
					# otherwise, arrest
					else:
						# prepare investigation early, because it's about op, not rescue
						GameLogic.Investigations.append(
							{
								"Type": 100,
								"FinishCounter": GameLogic.random.randi_range(3,6),
								"Organization": which,
								"Operation": i,
								"Success": null,
								"Content": "Arrest of " + str(GameLogic.Operations[i].AbroadPlan.Officers) + " Officers in Operation " + str(GameLogic.Operations[i].Name) + "\n\nInvestigation team concluded that the operation failed due to:\n\n" + PoolStringArray(contentReasons).join("\n"),
							}
						)
						# asking user for action
						var ifExfiltrationAvailable = false
						if GameLogic.OfficersInHQ > 0: ifExfiltrationAvailable = true
						CallManager.CallQueue.append(
							{
								"Header": "Urgent Decision",
								"Level": GameLogic.Operations[i].Level,
								"Operation": GameLogic.Operations[i].Name + "\nagainst " + WorldData.Organizations[GameLogic.Operations[i].Target].Name,
								"Content": str(GameLogic.Operations[i].AbroadPlan.Officers) + " officers executing the action were arrested by " + WorldData.Countries[GameLogic.Operations[i].Country].Adjective + " authorities. Decide on appropriate reaction.\n\nPossibilities:\n- engaging government will return officers, but significantly decrease government's trust\n- expelling will happen between intelligence services only, but these officers will never be allowed to enter this country again\n- denying affiliation will result in officer imprisonment and their de facto loss, affecting internal trust, but not affecting any external institutions\n- exfiltration is a risky, covert rescue operation performed by the rest of the officers (" +str(GameLogic.OfficersInHQ) + " available) and eventual agent network (" +str(WorldData.Countries[GameLogic.Operations[i].Country].Network) + " available), which returns officers intact in case of success but leads to both huge trust loss and expulsion in case of failure",
								"Show1": true,
								"Show2": true,
								"Show3": true,
								"Show4": ifExfiltrationAvailable,
								"Text1": "Engage government",
								"Text2": "Push for expelling",
								"Text3": "Deny affiliation",
								"Text4": "Attempt exfiltration",
								"Decision1Callback": funcref(GameLogic, "ImplementOfficerRescue"),
								"Decision1Argument": {"Operation":i, "Choice":1},
								"Decision2Callback": funcref(GameLogic, "ImplementOfficerRescue"),
								"Decision2Argument": {"Operation":i, "Choice":2},
								"Decision3Callback": funcref(GameLogic, "ImplementOfficerRescue"),
								"Decision3Argument": {"Operation":i, "Choice":3},
								"Decision4Callback": funcref(GameLogic, "ImplementOfficerRescue"),
								"Decision4Argument": {"Operation":i, "Choice":4},
							}
						)
						doesItEndWithCall = true
						# also, if this was gov op, then we loose trust
						if GameLogic.Operations[i].Source == 1:
							GameLogic.Trust -= GameLogic.random.randi_range(1,10)
				# base p=25/100: escape
				elif whatHappened <= 35:
					GameLogic.AddEvent(WorldData.Countries[GameLogic.Operations[i].Country].Name + " (" + GameLogic.Operations[i].Name + "): officers were almost caught and had to flee to Homeland")
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
					WorldData.DiplomaticRelations[0][GameLogic.Operations[i].Country] -= 2
					if (WorldData.Countries[0].PoliticsIntel+GameLogic.random.randi_range(-15,15)) > 50:
						# changing only if government cares
						GameLogic.Trust -= GameLogic.PriorityPublic*0.05
				# base p=65/100: slowdown
				else:
					GameLogic.AddEvent(WorldData.Countries[GameLogic.Operations[i].Country].Name + " (" + GameLogic.Operations[i].Name + "): counterintelligence slowed down operation")
					GameLogic.StaffSkill = GameLogic.StaffSkill*1.01
					GameLogic.StaffExperience = GameLogic.StaffExperience*1.02
			####################################################################
			# operation finish: MORE_INTEL type
			if GameLogic.Operations[i].AbroadProgress <= 0 and GameLogic.Operations[i].Type == OperationGenerator.Type.MORE_INTEL:
				# operation finishes with intel gathering
				var localCall = WorldIntel.GatherOnOrg(
					GameLogic.Operations[i].Target,
					GameLogic.Operations[i].AbroadPlan.Quality,
					GameLogic.GiveDateWithYear(),
					false
				)
				if localCall == true: doesItEndWithCall = true
				# debriefing variables
				GameLogic.Operations[i].Stage = OperationGenerator.Stage.FINISHED
				GameLogic.OfficersInHQ += GameLogic.Operations[i].AbroadPlan.Officers
				GameLogic.OfficersAbroad -= GameLogic.Operations[i].AbroadPlan.Officers
				GameLogic.BudgetOngoingOperations -= GameLogic.Operations[i].AbroadPlan.Cost
				GameLogic.PursuedOperations -= 1
				WorldData.Countries[GameLogic.Operations[i].Country].KnowhowLanguage *= 1.01
				WorldData.Countries[GameLogic.Operations[i].Country].KnowhowCustoms += 2
				if WorldData.Countries[GameLogic.Operations[i].Country].KnowhowCustoms > 85:
					WorldData.Countries[GameLogic.Operations[i].Country].KnowhowCustoms -= 2
				if GameLogic.Operations[i].AbroadPlan.Covert == true:
					WorldData.Countries[GameLogic.Operations[i].Country].CovertTravel += 2
					if WorldData.Countries[GameLogic.Operations[i].Country].CovertTravel > 98:
						WorldData.Countries[GameLogic.Operations[i].Country].CovertTravel = 98
				# always success because always some intel gathered
				if GameLogic.Operations[i].Country in GameLogic.PriorityTargetCountries:
					GameLogic.Trust += GameLogic.random.randi_range(1,3)
				elif GameLogic.Operations[i].Country in GameLogic.PriorityOfflimitCountries:
					GameLogic.Trust -= GameLogic.random.randi_range(1,3)
				# quality as the main outcome
				var qualityDiff = (0.0 + GameLogic.Operations[i].AbroadPlan.Quality - GameLogic.Operations[i].ExpectedQuality) / GameLogic.Operations[i].ExpectedQuality
				if qualityDiff > 2.0: qualityDiff = 2.0
				var content = ""
				# debriefing user and results of the intel
				if GameLogic.Operations[i].Source == 0:
					content = "Operation was sucessfully executed. "
					content += "Intel gathered on " + WorldData.Organizations[GameLogic.Operations[i].Target].Name + ":\n" + WorldData.Organizations[GameLogic.Operations[i].Target].IntelDescription[0].substr(18)
					GameLogic.Operations[i].Result = "SUCCESS"
					# special gov feedbacks
					var whichO = GameLogic.Operations[i].Target
					if WorldData.Organizations[whichO].Type == WorldData.OrgType.COMPANY or WorldData.Organizations[whichO].Type == WorldData.OrgType.UNIVERSITY:
						if GameLogic.Operations[i].AbroadPlan.Quality >= 40:
							if WorldData.Organizations[whichO].Technology >= 60:
								GameLogic.Trust += GameLogic.random.randi_range(5,15) * (GameLogic.PriorityTech*0.01)
					elif WorldData.Organizations[whichO].Type == WorldData.OrgType.GENERALTERROR:
						GameLogic.Trust += GameLogic.random.randi_range(1,5) * (GameLogic.PriorityTerrorism*0.01)
					elif WorldData.Organizations[whichO].Type == WorldData.OrgType.GOVERNMENT:
						GameLogic.Trust += GameLogic.random.randi_range(1,5) * (GameLogic.PriorityGovernments*0.01)
					elif WorldData.Organizations[whichO].Type == WorldData.OrgType.UNIVERSITY_OFFENSIVE:
						GameLogic.Trust += GameLogic.random.randi_range(1,5) * (GameLogic.PriorityWMD*0.01)
					else:
						GameLogic.Trust += 0.25
				# debriefing government and effect on the user
				elif GameLogic.Operations[i].Source == 1:
					# standard gov feedback
					var govFeedback = 0  # from -100 to 100, usually -20 to 20
					var weekDiff = (0.0 + GameLogic.Operations[i].WeeksPassed - GameLogic.Operations[i].ExpectedWeeks) / GameLogic.Operations[i].ExpectedWeeks
					govFeedback += weekDiff * 10  # -1 for being 10% late
					govFeedback += qualityDiff * 10  # +1 for 10% better quality
					if govFeedback > 0: govFeedback *= WorldData.Countries[0].PoliticsIntel*0.01
					if govFeedback < -5: govFeedback = GameLogic.random.randi_range(-5,-7)
					if govFeedback > 5: govFeedback = GameLogic.random.randi_range(5,7)
					govFeedback = int(govFeedback)
					if govFeedback == 0: govFeedback = -1
					var whichO = GameLogic.Operations[i].Target
					# special gov feedbacks
					if WorldData.Organizations[whichO].Type == WorldData.OrgType.COMPANY or WorldData.Organizations[whichO].Type == WorldData.OrgType.UNIVERSITY:
						if GameLogic.Operations[i].AbroadPlan.Quality >= 20:
							if WorldData.Organizations[whichO].Technology > 30:
								govFeedback = GameLogic.random.randi_range(4,8) * (GameLogic.PriorityTech*0.01)
							elif WorldData.Organizations[whichO].Technology > 60:
								govFeedback = GameLogic.random.randi_range(7,15) * (GameLogic.PriorityTech*0.01)
					elif WorldData.Organizations[whichO].Type == WorldData.OrgType.GOVERNMENT:
						govFeedback *= (GameLogic.PriorityGovernments*0.01)
					elif WorldData.Organizations[whichO].Type == WorldData.OrgType.UNIVERSITY_OFFENSIVE:
						govFeedback *= (GameLogic.PriorityWMD*0.01)
					GameLogic.Trust += govFeedback
					var govFeedbackDesc = "negatively rated its execution. Bureau lost "+str(int((-1)*govFeedback))+"% of trust."
					GameLogic.Operations[i].Result = "COMPLETED, negative feedback"
					if govFeedback > 0:
						var budgetIncrease = GameLogic.BudgetFull*(0.01*GameLogic.Trust*0.5)
						if budgetIncrease > 50: budgetIncrease = 50
						GameLogic.BudgetFull += budgetIncrease
						govFeedbackDesc = "positively rated its execution. Bureau gained "+str(int(govFeedback))+"% of trust. As a confirmation, government increases bureau's budget by €"+str(int(budgetIncrease))+",000.\n"
						GameLogic.Operations[i].Result = "SUCCESS, positive feedback"
						GameLogic.AddEvent("Government increased budget by €"+str(int(budgetIncrease))+"k")
					content = "Government-designated operation was finished. Homeland " + govFeedbackDesc
				# debriefing user
				if GameLogic.Operations[i].AbroadPlan.Remote == false:
					GameLogic.AddEvent(WorldData.Countries[GameLogic.Operations[i].Country].Name + " (" + GameLogic.Operations[i].Name + "): "+str(GameLogic.Operations[i].AbroadPlan.Officers)+" officer(s) returned to Homeland")
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
				# don't DRY here: a different, call-based code!
				# operation finishes with success or failure now
				var sourceLevel = WorldIntel.RecruitInOrg(
					GameLogic.Operations[i].Target,
					GameLogic.Operations[i].AbroadPlan.Quality,
					GameLogic.GiveDateWithYear()
				)  # where 0 means no source
				# ensuring elementary intel if there isn't any
				if len(WorldData.Organizations[GameLogic.Operations[i].Target].IntelDescription) == 0:
					var localCall = WorldIntel.GatherOnOrg(
						GameLogic.Operations[i].Target,
						GameLogic.Operations[i].AbroadPlan.Quality,
						GameLogic.GiveDateWithYear(),
						false
					)
					if localCall == true: doesItEndWithCall = true
				# debriefing variables
				GameLogic.Operations[i].Stage = OperationGenerator.Stage.FINISHED
				GameLogic.OfficersInHQ += GameLogic.Operations[i].AbroadPlan.Officers
				GameLogic.OfficersAbroad -= GameLogic.Operations[i].AbroadPlan.Officers
				GameLogic.BudgetOngoingOperations -= GameLogic.Operations[i].AbroadPlan.Cost
				GameLogic.PursuedOperations -= 1
				WorldData.Countries[GameLogic.Operations[i].Country].KnowhowLanguage *= 1.01
				WorldData.Countries[GameLogic.Operations[i].Country].KnowhowCustoms += 3
				if WorldData.Countries[GameLogic.Operations[i].Country].KnowhowCustoms > 90:
					WorldData.Countries[GameLogic.Operations[i].Country].KnowhowCustoms -= 3
				if GameLogic.Operations[i].AbroadPlan.Covert == true:
					WorldData.Countries[GameLogic.Operations[i].Country].CovertTravel += 2
					if WorldData.Countries[GameLogic.Operations[i].Country].CovertTravel > 98:
						WorldData.Countries[GameLogic.Operations[i].Country].CovertTravel = 98
				# targeting is what matters here, not the result
				if GameLogic.Operations[i].Country in GameLogic.PriorityTargetCountries:
					GameLogic.Trust += GameLogic.random.randi_range(4,10)
				elif GameLogic.Operations[i].Country in GameLogic.PriorityOfflimitCountries:
					GameLogic.Trust -= GameLogic.random.randi_range(3,6)
				# debriefing user and results of the intel
				var difficulty = WorldData.Organizations[GameLogic.Operations[i].Target].Counterintelligence
				var content = ""
				if GameLogic.Operations[i].Source == 0:
					if sourceLevel == 0:
						content = "Operation failed. Officers gathered some intel on " + WorldData.Organizations[GameLogic.Operations[i].Target].Name + ", but they did not recruit a source in or near the organization.\n"
						GameLogic.Operations[i].Result = "FAILURE"
						GameLogic.StaffSkill += 2
						GameLogic.StaffTrust = GameLogic.StaffTrust*0.95
						if (WorldData.Countries[0].PoliticsIntel+GameLogic.random.randi_range(-15,15)) > 50:
							# changing after own operation only if government cares
							GameLogic.Trust *= 0.98
					else:
						var wordLevel = "low"
						if sourceLevel > 70: wordLevel = "high"
						elif sourceLevel > 30: wordLevel = "medium"
						content = "Operation was successfully executed. A new, " +wordLevel+ "-level source in " + WorldData.Organizations[GameLogic.Operations[i].Target].Name + " will regularly provide new intel.\n"
						GameLogic.Operations[i].Result = "SUCCESS"
						GameLogic.StaffSkill += GameLogic.random.randi_range(3,6)
						GameLogic.StaffTrust = GameLogic.StaffTrust*(1.05+difficulty*0.0025)
						if (WorldData.Countries[0].PoliticsIntel+GameLogic.random.randi_range(-15,15)) > 50:
							# increasing more if government cares
							GameLogic.Trust += 2
						else:
							GameLogic.Trust += 1
						# special gov feedbacks
						var whichO = GameLogic.Operations[i].Target
						if WorldData.Organizations[whichO].Type == WorldData.OrgType.COMPANY or WorldData.Organizations[whichO].Type == WorldData.OrgType.UNIVERSITY:
							if GameLogic.Operations[i].AbroadPlan.Quality >= 40:
								if WorldData.Organizations[whichO].Technology >= 60:
									GameLogic.Trust += GameLogic.random.randi_range(4,8) * (GameLogic.PriorityTech*0.01)
						elif WorldData.Organizations[whichO].Type == WorldData.OrgType.GENERALTERROR:
							GameLogic.Trust += GameLogic.random.randi_range(1,5) * (GameLogic.PriorityTerrorism*0.01)
						elif WorldData.Organizations[whichO].Type == WorldData.OrgType.GOVERNMENT:
							GameLogic.Trust += GameLogic.random.randi_range(1,5) * (GameLogic.PriorityGovernments*0.01)
						elif WorldData.Organizations[whichO].Type == WorldData.OrgType.UNIVERSITY_OFFENSIVE:
							GameLogic.Trust += GameLogic.random.randi_range(1,5) * (GameLogic.PriorityWMD*0.01)
						else:
							GameLogic.Trust += 0.5
				# debriefing government and effect on the user
				elif GameLogic.Operations[i].Source == 1:
					var govFeedback = sourceLevel*(1.0+(difficulty*0.05))
					if sourceLevel == 0:
						govFeedback = GameLogic.random.randi_range(-40,-10)*(1.0-(difficulty*0.05))
					if govFeedback > 0: govFeedback *= WorldData.Countries[0].PoliticsIntel*0.01
					if govFeedback < -10: govFeedback = GameLogic.random.randi_range(-12,-10)
					if govFeedback > 10: govFeedback = GameLogic.random.randi_range(10,12)
					govFeedback = int(govFeedback)
					var whichO = GameLogic.Operations[i].Target
					# special gov feedbacks
					if WorldData.Organizations[whichO].Type == WorldData.OrgType.COMPANY or WorldData.Organizations[whichO].Type == WorldData.OrgType.UNIVERSITY:
						if GameLogic.Operations[i].AbroadPlan.Quality >= 20 and sourceLevel > 0:
							if WorldData.Organizations[whichO].Technology > 30:
								govFeedback = GameLogic.random.randi_range(4,9)
							elif WorldData.Organizations[whichO].Technology > 60:
								govFeedback = GameLogic.random.randi_range(9,16)
					elif WorldData.Organizations[whichO].Type == WorldData.OrgType.GOVERNMENT:
						govFeedback *= (GameLogic.PriorityGovernments*0.01)
					elif WorldData.Organizations[whichO].Type == WorldData.OrgType.UNIVERSITY_OFFENSIVE:
						govFeedback *= (GameLogic.PriorityWMD*0.01)
					GameLogic.Trust += govFeedback
					var govFeedbackDesc = "Officers failed at acquiring a new source in an organization indicated by the government. Bureau lost "+str(int((-1)*govFeedback))+"% of trust."
					GameLogic.Operations[i].Result = "COMPLETED, negative feedback"
					if sourceLevel != 0:
						var budgetIncrease = GameLogic.BudgetFull*(0.01*GameLogic.Trust*0.5)
						if budgetIncrease > 50: budgetIncrease = 50
						GameLogic.BudgetFull += budgetIncrease
						govFeedbackDesc = "Officers acquired a new source in an organization indicated by the government. Bureau gained "+str(int(govFeedback))+"% of trust. As a confirmation, government increases bureau's budget by €"+str(int(budgetIncrease))+",000.\n"
						GameLogic.Operations[i].Result = "SUCCESS, positive feedback"
						GameLogic.AddEvent("Government increased budget by €"+str(int(budgetIncrease))+"k")
					content = "Operation has been finished. " + govFeedbackDesc
				# debriefing user
				if sourceLevel != 0:
					GameLogic.AddEvent(WorldData.Countries[GameLogic.Operations[i].Country].Name + " (" + GameLogic.Operations[i].Name + "): bureau acquired a new source")
				if GameLogic.Operations[i].AbroadPlan.Remote == false:
					GameLogic.AddEvent(WorldData.Countries[GameLogic.Operations[i].Country].Name + " (" + GameLogic.Operations[i].Name + "): "+str(GameLogic.Operations[i].AbroadPlan.Officers)+" officer(s) returned to Homeland")
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
			####################################################################
			# operation finish: OFFENSIVE type
			elif GameLogic.Operations[i].AbroadProgress <= 0 and GameLogic.Operations[i].Type == OperationGenerator.Type.OFFENSIVE:
				# work out anything that's possible from method
				# but not everything is, so some parts are hardcoded
				# debriefing variables
				GameLogic.Operations[i].Stage = OperationGenerator.Stage.FINISHED
				GameLogic.OfficersInHQ += GameLogic.Operations[i].AbroadPlan.Officers
				GameLogic.OfficersAbroad -= GameLogic.Operations[i].AbroadPlan.Officers
				GameLogic.BudgetOngoingOperations -= GameLogic.Operations[i].AbroadPlan.Cost
				GameLogic.PursuedOperations -= 1
				WorldData.Countries[GameLogic.Operations[i].Country].KnowhowLanguage *= 1.01
				WorldData.Countries[GameLogic.Operations[i].Country].KnowhowCustoms += 3
				if WorldData.Countries[GameLogic.Operations[i].Country].KnowhowCustoms > 90:
					WorldData.Countries[GameLogic.Operations[i].Country].KnowhowCustoms -= 3
				if GameLogic.Operations[i].AbroadPlan.Covert == true:
					WorldData.Countries[GameLogic.Operations[i].Country].CovertTravel += 2
					if WorldData.Countries[GameLogic.Operations[i].Country].CovertTravel > 98:
						WorldData.Countries[GameLogic.Operations[i].Country].CovertTravel = 98
				var whichOrg = GameLogic.Operations[i].Target
				WorldData.Organizations[whichOrg].IntelValue += 2
				# targeting is what matters here, not the result
				if GameLogic.Operations[i].Country in GameLogic.PriorityTargetCountries:
					GameLogic.Trust += GameLogic.random.randi_range(8,15)
				elif GameLogic.Operations[i].Country in GameLogic.PriorityOfflimitCountries:
					GameLogic.Trust -= GameLogic.random.randi_range(15,30)
				# actual result and influence on organization
				var success = false
				var casualties = 0
				var funds = 0
				var destroyedOrg = false
				var destroyedOps = 0
				var lengthenedOps = 0
				var methodId = GameLogic.Operations[i].AbroadPlan.Methods[0]
				if GameLogic.random.randi_range(0,100) < GameLogic.Operations[i].AbroadPlan.Quality:
					success = true
					# removing members
					if WorldData.Methods[2][methodId].PossibleCasualties > 0:
						casualties = WorldData.Methods[2][methodId].PossibleCasualties * (1.0+(0.1*GameLogic.random.randi_range(-5,5)))
						if casualties > WorldData.Organizations[whichOrg].Staff:
							casualties = WorldData.Organizations[whichOrg].Staff
						WorldData.Organizations[whichOrg].Staff -= casualties
						if WorldData.Organizations[whichOrg].Staff <= 0:
							destroyedOrg = true
					# removing money
					if WorldData.Methods[2][methodId].BudgetChange > 0:
						funds = (WorldData.Methods[2][methodId].BudgetChange*0.01) * WorldData.Organizations[whichOrg].Budget - GameLogic.random.randi_range(100,1000)
						if funds > WorldData.Organizations[whichOrg].Budget:
							funds = WorldData.Organizations[whichOrg].Budget
						WorldData.Organizations[whichOrg].Budget -= funds
						if WorldData.Organizations[whichOrg].Budget <= 0 and WorldData.Organizations[whichOrg].Type != WorldData.OrgType.MOVEMENT:
							destroyedOrg = true
					# damaging connected organizations
					for z in WorldData.Organizations[whichOrg].ConnectedTo:
						# movement -> terror org
						if WorldData.Organizations[whichOrg].Type == WorldData.OrgType.MOVEMENT:
							if casualties > 0:
								WorldData.OrgType[z].Aggression += GameLogic.random.randi_range(5,10)
								if WorldData.OrgType[z].Staff > casualties:
									WorldData.OrgType[z].Staff -= GameLogic.random.randi_range(0, casualties*0.5)
							WorldData.Organizations[z].Budget *= 1.0 - (WorldData.Methods[2][methodId].BudgetChange*0.002)
							if WorldData.Organizations[z].ActiveOpsAgainstHomeland > 0:
								for u in range(0,len(WorldData.Organizations[z].OpsAgainstHomeland)):
									WorldData.Organizations[z].OpsAgainstHomeland[u].FinishCounter *= (1.0 + GameLogic.random.randi_range(1,25)*0.01)
						# armtrader -> terror org
						if WorldData.Organizations[whichOrg].Type == WorldData.OrgType.ARMTRADER:
							if WorldData.Organizations[z].ActiveOpsAgainstHomeland > 0:
								for u in range(0,len(WorldData.Organizations[z].OpsAgainstHomeland)):
									if destroyedOrg == false:
										WorldData.Organizations[z].OpsAgainstHomeland[u].FinishCounter *= (1.0 + GameLogic.random.randi_range(1,25)*0.01)
										WorldData.Organizations[z].OpsAgainstHomeland[u].Damage -= GameLogic.random.randi_range(5,25)
									else:
										if GameLogic.random.randi_range(1,2) == 1:
											WorldData.Organizations[z].OpsAgainstHomeland[u].Active = false
											destroyedOps += 1
										else:
											WorldData.Organizations[z].OpsAgainstHomeland[u].FinishCounter *= (1.0 + GameLogic.random.randi_range(25,100)*0.01)
					# removing technology, accumulated
					if WorldData.Organizations[whichOrg].Type == WorldData.OrgType.UNIVERSITY_OFFENSIVE:
						if GameLogic.random.randi_range(0,100) < WorldData.Methods[2][methodId].DamageToOps:
							WorldData.Organizations[whichOrg].Technology -= GameLogic.random.randi_range(1, WorldData.Methods[2][methodId].DamageToOps*0.5)
					# removing operations, accumulated with previous ones
					if WorldData.Organizations[whichOrg].ActiveOpsAgainstHomeland > 0:
						for a in range(0, len(WorldData.Organizations[whichOrg].OpsAgainstHomeland)):
							if WorldData.Organizations[whichOrg].OpsAgainstHomeland[a].Active == false:
								continue
							# isolated approach
							if GameLogic.random.randi_range(0,100) < WorldData.Methods[2][methodId].DamageToOps:
								if GameLogic.random.randi_range(1,4) == 2:
									WorldData.Organizations[whichOrg].OpsAgainstHomeland[a].Active = false
									destroyedOps += 1
									continue
								else:
									WorldData.Organizations[whichOrg].OpsAgainstHomeland[a].FinishCounter *= 1.0 + (WorldData.Methods[2][methodId].DamageToOps*0.005)
									lengthenedOps += 1
									continue
							# person-based approach
							if WorldData.Organizations[whichOrg].OpsAgainstHomeland[a].Persons > casualties:
								WorldData.Organizations[whichOrg].OpsAgainstHomeland[a].Active = false
								destroyedOps += 1
								continue
							elif casualties > 0:
								var percentOfChange = 1.0 + (casualties*1.0 / WorldData.Organizations[whichOrg].OpsAgainstHomeland[a].Persons) + (GameLogic.random.randi_range(-10,10)*0.01)
								WorldData.Organizations[whichOrg].OpsAgainstHomeland[a].FinishCounter *= percentOfChange
								WorldData.Organizations[whichOrg].OpsAgainstHomeland[a].Damage -= 5
								if percentOfChange > 1.0: lengthenedOps += 1
								continue
							# budget-based approach
							if WorldData.Organizations[whichOrg].OpsAgainstHomeland[a].Budget > funds:
								WorldData.Organizations[whichOrg].OpsAgainstHomeland[a].Active = false
								destroyedOps += 1
								continue
							elif funds > 0:
								var percentOfChange = 1.0 + (funds*1.0 / WorldData.Organizations[whichOrg].OpsAgainstHomeland[a].Budget) + (GameLogic.random.randi_range(-10,10)*0.01)
								WorldData.Organizations[whichOrg].OpsAgainstHomeland[a].FinishCounter *= percentOfChange
								WorldData.Organizations[whichOrg].OpsAgainstHomeland[a].Damage -= 5
								if percentOfChange > 1.0: lengthenedOps += 1
								continue
				var inflictedDamage = ""
				if success == true:
					if destroyedOrg == true and WorldData.Organizations[whichOrg].Fixed == false:
						inflictedDamage = "As a result, the organization has been completely eliminated. "
						WorldData.Organizations[whichOrg].Active = false
						WorldData.Countries[0].SoftPower += GameLogic.random.randi_range(2,6)
						GameLogic.AddEvent("Bureau eliminated " + WorldData.Organizations[whichOrg].Name)
					else:
						if destroyedOps > 0:
							inflictedDamage = "As a result, danger of some of the attacks was eliminated. "
						elif lengthenedOps > 0:
							inflictedDamage = "As a result, some operations of the organization were delayed. "
					casualties = int(casualties)
					funds = int(funds)
					if casualties > 0:
						if casualties > 1:
							inflictedDamage += WorldData.Organizations[whichOrg].Name + " lost " + str(casualties) + " members. "
						elif casualties == 1:
							inflictedDamage += WorldData.Organizations[whichOrg].Name + " lost one valuable member. "
					if funds > 0:
						inflictedDamage += "Inflicted financial damage is estimated at €" + str(funds) + ",000. "
					if len(WorldData.Organizations[whichOrg].ConnectedTo) > 0:
						inflictedDamage += "In addition, some of the terrorist organizations connected to " + WorldData.Organizations[whichOrg].Name + " were also affected. "
				# special case: offensive action against government
				var attributionDesc = ""
				if WorldData.Organizations[whichOrg].Type == WorldData.OrgType.GOVERNMENT:
					if success == true:
						# destabilization
						WorldData.Countries[WorldData.Organizations[whichOrg].Countries[0]].PoliticsStability -= GameLogic.random.randint(5,20)
						# psyop destabilization
						if methodId >= 9:
							WorldData.Countries[WorldData.Organizations[whichOrg].Countries[0]].PoliticsStability -= GameLogic.random.randint(10,30)
					# attribution can lead to diplomatic scandal
					if GameLogic.random.randi_range(0,100) < WorldData.Methods[2][methodId].Attribution and WorldData.Countries[0].InStateOfWar == false:
						attributionDesc = "Unfortunately, the operation was publicly associated with Bureau, which led to international diplomatic scandal. "
						WorldData.DiplomaticRelations[0][GameLogic.Operations[i].Country] -= GameLogic.random.randi_range(30,60)
						WorldData.DiplomaticRelations[GameLogic.Operations[i].Country][0] -= GameLogic.random.randi_range(30,60)
				# wartime offensive op
				var whichC = WorldData.Organizations[whichOrg].Countries[0]
				if WorldData.Countries[whichC].InStateOfWar == true and WorldData.Countries[0].InStateOfWar == true:
					# dont assume conflict yet, be prepared for more complicated situations
					var conflict = -1
					for b in range(0, len(WorldData.Wars)):
						if WorldData.Wars[b].Active == false: continue
						if WorldData.Wars[b].CountryA != 0 and WorldData.Wars[b].CountryB != 0:
							continue
						if WorldData.Wars[b].CountryA != whichC and WorldData.Wars[b].CountryB != whichC:
							continue
						conflict = b
						break
					if conflict > -1:
						if WorldData.Organizations[whichOrg].Type == WorldData.OrgType.GOVERNMENT or WorldData.Organizations[whichOrg].Type == WorldData.OrgType.INTEL or WorldData.Organizations[whichOrg].Type == WorldData.OrgType.UNIVERSITY_OFFENSIVE:
							var amount = 0
							if success == true: amount = 5
							amount += WorldData.Methods[2][methodId].DamageToOps*0.1
							amount += casualties * 0.1
							amount += funds * 0.001
							if destroyedOrg == true: amount += 20
							if WorldData.Wars[conflict].CountryA == 0: # positive is into homeland direction
								WorldData.Wars[conflict].Result += amount
							else:  # negative is our direction
								WorldData.Wars[conflict].Result -= amount
				# debriefing user and results of the intel
				var content = ""
				var methodDesc = WorldData.Methods[2][GameLogic.Operations[i].AbroadPlan.Methods[0]].Name.replace("(remote) ", "")
				if GameLogic.Operations[i].Source == 0:
					if success == false:
						content = "Operation failed. Officers did not damage " + WorldData.Organizations[GameLogic.Operations[i].Target].Name + ", they were not able to successfully " + methodDesc + ". " + attributionDesc + "\n"
						GameLogic.Operations[i].Result = "FAILURE"
						GameLogic.StaffSkill += 2
						GameLogic.StaffTrust = GameLogic.StaffTrust*0.9
						if (WorldData.Countries[0].PoliticsIntel+GameLogic.random.randi_range(-15,15)) > 50:
							# changing after own operation only if government cares
							GameLogic.Trust *= 0.95
							if len(attributionDesc) > 1: GameLogic.Trust *= (100-GameLogic.PriorityPublic)*0.01
					else:
						content = "Operation was successfully executed. Officers damaged " + WorldData.Organizations[GameLogic.Operations[i].Target].Name + ", they were able to successfully " + methodDesc + ". " + inflictedDamage + attributionDesc
						GameLogic.Operations[i].Result = "SUCCESS"
						GameLogic.StaffSkill += GameLogic.random.randi_range(3,6)
						GameLogic.StaffTrust = GameLogic.StaffTrust*1.1
						if (WorldData.Countries[0].PoliticsIntel+GameLogic.random.randi_range(-15,15)) > 50:
							# increasing more if government cares
							GameLogic.Trust += 2
						else:
							GameLogic.Trust += 1
						# special gov feedbacks
						var whichO = GameLogic.Operations[i].Target
						if WorldData.Organizations[whichO].Type == WorldData.OrgType.GENERALTERROR:
							GameLogic.Trust += GameLogic.random.randi_range(5,15) * (GameLogic.PriorityTerrorism*0.01)
						if len(attributionDesc) > 1: GameLogic.Trust *= (100-GameLogic.PriorityPublic)*0.01
				# debriefing government and effect on the user
				elif GameLogic.Operations[i].Source == 1:
					var govFeedback = GameLogic.random.randi_range(10,30)
					if success == false:
						govFeedback = GameLogic.random.randi_range(-20,-5)
					if govFeedback > 0: govFeedback *= WorldData.Countries[0].PoliticsIntel*0.01
					if govFeedback > 20: govFeedback = GameLogic.random.randi_range(20,23)
					govFeedback = int(govFeedback)
					if len(attributionDesc) > 1: govFeedback -= 30
					if (GameLogic.Trust-govFeedback) < 0: govFeedback = (-1)*GameLogic.Trust
					GameLogic.Trust += govFeedback
					var govFeedbackDesc = "Officers failed at damaging an organization indicated by the government. Bureau lost "+str(int((-1)*govFeedback))+"% of trust. "
					GameLogic.Operations[i].Result = "COMPLETED, negative feedback"
					if success == true:
						var budgetIncrease = GameLogic.BudgetFull*(0.01*GameLogic.Trust*0.5)
						if budgetIncrease > 100: budgetIncrease = 100
						GameLogic.BudgetFull += budgetIncrease
						govFeedbackDesc = "Officers damaged an organization indicated by the government. " + inflictedDamage + " Bureau gained "+str(int(govFeedback))+"% of trust. As a confirmation, government increases bureau's budget by €"+str(int(budgetIncrease))+",000.\n"
						GameLogic.Operations[i].Result = "SUCCESS, positive feedback"
						GameLogic.AddEvent("Government increased budget by €"+str(int(budgetIncrease))+"k")
					content = "Operation has been finished. " + govFeedbackDesc + attributionDesc
				# debriefing user
				if success == true:
					GameLogic.AddEvent(WorldData.Countries[GameLogic.Operations[i].Country].Name + " (" + GameLogic.Operations[i].Name + "): bureau inflicted damage on the target")
				if GameLogic.Operations[i].AbroadPlan.Remote == false:
					GameLogic.AddEvent(WorldData.Countries[GameLogic.Operations[i].Country].Name + " (" + GameLogic.Operations[i].Name + "): "+str(GameLogic.Operations[i].AbroadPlan.Officers)+" officer(s) returned to Homeland")
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
