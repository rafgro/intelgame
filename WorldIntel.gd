extends Node

# Gathering intelligence information about organizations
func GatherOnOrg(o, quality, date):
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
	var desc = "[b]"+date+"[/b] "
	# continuous intel value
	var noOfIdentified = 0
	if quality > WorldData.Organizations[o].IntelValue:
		# general intel value
		WorldData.Organizations[o].IntelValue += quality*0.5
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
	# general intel description for the user
	if WorldData.Organizations[o].Type == WorldData.OrgType.INTEL:
		WorldData.Organizations[o].IntelDescType = "intelligence agency"
	elif WorldData.Organizations[o].Type == WorldData.OrgType.GOVERNMENT:
		WorldData.Organizations[o].IntelDescType = "official government"
	# discrete intel descriptions, four stages
	if quality >= 0 and quality < 10:
		if WorldData.Organizations[o].Type == WorldData.OrgType.GENERALTERROR or WorldData.Organizations[o].Type == WorldData.OrgType.ARMTRADER or WorldData.Organizations[o].Type == WorldData.OrgType.PARAMILITARY:
			WorldData.Organizations[o].IntelDescType = "suspected criminal organization"
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
		WorldData.Organizations[o].IntelDescription.push_front(desc)
	elif quality < 30:
		if WorldData.Organizations[o].Type == WorldData.OrgType.GENERALTERROR or WorldData.Organizations[o].Type == WorldData.OrgType.PARAMILITARY:
			WorldData.Organizations[o].IntelDescType = "terrorist organization"
		elif WorldData.Organizations[o].Type == WorldData.OrgType.ARMTRADER:
			WorldData.Organizations[o].IntelDescType = "criminal organization"
		# rounding example:
		# 12,000 * 0.0001 = 1.2 -> ~= 1 -> = 1 * 10,000 = 10,000
		var antihomeland = "no knowledge of activity against Homeland"
		if WorldData.Organizations[o].ActiveOpsAgainstHomeland > 0:
			if GameLogic.random.randi_range(1,4) == 2:
				antihomeland = "[u]possible suspicious activity towards Homeland[/u]"
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
		WorldData.Organizations[o].IntelDescription.push_front(desc + antihomeland + ", " + desc1 + "approximately " + roundedStaff + " members, budget of " + roundedBudget + " millions monthly, " + counter + " counterintelligence measures")
	elif quality < 50:
		if WorldData.Organizations[o].Type == WorldData.OrgType.GENERALTERROR:
			WorldData.Organizations[o].IntelDescType = "terrorist organization"
		elif WorldData.Organizations[o].Type == WorldData.OrgType.PARAMILITARY:
			WorldData.Organizations[o].IntelDescType = "paramilitary organization"
		elif WorldData.Organizations[o].Type == WorldData.OrgType.ARMTRADER:
			WorldData.Organizations[o].IntelDescType = "arms trader"
		var antihomeland = "probably no operations against Homeland"
		if WorldData.Organizations[o].ActiveOpsAgainstHomeland > 0:
			if GameLogic.random.randi_range(1,2) == 1:
				antihomeland = "[u]probably involved in operations against Homeland[/u]"
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
		WorldData.Organizations[o].IntelDescription.push_front(desc + antihomeland + ", " + desc1 + "approximately " + roundedStaff + " members, budget of " + roundedBudget + " millions monthly, " + str(roundedCounter) + "/100 counterintelligence measures")
	elif quality < 70:
		if WorldData.Organizations[o].Type == WorldData.OrgType.GENERALTERROR:
			WorldData.Organizations[o].IntelDescType = "terrorist organization"
		elif WorldData.Organizations[o].Type == WorldData.OrgType.PARAMILITARY:
			WorldData.Organizations[o].IntelDescType = "paramilitary organization"
		elif WorldData.Organizations[o].Type == WorldData.OrgType.ARMTRADER:
			WorldData.Organizations[o].IntelDescType = "arms trader"
		var antihomeland = "no operations against Homeland"
		if WorldData.Organizations[o].ActiveOpsAgainstHomeland > 0:
			antihomeland = "[u]executes operations against Homeland[/u]"
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
		WorldData.Organizations[o].IntelDescription.push_front(desc + antihomeland + ", " + desc1 + "approximately " + roundedStaff + " members, budget of " + roundedBudget + " millions monthly, " + str(roundedCounter) + "/100 counterintelligence measures")
	else:
		if WorldData.Organizations[o].Type == WorldData.OrgType.GENERALTERROR:
			WorldData.Organizations[o].IntelDescType = "terrorist organization"
		elif WorldData.Organizations[o].Type == WorldData.OrgType.PARAMILITARY:
			WorldData.Organizations[o].IntelDescType = "paramilitary organization"
		elif WorldData.Organizations[o].Type == WorldData.OrgType.ARMTRADER:
			WorldData.Organizations[o].IntelDescType = "arms trader"
		var antihomeland = "no operations against Homeland"
		if WorldData.Organizations[o].ActiveOpsAgainstHomeland > 0:
			antihomeland = "[u]executes " +str(WorldData.Organizations[o].ActiveOpsAgainstHomeland)+ " operations against Homeland[/u]"
		var desc1 = ""
		if noOfIdentified > 0: desc1 += "identified " + str(noOfIdentified) + " individuals inside, "
		desc1 += "current state of org: "
		var roundedStaff = str(WorldData.Organizations[o].Staff)
		var roundedBudget = "€"+str(int(WorldData.Organizations[o].Budget * 0.01))
		if roundedBudget == "€0": roundedBudget = "less than €1"
		var roundedCounter = WorldData.Organizations[o].Counterintelligence
		WorldData.Organizations[o].IntelDescription.push_front(desc + antihomeland + ", " + desc1 + roundedStaff + " members, budget of " + roundedBudget + " millions monthly, " + str(roundedCounter) + "/100 counterintelligence measures")
	# backing up after deception
	if credible == false:
		WorldData.Organizations[o].Staff = backup.Staff
		WorldData.Organizations[o].Budget = backup.Budget
		WorldData.Organizations[o].Counterintelligence = backup.Counterintelligence
		WorldData.Organizations[o].Type = backup.Type
		WorldData.Organizations[o].ActiveOpsAgainstHomeland = backup.ActiveOpsAgainstHomeland

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
		WorldData.Organizations[o].IntelDescription.push_front(desc + " a new "+wordLevel+"-level source acquired")
		# returning for user notification
		return levelOfSuccess
