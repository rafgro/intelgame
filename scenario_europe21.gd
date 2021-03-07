extends Node

var PossibleCountries = [
	WorldData.aNewCountry({ "Name": "Ireland", "Adjective": "Irish", "TravelCost": 1, "LocalCost": 1, "IntelFriendliness": 90, "Size": 5, "ElectionPeriod": 52*5, "ElectionProgress": 52*4.1, "SoftPower": 40, }),
	WorldData.aNewCountry({ "Name": "United Kingdom", "Adjective": "British", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 40, "Size": 67, "ElectionPeriod": 52*5, "ElectionProgress": 52*3.4, "SoftPower": 90, }),
	WorldData.aNewCountry({ "Name": "Belgium", "Adjective": "Belgian", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 80, "Size": 11, "ElectionPeriod": 52*5,  "ElectionProgress": 52*3.5, "SoftPower": 50, }),
	WorldData.aNewCountry({ "Name": "Germany", "Adjective": "German", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 60, "Size": 83, "ElectionPeriod": 52*4, "ElectionProgress": 7*4*10, "SoftPower": 80, }),
	WorldData.aNewCountry({ "Name": "United States", "Adjective": "American", "TravelCost": 3, "LocalCost": 2, "IntelFriendliness": 30, "Size": 328, "ElectionPeriod": 52*5, "ElectionProgress": 52*4.8, "SoftPower": 95, }),
	WorldData.aNewCountry({ "Name": "France", "Adjective": "French", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 40, "Size": 67, "ElectionPeriod": 52*5, "ElectionProgress": 52*1.4, "SoftPower": 75, }),
	WorldData.aNewCountry({ "Name": "Russia", "Adjective": "Russian", "TravelCost": 3, "LocalCost": 1, "IntelFriendliness": 30, "Size": 144, "ElectionPeriod": 52*20, "ElectionProgress": 52*15, "SoftPower": 80, }),
	WorldData.aNewCountry({ "Name": "China", "Adjective": "Chinese", "TravelCost": 5, "LocalCost": 2, "IntelFriendliness": 20, "Size": 1398, "ElectionPeriod": 52*20, "ElectionProgress": 52*19, "SoftPower": 95, }),
	WorldData.aNewCountry({ "Name": "Israel", "Adjective": "Israeli", "TravelCost": 3, "LocalCost": 2, "IntelFriendliness": 30, "Size": 9, "ElectionPeriod": 52*4, "ElectionProgress": 7*4*3, "SoftPower": 80, }),
	WorldData.aNewCountry({ "Name": "Spain", "Adjective": "Spanish", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 60, "Size": 47, "ElectionPeriod": 52*4, "ElectionProgress": 52*2.4, "SoftPower": 60, }),
	WorldData.aNewCountry({ "Name": "Italy", "Adjective": "Italian", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 55, "Size": 60, "ElectionPeriod": 52*5, "ElectionProgress": 52*2.5, "SoftPower": 60, }),
	WorldData.aNewCountry({ "Name": "Switzerland", "Adjective": "Swiss", "TravelCost": 2, "LocalCost": 3, "IntelFriendliness": 65, "Size": 9, "ElectionPeriod": 52*4, "ElectionProgress": 52*2.8, "SoftPower": 70, }),
]

func CreateAdHocOrgs():
	# solves problem of various country ids
	for c in range(0, len(WorldData.Countries)):
		if WorldData.Countries[c].Name == "Belgium":
			WorldData.Organizations.append(
				WorldData.aNewOrganization({ "Type": WorldData.OrgType.INTERNATIONAL, "Name": "European Parliament", "Fixed": true, "Known": true, "Staff": 7500, "Budget": 100000, "Counterintelligence": 60, "Aggression": 30, "Countries": [c], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [1], })
			)
			WorldData.Organizations.append(
				WorldData.aNewOrganization({ "Type": WorldData.OrgType.INTERNATIONAL, "Name": "NATO HQ", "Fixed": true, "Known": true, "Staff": 3800, "Budget": 500, "Counterintelligence": 80, "Aggression": 80, "Countries": [c], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [1], })
			)
		elif WorldData.Countries[c].Name == "United States":
			WorldData.Organizations.append(
				WorldData.aNewOrganization({ "Type": WorldData.OrgType.INTERNATIONAL, "Name": "United Nations", "Fixed": true, "Known": true, "Staff": 26400, "Budget": 100000, "Counterintelligence": 50, "Aggression": 10, "Countries": [c], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [1], })
			)
			WorldData.Organizations.append(
				WorldData.aNewOrganization({ "Type": WorldData.OrgType.INTERNATIONAL, "Name": "IMF", "Fixed": true, "Known": true, "Staff": 2400, "Budget": 1000000, "Counterintelligence": 40, "Aggression": 10, "Countries": [c], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [1], })
			)
			WorldData.Organizations.append(
				WorldData.aNewOrganization({ "Type": WorldData.OrgType.INTERNATIONAL, "Name": "World Bank", "Fixed": true, "Known": true, "Staff": 500, "Budget": 1000000, "Counterintelligence": 40, "Aggression": 10, "Countries": [c], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [1], })
			)
		elif WorldData.Countries[c].Name == "Switzerland":
			WorldData.Organizations.append(
				WorldData.aNewOrganization({ "Type": WorldData.OrgType.INTERNATIONAL, "Name": "WTO", "Fixed": true, "Known": true, "Staff": 600, "Budget": 10000, "Counterintelligence": 30, "Aggression": 10, "Countries": [c], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [1], })
			)
		elif WorldData.Countries[c].Name == "France":
			WorldData.Organizations.append(
				WorldData.aNewOrganization({ "Type": WorldData.OrgType.INTERNATIONAL, "Name": "Interpol", "Fixed": true, "Known": true, "Staff": 1000, "Budget": 5000, "Counterintelligence": 70, "Aggression": 60, "Countries": [c], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [1], })
			)
		elif WorldData.Countries[c].Name == "Netherlands":
			WorldData.Organizations.append(
				WorldData.aNewOrganization({ "Type": WorldData.OrgType.INTERNATIONAL, "Name": "OPCW", "Fixed": true, "Known": true, "Staff": 500, "Budget": 5000, "Counterintelligence": 50, "Aggression": 30, "Countries": [c], "IntelValue": 0, "TargetConsistency": 0, "TargetCountries": [1], })
			)

func ReturnCountries():
	return null
