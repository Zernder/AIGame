extends Control



@onready var character_sheet = $"../Character Sheet"
func CharacterScreenTouched():
	print("Touch me!")
	if character_sheet.visible:
		character_sheet.hide()
	else:
		character_sheet.show()


func InventoryTouched():
	pass # Replace with function body.


