extends Panel

# Called when the node enters the scene tree for the first time.
func _ready():
	$M/R/ActiveOfficers.text = "Active Officers: " + str(GameLogic.ActiveOfficers)
	$M/R/SkillBar.value = GameLogic.StaffSkill
	$M/R/ExperienceBar.value = GameLogic.StaffExperience
	$M/R/TrustBar.value = GameLogic.StaffTrust

func _on_Return_pressed():
	get_tree().change_scene("res://main.tscn")
