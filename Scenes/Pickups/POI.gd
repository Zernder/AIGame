extends Area2D

var player


func _on_area_entered(area):
	if area.get_parent().is_in_group("player"):
		player = area.get_parent()
		queue_free()
