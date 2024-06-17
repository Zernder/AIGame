extends CanvasLayer


@onready var slimes = $"../Slimes"
@onready var label = $Panel/Label


func _process(_delta):
	EnemiesLeft()

func EnemiesLeft():
	label.text = "Enemies Left: " + str(slimes.get_child_count())
