extends Control


@onready var player = get_tree().get_first_node_in_group("player")
@export var inventory: Control
@export var CharacterScreen: Control

func _ready():
	pass


func CharacterScreenPressed():
	if CharacterScreen.visible:
		CharacterScreen.hide()
	else:
		CharacterScreen.show()


func InventoryPressed():
	pass # Replace with function body.


func StuckPressed():
	player.unstuck_timer.start(0.5)


func CharacterSheetPushed():
	if CharacterScreen.visible:
		CharacterScreen.hide()
	else:
		CharacterScreen.show()
