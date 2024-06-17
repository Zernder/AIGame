extends Area2D

@onready var enemy = $"."
var mouseentered: bool = false
@onready var Ally = get_tree().get_first_node_in_group("Ally")
var BarrierPlacementTimer: Timer = Timer.new()
var BarrierCooldown: bool = false


func _input(_event):
	RemoveBarrier()


func _on_area_entered(area):
	if area.is_in_group("AllyHitbox"):
		var playerai = area.get_parent()
		playerai.target = to_local(playerai.navagent.get_next_path_position()).normalized()
		playerai.velocity = playerai.target * playerai.speed


func _on_mouse_entered():
	mouseentered = true


func _on_mouse_exited():
	mouseentered = false


func RemoveBarrier():
	if Input.is_action_just_pressed("RemoveBarrier") and Ally.Points >= 1 and mouseentered == true and BarrierCooldown == false:
		BarrierCooldown = true
		enemy.queue_free()
		Ally.Points -= 1
		enemy.add_child(BarrierPlacementTimer)
		BarrierPlacementTimer.start(1)
		await BarrierPlacementTimer.timeout
		BarrierCooldown = false
