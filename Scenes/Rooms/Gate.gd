extends Area2D


@onready var animated_sprite_2d = $AnimatedSprite2D




func _on_body_entered(body):
	if body.is_in_group("Player"):
		animated_sprite_2d.play("Open")
	if body.is_in_group("Player") and self.is_in_group("Exit"):
		pass


func _on_body_exited(body):
	if body.is_in_group("Player"):
		animated_sprite_2d.play("Close")
