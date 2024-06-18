extends Node2D

@onready var world = $"."
@onready var room_one = $RoomOne
@onready var Player = get_tree().get_first_node_in_group("Player")
var BarrierPlacementTimer: Timer = Timer.new()
var BarrierCooldown: bool = false
var BeaconPlacementTimer: Timer = Timer.new()
var BeaconCooldown: bool = false



func _ready():
	world.add_child(BarrierPlacementTimer)
	world.add_child(BeaconPlacementTimer)

func _input(_event):
	PlaceBarrier()
	PlaceBeacon()


const BARRIER = preload("res://Scenes/Placements/Barrier.tscn")
func PlaceBarrier():
	if Input.is_action_just_pressed("PlaceBarrier") and Player.Points >= 2 and BarrierCooldown == false:
		BarrierCooldown = true
		var beacon = BARRIER.instantiate()
		world.add_child(beacon)
		var mousepos = get_global_mouse_position()
		beacon.position = mousepos
		Player.Points -= 2
		BarrierPlacementTimer.start(1)
		await BarrierPlacementTimer.timeout
		BarrierCooldown = false


const BEACON = preload("res://Scenes/Placements/Beacon.tscn")
func PlaceBeacon():
	if Input.is_action_just_pressed("PlaceBeacon") and Player.Points >= 2 and BeaconCooldown == false:
		BeaconCooldown = true
		var beacon = BEACON.instantiate()
		world.add_child(beacon)
		var mousepos = get_global_mouse_position()
		beacon.position = mousepos
		Player.Points -= 2
		BeaconPlacementTimer.start(1)
		await BeaconPlacementTimer.timeout
		BeaconCooldown = false


