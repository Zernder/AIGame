class_name FloorOne extends Node2D


@onready var player = get_tree().get_first_node_in_group("player")
@onready var label = $LevelUI/Panel/Label
@onready var slimes = $Slimes
@onready var room_1_marker = $Waypoints/AreaOne/F1R1/Room1Marker
@onready var room_2_marker = $Waypoints/BedroomOne/F1R1Exit/Room2Marker


func _process(_delta):
	WinGame()
	pass


func WinGame():
	label.text = "Enemies Left: " + str(slimes.get_child_count())
	if slimes.get_child_count() == 0:
		get_tree().change_scene_to_file("res://Scenes/Menus/WinScreen.tscn")


func R1Entered(body):
	if body.is_in_group("player"):
		player.global_position = room_1_marker.global_position
		player.whichfloor = 2
		player.currentState = player.IDLE
		player.StateMachine()


func R1Exited(body):
	if body.is_in_group("player"):
		player.global_position = room_2_marker.global_position
		player.whichfloor = 1
		player.currentState = player.IDLE
		player.StateMachine()
