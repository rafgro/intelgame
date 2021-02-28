extends Node

class ACountry:
	var Name = null
	var Adjective = null
	var TravelCost = 0  # cost of getting there for one person
	var LocalCost = 0  # weekly base cost of one person operation
	var IntelFriendliness = 100  # towards all operations, 0 to 100
	var Size = 2 # population in millions
	var ElectionPeriod = 52*4  # almost-fixed weeks of governance
	# generated below
	var ElectionProgress = 52*4  # counter to the next election
	var PoliticsIntel = 50  # attitude towards own intel agency, 0 to 100
	var PoliticsAggression = 0  # attitude towards other countries, 0 to 100
	var PoliticsStability = 50  # risk of wrong decisions or earlier elections, 0 to 100
	var SoftPower = 0  # 0 to 100, currently defines technology
	# direction-related variables
	var Expelled = 0  # how many officers are persona non grata
	var DiplomaticTravel = true  # if officers can travel officially
	var CovertTravel = 50  # 0 (unavailable) to 100 (easy to conduct)
	var OperationStats = 0  # how many operations performed here
	var KnowhowLanguage = 0  # 0 (no knowledge) to 100 (native)
	var KnowhowCustoms = 10  # 0 (no knowledge) to 100 (native)
	var Network = 0  # number of members in a local asset network, supporting ops
	var Station = 0  # number of employees in a local station, supporting ops
	
	func _init(aDictionary):
		Name = aDictionary.Name
		Adjective = aDictionary.Adjective
		TravelCost = aDictionary.TravelCost
		LocalCost = aDictionary.LocalCost
		IntelFriendliness = aDictionary.IntelFriendliness
		Size = aDictionary.Size
		ElectionPeriod = aDictionary.ElectionPeriod
		ElectionProgress = aDictionary.ElectionProgress
		SoftPower = aDictionary.SoftPower

# All rough locations, usually countries, separated by costs and difficulty
var Countries = [
	ACountry.new({
		"Name": "Homeland",
		"Adjective": "Our",
		"TravelCost": 0,  # cost of getting there for one person
		"LocalCost": 0,  # weekly base cost of one person operation
		"IntelFriendliness": 100,  # towards all operations, 0 to 100
		"Size": 2, # population in millions
		"ElectionPeriod": 52*4,  # almost-fixed weeks of governance
		"ElectionProgress": 52*4,  # counter to the next election
		"SoftPower": GameLogic.random.randi_range(30,70),
	}),
	ACountry.new({ "Name": "Ireland", "Adjective": "Irish", "TravelCost": 1, "LocalCost": 1, "IntelFriendliness": 90, "Size": 5, "ElectionPeriod": 52*4, "ElectionProgress": GameLogic.random.randi_range(1,50*4), "SoftPower": GameLogic.random.randi_range(30,70), }),
	ACountry.new({ "Name": "United Kingdom", "Adjective": "British", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 40, "Size": 67, "ElectionPeriod": 52*4, "ElectionProgress": GameLogic.random.randi_range(1,50*4), "SoftPower": GameLogic.random.randi_range(50,100), }),
	ACountry.new({ "Name": "Belgium", "Adjective": "Belgian", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 80, "Size": 11, "ElectionPeriod": 52*4,  "ElectionProgress": GameLogic.random.randi_range(1,50*4), "SoftPower": GameLogic.random.randi_range(30,70), }),
	ACountry.new({ "Name": "Germany", "Adjective": "German", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 50, "Size": 83, "ElectionPeriod": 52*4, "ElectionProgress": GameLogic.random.randi_range(1,50*4), "SoftPower": GameLogic.random.randi_range(60,90), }),
	ACountry.new({ "Name": "United States", "Adjective": "American", "TravelCost": 3, "LocalCost": 2, "IntelFriendliness": 30, "Size": 328, "ElectionPeriod": 52*4, "ElectionProgress": GameLogic.random.randi_range(1,50*4), "SoftPower": GameLogic.random.randi_range(70,100), }),
	ACountry.new({ "Name": "Poland", "Adjective": "Polish", "TravelCost": 1, "LocalCost": 1, "IntelFriendliness": 60, "Size": 38, "ElectionPeriod": 52*4, "ElectionProgress": GameLogic.random.randi_range(1,50*4), "SoftPower": GameLogic.random.randi_range(30,70), }),
	ACountry.new({ "Name": "France", "Adjective": "French", "TravelCost": 1, "LocalCost": 2, "IntelFriendliness": 40, "Size": 67, "ElectionPeriod": 52*4, "ElectionProgress": GameLogic.random.randi_range(1,50*4), "SoftPower": GameLogic.random.randi_range(30,70), }),
	ACountry.new({ "Name": "Russia", "Adjective": "Russian", "TravelCost": 3, "LocalCost": 1, "IntelFriendliness": 30, "Size": 144, "ElectionPeriod": 52*10, "ElectionProgress": GameLogic.random.randi_range(50*5,50*10), "SoftPower": GameLogic.random.randi_range(10,50), }),
	ACountry.new({ "Name": "China", "Adjective": "Chinese", "TravelCost": 5, "LocalCost": 2, "IntelFriendliness": 20, "Size": 1398, "ElectionPeriod": 52*20, "ElectionProgress": GameLogic.random.randi_range(50*10,50*20), "SoftPower": GameLogic.random.randi_range(60,95), }),
	ACountry.new({ "Name": "Israel", "Adjective": "Israeli", "TravelCost": 3, "LocalCost": 2, "IntelFriendliness": 30, "Size": 9, "ElectionPeriod": 52*4, "ElectionProgress": GameLogic.random.randi_range(1,50*4), "SoftPower": GameLogic.random.randi_range(50,90), }),
	ACountry.new({ "Name": "Turkey", "Adjective": "Turkish", "TravelCost": 2, "LocalCost": 1, "IntelFriendliness": 50, "Size": 84, "ElectionPeriod": 52*10, "ElectionProgress": GameLogic.random.randi_range(1,50*10), "SoftPower": GameLogic.random.randi_range(30,70), }),
	ACountry.new({ "Name": "Iraq", "Adjective": "Iraqi", "TravelCost": 3, "LocalCost": 1, "IntelFriendliness": 40, "Size": 40, "ElectionPeriod": 52*4, "ElectionProgress": GameLogic.random.randi_range(1,50*4), "SoftPower": GameLogic.random.randi_range(2,20), }),
	ACountry.new({ "Name": "Afghanistan", "Adjective": "Afghan", "TravelCost": 3, "LocalCost": 1, "IntelFriendliness": 60, "Size": 38, "ElectionPeriod": 52*4, "ElectionProgress": GameLogic.random.randi_range(1,50*4), "SoftPower": GameLogic.random.randi_range(2,10), }),
]

# Intercountry relations, 2d array
var DiplomaticRelations = []

# Basic list of organizations, modified and generated additionally later
enum OrgType {
	GOVERNMENT,
	INTEL,
	GENERALTERROR,
	ARMTRADER,
	COMPANY,
	UNIVERSITY,
}

class AnOrganization:
	var Active = true  # instead of removing, just inactivating organizations
	var Type = OrgType.INTEL
	var Name = null
	var Fixed = true  # cannot delete if true, mainly for intel agencies
	var Known = true  # false for hidden criminal organizations
	var Staff = 0  # number of human members
	var Budget = 0  # monthly in thousands
	var Counterintelligence = 0  # from 0 (get in from the street) to 100 (impossible to infiltrate)
	var Aggression = 0  # from 0 (university) to 100 (isis), when officers caught or ops performed
	var Countries = null  # ids of host countries
	# generated and/or frequently modified
	var ActiveOpsAgainstHomeland = 0  # counter to avoid browsing the array below
	var OpsAgainstHomeland = []  # objects of AnExternalOperation
	var IntelDescription = []  # just for user display, sort of log: date - desc, many times
	var IntelDescType = ""  # just for user display, showed over list of gathered intels
	var IntelIdentified = 0  # number of identified members for possible recruitment
	var IntelValue = 0  # -100 (long search) to 100 (own), determines available methods
	var IntelSources = []  # arr of dicts {"Level","Trust"}
	var UndercoverCounter = 0  # weeks with known=false, subtracted 1 every week
	var OffensiveClearance = false  # gov-given clearance for using offensive methods
	var Technology = 0  # for companies and universities only, 0 to 100
	var IntelTechnology = 0  # updated with previous discovered technology, for discovering new one
	
	func _init(adictionary):
		Type = adictionary.Type
		Name = adictionary.Name
		Fixed = adictionary.Fixed
		Known = adictionary.Known
		Staff = adictionary.Staff
		Budget = adictionary.Budget
		Counterintelligence = adictionary.Counterintelligence
		Aggression = adictionary.Aggression
		Countries = adictionary.Countries.duplicate(true)
		IntelValue = adictionary.IntelValue

var Organizations = [
	AnOrganization.new({
		"Type": OrgType.INTEL,
		"Name": "MI6",
		"Fixed": true,  # cannot delete if true, mainly for intel agencies
		"Known": true,  # false for hidden criminal organizations
		"Staff": 2600,  # number of human members
		"Budget": 260000,  # monthly in thousands
		"Counterintelligence": 95,  # from 0 (get in from the street) to 100 (impossible to infiltrate)
		"Aggression": 65,
		"Countries": [2],  # ids of host countries
		"IntelValue": 5,  # -100 (long search) to 100 (own), determines available methods
	}),
	AnOrganization.new({ "Type": OrgType.INTEL, "Name": "BND", "Fixed": true, "Known": true, "Staff": 6500, "Budget": 85000, "Counterintelligence": 90, "Aggression": 70, "Countries": [4], "IntelValue": 5, }),
	AnOrganization.new({ "Type": OrgType.INTEL, "Name": "CIA", "Fixed": true, "Known": true, "Staff": 22000, "Budget": 1250000, "Counterintelligence": 95, "Aggression": 75, "Countries": [5], "IntelValue": 5, }),
	AnOrganization.new({ "Type": OrgType.INTEL, "Name": "AW (Agencja Wywiadu)", "Fixed": true, "Known": true, "Staff": 1000, "Budget": 20800, "Counterintelligence": 80, "Aggression": 70, "Countries": [6], "IntelValue": 5, }),
	AnOrganization.new({ "Type": OrgType.INTEL, "Name": "DGSE", "Fixed": true, "Known": true, "Staff": 6100, "Budget": 42000, "Counterintelligence": 95, "Aggression": 75, "Countries": [7], "IntelValue": 5, }),
	AnOrganization.new({ "Type": OrgType.INTEL, "Name": "ФСБ (FSB)", "Fixed": true, "Known": true, "Staff": 66200, "Budget": 1000000, "Counterintelligence": 95, "Aggression": 80, "Countries": [8], "IntelValue": 5, }),
	AnOrganization.new({ "Type": OrgType.INTEL, "Name": "Guoanbu", "Fixed": true, "Known": true, "Staff": 100000, "Budget": 2000000, "Counterintelligence": 98, "Aggression": 80, "Countries": [9],  "IntelValue": 5, }),
	AnOrganization.new({ "Type": OrgType.INTEL, "Name": "Mossad", "Fixed": true, "Known": true, "Staff": 7000, "Budget": 228000, "Counterintelligence": 98, "Aggression": 85, "Countries": [10], "IntelValue": 5, }),
	AnOrganization.new({ "Type": OrgType.INTEL, "Name": "MIT (Milli Istihbarat Teskilati)", "Fixed": true, "Known": true, "Staff": 8000, "Budget": 180000, "Counterintelligence": 90, "Aggression": 80, "Countries": [11], "IntelValue": 5, }),
	AnOrganization.new({ "Type": OrgType.INTEL, "Name": "Mukhabarat", "Fixed": true, "Known": true, "Staff": 4000, "Budget": 20000, "Counterintelligence": 85, "Aggression": 80, "Countries": [12], "IntelValue": 5, }),
	AnOrganization.new({ "Type": OrgType.INTEL, "Name": "NDS", "Fixed": true, "Known": true, "Staff": 3000, "Budget": 10000, "Counterintelligence": 80, "Aggression": 70, "Countries": [13], "IntelValue": 5, }),
	AnOrganization.new({ "Type": OrgType.GENERALTERROR, "Name": "Islamic State", "Fixed": false, "Known": true, "Staff": 5500, "Budget": 25000, "Counterintelligence": 50, "Aggression": 90, "Countries": [12,13], "IntelValue": 0, }),
]

class AMethod:
	var Name = null
	var Cost = 0  # weekly
	var Quality = 0  # from 0 (useless) to 100 (perfect theft)
	var Risk = 0  # from 0 (hacking) to 100 (shooting), given well working counterintelligence
	var OfficersRequired = 0  # how many must be involved in operation
	var MinimalSkill = 0  # minimal average skill to permit this method
	var Available = false  # automatically controlled and set by the game
	var MinimalIntel = 0  # minimal intel level about a target to use this method
	var MinimalTrust = 0  # minimal government trust level to use this method
	var MinimalTech = 0  # minimal technology score to use this method
	var MinimalLocal = 0  # 0 (no role of local skills) to 100 (perfect language and customs required)
	
	func _init(aDictionary):
		Name = aDictionary.Name
		Cost = aDictionary.Cost
		Quality = aDictionary.Quality
		Risk = aDictionary.Risk
		OfficersRequired = aDictionary.OfficersRequired
		MinimalSkill = aDictionary.MinimalSkill
		Available = aDictionary.Available
		MinimalIntel = aDictionary.MinimalIntel
		MinimalTrust = aDictionary.MinimalTrust
		MinimalTech = aDictionary.MinimalTech
		MinimalLocal = aDictionary.MinimalLocal

class AMethodOffensive:  # in future change to inheritance or something
	# difference to normal methods: offensive ones are exclusive
	# plus quality is regarded as a probability/luck factor
	# whereas other, precise parameters define actual outcome
	var Name = null
	var Cost = 0  # weekly
	var Quality = 0  # from 0 (useless) to 100 (perfect theft)
	var Risk = 0  # from 0 (hacking) to 100 (shooting), given well working counterintelligence
	var OfficersRequired = 0  # how many must be involved in operation
	var MinimalSkill = 0  # minimal average skill to permit this method
	var Available = false  # automatically controlled and set by the game
	var MinimalIntel = 0  # minimal intel level about a target to use this method
	var MinimalTrust = 0  # minimal government trust level to use this method
	var MinimalTech = 0  # minimal technology score to use this method
	var MinLength = 0  # minimal length of operation in weeks
	var MaxLength = 0  # maximal length of operation in weeks
	var PossibleCasualties = 0  # how many members of org can be killed or arrested
	var BudgetChange = 0  # 0 to 100, additional change, apart from casualties
	var DamageToOps = 0  # 0 to 100, additional change, apart from budget and casualties
	var Attribution = 0  # 0 to 100, public attribution of the operation to bureau
	var MinimalLocal = 0  # 0 (no role of local skills) to 100 (perfect language and customs required)
	
	func _init(aDictionary):
		Name = aDictionary.Name
		Cost = aDictionary.Cost
		Quality = aDictionary.Quality
		Risk = aDictionary.Risk
		OfficersRequired = aDictionary.OfficersRequired
		MinimalSkill = aDictionary.MinimalSkill
		Available = aDictionary.Available
		MinimalIntel = aDictionary.MinimalIntel
		MinimalTrust = aDictionary.MinimalTrust
		MinimalTech = aDictionary.MinimalTech
		MinLength = aDictionary.MinLength
		MaxLength = aDictionary.MaxLength
		PossibleCasualties = aDictionary.PossibleCasualties
		BudgetChange = aDictionary.BudgetChange
		DamageToOps = aDictionary.DamageToOps
		MinimalLocal = aDictionary.MinimalLocal

# Methods on the ground
# 2D array: first row for MORE_INTEL, second row for RECRUIT_SOURCE etc
var Methods = [
	# MORE_INTEL methods
	[
		AMethod.new({ "Name": "general surveillance", "Cost": 2, "Quality": 10, "Risk": 2, "OfficersRequired": 1, "MinimalSkill": 0, "Available": false, "MinimalIntel": -100, "MinimalTrust": 0, "MinimalTech": 0, "MinimalLocal": 0, }),
		AMethod.new({ "Name": "street observation on foot and by car", "Cost": 2, "Quality": 12, "Risk": 10, "OfficersRequired": 1, "MinimalSkill": 0, "Available": false, "MinimalIntel": -30, "MinimalTrust": 0, "MinimalTech": 0, "MinimalLocal": 5, }),
		AMethod.new({ "Name": "following members of organization", "Cost": 3, "Quality": 20, "Risk": 20, "OfficersRequired": 3, "MinimalSkill": 10, "Available": false, "MinimalIntel": -20, "MinimalTrust": 0, "MinimalTech": 0, "MinimalLocal": 5, }),
		AMethod.new({ "Name": "open observation by disguised officers", "Cost": 4, "Quality": 25, "Risk": 5, "OfficersRequired": 3, "MinimalSkill": 20, "Available": false, "MinimalIntel": -30, "MinimalTrust": 0, "MinimalTech": 5, "MinimalLocal": 5, }),
		AMethod.new({ "Name": "install and operate external cameras", "Cost": 5, "Quality": 30, "Risk": 12, "OfficersRequired": 1, "MinimalSkill": 11, "Available": false, "MinimalIntel": -10, "MinimalTrust": 0, "MinimalTech": 10, "MinimalLocal": 0, }),
		AMethod.new({ "Name": "intercept local mobile communication", "Cost": 10, "Quality": 40, "Risk": 5, "OfficersRequired": 1, "MinimalSkill": 30, "Available": false, "MinimalIntel": -10, "MinimalTrust": 10, "MinimalTech": 25, "MinimalLocal": 10, }),
		AMethod.new({ "Name": "rent house for observation", "Cost": 20, "Quality": 35, "Risk": 2, "OfficersRequired": 2, "MinimalSkill": 5, "Available": false, "MinimalIntel": 5, "MinimalTrust": 0, "MinimalTech": 0, "MinimalLocal": 30, }),
		AMethod.new({ "Name": "attemp walk in from a street", "Cost": 20, "Quality": 60, "Risk": 55, "OfficersRequired": 5, "MinimalSkill": 25, "Available": false, "MinimalIntel": 10, "MinimalTrust": 40, "MinimalTech": 0, "MinimalLocal": 50, }),
		AMethod.new({ "Name": "bug places frequented by members", "Cost": 60, "Quality": 80, "Risk": 15, "OfficersRequired": 4, "MinimalSkill": 40, "Available": false, "MinimalIntel": 25, "MinimalTrust": 40, "MinimalTech": 35, "MinimalLocal": 10, }),
		AMethod.new({ "Name": "break-in and copy documents", "Cost": 60, "Quality": 90, "Risk": 75, "OfficersRequired": 10, "MinimalSkill": 50, "Available": false, "MinimalIntel": 50, "MinimalTrust": 50, "MinimalTech": 60, "MinimalLocal": 5, }),
		AMethod.new({ "Name": "pose as undercover local company", "Cost": 100, "Quality": 60, "Risk": 20, "OfficersRequired": 12, "MinimalSkill": 40, "Available": false, "MinimalIntel": -50, "MinimalTrust": 40, "MinimalTech": 0, "MinimalLocal": 70, }),
		AMethod.new({ "Name": "pose as undercover government organization", "Cost": 300, "Quality": 85, "Risk": 25, "OfficersRequired": 16, "MinimalSkill": 50, "Available": false, "MinimalIntel": -100, "MinimalTrust": 75, "MinimalTech": 0, "MinimalLocal": 90, }),
		AMethod.new({ "Name": "buy information from close contacts", "Cost": 30, "Quality": 50, "Risk": 50, "OfficersRequired": 1, "MinimalSkill": 10, "Available": false, "MinimalIntel": -10, "MinimalTrust": 0, "MinimalTech": 0, "MinimalLocal": 20, }),
	],
	# RECRUIT_SOURCE methods
	[
		AMethod.new({ "Name": "basic observation of potential assets", "Cost": 4, "Quality": 10, "Risk": 3, "OfficersRequired": 2, "MinimalSkill": 0, "Available": false, "MinimalIntel": -25, "MinimalTrust": 0, "MinimalTech": 0, "MinimalLocal": 0, }),
		AMethod.new({ "Name": "background check", "Cost": 6, "Quality": 20, "Risk": 10, "OfficersRequired": 3, "MinimalSkill": 10, "Available": false, "MinimalIntel": -10, "MinimalTrust": 0, "MinimalTech": 0, "MinimalLocal": 30, }),
		AMethod.new({ "Name": "arrange natural meetings with potential assets", "Cost": 10, "Quality": 30, "Risk": 20, "OfficersRequired": 2, "MinimalSkill": 10, "Available": false, "MinimalIntel": 15, "MinimalTrust": 0, "MinimalTech": 0, "MinimalLocal": 60, }),
		AMethod.new({ "Name": "build relationship with potential assets", "Cost": 10, "Quality": 50, "Risk": 30, "OfficersRequired": 2, "MinimalSkill": 40, "Available": false, "MinimalIntel": 15, "MinimalTrust": 0, "MinimalTech": 0, "MinimalLocal": 80, }),
		AMethod.new({ "Name": "set up thorough covers for officers", "Cost": 30, "Quality": 40, "Risk": 0, "OfficersRequired": 1, "MinimalSkill": 25, "Available": false, "MinimalIntel": 0, "MinimalTrust": 0, "MinimalTech": 5, "MinimalLocal": 70, }),
		AMethod.new({ "Name": "large amount of money for cooperation", "Cost": 100, "Quality": 40, "Risk": 15, "OfficersRequired": 2, "MinimalSkill": 0, "Available": false, "MinimalIntel": -10, "MinimalTrust": 0, "MinimalTech": 0, "MinimalLocal": 50, }),
		AMethod.new({ "Name": "collect blackmail material", "Cost": 12, "Quality": 60, "Risk": 15, "OfficersRequired": 8, "MinimalSkill": 35, "Available": false, "MinimalIntel": 30, "MinimalTrust": 0, "MinimalTech": 5, "MinimalLocal": 60, }),
		AMethod.new({ "Name": "honeytrap blackmail", "Cost": 20, "Quality": 60, "Risk": 5, "OfficersRequired": 5, "MinimalSkill": 35, "Available": false, "MinimalIntel": 10, "MinimalTrust": 0, "MinimalTech": 0, "MinimalLocal": 70, }),
		AMethod.new({ "Name": "construct network of close contacts", "Cost": 15, "Quality": 55, "Risk": 20, "OfficersRequired": 6, "MinimalSkill": 45, "Available": false, "MinimalIntel": 40, "MinimalTrust": 0, "MinimalTech": 5, "MinimalLocal": 60, }),
		AMethod.new({ "Name": "identify potential defectors", "Cost": 25, "Quality": 70, "Risk": 40, "OfficersRequired": 12, "MinimalSkill": 55, "Available": false, "MinimalIntel": 45, "MinimalTrust": 0, "MinimalTech": 0, "MinimalLocal": 85, }),
		AMethod.new({ "Name": "target members close to the leader", "Cost": 40, "Quality": 90, "Risk": 55, "OfficersRequired": 15, "MinimalSkill": 65, "Available": false, "MinimalIntel": 50, "MinimalTrust": 0, "MinimalTech": 0, "MinimalLocal": 85, }),
	],
	# OFFENSIVE methods
	[
		AMethodOffensive.new({ "Name": "target any funding sources", "Cost": 10, "Quality": 90, "Risk": 20, "OfficersRequired": 3, "MinimalSkill": 10, "Available": false, "MinimalIntel": -10, "MinimalTrust": 0, "MinLength": 3, "MaxLength": 6, "PossibleCasualties": 0, "BudgetChange": 10, "DamageToOps": 0, "Attribution": 5, "MinimalTech": 0, "MinimalLocal": 10, }),
		AMethodOffensive.new({ "Name": "provide evidence for local arrests", "Cost": 2, "Quality": 15, "Risk": 30, "OfficersRequired": 1, "MinimalSkill": 10, "Available": false, "MinimalIntel": 15, "MinimalTrust": 10, "MinLength": 1, "MaxLength": 2, "PossibleCasualties": 20, "BudgetChange": 0, "DamageToOps": 10, "Attribution": 100, "MinimalTech": 0, "MinimalLocal": 40, }),
		AMethodOffensive.new({ "Name": "track down and disrupt funding", "Cost": 15, "Quality": 50, "Risk": 20, "OfficersRequired": 3, "MinimalSkill": 15, "Available": false, "MinimalIntel": -10, "MinimalTrust": 0, "MinLength": 4, "MaxLength": 10, "PossibleCasualties": 0, "BudgetChange": 50, "DamageToOps": 0, "Attribution": 0, "MinimalTech": 10, "MinimalLocal": 50, }),
		AMethodOffensive.new({ "Name": "kidnap and interrogate a known member", "Cost": 20, "Quality": 35, "Risk": 90, "OfficersRequired": 6, "MinimalSkill": 30, "Available": false, "MinimalIntel": 20, "MinimalTrust": 25, "MinLength": 2, "MaxLength": 3, "PossibleCasualties": 1, "BudgetChange": 0, "DamageToOps": 40, "Attribution": 40, "MinimalTech": 10, "MinimalLocal": 10, }),
		AMethodOffensive.new({ "Name": "kill a known member", "Cost": 30, "Quality": 50, "Risk": 75, "OfficersRequired": 8, "MinimalSkill": 35, "Available": false, "MinimalIntel": 15, "MinimalTrust": 25, "MinLength": 1, "MaxLength": 2, "PossibleCasualties": 1, "BudgetChange": 0, "DamageToOps": 40, "Attribution": 60, "MinimalTech": 30, "MinimalLocal": 0, }),
		AMethodOffensive.new({ "Name": "poison highest-ranking known member", "Cost": 20, "Quality": 65, "Risk": 60, "OfficersRequired": 3, "MinimalSkill": 50, "Available": false, "MinimalIntel": 15, "MinimalTrust": 25, "MinLength": 2, "MaxLength": 4, "PossibleCasualties": 1, "BudgetChange": 0, "DamageToOps": 60, "Attribution": 10, "MinimalTech": 75, "MinimalLocal": 0, }),
		AMethodOffensive.new({ "Name": "engage local gangs", "Cost": 50, "Quality": 10, "Risk": 40, "OfficersRequired": 2, "MinimalSkill": 15, "Available": false, "MinimalIntel": 20, "MinimalTrust": 35, "MinLength": 1, "MaxLength": 3, "PossibleCasualties": 250, "BudgetChange": 40, "DamageToOps": 30, "Attribution": 5, "MinimalTech": 0, "MinimalLocal": 70, }),
		AMethodOffensive.new({ "Name": "bomb locations", "Cost": 60, "Quality": 75, "Risk": 60, "OfficersRequired": 10, "MinimalSkill": 45, "Available": false, "MinimalIntel": -20, "MinimalTrust": 25, "MinLength": 2, "MaxLength": 4, "PossibleCasualties": 1000, "BudgetChange": 20, "DamageToOps": 70, "Attribution": 60, "MinimalTech": 50, "MinimalLocal": 0, }),
		AMethodOffensive.new({ "Name": "train and send private guerilla", "Cost": 100, "Quality": 85, "Risk": 20, "OfficersRequired": 25, "MinimalSkill": 35, "Available": false, "MinimalIntel": -40, "MinimalTrust": 50, "MinLength": 10, "MaxLength": 25, "PossibleCasualties": 2500, "BudgetChange": 50, "DamageToOps": 90, "Attribution": 5, "MinimalTech": 20, "MinimalLocal": 60, }),
		AMethodOffensive.new({ "Name": "perform basic psychological operation", "Cost": 30, "Quality": 10, "Risk": 10, "OfficersRequired": 3, "MinimalSkill": 20, "Available": false, "MinimalIntel": 5, "MinimalTrust": 0, "MinLength": 2, "MaxLength": 9, "PossibleCasualties": 0, "BudgetChange": 10, "DamageToOps": 10, "Attribution": 0, "MinimalTech": 5, "MinimalLocal": 60, }),
		AMethodOffensive.new({ "Name": "execute misinformation campaign", "Cost": 50, "Quality": 30, "Risk": 10, "OfficersRequired": 6, "MinimalSkill": 40, "Available": false, "MinimalIntel": 15, "MinimalTrust": 20, "MinLength": 2, "MaxLength": 9, "PossibleCasualties": 0, "BudgetChange": 20, "DamageToOps": 20, "Attribution": 5, "MinimalTech": 20, "MinimalLocal": 80, }),
		AMethodOffensive.new({ "Name": "spread black propaganda", "Cost": 100, "Quality": 45, "Risk": 5, "OfficersRequired": 25, "MinimalSkill": 60, "Available": false, "MinimalIntel": 25, "MinimalTrust": 40, "MinLength": 6, "MaxLength": 12, "PossibleCasualties": 0, "BudgetChange": 40, "DamageToOps": 100, "Attribution": 10, "MinimalTech": 30, "MinimalLocal": 90, }),
	],
]

enum ExtOpType {
	HOME_TERRORIST_ATTACK = 0,
	EMBASSY_TERRORIST_ATTACK = 1,
	PLANE_HIJACKING = 2,
	LEADER_ASSASSINATION = 3,
}

class AnExternalOperation:
	var Type = 0
	var Budget = 0  # weekly budget in thousands required for the operation to progress
	var Persons = 0  # number of persons involved, more -> easier to catch but also more damage
	var Secrecy = 0  # 0 (public knowledge) to 100 (bataclan)
	var Damage = 0  # done to the target, 0 (observation) to 100 (9/11)
	# state vars
	var Active = false  # operations are not removed, only deactivated, to allow investigations
	var FinishCounter = 0  # -1 every week until it is 0 and operation is launched
	var IntelValue = 0  # 0 (uknown) to 100 (perfectly known)
	
	func _init(adict):
		Active = true
		Type = adict.Type
		Budget = adict.Budget
		Persons = adict.Persons
		Secrecy = adict.Secrecy
		Damage = adict.Damage
		FinishCounter = adict.FinishCounter

# <countryA> phrase <countryB>
var DiplomaticPhrasesPositive = ["'s officials visited ", " expressed will to improve relations with "]
var DiplomaticPhrasesVeryPositive = [" signed a treaty with ", " held joint military exercise with ", " formed bilateral committee "]
var DiplomaticPhrasesNegative = [" condemned actions of ", " withdraw from a treaty with ", " expressed concern about changes in "]
var DiplomaticPhrasesVeryNegative = [" refused to meet with officials of ", " expelled some citizens of ", " attributed destabilization of the region to ", "'s military officials threatened "]
var TechnologicalPhrases = ["New discovery reported by scientists", "Significant technological breakthrough made by engineers", "Scientific innovation presented"]
