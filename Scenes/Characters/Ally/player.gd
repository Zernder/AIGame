class_name AllyBaseScene extends CharacterBody2D


@export var health: float
@export var maxHealth: float
@export var level: int
@export var damage: float
@export var speed: float
@export var Points: int

@onready var currentxp: int = 0
@onready var requiredxp: int = 100 * level
@onready var tile_map = $"../TileMap"

#region UI Imports

@onready var panel = $UI/Panel
@onready var points = $UI/Panel/Points
@onready var directions = $UI/Panel/Directions
@onready var profile = $UI/Profile
@onready var levellabel = $UI/Profile/LevelLabel
@onready var healthbar = $UI/Profile/Healthbar
@onready var healthlabel = $UI/Profile/Healthbar/healthlabel
@onready var expbar = $UI/Profile/Expbar
#@onready var navagent = $NavigationAgent2D

#endregion

var beacon
var BeaconArray: Array = []
var beaconinRange: bool = false

var enemy
var EnemyArray: Array = []
var enemyinRange: bool = false

var target
var direction: Vector2 = Vector2()
var currentState

var agrid: AStarGrid2D
var currentidpath: Array[Vector2i]

func _ready():
	currentState = WANDER
	healthbar.max_value = maxHealth
	health = maxHealth

func _process(_delta):
	UIProcess()
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
}



func StateMachine():
	match currentState:
		WANDER:
			Wander()
		COMBAT:
			Combat()
		BEACON:
			Beacon()


func StateTimeout():
	StateMachine()

@onready var StateTimer = $Timers/StateTimeout

func Wander():
	if EnemyArray.is_empty() == false:
		currentState = COMBAT
	if BeaconArray.is_empty() == false:
		currentState = BEACON
	else:
		var chooseDirection = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
		chooseDirection.shuffle()
		direction = chooseDirection.front()
		var wandertime = randf_range(1,3)
		velocity = direction * speed
		StateTimer.start(wandertime)


var enemycombat
func Combat():
	var safe_distance = 10
	for e in EnemyArray:
		if e != null:
			if e.is_in_group("Enemy"):
				enemycombat = e.global_position
				var distance_to_enemy = global_position.distance_to(enemycombat)
				if distance_to_enemy < safe_distance:
					var direction_away = (global_position - enemycombat).normalized()
					var target_position = enemycombat + direction_away * safe_distance
					currentidpath.append(target_position)
					#velocity = target * speed
				else:
					velocity = Vector2.ZERO
				VoidBolt(true)

const VOID_BOLT = preload("res://Scenes/Abilities/VoidBolt.tscn")
func FireVoidBolt():
	velocity = Vector2.ZERO
	VoidBolt(true)
	var vbolt = VOID_BOLT.instantiate()
	add_child(vbolt)
	vbolt.global_position = $".".global_position
	var direction_to_enemy = (enemycombat - global_position).normalized()
	vbolt.velocity = direction_to_enemy * vbolt.speed


func Beacon(): 
	for b in BeaconArray:
		if b.is_in_group("Beacon"):
			var BPosition = Vector2i(b.position)
			var idpath = tile_map.astar.get_id_path(tile_map.local_to_map(global_position), tile_map.local_to_map(b.position)).slice(1)
			if idpath.is_empty() == false:
				currentidpath = idpath

#endregion

#region Boxes and Timeouts

func PointsTimer():
	Points += 1

func Detected(area):
	if area.get_parent().is_in_group("Enemy"):
		@warning_ignore("shadowed_variable")
		var enemy = area.get_parent()
		EnemyArray.append(enemy)
		enemyinRange = true
		target = enemy
		currentState = COMBAT

func NotDetected(area):
	if area.get_parent().is_in_group("Enemy"):
		@warning_ignore("shadowed_variable")
		var enemy = area.get_parent()
		EnemyArray.erase(enemy)
		currentState = WANDER

func PlayerHit(area):
	if area.get_parent().is_in_group("Enemy"):
		target = area.get_parent()
		health -= target.damage
		Knockback(target, area)
	elif area.is_in_group("Blocks"):
		Knockback(target, area)

func BeaconDetected(area):
	if area.is_in_group("Beacon"):
		BeaconArray.append(area)
		currentState = BEACON
		print("Beacon")

func BeaconLost(area):
	if area.is_in_group("Beacon"):
		BeaconArray.erase(area)
		currentState = WANDER

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

