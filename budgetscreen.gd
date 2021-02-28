extends Panel

func IntensityPercent(which):
	return str(int(which * 1.0 / (GameLogic.IntensityHiring + GameLogic.IntensityUpskill + GameLogic.IntensityTech) * 100)) + "%"

func _ready():
	$M/R/MonthlyBudget.text = "Monthly budget: €" + str(int(GameLogic.BudgetFull)) \
		+ ",000 (€" + str(int(GameLogic.FreeFundsWeeklyWithoutOngoing())) + "k free for operations)"
	$M/R/CHiring/HiringLabel.text = "Hiring intensity: " + IntensityPercent(GameLogic.IntensityHiring)
	$M/R/CHiring/HiringSlider.max_value = 100
	$M/R/CHiring/HiringSlider.value = GameLogic.IntensityHiring
	$M/R/CUpskill/UpskillLabel.text = "Upskilling intensity: " + IntensityPercent(GameLogic.IntensityUpskill)
	$M/R/CUpskill/UpskillSlider.max_value = 100
	$M/R/CUpskill/UpskillSlider.value = GameLogic.IntensityUpskill
	$M/R/CTech/TechLabel.text = "R&D intensity: " + IntensityPercent(GameLogic.IntensityTech)
	$M/R/CTech/TechSlider.max_value = 100
	$M/R/CTech/TechSlider.value = GameLogic.IntensityTech

func _on_Return_pressed():
	get_tree().change_scene("res://main.tscn")

func _on_HiringSlider_value_changed(value):
	GameLogic.IntensityHiring = value
	$M/R/CHiring/HiringLabel.text = "Hiring intensity: " + IntensityPercent(GameLogic.IntensityHiring)
	$M/R/CUpskill/UpskillLabel.text = "Upskilling intensity: " + IntensityPercent(GameLogic.IntensityUpskill)
	$M/R/CTech/TechLabel.text = "R&D intensity: " + IntensityPercent(GameLogic.IntensityTech)

func _on_UpskillSlider_value_changed(value):
	GameLogic.IntensityUpskill = value
	$M/R/CHiring/HiringLabel.text = "Hiring intensity: " + IntensityPercent(GameLogic.IntensityHiring)
	$M/R/CUpskill/UpskillLabel.text = "Upskilling intensity: " + IntensityPercent(GameLogic.IntensityUpskill)
	$M/R/CTech/TechLabel.text = "R&D intensity: " + IntensityPercent(GameLogic.IntensityTech)

func _on_TechSlider_value_changed(value):
	GameLogic.IntensityTech = value
	$M/R/CHiring/HiringLabel.text = "Hiring intensity: " + IntensityPercent(GameLogic.IntensityHiring)
	$M/R/CUpskill/UpskillLabel.text = "Upskillings intensity: " + IntensityPercent(GameLogic.IntensityUpskill)
	$M/R/CTech/TechLabel.text = "R&D intensity: " + IntensityPercent(GameLogic.IntensityTech)
