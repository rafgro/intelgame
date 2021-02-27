extends Node

# Gathering intelligence information about organizations
func GatherOnOrg(o, quality, date):
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
		}
		WorldData.Organizations[o].Staff *= (1.0+GameLogic.random.randi_range(-1,1)*0.1)
		WorldData.Organizations[o].Budget *= (1.0+GameLogic.random.randi_range(-1,1)*0.1)
		WorldData.Organizations[o].Counterintelligence *= (1.0+GameLogic.random.randi_range(-1,1)*0.1)
		if WorldData.Organizations[o].Type != WorldData.OrgType.GOVERNMENT and WorldData.Organizations[o].Type != WorldData.OrgType.INTEL:
			# do not change type of obvious organizations
			pass  # todo in the future, eg criminal showed as noncriminal
		if GameLogic.random.randi_range(1,2) == 2:
			WorldData.Organizations[o].ActiveOpsAgainstHomeland = 0
		else:
			WorldData.Organizations[o].ActiveOpsAgainstHomeland = GameLogic.random.randi_range(1,2)
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
		WorldData.Organizations[o].IntelValue += quality*theFactor
		if credible == false: WorldData.Organizations[o].IntelValue -= quality
		# individual members identified
		var infFactor = 0.001*quality  # eg, 30->0.03
		var newIdentified = int(WorldData.Organizations[o].Staff*1.0*infFactor)
		if newIdentified == 0 and quality > 20: newIdentified = 1
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
	############################################################################
	# discrete intel descriptions, four stages
	var discreteDesc = ""
	var indicatedOps = false  # used further to provide operation details
	if quality >= 0 and quality < 10:
		if WorldData.Organizations[o].Type == WorldData.OrgType.GENERALTERROR or WorldData.Organizations[o].Type == WorldData.OrgType.ARMTRADER:
			WorldData.Organizations[o].IntelDescType = "suspected criminal organization"
		var desc = ""
		if noOfIdentified > 0: desc += "identified " + str(noOfIdentified) + " individuals inside, "
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
		elif WorldData.Organizations[o].Type == WorldData.OrgType.ARMTRADER:
			WorldData.Organizations[o].IntelDescType = "criminal organization"
		# rounding example:
		# 12,000 * 0.0001 = 1.2 -> ~= 1 -> = 1 * 10,000 = 10,000
		var desc1 = ""
		if noOfIdentified > 0: desc1 += "identified " + str(noOfIdentified) + " individuals inside, "
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
		elif WorldData.Organizations[o].Type == WorldData.OrgType.ARMTRADER:
			WorldData.Organizations[o].IntelDescType = "arms trader"
		var desc1 = ""
		if noOfIdentified > 0: desc1 += "identified " + str(noOfIdentified) + " individuals inside, "
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
		discreteDesc = desc1 + "approximately " + roundedStaff + " members, budget of " + roundedBudget + " millions monthly, " + str(roundedCounter) + "/100 counterintelligence measures"
	############################################################################
	elif quality < 70:
		if WorldData.Organizations[o].Type == WorldData.OrgType.GENERALTERROR:
			WorldData.Organizations[o].IntelDescType = "terrorist organization"
		elif WorldData.Organizations[o].Type == WorldData.OrgType.ARMTRADER:
			WorldData.Organizations[o].IntelDescType = "arms trader"
		var desc1 = ""
		if noOfIdentified > 0: desc1 += "identified " + str(noOfIdentified) + " individuals inside, "
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
		discreteDesc = desc1 + "approximately " + roundedStaff + " members, budget of " + roundedBudget + " millions monthly, " + str(roundedCounter) + "/100 counterintelligence measures"
	############################################################################
	else:
		if WorldData.Organizations[o].Type == WorldData.OrgType.GENERALTERROR:
			WorldData.Organizations[o].IntelDescType = "terrorist organization"
		elif WorldData.Organizations[o].Type == WorldData.OrgType.ARMTRADER:
			WorldData.Organizations[o].IntelDescType = "arms trader"
		var desc1 = ""
		if noOfIdentified > 0: desc1 += "identified " + str(noOfIdentified) + " individuals inside, "
		desc1 += "current state of org: "
		var roundedStaff = str(int(WorldData.Organizations[o].Staff))
		var roundedBudget = "€"+str(int(WorldData.Organizations[o].Budget * 0.01))
		if roundedBudget == "€0": roundedBudget = "less than €1"
		var roundedCounter = WorldData.Organizations[o].Counterintelligence
		discreteDesc = desc1 + roundedStaff + " members, budget of " + roundedBudget + " millions monthly, " + str(roundedCounter) + "/100 counterintelligence measures"
	############################################################################
	# operation intel, both discrete descriptions and logic mechanics
	# TODO: UPDATE TO HANDLE DECEPTION
	# todo: update to handle postmortem investigations
	var antihomeland = ""
	if quality >= 10:
		var opDescriptions = []
		for z in range(0,len(WorldData.Organizations[o].OpsAgainstHomeland)):
			if WorldData.Organizations[o].OpsAgainstHomeland[z].Active == false:
				continue
			# most important logic change
			var pastIntel = WorldData.Organizations[o].OpsAgainstHomeland[z].IntelValue
			WorldData.Organizations[o].OpsAgainstHomeland[z].IntelValue += quality * ((100.0-WorldData.Organizations[o].OpsAgainstHomeland[z].Secrecy)*0.01)
			var newIntel = WorldData.Organizations[o].OpsAgainstHomeland[z].IntelValue
			# describing
			if newIntel < 20:
				var roundedD = WorldData.Organizations[o].OpsAgainstHomeland[z].FinishCounter/4 + GameLogic.random.randi_range(-2,2)
				if roundedD < 1: roundedD = 1
				opDescriptions.append("possible operation finishing in ~" + str(int(roundedD)) + " months")
			elif newIntel < 40:
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
				opDescriptions.append(damage + " " + theType + ", with " + WorldData.Organizations[o].OpsAgainstHomeland[z].Persons + " individuals involved" + knownInvolved + ", finishing in " + str(WorldData.Organizations[o].OpsAgainstHomeland[z].FinishCounter) + " weeks")
			# comparing significant intel change and notifying user if possible
			var diff = newIntel - pastIntel
			if diff >= 20:
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
		if quality < 20:
			antihomeland = "lack of knowledge about activity against Homeland"
			if WorldData.Organizations[o].ActiveOpsAgainstHomeland > 0:
				if GameLogic.random.randi_range(1,4) == 2:
					antihomeland = "[u]possible suspicious activity towards Homeland[/u]"
					antihomeland += " ([u]" + opDescriptions[randi() % opDescriptions.size()] + "[/u])"
		elif quality < 40:
			antihomeland = "probably no operations against Homeland"
			if WorldData.Organizations[o].ActiveOpsAgainstHomeland > 0:
				if GameLogic.random.randi_range(1,2) == 1:
					antihomeland = "[u]probably involved in operations against Homeland[/u]"
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
		if quality < 5:
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
				var ifAnyCall = GatherOnOrg(whichOrg, GameLogic.random.randi_range(10,WorldData. Organizations[whichOrg].Counterintelligence*0.5), date)  # counter as upper, since it's directly proportional to quality of the agency
				orgNames.append(WorldData.Organizations[whichOrg].Name)
				if ifAnyCall == true: doesItEndWithCall = true
			if len(orgNames) > 0:
				discreteDesc += ", in addition officers tapped into intel gathered by this agency about " + PoolStringArray(orgNames).join(", ")
	############################################################################
	# organization-type-specific intels
	elif WorldData.Organizations[o].Type == WorldData.OrgType.COMPANY or WorldData.Organizations[o].Type == WorldData.OrgType.UNIVERSITY:
		var techDesc = ""
		if quality < 5:
			pass  # not enough
		elif quality < 20:
			techDesc = ", probably no interesting technology"
			if WorldData.Organizations[o].Technology > 50 and GameLogic.random.randi_range(1,2) == 1:
				techDesc = ", potentially interesting technology"
		elif quality < 40:
			if WorldData.Organizations[o].Technology < 30:
				techDesc = ", no interesting technology"
			elif WorldData.Organizations[o].Technology < 60:
				techDesc = ", some technological details acquired"
			else:
				techDesc = ", interesting technological details acquired"
		elif quality < 75:
			if WorldData.Organizations[o].Technology < 30:
				techDesc = ", no interesting technology"
			elif WorldData.Organizations[o].Technology < 60:
				techDesc = ", technological documents acquired"
			else:
				techDesc = ", interesting technological documents acquired"
		else:
			if WorldData.Organizations[o].Technology < 30:
				techDesc = ", no valuable technology"
			elif WorldData.Organizations[o].Technology < 60:
				techDesc = ", valuable technological documents acquired"
			else:
				techDesc = ", significantly valuable technological documents acquired"
		discreteDesc += techDesc
	############################################################################
	# result
	if len(antihomeland) > 0 and WorldData.Organizations[o].Type != WorldData.OrgType.COMPANY and WorldData.Organizations[o].Type != WorldData.OrgType.UNIVERSITY:
		WorldData.Organizations[o].IntelDescription.push_front("[b]"+date+"[/b] " + antihomeland + ", " + discreteDesc)
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
			}
		)
		var wordLevel = "low"
		if levelOfSuccess > 70: wordLevel = "high"
		elif levelOfSuccess > 30: wordLevel = "medium"
		WorldData.Organizations[o].IntelDescription.push_front(desc + "a new "+wordLevel+"-level source acquired")
		# ensuring that some minimal intel is present
		if len(WorldData.Organizations[o].IntelDescription) == 1:
			GatherOnOrg(o, GameLogic.random.randi_range(5,15), date)
		# returning for user notification
		return levelOfSuccess
