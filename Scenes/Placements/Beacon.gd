extends Area2D


@onready var beacon = $"."
var mouseentered: bool = false
@onready var Ally = get_tree().get_first_node_in_group("Ally")
var beaconPlacementTimer: Timer = Timer.new()
var beaconCooldown: bool = false


func _input(event):
	RemoveBeacon()


func _on_body_entered(body):
	if body.is_in_group("Ally"):
		beacon.queue_free()


func _on_mouse_entered():
	mouseentered = true


func _on_mouse_exited():
	mouseentered = false


func RemoveBeacon():
	if Input.is_action_just_pressed("RemoveBeacon") and Ally.Points >= 1 and mouseentered == true and beaconCooldown == false:
		beaconCooldown = true
		beacon.queue_free()
		Ally.Points -= 1
		beacon.add_child(beaconPlacementTimer)
		beaconPlacementTimer.start(1)
		await beaconPlacementTimer.timeout
		beaconCooldown = false



