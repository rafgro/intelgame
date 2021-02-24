extends Node

# Gathering intelligence information about organizations
func GatherOnOrg(o, quality, date):
	var desc = "[b]"+date+"[/b] "
	if WorldData.Organizations[o].Type == WorldData.OrgType.INTEL:
		# continuous intel value
		if quality > WorldData.Organizations[o].IntelValue:
			WorldData.Organizations[o].IntelValue += quality*0.5
		else:
			WorldData.Organizations[o].IntelValue += 1
		# discrete intel descriptions
		if quality >= 0 and quality < 10:
			if WorldData.Organizations[o].Staff < 5000: desc += "small number of officers"
			elif WorldData.Organizations[o].Staff < 15000: desc += "medium number of officers"
			elif WorldData.Organizations[o].Staff < 30000: desc += "large number of officers"
			else: desc += "huge number of officers"
			if WorldData.Organizations[o].Budget < 30000: desc += ", small budget"
			elif WorldData.Organizations[o].Budget < 500000: desc += ", medium budget"
			elif WorldData.Organizations[o].Budget < 1000000: desc += ", large budget"
			else: desc += ", huge budget"
			WorldData.Organizations[o].IntelDescription.push_front(desc)
		else:
			WorldData.Organizations[o].IntelDescription.push_front("placeholder for deeper intel")
