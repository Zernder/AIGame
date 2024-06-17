extends Area2D


@onready var room_one = $".."
const WIN_SCREEN = preload("res://Scenes/Menus/WinScreen.tscn")
@onready var slimes = $"../Slimes"



func RoomOneExit(_body):
	if slimes.get_child_count() == 0:
		print("Moving to Level Two!")
		var winner = WIN_SCREEN.instantiate()
		get_tree().get_root().add_child(winner)
		room_one.queue_free()

