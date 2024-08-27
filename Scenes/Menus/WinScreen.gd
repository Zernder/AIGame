extends Control



func PlayAgainPressed():
	get_tree().change_scene_to_file("res://World.tscn")


func _on_exit_pressed():
	get_tree().quit()


