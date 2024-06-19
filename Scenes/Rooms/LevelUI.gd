class_name LevelUI extends CanvasLayer


@onready var slimes = $"../Slimes"
@onready var label = $Panel/Label


func _process(_delta):
	EnemiesLeft()
	WinGame()

func EnemiesLeft():
	label.text = "Enemies Left: " + str(slimes.get_child_count())


func WinGame():
	if slimes.get_child_count() == 0:
		get_tree().change_scene_to_file("res://Scenes/Menus/WinScreen.tscn")
