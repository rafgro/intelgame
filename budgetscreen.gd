extends Panel

# Refreshing percent of budget spent
func CalculateCurrentBudget():
	var spent = 100*(float(GameLogic.BudgetSalaries+GameLogic.BudgetOffice \
		+GameLogic.BudgetRecruitment+GameLogic.BudgetUpskilling \
		+GameLogic.BudgetSecurity+GameLogic.BudgetOngoingOperations) / GameLogic.BudgetFull)
	$M/R/MonthlyBudget.text = "Monthly budget: €" + str(GameLogic.BudgetFull) \
		+ ",000 (" + str(spent) + "% spent)"
	return spent

func _ready():
	CalculateCurrentBudget()
	$M/R/BasicCosts.text = "Basic costs\n" \
 		+ " - €" + str(GameLogic.BudgetSalaries) + ",000 staff compensation\n" \
		+ " - €" + str(GameLogic.BudgetOffice) + ",000 office maintenance\n\n" \
		+ "Ongoing abroad operations\n - €" + str(GameLogic.BudgetOngoingOperations) \
		+ ",000 travel, maintenance, technology"
	$M/R/CRecruit/RecruitBudget.text = "Recruit officers: €" + str(GameLogic.BudgetRecruitment) + ",000"
	$M/R/CRecruit/RecruitSlider.max_value = GameLogic.BudgetFull-(GameLogic.BudgetSalaries+GameLogic.BudgetOffice)
	$M/R/CRecruit/RecruitSlider.value = GameLogic.BudgetRecruitment
	$M/R/CUpskill/UpskillBudget.text = "Upskill staff: €" + str(GameLogic.BudgetUpskilling) + ",000"
	$M/R/CUpskill/UpskillSlider.max_value = GameLogic.BudgetFull-(GameLogic.BudgetSalaries+GameLogic.BudgetOffice)
	$M/R/CUpskill/UpskillSlider.value = GameLogic.BudgetUpskilling
	$M/R/COffice/OfficeBudget.text = "Office security: €" + str(GameLogic.BudgetSecurity) + ",000"
	$M/R/COffice/OfficeSlider.max_value = GameLogic.BudgetFull-(GameLogic.BudgetSalaries+GameLogic.BudgetOffice)
	$M/R/COffice/OfficeSlider.value = GameLogic.BudgetSecurity

func _on_Return_pressed():
	get_tree().change_scene("res://main.tscn")

func _on_RecruitSlider_value_changed(value):
	GameLogic.BudgetRecruitment = value
	var spent = CalculateCurrentBudget()
	if spent > 100:  # capping allowable spending
		GameLogic.BudgetRecruitment = value - (GameLogic.BudgetFull*(spent-100)*0.01)
	CalculateCurrentBudget()
	$M/R/CRecruit/RecruitSlider.value = int(GameLogic.BudgetRecruitment)
	$M/R/CRecruit/RecruitBudget.text = "Recruit officers: €" + str(GameLogic.BudgetRecruitment) + ",000"

func _on_UpskillSlider_value_changed(value):
	GameLogic.BudgetUpskilling = value
	var spent = CalculateCurrentBudget()
	if spent > 100:  # capping allowable spending
		GameLogic.BudgetUpskilling = value - (GameLogic.BudgetFull*(spent-100)*0.01)
	CalculateCurrentBudget()
	$M/R/CUpskill/UpskillSlider.value = int(GameLogic.BudgetUpskilling)
	$M/R/CUpskill/UpskillBudget.text = "Upskill staff: €" + str(GameLogic.BudgetUpskilling) + ",000"

func _on_OfficeSlider_value_changed(value):
	GameLogic.BudgetSecurity = value
	var spent = CalculateCurrentBudget()
	if spent > 100:  # capping allowable spending
		GameLogic.BudgetSecurity = value - (GameLogic.BudgetSecurity*(spent-100)*0.01)
	CalculateCurrentBudget()
	$M/R/COffice/OfficeSlider.value = int(GameLogic.BudgetSecurity)
	$M/R/COffice/OfficeBudget.text = "Office security: €" + str(GameLogic.BudgetSecurity) + ",000"
