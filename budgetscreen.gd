extends Panel

func _ready():
	# general stats
	$M/R/MonthlyBudget.text = "Monthly budget: €" + str(int(GameLogic.BudgetFull)) \
		+ ",000 (€" + str(int(GameLogic.FreeFundsWeeklyWithoutOngoing()*4)) + "k free for operations)"
	# sliders
	$M/R/CHiring/HiringLabel.text = "Hiring intensity: " + str(GameLogic.IntensityPercent(GameLogic.IntensityHiring)) + "%"
	$M/R/CHiring/HiringSlider.max_value = 100
	$M/R/CHiring/HiringSlider.value = GameLogic.IntensityHiring
	$M/R/CUpskill/UpskillLabel.text = "Upskilling intensity: " + str(GameLogic.IntensityPercent(GameLogic.IntensityUpskill)) + "%"
	$M/R/CUpskill/UpskillSlider.max_value = 100
	$M/R/CUpskill/UpskillSlider.value = GameLogic.IntensityUpskill
	$M/R/CTech/TechLabel.text = "R&D intensity: " + str(GameLogic.IntensityPercent(GameLogic.IntensityTech)) + "%"
	$M/R/CTech/TechSlider.max_value = 100
	$M/R/CTech/TechSlider.value = GameLogic.IntensityTech
	# specific stats
	$M/R/CSkill/SkillBar.value = GameLogic.StaffSkill
	var diff = int(GameLogic.StaffSkill - GameLogic.StaffSkillMonthsAgo[0])
	if diff > 0: $M/R/SkillChange.text = "+" + str(diff) + "% in the last six months"
	else: $M/R/SkillChange.text = str(diff) + "% in the last six months"
	$M/R/CTech2/TechBar.value = GameLogic.Technology
	diff = int(GameLogic.Technology - GameLogic.TechnologyMonthsAgo[0])
	if diff > 0: $M/R/TechChange.text = "+" + str(diff) + "% in the last six months"
	else: $M/R/TechChange.text = str(diff) + "% in the last six months"
	$M/R/CExperience/ExperienceBar.value = GameLogic.StaffExperience
	diff = int(GameLogic.StaffExperience - GameLogic.StaffExperienceMonthsAgo[0])
	if diff > 0: $M/R/ExperienceChange.text = "+" + str(diff) + "% in the last six months"
	else: $M/R/ExperienceChange.text = str(diff) + "% in the last six months"
	$M/R/CTrust/TrustBar.value = GameLogic.StaffTrust
	diff = int(GameLogic.StaffTrust - GameLogic.StaffTrustMonthsAgo[0])
	if diff > 0: $M/R/TrustChange.text = "+" + str(diff) + "% in the last six months"
	else: $M/R/TrustChange.text = str(diff) + "% in the last six months"

func _on_Return_pressed():
	get_tree().change_scene("res://main.tscn")

func _on_HiringSlider_value_changed(value):
	GameLogic.IntensityHiring = value
	$M/R/CHiring/HiringLabel.text = "Hiring intensity: " + str(GameLogic.IntensityPercent(GameLogic.IntensityHiring)) + "%"
	$M/R/CUpskill/UpskillLabel.text = "Upskilling intensity: " + str(GameLogic.IntensityPercent(GameLogic.IntensityUpskill)) + "%"
	$M/R/CTech/TechLabel.text = "R&D intensity: " + str(GameLogic.IntensityPercent(GameLogic.IntensityTech)) + "%"

func _on_UpskillSlider_value_changed(value):
	GameLogic.IntensityUpskill = value
	$M/R/CHiring/HiringLabel.text = "Hiring intensity: " + str(GameLogic.IntensityPercent(GameLogic.IntensityHiring)) + "%"
	$M/R/CUpskill/UpskillLabel.text = "Upskilling intensity: " + str(GameLogic.IntensityPercent(GameLogic.IntensityUpskill)) + "%"
	$M/R/CTech/TechLabel.text = "R&D intensity: " + str(GameLogic.IntensityPercent(GameLogic.IntensityTech)) + "%"

func _on_TechSlider_value_changed(value):
	GameLogic.IntensityTech = value
	$M/R/CHiring/HiringLabel.text = "Hiring intensity: " + str(GameLogic.IntensityPercent(GameLogic.IntensityHiring)) + "%"
	$M/R/CUpskill/UpskillLabel.text = "Upskilling intensity: " + str(GameLogic.IntensityPercent(GameLogic.IntensityUpskill)) + "%"
	$M/R/CTech/TechLabel.text = "R&D intensity: " + str(GameLogic.IntensityPercent(GameLogic.IntensityTech)) + "%"
