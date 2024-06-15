extends Area2D


@onready var slimes = $"../Slimes"


func RoomOneExit(_body):
	if slimes.get_child_count() == 0:
		print("Moving to Level Two!")
