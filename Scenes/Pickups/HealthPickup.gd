extends Area2D


func _on_body_entered(body):
	if body.is_in_group("Ally"):
		var ally = body
		if ally.health < ally.maxHealth:
			ally.health = ally.maxHealth
			queue_free()
	else:
		pass
