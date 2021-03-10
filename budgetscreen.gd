extends Control

func _ready():
	# general stats
	$C/M/R/MonthlyBudget.text = "Monthly budget: €" + str(int(GameLogic.BudgetFull)) \
		+ ",000 (€" + str(int(GameLogic.FreeFundsWeekly()*4)) + "k free for new operations)" \
		+ "\nCurrent cost of ongoing operations: €" + str(int(GameLogic.BudgetOngoingOperations))+ ",000"
	# sliders
	$C/M/R/CHiring/HiringLabel.text = "Hiring intensity: " + str(int(GameLogic.IntensityPercent(GameLogic.IntensityHiring))) + "%"
	$C/M/R/CHiring/HiringSlider.max_value = 100
	$C/M/R/CHiring/HiringSlider.value = GameLogic.IntensityHiring
	$C/M/R/CUpskill/UpskillLabel.text = "Upskilling intensity: " + str(int(GameLogic.IntensityPercent(GameLogic.IntensityUpskill))) + "%"
	$C/M/R/CUpskill/UpskillSlider.max_value = 100
	$C/M/R/CUpskill/UpskillSlider.value = GameLogic.IntensityUpskill
	$C/M/R/CTech/TechLabel.text = "R&D intensity: " + str(int(GameLogic.IntensityPercent(GameLogic.IntensityTech))) + "%"
	$C/M/R/CTech/TechSlider.max_value = 100
	$C/M/R/CTech/TechSlider.value = GameLogic.IntensityTech
	# specific stats
	$C/M/R/CSkill/SkillBar.value = GameLogic.StaffSkill
	var diff = int(GameLogic.StaffSkill - GameLogic.StaffSkillMonthsAgo[0])
	if diff > 0: $C/M/R/SkillChange.text = "+" + str(int(diff)) + "% in the last six months"
	else: $C/M/R/SkillChange.text = str(int(diff)) + "% in the last six months"
	$C/M/R/CTech2/TechBar.value = GameLogic.Technology
	diff = int(GameLogic.Technology - GameLogic.TechnologyMonthsAgo[0])
	if diff > 0: $C/M/R/TechChange.text = "+" + str(int(diff)) + "% in the last six months"
	else: $C/M/R/TechChange.text = str(diff) + "% in the last six months"
	$C/M/R/CExperience/ExperienceBar.value = GameLogic.StaffExperience
	diff = int(GameLogic.StaffExperience - GameLogic.StaffExperienceMonthsAgo[0])
	if diff > 0: $C/M/R/ExperienceChange.text = "+" + str(int(diff)) + "% in the last six months"
	else: $C/M/R/ExperienceChange.text = str(int(diff)) + "% in the last six months"
	$C/M/R/CTrust/TrustBar.value = GameLogic.StaffTrust
	diff = int(GameLogic.StaffTrust - GameLogic.StaffTrustMonthsAgo[0])
	if diff > 0: $C/M/R/TrustChange.text = "+" + str(int(diff)) + "% in the last six months"
	else: $C/M/R/TrustChange.text = str(diff) + "% in the last six months"

func _on_Return_pressed():
	get_tree().change_scene("res://main.tscn")

func _on_HiringSlider_value_changed(value):
	GameLogic.IntensityHiring = value
	$C/M/R/CHiring/HiringLabel.text = "Hiring intensity: " + str(int(GameLogic.IntensityPercent(GameLogic.IntensityHiring))) + "%"
	$C/M/R/CUpskill/UpskillLabel.text = "Upskilling intensity: " + str(int(GameLogic.IntensityPercent(GameLogic.IntensityUpskill))) + "%"
	$C/M/R/CTech/TechLabel.text = "R&D intensity: " + str(int(GameLogic.IntensityPercent(GameLogic.IntensityTech))) + "%"

func _on_UpskillSlider_value_changed(value):
	GameLogic.IntensityUpskill = value
	$C/M/R/CHiring/HiringLabel.text = "Hiring intensity: " + str(int(GameLogic.IntensityPercent(GameLogic.IntensityHiring))) + "%"
	$C/M/R/CUpskill/UpskillLabel.text = "Upskilling intensity: " + str(int(GameLogic.IntensityPercent(GameLogic.IntensityUpskill))) + "%"
	$C/M/R/CTech/TechLabel.text = "R&D intensity: " + str(int(GameLogic.IntensityPercent(GameLogic.IntensityTech))) + "%"

func _on_TechSlider_value_changed(value):
	GameLogic.IntensityTech = value
	$C/M/R/CHiring/HiringLabel.text = "Hiring intensity: " + str(int(GameLogic.IntensityPercent(GameLogic.IntensityHiring))) + "%"
	$C/M/R/CUpskill/UpskillLabel.text = "Upskilling intensity: " + str(int(GameLogic.IntensityPercent(GameLogic.IntensityUpskill))) + "%"
	$C/M/R/CTech/TechLabel.text = "R&D intensity: " + str(int(GameLogic.IntensityPercent(GameLogic.IntensityTech))) + "%"
