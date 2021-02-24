extends Node

# Gathering intelligence information about organizations
func GatherOnOrg(o, quality, date):
	var desc = "[b]"+date+"[/b] "
	# continuous intel value
	if quality > WorldData.Organizations[o].IntelValue:
		WorldData.Organizations[o].IntelValue += quality*0.5
	else:
		WorldData.Organizations[o].IntelValue += 1
	# discrete intel descriptions, four stages
	if quality >= 0 and quality < 10:
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
		# rounding example:
		# 12,000 * 0.0001 = 1.2 -> ~= 1 -> = 1 * 10,000 = 10,000
		var antihomeland = "no knowledge of activity against Homeland, "
		if len(WorldData.Organizations[o].OpsAgainstHomeland) > 0:
			if GameLogic.random.randi_range(1,4) == 2:
				antihomeland = "[u]possible suspicious activity towards Homeland[/u]"
		var roundedStaff = str(int(WorldData.Organizations[o].Staff * 0.0001) * 10000)
		if roundedStaff == 0:
			if WorldData.Organizations[o].Staff < 50: roundedStaff = "less than 50"
			elif WorldData.Organizations[o].Staff < 500: roundedStaff = "50-500"
			else: roundedStaff = "500-5000"
		var roundedBudget = "€" + str(int(WorldData.Organizations[o].Budget * 0.00001) * 1000)
		if roundedBudget == 0: roundedBudget = "less than €1000"
		var counter = "non-existent"
		if WorldData.Organizations[o].Counterintelligence > 90: counter = "extreme"
		elif WorldData.Organizations[o].Counterintelligence > 70: counter = "significant"
		elif WorldData.Organizations[o].Counterintelligence > 50: counter = "medium"
		elif WorldData.Organizations[o].Counterintelligence > 20: counter = "weak"
		WorldData.Organizations[o].IntelDescription.push_front(antihomeland + "; approximately " + roundedStaff + " members, budget of " + roundedBudget + " millions monthly, " + counter + " counterintelligence measures")
	elif quality < 50:
		var antihomeland = "probably no operations against Homeland, "
		if len(WorldData.Organizations[o].OpsAgainstHomeland) > 0:
			if GameLogic.random.randi_range(1,2) == 1:
				antihomeland = "[u]probably involved in operations against Homeland[/u]"
		var roundedStaff = str(int(WorldData.Organizations[o].Staff * 0.001) * 1000)
		if roundedStaff == 0:
			if WorldData.Organizations[o].Staff < 10: roundedStaff = "less than 10"
			elif WorldData.Organizations[o].Staff < 100: roundedStaff = "10-100"
			elif WorldData.Organizations[o].Staff < 500: roundedStaff = "100-500"
			else: roundedStaff = "500-1000"
		var roundedBudget = "€"+str(int(WorldData.Organizations[o].Budget * 0.001) * 10)
		if roundedBudget == 0: roundedBudget = "less than €10"
		var roundedCounter = int(WorldData.Organizations[o].Counterintelligence * 0.1) * 10
		WorldData.Organizations[o].IntelDescription.push_front(antihomeland + "; approximately " + roundedStaff + " members, budget of " + roundedBudget + " millions monthly, " + str(roundedCounter) + "/100 counterintelligence measures")
	elif quality < 70:
		var antihomeland = "no operations against Homeland, "
		if len(WorldData.Organizations[o].OpsAgainstHomeland) > 0:
			antihomeland = "[u]executes operations against Homeland[/u]"
		var roundedStaff = str(int(WorldData.Organizations[o].Staff * 0.01) * 100)
		if roundedStaff == 0:
			if WorldData.Organizations[o].Staff < 5: roundedStaff = "less than 5"
			elif WorldData.Organizations[o].Staff < 15: roundedStaff = "5-15"
			elif WorldData.Organizations[o].Staff < 60: roundedStaff = "15-60"
			else: roundedStaff = "60-100"
		var roundedBudget = "€"+str(int(WorldData.Organizations[o].Budget * 0.01))
		if roundedBudget == 0: roundedBudget = "less than €1"
		var roundedCounter = WorldData.Organizations[o].Counterintelligence
		WorldData.Organizations[o].IntelDescription.push_front(antihomeland + "; approximately " + roundedStaff + " members, budget of " + roundedBudget + " millions monthly, " + str(roundedCounter) + "/100 counterintelligence measures")
	else:
		var antihomeland = "no operations against Homeland, "
		if len(WorldData.Organizations[o].OpsAgainstHomeland) > 0:
			antihomeland = "[u]executes " +str(len(WorldData.Organizations[o].OpsAgainstHomeland))+ " operations against Homeland[/u]"
		var roundedStaff = str(WorldData.Organizations[o].Staff)
		var roundedBudget = "€"+str(int(WorldData.Organizations[o].Budget * 0.01))
		if roundedBudget == 0: roundedBudget = "less than €1"
		var roundedCounter = WorldData.Organizations[o].Counterintelligence
		WorldData.Organizations[o].IntelDescription.push_front(antihomeland + "; " + roundedStaff + " members, budget of " + roundedBudget + " millions monthly, " + str(roundedCounter) + "/100 counterintelligence measures")
