extends Area2D


func _on_body_entered(body):
	if body.is_in_group("Ally"):
		body.health += 50
		queue_free()
