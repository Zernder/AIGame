class_name PlayerBaseScene extends CharacterBody2D

#region The Variables


@export var health: float
@export var maxHealth: float
@export var level: int
@export var damage: float
@export var speed: float
@export var Points: int

@onready var currentxp: int = 0
@onready var requiredxp: int = 100 * level
@onready var tile_map = $"../TileMap"

var healthpotions: int = 5

#region UI Imports

@onready var panel = $UI/Panel
@onready var points = $UI/Panel/Points
@onready var directions = $UI/Panel/Directions
@onready var profile = $UI/Profile
@onready var levellabel = $UI/Profile/LevelLabel
@onready var healthbar = $UI/Profile/Healthbar
@onready var healthlabel = $UI/Profile/Healthbar/healthlabel
@onready var expbar = $UI/Profile/Expbar


@onready var StateTimer = $Timers/StateTimeout
#@onready var navagent = $NavigationAgent2D

#endregion

var DetectedArray: Array = []
var beaconinRange: bool = false
var enemyinRange: bool = false

var target
var direction: Vector2 = Vector2()
var currentState

var agrid: AStarGrid2D
var currentidpath: Array[Vector2i]

#endregion

func _ready():
	currentState = WANDER
	StateMachine()
	healthbar.max_value = maxHealth
	health = maxHealth

func _process(_delta):
	UsePotion()
	UIProcess()
	SeenCoords()
	#LevelUp()

func _physics_process(delta):
	Death()
	Movement()
	if velocity == Vector2.ZERO:
		SetWalking(false)
		UpdateBlend()
	else:
		SetWalking(true)
		UpdateBlend()
	var collision = move_and_collide(velocity * delta)
	if collision:
		Wander()
		UpdateBlend()




func UIProcess():
	healthbar.max_value = maxHealth
	healthbar.value = health
	healthlabel.text = str(health) + "/" + str(maxHealth)
	expbar.value = currentxp
	expbar.max_value = requiredxp
	levellabel.text = "Level: " + str(level)
	points.text = "Points: " + str(Points)
	directions.text = "Place Beacon: 2 Points" + "\n" + "Remove Beacon: 1 Points"



func GrMovement():
	var idpath = tile_map.astar.get_id_path(tile_map.local_to_map(global_position), tile_map.local_to_map(get_global_mouse_position())).slice(1)
	
	
	if idpath.is_empty() == false:
		currentidpath = idpath

func Movement():
	if currentidpath.is_empty():
		return
	
	var targetposition = tile_map.map_to_local(currentidpath.front())
	
	global_position = global_position.move_toward(targetposition, 1)
	
	if global_position == targetposition:
		currentidpath.pop_front()


#region Animations


@onready var AnimTree = $AnimationTree


func UpdateBlend():
	AnimTree["parameters/Idle/blend_position"] = direction
	AnimTree["parameters/Walking/blend_position"] = direction
	AnimTree["parameters/VoidBolt/blend_position"] = direction


func SetWalking(value):
	AnimTree["parameters/conditions/Idle"] = not value
	AnimTree["parameters/conditions/Walking"] = value

func VoidBolt(value: bool):
	AnimTree["parameters/conditions/VoidBolt"] = value

#endregion

#region States


enum {
	WANDER,
	COMBAT,
	BEACON,
	PICKUP,
}



func StateMachine():
	match currentState:
		WANDER:
			Wander()
		COMBAT:
			Combat()
		PICKUP:
			PickupItem()
		#BEACON:
			#Beacon()



var seencoords: Array = []

func Wander():
		var maxDistance = 100.0
		var maxDistanceTiles = int(maxDistance / 16.0)
		var potential_positions = []
		for x_offset in range(-maxDistanceTiles, maxDistanceTiles + 1):
			for y_offset in range(-maxDistanceTiles, maxDistanceTiles + 1):
				var potential_pos = round(position / 16) + Vector2(x_offset, y_offset)
				if !seencoords.has(potential_pos):
					potential_positions.append(potential_pos)
		if potential_positions.size() > 0:
			potential_positions.shuffle()
			var new_position = potential_positions.front() * 16
			direction = (new_position - position).normalized()
			var wandertime = randf_range(1, 3)
			velocity = direction * speed
			StateTimer.start(wandertime)
			UpdateSeenCoords(new_position)
			await StateTimer.timeout
			StateMachine()
		else:
			var chooseDirection = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
			chooseDirection.shuffle()
			direction = chooseDirection.front()
			var wandertime = randf_range(1, 3)
			velocity = direction * speed
			StateTimer.start(wandertime)
			await StateTimer.timeout
			UpdateSeenCoords(position + direction * 16)
			StateMachine()

 
func SeenCoords():
	var current_tile = round(position / 16)
	if !seencoords.has(current_tile):
		seencoords.append(current_tile)


func UpdateSeenCoords(pos):
	var new_tile = round(pos / 16)
	if !seencoords.has(new_tile):
		seencoords.append(new_tile)
	var area_position = pos + direction * 16
	var area_tile = round(area_position / 16)
	if !seencoords.has(area_tile):
		seencoords.append(area_tile)


var enemytarget
func Combat():
	for enemy in DetectedArray:
		if enemy != null:
			if enemy.is_in_group("Enemy") and enemy.health >= 0:
				enemytarget = enemy
				#var target_position = enemycombat
				#currentidpath.append(target_position)
				velocity = Vector2.ZERO
				VoidBolt(true)
				StateTimer.start(4.8)
				await StateTimer.timeout
				if DetectedArray.has(enemy):
					currentState = COMBAT
					StateMachine()
				else:
					currentState = WANDER
					StateMachine()
				

const VOID_BOLT = preload("res://Scenes/Abilities/VoidBolt.tscn")
func FireVoidBolt():
	if enemytarget != null:
		direction = enemytarget.position
		velocity = Vector2.ZERO
		var vbolt = VOID_BOLT.instantiate()
		add_child(vbolt)
		vbolt.global_position = $".".global_position
		var enemydirection = (enemytarget.global_position - global_position).normalized()
		vbolt.velocity = enemydirection * vbolt.speed


#func Beacon():
	#for b in DetectedArray:
		#if b.is_in_group("Beacon"):
			#var Ignore: bool = randi() % 2 == 0
			#if Ignore:
				#print("Not Interested in Beacon")
				#DetectedArray.erase(b)
				#b.queue_free()
			#else:
				#print("OMW to Beacon")
				#var idpath = tile_map.astar.get_id_path(tile_map.local_to_map(global_position), tile_map.local_to_map(b.position)).slice(1)
				#if idpath.is_empty() == false:
					#currentidpath = idpath


func PickupItem():
	#target = Vector2i(position)
	if item != null:
		var itemp = item.position
		var idpath = tile_map.astar.get_id_path(tile_map.local_to_map(global_position), tile_map.local_to_map(itemp)).slice(1)
		if idpath.is_empty() == false:
			currentidpath = idpath


func UsePotion():
	if health <= (maxHealth * 0.5) and healthpotions >= 1:
		healthpotions -= 1
		health = maxHealth
		print("Used Potion!")

#endregion


#region Boxes and Timeouts

func PointsTimer():
	Points += 1

func Detected(area):
	if area.get_parent().is_in_group("Enemy"):
		var enemy = area.get_parent()
		DetectedArray.append(enemy)
		Wander()
		print(DetectedArray)
	if area.is_in_group("Beacon"):
		var beacon = area
		DetectedArray.append(beacon)
		Wander()
		print(DetectedArray)
	if area.is_in_group("Pickup"):
		var Item = area
		DetectedArray.append(Item)
		Wander()
		print(DetectedArray)


func NotDetected(area):
	if area.get_parent().is_in_group("Enemy"):
		var enemy = area.get_parent()
		DetectedArray.erase(enemy)
		enemyinRange = false
		print(DetectedArray)
	if area.is_in_group("Beacon"):
		DetectedArray.erase(area)
		beaconinRange = false
		print(DetectedArray)



func PlayerHit(area):
	if area.get_parent().is_in_group("Enemy"):
		target = area.get_parent()
		health -= target.damage
		Knockback(target, area)
	elif area.is_in_group("Blocks"):
		Knockback(target, area)


#endregion

#region other

func LevelUp():
	if currentxp >= requiredxp:
		level += 1
		maxHealth += 10
		health = maxHealth
		damage += 5
		requiredxp = 100 * level
		currentxp = 0

@warning_ignore("shadowed_variable")
func Knockback(enemy, _area, reverse: bool = false):
	var pushback = (enemy.global_position - global_position).normalized() * 30
	if reverse:
		pushback = -pushback
	var KnockbackTween = create_tween()
	if enemy.is_inside_tree() and enemy != null:
		KnockbackTween.tween_property(enemy, "position", enemy.position + pushback, 0.2)

func Death():
	if health <= 0:
		get_tree().quit()

#endregion


var item
func ItemDetection(area):
	if area.is_in_group("Pickup"):
		item = area
		currentState = PICKUP
		print("Found Item!")



func Seenreset():
	seencoords = []


func StateTimerTimeout():
	if !DetectedArray.is_empty():
		for i in DetectedArray:
			if i.is_in_group("Enemy"):
				currentState = COMBAT
				return
			if i.is_in_group("Beacon"):
				currentState = BEACON
				return
	else:
		currentState = WANDER
