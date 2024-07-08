extends Area2D


func _on_body_entered(body):
	if body.is_in_group("player"):
		var Player = body
		Player.healthpotions += 1
		print(Player.healthpotions)
		queue_free()



func _on_area_entered(area):
	if area.is_in_group("PlayerDetectionbox"):
		pass
		#var player = area.get_parent()
