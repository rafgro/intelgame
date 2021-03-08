extends Node

# Gathering intelligence information about organizations
func GatherOnOrg(o, quality, date, ifHideCalls):
	var doesItEndWithCall = false
	var credible = true
	var backup = null
	if quality < 0:
		credible = false
		quality *= (-1)
		# deception trick: temporarily change organization values, then back them up
		backup = {
			"Staff": WorldData.Organizations[o].Staff,
			"Budget": WorldData.Organizations[o].Budget,
			"Counterintelligence": WorldData.Organizations[o].Counterintelligence,
			"Type": WorldData.Organizations[o].Type,
			"ActiveOpsAgainstHomeland": WorldData.Organizations[o].ActiveOpsAgainstHomeland,
			"Technology": WorldData.Organizations[o].Technology,
		}
		WorldData.Organizations[o].Staff *= (1.0+GameLogic.random.randi_range(-1,1)*0.1)
		WorldData.Organizations[o].Budget *= (1.0+GameLogic.random.randi_range(-1,1)*0.1)
		WorldData.Organizations[o].Counterintelligence *= (1.0+GameLogic.random.randi_range(-1,1)*0.1)
		if WorldData.Organizations[o].Type != WorldData.OrgType.GOVERNMENT and WorldData.Organizations[o].Type != WorldData.OrgType.INTEL:
			# do not change type of obvious organizations
			pass  # todo in the future, eg criminal showed as noncriminal
		WorldData.Organizations[o].ActiveOpsAgainstHomeland = 0  # always report no ops
		WorldData.Organizations[o].Technology += GameLogic.random.randi_range(-40,40)
	############################################################################
	# continuous intel value
	var noOfIdentified = 0
	if quality > WorldData.Organizations[o].IntelValue:
		# general intel value
		var theFactor = 0.1  # easier to gain in early stages, harder in later
		if WorldData.Organizations[o].IntelValue < 10: theFactor = 1.0
		elif WorldData.Organizations[o].IntelValue < 20: theFactor = 0.8
		elif WorldData.Organizations[o].IntelValue < 35: theFactor = 0.6
		elif WorldData.Organizations[o].IntelValue < 50: theFactor = 0.4
		elif WorldData.Organizations[o].IntelValue < 70: theFactor = 0.2
		if credible == true: WorldData.Organizations[o].IntelValue += quality*theFactor
		else: WorldData.Organizations[o].IntelValue -= quality
		# government use of intel
		if WorldData.Organizations[o].Type == WorldData.OrgType.GOVERNMENT or WorldData.Organizations[o].Type == WorldData.OrgType.INTERNATIONAL:
			if credible == true: GameLogic.Use += quality*theFactor*0.1
			else: GameLogic.Use -= quality*2*0.1  # huge impact of false intel on gov
		elif WorldData.Organizations[o].Type == WorldData.OrgType.UNIVERSITY_OFFENSIVE and quality >= 20:
			if credible == true: GameLogic.Use += quality*theFactor*0.5
			else: GameLogic.Use -= quality*2*0.5
		# individual members identified
		var infFactor = 0.001*quality  # eg, 30->0.03
		var newIdentified = int(WorldData.Organizations[o].Staff*1.0*infFactor)
		if newIdentified <= 1 and quality > 20: newIdentified = 1
		if newIdentified > 50: newIdentified = GameLogic.random.randi_range(40,60)
		noOfIdentified = newIdentified
		WorldData.Organizations[o].IntelIdentified += newIdentified
		if WorldData.Organizations[o].IntelIdentified > WorldData.Organizations[o].Staff:
			WorldData.Organizations[o].IntelIdentified = WorldData.Organizations[o].Staff
			noOfIdentified = WorldData.Organizations[o].IntelIdentified-newIdentified
	else:
		WorldData.Organizations[o].IntelValue += 1
	noOfIdentified = int(noOfIdentified)
	############################################################################
	# general intel description for the user
	if WorldData.Organizations[o].Type == WorldData.OrgType.INTEL:
		WorldData.Organizations[o].IntelDescType = "intelligence agency"
	elif WorldData.Organizations[o].Type == WorldData.OrgType.GOVERNMENT:
		WorldData.Organizations[o].IntelDescType = "official government"
	elif WorldData.Organizations[o].Type == WorldData.OrgType.COMPANY:
		WorldData.Organizations[o].IntelDescType = "private corporation"
	elif WorldData.Organizations[o].Type == WorldData.OrgType.UNIVERSITY:
		WorldData.Organizations[o].IntelDescType = "scientific institution"
	elif WorldData.Organizations[o].Type == WorldData.OrgType.MOVEMENT:
		WorldData.Organizations[o].IntelDescType = "unorganized civilian movement"
	elif WorldData.Organizations[o].Type == WorldData.OrgType.INTERNATIONAL:
		WorldData.Organizations[o].IntelDescType = "international organization"
	############################################################################
	# discrete intel descriptions, four stages
	var discreteDesc = ""
	var indicatedOps = false  # used further to provide operation details
	if quality >= 0 and quality < 10:
		if WorldData.Organizations[o].Type == WorldData.OrgType.GENERALTERROR or WorldData.Organizations[o].Type == WorldData.OrgType.ARMTRADER:
			WorldData.Organizations[o].IntelDescType = "suspected criminal organization"
		elif WorldData.Organizations[o].Type == WorldData.OrgType.UNIVERSITY_OFFENSIVE:
			WorldData.Organizations[o].IntelDescType = "scientific institution"
		var desc = ""
		if noOfIdentified > 0: desc += "identified " + str(int(noOfIdentified)) + " individuals inside, "
		desc += "current state of org: "
		if WorldData.Organizations[o].Staff < 100: desc += "very small number of members"
		elif WorldData.Organizations[o].Staff < 5000: desc += "small number of members"
		elif WorldData.Organizations[o].Staff < 15000: desc += "medium number of members"
		elif WorldData.Organizations[o].Staff < 30000: desc += "large number of members"
		else: desc += "huge number of members"
		if WorldData.Organizations[o].Budget < 300: desc += ", small budget"
		elif WorldData.Organizations[o].Budget < 5000: desc += ", medium budget"
		elif WorldData.Organizations[o].Budget < 1000000: desc += ", large budget"
		else: desc += ", huge budget"
		discreteDesc = desc
	############################################################################
	elif quality < 30:
		if WorldData.Organizations[o].Type == WorldData.OrgType.GENERALTERROR:
			WorldData.Organizations[o].IntelDescType = "terrorist organization"
			if WorldData.Organizations[o].TargetConsistency > 60 and len(WorldData.Organizations[o].TargetCountries) > 0:
				var cnames = []
				for v in WorldData.Organizations[o].TargetCountries:
					cnames.append(WorldData.Countries[v].Adjective)
				WorldData.Organizations[o].IntelDescType += " (anti-" + PoolStringArray(cnames).join(", anti-") + ")"
			WorldData.Organizations[o].OffensiveClearance = true
		elif WorldData.Organizations[o].Type == WorldData.OrgType.ARMTRADER:
			WorldData.Organizations[o].IntelDescType = "illegal arms dealer"
			WorldData.Organizations[o].OffensiveClearance = true
		elif WorldData.Organizations[o].Type == WorldData.OrgType.UNIVERSITY_OFFENSIVE:
			WorldData.Organizations[o].IntelDescType = "well-protected scientific institution"
		# rounding example:
		# 12,000 * 0.0001 = 1.2 -> ~= 1 -> = 1 * 10,000 = 10,000
		var desc1 = ""
		if noOfIdentified > 0: desc1 += "identified " + str(int(noOfIdentified)) + " individuals inside, "
		desc1 += "current state of org: "
		var roundedStaff = str(int(WorldData.Organizations[o].Staff * 0.0001) * 10000)
		if roundedStaff == "0":
			if WorldData.Organizations[o].Staff < 50: roundedStaff = "less than 50"
			elif WorldData.Organizations[o].Staff < 500: roundedStaff = "50-500"
			else: roundedStaff = "500-5000"
		var roundedBudget = "€" + str(int(WorldData.Organizations[o].Budget * 0.00001) * 1000)
		if roundedBudget == "€0": roundedBudget = "less than €1000"
		var counter = "non-existent"
		if WorldData.Organizations[o].Counterintelligence > 90: counter = "extreme"
		elif WorldData.Organizations[o].Counterintelligence > 70: counter = "significant"
		elif WorldData.Organizations[o].Counterintelligence > 50: counter = "medium"
		elif WorldData.Organizations[o].Counterintelligence > 20: counter = "weak"
		discreteDesc = desc1 + "approximately " + roundedStaff + " members, budget of " + roundedBudget + " millions monthly, " + counter + " counterintelligence measures"
	############################################################################
	elif quality < 50:
		if WorldData.Organizations[o].Type == WorldData.OrgType.GENERALTERROR:
			WorldData.Organizations[o].IntelDescType = "terrorist organization"
			if WorldData.Organizations[o].TargetConsistency > 60 and len(WorldData.Organizations[o].TargetCountries) > 0:
				var cnames = []
				for v in WorldData.Organizations[o].TargetCountries:
					cnames.append(WorldData.Countries[v].Adjective)
				WorldData.Organizations[o].IntelDescType += " (anti-" + PoolStringArray(cnames).join(", anti-") + ")"
			WorldData.Organizations[o].OffensiveClearance = true
		elif WorldData.Organizations[o].Type == WorldData.OrgType.ARMTRADER:
			WorldData.Organizations[o].IntelDescType = "illegal arms dealer"
			WorldData.Organizations[o].OffensiveClearance = true
		elif WorldData.Organizations[o].Type == WorldData.OrgType.UNIVERSITY_OFFENSIVE:
			WorldData.Organizations[o].IntelDescType = "well-protected scientific institution"
		var desc1 = ""
		if noOfIdentified > 0: desc1 += "identified " + str(int(noOfIdentified)) + " individuals inside, "
		desc1 += "current state of org: "
		var roundedStaff = str(int(WorldData.Organizations[o].Staff * 0.001) * 1000)
		if roundedStaff == "0":
			if WorldData.Organizations[o].Staff < 10: roundedStaff = "less than 10"
			elif WorldData.Organizations[o].Staff < 100: roundedStaff = "10-100"
			elif WorldData.Organizations[o].Staff < 500: roundedStaff = "100-500"
			else: roundedStaff = "500-1000"
		var roundedBudget = "€"+str(int(WorldData.Organizations[o].Budget * 0.001) * 10)
		if roundedBudget == "€0": roundedBudget = "less than €10"
		var roundedCounter = int(WorldData.Organizations[o].Counterintelligence * 0.1) * 10
		discreteDesc = desc1 + "approximately " + roundedStaff + " members, budget of " + roundedBudget + " millions monthly, " + str(int(roundedCounter)) + "/100 counterintelligence measures"
	############################################################################
	elif quality < 70:
		if WorldData.Organizations[o].Type == WorldData.OrgType.GENERALTERROR:
			WorldData.Organizations[o].IntelDescType = "terrorist organization"
			if WorldData.Organizations[o].TargetConsistency > 60 and len(WorldData.Organizations[o].TargetCountries) > 0:
				var cnames = []
				for v in WorldData.Organizations[o].TargetCountries:
					cnames.append(WorldData.Countries[v].Adjective)
				WorldData.Organizations[o].IntelDescType += " (anti-" + PoolStringArray(cnames).join(", anti-") + ")"
			WorldData.Organizations[o].OffensiveClearance = true
		elif WorldData.Organizations[o].Type == WorldData.OrgType.ARMTRADER:
			WorldData.Organizations[o].IntelDescType = "illegal arms dealer"
			WorldData.Organizations[o].OffensiveClearance = true
		elif WorldData.Organizations[o].Type == WorldData.OrgType.UNIVERSITY_OFFENSIVE:
			WorldData.Organizations[o].IntelDescType = "well-protected scientific institution"
		var desc1 = ""
		if noOfIdentified > 0: desc1 += "identified " + str(int(noOfIdentified)) + " individuals inside, "
		desc1 += "current state of org: "
		var roundedStaff = str(int(WorldData.Organizations[o].Staff * 0.01) * 100)
		if roundedStaff == "0":
			if WorldData.Organizations[o].Staff < 5: roundedStaff = "less than 5"
			elif WorldData.Organizations[o].Staff < 15: roundedStaff = "5-15"
			elif WorldData.Organizations[o].Staff < 60: roundedStaff = "15-60"
			else: roundedStaff = "60-100"
		var roundedBudget = "€"+str(int(WorldData.Organizations[o].Budget * 0.01))
		if roundedBudget == "€0": roundedBudget = "less than €1"
		var roundedCounter = WorldData.Organizations[o].Counterintelligence
		discreteDesc = desc1 + "approximately " + roundedStaff + " members, budget of " + roundedBudget + " millions monthly, " + str(int(roundedCounter)) + "/100 counterintelligence measures"
	############################################################################
	else:
		if WorldData.Organizations[o].Type == WorldData.OrgType.GENERALTERROR:
			WorldData.Organizations[o].IntelDescType = "terrorist organization"
			if WorldData.Organizations[o].TargetConsistency > 60 and len(WorldData.Organizations[o].TargetCountries) > 0:
				var cnames = []
				for v in WorldData.Organizations[o].TargetCountries:
					cnames.append(WorldData.Countries[v].Adjective)
				WorldData.Organizations[o].IntelDescType += " (anti-" + PoolStringArray(cnames).join(", anti-") + ")"
			WorldData.Organizations[o].OffensiveClearance = true
		elif WorldData.Organizations[o].Type == WorldData.OrgType.ARMTRADER:
			WorldData.Organizations[o].IntelDescType = "illegal arms dealer"
			WorldData.Organizations[o].OffensiveClearance = true
		elif WorldData.Organizations[o].Type == WorldData.OrgType.UNIVERSITY_OFFENSIVE:
			WorldData.Organizations[o].IntelDescType = "well-protected scientific institution"
		var desc1 = ""
		if noOfIdentified > 0: desc1 += "identified " + str(int(noOfIdentified)) + " individuals inside, "
		desc1 += "current state of org: "
		var roundedStaff = str(int(WorldData.Organizations[o].Staff))
		var roundedBudget = "€"+str(int(WorldData.Organizations[o].Budget * 0.01))
		if roundedBudget == "€0": roundedBudget = "less than €1"
		var roundedCounter = WorldData.Organizations[o].Counterintelligence
		discreteDesc = desc1 + roundedStaff + " members, budget of " + roundedBudget + " millions monthly, " + str(int(roundedCounter)) + "/100 counterintelligence measures"
	############################################################################
	# operation intel, both discrete descriptions and logic mechanics
	var antihomeland = ""
	if quality >= 10:
		var ifGlobalKidnapping = false
		var opDescriptions = []
		for z in range(0,len(WorldData.Organizations[o].OpsAgainstHomeland)):
			if WorldData.Organizations[o].OpsAgainstHomeland[z].Active == false:
				continue
			# intelligence agency operations are different, have no expiration time etc
			var ifCounterintel = false
			if WorldData.Organizations[o].OpsAgainstHomeland[z].Type == WorldData.ExtOpType.COUNTERINTEL:
				ifCounterintel = true
			# kidnapping operations are different, intel about them is easier to obtain and then acted
			var ifKidnapping = false
			if WorldData.Organizations[o].OpsAgainstHomeland[z].Type == WorldData.ExtOpType.KIDNAPPING_AND_MURDER:
				ifKidnapping = true
				ifGlobalKidnapping = true
			# most important logic change
			var pastIntel = WorldData.Organizations[o].OpsAgainstHomeland[z].IntelValue
			WorldData.Organizations[o].OpsAgainstHomeland[z].IntelValue += quality * ((100.0-WorldData.Organizations[o].OpsAgainstHomeland[z].Secrecy)*0.01)
			var newIntel = WorldData.Organizations[o].OpsAgainstHomeland[z].IntelValue
			# describing
			if newIntel < 20:
				var roundedD = WorldData.Organizations[o].OpsAgainstHomeland[z].FinishCounter/4 + GameLogic.random.randi_range(-2,2)
				if roundedD < 1: roundedD = 1
				if ifCounterintel == true:
					opDescriptions.append("possible operation against Bureau")
				elif ifKidnapping == true:
					opDescriptions.append("probably kidnapped Homeland citizen")
					WorldData.Organizations[o].KnownKidnapper = true
				else:
					opDescriptions.append("possible operation finishing in ~" + str(int(roundedD)) + " months")
			elif newIntel < 40:
				if ifCounterintel == true:
					var damage = "deep"
					if WorldData.Organizations[o].OpsAgainstHomeland[z].Damage < 50: damage = "shallow"
					opDescriptions.append("probable " + damage + " operation targeting Bureau officers")
				elif ifKidnapping == true:
					opDescriptions.append("kidnapped Homeland citizen")
					WorldData.Organizations[o].KnownKidnapper = true
				else:
					var roundedD = WorldData.Organizations[o].OpsAgainstHomeland[z].FinishCounter + GameLogic.random.randi_range(-2,2)
					if roundedD < 1: roundedD = 1
					var theType = "terrorist operation inside Homeland"
					if WorldData.Organizations[o].OpsAgainstHomeland[z].Type == WorldData.ExtOpType.EMBASSY_TERRORIST_ATTACK or WorldData.Organizations[o].OpsAgainstHomeland[z].Type == WorldData.ExtOpType.PLANE_HIJACKING:
						theType = "terrorist operation targeting Homeland citizens abroad"
					var damage = "large"
					if WorldData.Organizations[o].OpsAgainstHomeland[z].Damage < 50: damage = "minor"
					var people = "few"
					if WorldData.Organizations[o].OpsAgainstHomeland[z].Persons > 20: people = "dozens of"
					opDescriptions.append("probable " + damage + " " + theType + ", with " + people + " people involved, finishing in ~" + str(int(roundedD)) + " weeks")
			elif newIntel < 60:
				if ifCounterintel == true:
					var damage = "deep"
					if WorldData.Organizations[o].OpsAgainstHomeland[z].Damage < 20: damage = "shallow"
					elif WorldData.Organizations[o].OpsAgainstHomeland[z].Damage < 60: damage = "moderate"
					opDescriptions.append(damage + " operation targeting Bureau officers")
				elif ifKidnapping == true:
					opDescriptions.append("kidnapped Homeland citizen, confinement location is known")
					WorldData.Organizations[o].KnownKidnapper = true
				else:
					var theType = "terrorist operation inside Homeland"
					if WorldData.Organizations[o].OpsAgainstHomeland[z].Type == WorldData.ExtOpType.EMBASSY_TERRORIST_ATTACK:
						theType = "terrorist operation targeting embassy"
					elif WorldData.Organizations[o].OpsAgainstHomeland[z].Type == WorldData.ExtOpType.PLANE_HIJACKING:
						theType = "terrorist operation using Homeland planes"
					elif WorldData.Organizations[o].OpsAgainstHomeland[z].Type == WorldData.ExtOpType.LEADER_ASSASSINATION:
						theType = "terrorist operation targeting Homeland leaders"
					var damage = "large"
					if WorldData.Organizations[o].OpsAgainstHomeland[z].Damage < 20: damage = "minor"
					elif WorldData.Organizations[o].OpsAgainstHomeland[z].Damage < 60: damage = "medium-sized"
					var roundedP = WorldData.Organizations[o].OpsAgainstHomeland[z].Persons * (1.0+0.1*GameLogic.random.randi_range(-4,4))
					if roundedP < 1: roundedP = 1
					var knownInvolvedValue = WorldData.Organizations[o].OpsAgainstHomeland[z].Persons * (WorldData.Organizations[o].IntelIdentified*1.0 / WorldData.Organizations[o].Staff)
					if knownInvolvedValue < roundedP: knownInvolvedValue = roundedP
					var knownInvolved = " [no identified participants]"
					if knownInvolvedValue > 0:
						knownInvolved = " ["+str(int(knownInvolvedValue))+" identified participants]"
					opDescriptions.append(damage + " " + theType + ", with ~" + str(int(roundedP)) + " individuals involved"+knownInvolved+", finishing in " + str(WorldData.Organizations[o].OpsAgainstHomeland[z].FinishCounter) + " weeks")
			else:
				if ifCounterintel == true:
					var damage = "deep"
					if WorldData.Organizations[o].OpsAgainstHomeland[z].Damage < 20: damage = "shallow"
					elif WorldData.Organizations[o].OpsAgainstHomeland[z].Damage < 60: damage = "moderate"
					opDescriptions.append(damage + " operation targeting Bureau officers")
				elif ifKidnapping == true:
					opDescriptions.append("kidnapped Homeland citizen, precise confinement location is known")
					WorldData.Organizations[o].KnownKidnapper = true
				else:
					var theType = "terrorist operation inside Homeland"
					if WorldData.Organizations[o].OpsAgainstHomeland[z].Type == WorldData.ExtOpType.EMBASSY_TERRORIST_ATTACK:
						theType = "terrorist operation against embassy"
					elif WorldData.Organizations[o].OpsAgainstHomeland[z].Type == WorldData.ExtOpType.PLANE_HIJACKING:
						theType = "terrorist operation using Homeland planes"
					elif WorldData.Organizations[o].OpsAgainstHomeland[z].Type == WorldData.ExtOpType.LEADER_ASSASSINATION:
						theType = "terrorist operation targeting Homeland leaders"
					var damage = "huge"
					if WorldData.Organizations[o].OpsAgainstHomeland[z].Damage < 20: damage = "minor"
					elif WorldData.Organizations[o].OpsAgainstHomeland[z].Damage < 60: damage = "medium-sized"
					elif WorldData.Organizations[o].OpsAgainstHomeland[z].Damage < 90: damage = "large"
					var knownInvolvedValue = WorldData.Organizations[o].OpsAgainstHomeland[z].Persons * (WorldData.Organizations[o].IntelIdentified*1.0 / WorldData.Organizations[o].Staff)
					if knownInvolvedValue > WorldData.Organizations[o].OpsAgainstHomeland[z].Persons:
						knownInvolvedValue = WorldData.Organizations[o].OpsAgainstHomeland[z].Persons
					var knownInvolved = " [no identified participants]"
					if knownInvolvedValue > 0:
						knownInvolved = " ["+str(int(knownInvolvedValue))+" identified participants]"
					opDescriptions.append(damage + " " + theType + ", with " + str(int(WorldData.Organizations[o].OpsAgainstHomeland[z].Persons)) + " individuals involved" + knownInvolved + ", finishing in " + str(WorldData.Organizations[o].OpsAgainstHomeland[z].FinishCounter) + " weeks")
			# comparing significant intel change and notifying user if possible
			var diff = newIntel - pastIntel
			if WorldData.Organizations[o].OffensiveClearance == false and ifKidnapping == true: diff = 21
			if diff >= 20 and ifCounterintel == false and ifHideCalls == false:
				CallManager.CallQueue.append(
					{
						"Header": "Important Information",
						"Level": "Top Secret",
						"Operation": "-//-",
						"Content": "New, significant intel has been gathered in " + WorldData.Organizations[o].Name + ". The organization was associated with:\n\n[b]"+opDescriptions[-1]+"[/b]\n\nHomeland authorities were notified about the danger. More details will better assist them in preventing the event from happening. Knowledge about members of the organization and persons involved in the operation is especially valuable. Bureau is also cleared to perform offensive operations against " + WorldData.Organizations[o].Name + " to disrupt, slow down, or even eliminate the adversary.",
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
				if WorldData.Organizations[o].OffensiveClearance == false:
					WorldData.Organizations[o].OffensiveClearance = true
					GameLogic.AddEvent("Bureau received offensive clearance for targeting " + WorldData.Organizations[o].Name)
				doesItEndWithCall = true
		# op description assembly
		if ifGlobalKidnapping == true:
			antihomeland = "[u]" + opDescriptions[randi() % opDescriptions.size()] + "[/u]"
		elif quality < 20:
			antihomeland = "lack of knowledge about activity against Homeland"
			if WorldData.Organizations[o].ActiveOpsAgainstHomeland > 0:
				if GameLogic.random.randi_range(1,4) == 2:
					antihomeland = "[u]possible suspicious activity towards Homeland[/u]"
					if len(opDescriptions) > 0:
						antihomeland += " ([u]" + opDescriptions[randi() % opDescriptions.size()] + "[/u])"
		elif quality < 40:
			antihomeland = "probably no operations against Homeland"
			if WorldData.Organizations[o].ActiveOpsAgainstHomeland > 0:
				if GameLogic.random.randi_range(1,2) == 1:
					antihomeland = "[u]probably involved in operations against Homeland[/u]"
					if len(opDescriptions) > 0:
						antihomeland += " ([u]" + opDescriptions[randi() % opDescriptions.size()] + "[/u])"
					if WorldData.Organizations[o].OffensiveClearance == false:
						WorldData.Organizations[o].OffensiveClearance = true
						GameLogic.AddEvent("Bureau received offensive clearance for targeting " + WorldData.Organizations[o].Name)
		elif quality < 60:
			antihomeland = "no operations against Homeland"
			if WorldData.Organizations[o].ActiveOpsAgainstHomeland > 0:
				antihomeland = "[u]executes operations against Homeland[/u]"
				antihomeland += " ([u]" + opDescriptions[0] + "[/u])"
				if WorldData.Organizations[o].OffensiveClearance == false:
					WorldData.Organizations[o].OffensiveClearance = true
					GameLogic.AddEvent("Bureau received offensive clearance for targeting " + WorldData.Organizations[o].Name)
		else:
			antihomeland = "no operations against Homeland"
			if WorldData.Organizations[o].ActiveOpsAgainstHomeland > 0:
				antihomeland = "[u]executes " +str(WorldData.Organizations[o].ActiveOpsAgainstHomeland)+ " operations against Homeland[/u]"
				antihomeland += " ([u]" + PoolStringArray(opDescriptions).join("; ") + "[/u])"
				if WorldData.Organizations[o].OffensiveClearance == false:
					WorldData.Organizations[o].OffensiveClearance = true
					GameLogic.AddEvent("Bureau received offensive clearance for targeting " + WorldData.Organizations[o].Name)
	############################################################################
	# intel about agencies brings intel about random other organizations
	if WorldData.Organizations[o].Type == WorldData.OrgType.INTEL:
		if quality < 15:
			pass  # not enough
		else:
			var howManyOrgs = 1
			if quality > 90: howManyOrgs = 6
			elif quality > 70: howManyOrgs = 3
			elif quality > 35: howManyOrgs = 2
			var orgNames = []
			for h in range(0, howManyOrgs):
				var whichOrg = randi() % WorldData.Organizations.size()
				if whichOrg == o:
					continue
				if WorldData.Organizations[whichOrg].Type == WorldData.OrgType.INTEL:
					if GameLogic.random.randi_range(1,10) != 5:
						continue  # to avoid too frequent recurency
				var ifAnyCall = GatherOnOrg(whichOrg, GameLogic.random.randi_range(10,WorldData. Organizations[whichOrg].Counterintelligence*0.5), date, ifHideCalls)  # counter as upper, since it's directly proportional to quality of the agency
				orgNames.append(WorldData.Organizations[whichOrg].Name)
				if ifAnyCall == true: doesItEndWithCall = true
			if len(orgNames) > 0:
				discreteDesc += ", in addition officers tapped into intel gathered by this agency about " + PoolStringArray(orgNames).join(", ")
	############################################################################
	# organization-type-specific intels
	elif WorldData.Organizations[o].Type == WorldData.OrgType.COMPANY or WorldData.Organizations[o].Type == WorldData.OrgType.UNIVERSITY or WorldData.Organizations[o].Type == WorldData.OrgType.INTEL or (GameLogic.TurnOnWMD == true and WorldData.Organizations[o].Type == WorldData.OrgType.UNIVERSITY_OFFENSIVE):
		var technologyWinCall = false
		var techDesc = ""
		var innerTechChange = 0
		if quality < 10:
			pass  # not enough
		elif quality < 30:
			techDesc = ", probably no interesting technology"
			if WorldData.Organizations[o].Technology > 50 and GameLogic.random.randi_range(1,2) == 1:
				techDesc = ", potentially interesting technology"
				if len(WorldData.Organizations[o].TechDescription) > 0:
					techDesc += ": " + WorldData.Organizations[o].TechDescription
				WorldData.Organizations[o].IntelTechnology = WorldData.Organizations[o].Technology*0.2
				innerTechChange = 1
		elif quality < 50:
			if WorldData.Organizations[o].Technology < 30:
				techDesc = ", no interesting technology"
			elif WorldData.Organizations[o].Technology < 60:
				techDesc = ", some technological details acquired"
				if len(WorldData.Organizations[o].TechDescription) > 0:
					techDesc += ": " + WorldData.Organizations[o].TechDescription
				WorldData.Organizations[o].IntelTechnology = WorldData.Organizations[o].Technology*0.3
				innerTechChange = 1
			else:
				var ifNew = ""
				var newIntelTech = WorldData.Organizations[o].Technology*0.5
				if newIntelTech > WorldData.Organizations[o].IntelTechnology:
					technologyWinCall = true
					ifNew = "new "
					innerTechChange = 2
				else: innerTechChange = 1
				techDesc = ", " + ifNew + "interesting technological details acquired"
				if len(WorldData.Organizations[o].TechDescription) > 0:
					techDesc += ": " + WorldData.Organizations[o].TechDescription
				WorldData.Organizations[o].IntelTechnology = newIntelTech
		elif quality < 75:
			if WorldData.Organizations[o].Technology < 30:
				techDesc = ", no interesting technology"
			elif WorldData.Organizations[o].Technology < 60:
				techDesc = ", technological documents acquired"
				if len(WorldData.Organizations[o].TechDescription) > 0:
					techDesc += ": " + WorldData.Organizations[o].TechDescription
				var newIntelTech = WorldData.Organizations[o].Technology*0.6
				WorldData.Organizations[o].IntelTechnology = newIntelTech
				innerTechChange = 2
			else:
				var ifNew = ""
				var newIntelTech = WorldData.Organizations[o].Technology*0.8
				if newIntelTech > WorldData.Organizations[o].IntelTechnology:
					technologyWinCall = true
					ifNew = "new "
					innerTechChange = 3
				else: innerTechChange = 2
				techDesc = ", " + ifNew + "interesting technological documents acquired"
				if len(WorldData.Organizations[o].TechDescription) > 0:
					techDesc += ": " + WorldData.Organizations[o].TechDescription
				WorldData.Organizations[o].IntelTechnology = newIntelTech
		else:
			if WorldData.Organizations[o].Technology < 30:
				techDesc = ", no valuable technology"
			elif WorldData.Organizations[o].Technology < 60:
				var ifNew = ""
				var newIntelTech = WorldData.Organizations[o].Technology*0.8
				if newIntelTech > WorldData.Organizations[o].IntelTechnology:
					technologyWinCall = true
					ifNew = "new "
					innerTechChange = 3
				else: innerTechChange = 2
				techDesc = ", " + ifNew + "valuable technological documents acquired"
				if len(WorldData.Organizations[o].TechDescription) > 0:
					techDesc += ": " + WorldData.Organizations[o].TechDescription
				WorldData.Organizations[o].IntelTechnology = newIntelTech
			else:
				var ifNew = ""
				var newIntelTech = WorldData.Organizations[o].Technology
				if newIntelTech > WorldData.Organizations[o].IntelTechnology:
					technologyWinCall = true
					ifNew = "new "
					innerTechChange = 4
				else: innerTechChange = 3
				techDesc = ", " + ifNew + "significantly valuable technological documents acquired"
				if len(WorldData.Organizations[o].TechDescription) > 0:
					techDesc += ": " + WorldData.Organizations[o].TechDescription
				WorldData.Organizations[o].IntelTechnology = newIntelTech
		# inner technology change
		if credible == true and WorldData.Organizations[o].TradecraftTech == true:
			if WorldData.Organizations[o].Type == WorldData.OrgType.COMPANY or WorldData.Organizations[o].Type == WorldData.OrgType.UNIVERSITY:
				# limited use of private tech
				if GameLogic.Technology < 20: GameLogic.Technology += innerTechChange
				elif GameLogic.Technology < 30: GameLogic.Technology += innerTechChange*0.5
				elif GameLogic.Technology < 40: GameLogic.Technology += innerTechChange*0.1
			elif WorldData.Organizations[o].Type == WorldData.OrgType.INTEL:
				# huge use of intel tech
				if GameLogic.Technology < 50: GameLogic.Technology += innerTechChange
				elif GameLogic.Technology < 65: GameLogic.Technology += innerTechChange*0.5
				elif GameLogic.Technology < 80: GameLogic.Technology += innerTechChange*0.1
		# eventual user debriefing
		if technologyWinCall == true and ifHideCalls == false:
			var trustIncrease = quality*0.15*GameLogic.PriorityTech*0.01
			if trustIncrease > 10: trustIncrease = 10
			if (GameLogic.Trust+trustIncrease) > 100: trustIncrease = 101-GameLogic.Trust
			GameLogic.Trust += trustIncrease
			WorldData.Countries[0].SoftPower += GameLogic.random.randi_range(1,3)
			var budgetIncrease = quality*0.5
			if budgetIncrease > 50: budgetIncrease = 50
			GameLogic.BudgetFull += budgetIncrease
			var ifTechDetail = ""
			if len(WorldData.Organizations[o].TechDescription) > 0:
				ifTechDetail = " about " + WorldData.Organizations[o].TechDescription
			CallManager.CallQueue.append(
				{
					"Header": "Important Information",
					"Level": "Confidential",
					"Operation": "-//-",
					"Content": "New technological intel has been gathered in " + WorldData.Organizations[o].Name + ifTechDetail + ". Homeland authorities recognized it as highly valuable. In recognition of the efforts and in hope of continuation, government raised the trust by " + str(int(trustIncrease)) + "% and increased Bureau's budget by €" + str(int(budgetIncrease)) + ",000.",
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
		discreteDesc += techDesc
	elif GameLogic.TurnOnWMD == true and WorldData.Organizations[o].Type == WorldData.OrgType.UNIVERSITY_OFFENSIVE:
		# will call user only if clearance is off
		# this is trick/shortcut to have one-time wmd notification
		var technologyWinCall = false
		var techDesc = ""
		if quality < 10:
			pass  # not enough
		elif quality < 20:
			techDesc = ", lack of knowledge about research area"
			if WorldData.Organizations[o].Technology > 50 and GameLogic.random.randi_range(1,2) == 1:
				techDesc = ", potentially dangerous research"
				WorldData.Organizations[o].IntelTechnology = WorldData.Organizations[o].Technology*0.1
				WorldData.Countries[WorldData.Organizations[o].Countries[0]].WMDIntel += 5
		elif quality < 40:
			if WorldData.Organizations[o].Technology < 30:
				techDesc = ", no dangerous research"
				WorldData.Countries[WorldData.Organizations[o].Countries[0]].WMDIntel -= 5
			elif WorldData.Organizations[o].Technology < 60:
				techDesc = ", potentially conducting research on WMD"
				WorldData.Organizations[o].IntelTechnology = WorldData.Organizations[o].Technology*0.3
				WorldData.Countries[WorldData.Organizations[o].Countries[0]].WMDIntel += 5
			else:
				var newIntelTech = WorldData.Organizations[o].Technology*0.5
				techDesc = ", conducts research on WMD"
				WorldData.Organizations[o].IntelTechnology = newIntelTech
				technologyWinCall = true
				WorldData.Countries[WorldData.Organizations[o].Countries[0]].WMDIntel += 15
		elif quality < 75:
			if WorldData.Organizations[o].Technology < 30:
				techDesc = ", no dangerous research"
				WorldData.Countries[WorldData.Organizations[o].Countries[0]].WMDIntel -= 15
			elif WorldData.Organizations[o].Technology < 60:
				techDesc = ", conducts research on WMD, some details acquired"
				var newIntelTech = WorldData.Organizations[o].Technology*0.6
				WorldData.Organizations[o].IntelTechnology = newIntelTech
				technologyWinCall = true
				GameLogic.Trust += 5*GameLogic.PriorityWMD*0.01
				WorldData.Countries[WorldData.Organizations[o].Countries[0]].WMDIntel += 25
			else:
				var newIntelTech = WorldData.Organizations[o].Technology*0.8
				techDesc = ", conducts research on WMD, technological details acquired"
				WorldData.Organizations[o].IntelTechnology = newIntelTech
				technologyWinCall = true
				GameLogic.Trust += 10*GameLogic.PriorityWMD*0.01
				WorldData.Countries[WorldData.Organizations[o].Countries[0]].WMDIntel += 50
		else:
			if WorldData.Organizations[o].Technology < 30:
				techDesc = ", no dangerous technology"
				WorldData.Countries[WorldData.Organizations[o].Countries[0]].WMDIntel -= 20
			elif WorldData.Organizations[o].Technology < 60:
				var ifNew = ""
				var newIntelTech = WorldData.Organizations[o].Technology*0.8
				techDesc = ", conducts research on WMD, technological details acquired"
				WorldData.Organizations[o].IntelTechnology = newIntelTech
				technologyWinCall = true
				GameLogic.Trust += 10*GameLogic.PriorityWMD*0.01
				WorldData.Countries[WorldData.Organizations[o].Countries[0]].WMDIntel += 50
			else:
				var ifNew = ""
				var newIntelTech = WorldData.Organizations[o].Technology
				techDesc = ", conducts research on WMD, significantly valuable details acquired"
				WorldData.Organizations[o].IntelTechnology = newIntelTech
				technologyWinCall = true
				GameLogic.Trust += 20*GameLogic.PriorityWMD*0.01
				WorldData.Countries[WorldData.Organizations[o].Countries[0]].WMDIntel += 75
			# eventual user debriefing
			if technologyWinCall == true and WorldData.Organizations[o].OffensiveClearance == false and ifHideCalls == false:
				var trustIncrease = quality*0.15*GameLogic.PriorityWMD*0.01
				if trustIncrease > 10: trustIncrease = 10
				if (GameLogic.Trust+trustIncrease) > 100: trustIncrease = 101-GameLogic.Trust
				GameLogic.Trust += trustIncrease
				WorldData.Countries[0].SoftPower += GameLogic.random.randi_range(10,30)
				var budgetIncrease = quality*0.3
				if budgetIncrease > 40: budgetIncrease = 40
				GameLogic.BudgetFull += budgetIncrease
				CallManager.CallQueue.append(
					{
						"Header": "Important Information",
						"Level": "Top Secret",
						"Operation": "-//-",
						"Content": "New technological intel has been gathered in " + WorldData.Organizations[o].Name + ", concerning development of weapons of mass destruction. Homeland authorities recognized it as extremely valuable. In recognition of the efforts and in hope of continuation, government raised the trust by " + str(int(trustIncrease)) + "% and increased Bureau's budget by €" + str(int(budgetIncrease)) + ",000.\nnBureau is also cleared to conduct eventual offensive operations against the organization.",
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
				WorldData.Organizations[o].OffensiveClearance = true
				GameLogic.AddEvent("Bureau received offensive clearance for targeting " + WorldData.Organizations[o].Name)
				doesItEndWithCall = true
		discreteDesc += techDesc
	elif WorldData.Organizations[o].Type == WorldData.OrgType.MOVEMENT or WorldData.Organizations[o].Type == WorldData.OrgType.ARMTRADER:
		var movDesc = ""
		if quality < 2:
			pass  # not enough
		elif quality < 10:
			movDesc = ", probably not connected to terrorist organizations"
			if len(WorldData.Organizations[o].ConnectedTo) > 0 and GameLogic.random.randi_range(1,2) == 1:
				movDesc = ", potentially connected to a terrorist organization"
		elif quality < 25:
			movDesc = ", probably not connected to terrorist organizations"
			if len(WorldData.Organizations[o].ConnectedTo) > 0:
				movDesc = ", potentially connected to at least one terrorist organization (" + WorldData.Organizations[WorldData.Organizations[o].ConnectedTo[0]].Name + ")"
				WorldData.Organizations[WorldData.Organizations[o].ConnectedTo[0]].IntelValue += 5
				WorldData.Organizations[WorldData.Organizations[o].ConnectedTo[0]].IntelDescription.push_front("[b]"+date+"[/b] discovered connection to " + WorldData.Organizations[o].Name)
				if WorldData.Organizations[WorldData.Organizations[o].ConnectedTo[0]].Known == false:
					WorldData.Organizations[WorldData.Organizations[o].ConnectedTo[0]].Known = true
					GatherOnOrg(WorldData.Organizations[o].ConnectedTo[0], 5, date, ifHideCalls)
					antihomeland = "[u]previously unknown terrorist organization, " + WorldData.Organizations[WorldData.Organizations[o].ConnectedTo[0]].Name + ", was discovered in connection the to movement[/u]"
		elif quality < 50:
			movDesc = ", probably not connected to terrorist organizations"
			if len(WorldData.Organizations[o].ConnectedTo) > 0:
				movDesc = ", connected to at least one terrorist organization (" + WorldData.Organizations[WorldData.Organizations[o].ConnectedTo[0]].Name + ")"
				WorldData.Organizations[WorldData.Organizations[o].ConnectedTo[0]].IntelValue += 10
				WorldData.Organizations[WorldData.Organizations[o].ConnectedTo[0]].IntelDescription.push_front("[b]"+date+"[/b] discovered connection to " + WorldData.Organizations[o].Name)
				if WorldData.Organizations[WorldData.Organizations[o].ConnectedTo[0]].Known == false:
					WorldData.Organizations[WorldData.Organizations[o].ConnectedTo[0]].Known = true
					GatherOnOrg(WorldData.Organizations[o].ConnectedTo[0], 5, date, ifHideCalls)
					antihomeland = "[u]previously unknown terrorist organization, " + WorldData.Organizations[WorldData.Organizations[o].ConnectedTo[0]].Name + ", was discovered in connection the to movement[/u]"
		else:
			movDesc = ", not connected to terrorist organizations"
			if len(WorldData.Organizations[o].ConnectedTo) == 1:
				movDesc = ", connected to a terrorist organization (" + WorldData.Organizations[WorldData.Organizations[o].ConnectedTo[0]].Name + ")"
				WorldData.Organizations[WorldData.Organizations[o].ConnectedTo[0]].IntelValue += 20
				WorldData.Organizations[WorldData.Organizations[o].ConnectedTo[0]].IntelDescription.push_front("[b]"+date+"[/b] discovered connection to " + WorldData.Organizations[o].Name)
			elif len(WorldData.Organizations[o].ConnectedTo) > 1:
				var orgNames = []
				for y in WorldData.Organizations[o].ConnectedTo:
					orgNames.append(WorldData.Organizations[y].Name)
					WorldData.Organizations[y].IntelValue += 15
					WorldData.Organizations[y].IntelDescription.push_front("[b]"+date+"[/b] discovered connection to " + WorldData.Organizations[o].Name)
					if WorldData.Organizations[y].Known == false:
						WorldData.Organizations[y].Known = true
						GatherOnOrg(y, 5, date, ifHideCalls)
						antihomeland = "[u]previously unknown terrorist organization, " + WorldData.Organizations[y].Name + ", was discovered in connection the to movement[/u]"
				movDesc = ", connected to terrorist organizations (" + PoolStringArray(orgNames).join(", ") + ")"
		discreteDesc += movDesc
	############################################################################
	# wartime intel
	if WorldData.Organizations[o].Type == WorldData.OrgType.GOVERNMENT or WorldData.Organizations[o].Type == WorldData.OrgType.INTEL or WorldData.Organizations[o].Type == WorldData.OrgType.UNIVERSITY_OFFENSIVE:
		var whichC = WorldData.Organizations[o].Countries[0]
		if WorldData.Countries[whichC].InStateOfWar == true and WorldData.Countries[0].InStateOfWar == true:
			# dont assume conflict yet, be prepared for more complicated situations
			var conflict = -1
			for b in range(0, len(WorldData.Wars)):
				if WorldData.Wars[b].Active == false: continue
				if WorldData.Wars[b].CountryA != 0 and WorldData.Wars[b].CountryB != 0: continue
				if WorldData.Wars[b].CountryA != whichC and WorldData.Wars[b].CountryB != whichC: continue
				conflict = b
				break
			if conflict > -1:
				var howMuch = 5
				if WorldData.Organizations[o].Type == WorldData.OrgType.GOVERNMENT: howMuch += 10
				if WorldData.Wars[conflict].CountryA == 0: # positive is into homeland direction
					WorldData.Wars[conflict].Result += howMuch
				else:  # negative is our direction
					WorldData.Wars[conflict].Result -= howMuch
	############################################################################
	# new or not
	if len(WorldData.Organizations[o].IntelDescription) > 0:
		var first = WorldData.Organizations[o].IntelDescription[0].right(18)
		var second = antihomeland + "; " + discreteDesc
		if first == second:
			discreteDesc = "no new intel"
	############################################################################
	# result
	if len(antihomeland) > 0 and WorldData.Organizations[o].Type != WorldData.OrgType.COMPANY and WorldData.Organizations[o].Type != WorldData.OrgType.UNIVERSITY and WorldData.Organizations[o].Type != WorldData.OrgType.GOVERNMENT and WorldData.Organizations[o].Type != WorldData.OrgType.INTERNATIONAL:
		WorldData.Organizations[o].IntelDescription.push_front("[b]"+date+"[/b] " + antihomeland + "; " + discreteDesc)
	else:
		WorldData.Organizations[o].IntelDescription.push_front("[b]"+date+"[/b] " + discreteDesc)
	############################################################################
	# backing up after deception
	if credible == false:
		WorldData.Organizations[o].Staff = backup.Staff
		WorldData.Organizations[o].Budget = backup.Budget
		WorldData.Organizations[o].Counterintelligence = backup.Counterintelligence
		WorldData.Organizations[o].Type = backup.Type
		WorldData.Organizations[o].ActiveOpsAgainstHomeland = backup.ActiveOpsAgainstHomeland
		WorldData.Organizations[o].Technology = backup.Technology
	# finish
	return doesItEndWithCall

# Gathering intelligence information about organizations
func RecruitInOrg(o, quality, date):
	var desc = "[b]"+date+"[/b] "
	# difficulty is mainly determined by counterintelligence measures
	# this is compared against quality of operation and previous intel
	var counterHere = WorldData.Organizations[o].Counterintelligence + GameLogic.random.randi_range(-25,10)
	var approach = WorldData.Organizations[o].IntelValue + quality
	# pool of possible targets is also important
	if WorldData.Organizations[o].IntelIdentified < 5: approach *= 0.3
	elif WorldData.Organizations[o].IntelIdentified < 10: approach *= 0.5
	elif WorldData.Organizations[o].IntelIdentified < 20: approach *= 0.6
	elif WorldData.Organizations[o].IntelIdentified < 50: approach *= 0.8
	elif WorldData.Organizations[o].IntelIdentified < 100: approach *= 1.0
	elif WorldData.Organizations[o].IntelIdentified < 200: approach *= 1.1
	else: approach *= 1.2
	# final outcome
	if approach < counterHere:
		# failure
		WorldData.Organizations[o].IntelValue += 2
		return 0
	else:
		# success
		var levelOfSuccess = quality
		# one of how many..
		if WorldData.Organizations[o].Staff < 5: levelOfSuccess *= 3
		elif WorldData.Organizations[o].Staff < 10: levelOfSuccess *= 2
		elif WorldData.Organizations[o].Staff < 30: levelOfSuccess *= 1.5
		elif WorldData.Organizations[o].Staff < 100: levelOfSuccess *= 1.2
		elif WorldData.Organizations[o].Staff < 1000: levelOfSuccess *= 1.0
		elif WorldData.Organizations[o].Staff < 5000: levelOfSuccess *= 0.8
		else: levelOfSuccess *= 0.6
		if levelOfSuccess > 100: levelOfSuccess = 100
		# intel automatically rises thanks to the source
		# don't worry about it being too large, it decays 40% over a year
		WorldData.Organizations[o].IntelValue += levelOfSuccess * 0.4
		# noting source in org data
		WorldData.Organizations[o].IntelSources.append(
			{
				"Level": levelOfSuccess,
				"Trust": GameLogic.random.randi_range(5,25),
				"TurnedHowLong": 0,
				"TurnedByWho": "unknown organization",
			}
		)
		var wordLevel = "low"
		if levelOfSuccess > 70: wordLevel = "high"
		elif levelOfSuccess > 30: wordLevel = "medium"
		WorldData.Organizations[o].IntelDescription.push_front(desc + "a new "+wordLevel+"-level source acquired")
		# ensuring that some minimal intel is present
		if len(WorldData.Organizations[o].IntelDescription) == 1:
			GatherOnOrg(o, GameLogic.random.randi_range(5,15), date, false)
		# returning for user notification
		return levelOfSuccess

# External intelligence gathering inside our bureau and eventual consequences
func LeakBureauInfo(country, quality, sourceOrg, sourceOp):
	# covert travels and networks
	if quality < 20:
		WorldData.Countries[country].CovertTravelBlowup += 3
		WorldData.Countries[country].NetworkBlowup += 0.01*WorldData.Countries[country].Network
		if WorldData.Countries[country].NetworkBlowup > WorldData.Countries[country].Network:
			WorldData.Countries[country].NetworkBlowup = WorldData.Countries[country].Network
	elif quality < 50:
		WorldData.Countries[country].CovertTravelBlowup += 6
		WorldData.Countries[country].NetworkBlowup += 0.05*WorldData.Countries[country].Network
		if WorldData.Countries[country].NetworkBlowup > WorldData.Countries[country].Network:
			WorldData.Countries[country].NetworkBlowup = WorldData.Countries[country].Network
	elif quality < 80:
		WorldData.Countries[country].CovertTravelBlowup += 12
		WorldData.Countries[country].NetworkBlowup += 0.2*WorldData.Countries[country].Network
		if WorldData.Countries[country].NetworkBlowup > WorldData.Countries[country].Network:
			WorldData.Countries[country].NetworkBlowup = WorldData.Countries[country].Network
	else:
		WorldData.Countries[country].CovertTravelBlowup = WorldData.Countries[country].CovertTravel
		WorldData.Countries[country].NetworkBlowup = WorldData.Countries[country].Network
	# turning around sources in orgs in their country and their org
	if GameLogic.random.randi_range(20,100) < quality:
		for o in range(0, len(WorldData.Organizations)):
			if !(country in WorldData.Organizations[o].Countries): continue
			if len(WorldData.Organizations[o].IntelSources) == 0: continue
			if WorldData.Organizations[o].Type != WorldData.OrgType.COMPANY or WorldData.Organizations[o].Type != WorldData.OrgType.GOVERNMENT or WorldData.Organizations[o].Type != WorldData.OrgType.INTEL or WorldData.Organizations[o].Type != WorldData.OrgType.UNIVERSITY or WorldData.Organizations[o].Type != WorldData.OrgType.UNIVERSITY_OFFENSIVE: continue
			if GameLogic.random.randi_range(1,3) != 2: continue
			var chooseS = randi() % WorldData.Organizations[o].IntelSources.size()
			if WorldData.Organizations[o].IntelSources[chooseS].Level > 0:
				WorldData.Organizations[o].IntelSources[chooseS].Level *= -1
				WorldData.Organizations[o].IntelSources[chooseS].Level -= GameLogic.random.randi_range(0,15)
				WorldData.Organizations[o].IntelSources[chooseS].TurnedHowLong = 1
				WorldData.Organizations[o].IntelSources[chooseS].TurnedByWho = WorldData.Organizations[sourceOrg].Name
				WorldData.Organizations[sourceOrg].OpsAgainstHomeland[sourceOp].InvestigationData.TurnedSources += 1
