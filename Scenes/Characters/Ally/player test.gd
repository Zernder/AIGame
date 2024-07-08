class_name PlayerTestScene extends CharacterBody2D

class banana extends PlayerTestScene:
	pass

#region The Variables

@export var health: float
@export var maxHealth: float
@export var level: int
@export var damage: float
@export var speed: float
@onready var currentxp: int = 0
@onready var requiredxp: int = 1 * level
@onready var vision: Array = []
@onready var memory: Array = []


@onready var tilemap = $"../TileMap"
var direction: Vector2
var DetectedArray: Array = []
@onready var NavAgent = $NavigationAgent2D


#endregion


#region The Runtimes


func _ready():
	currentState = IDLE
	StateMachine()
	$UI/Profile/Healthbar.max_value = maxHealth
	health = maxHealth


func _process(_delta):
	UsePotion()
	UIProcess()
	LevelUp()

func _physics_process(delta):
	Death()
	var collision = move_and_collide(velocity * delta)
	if collision:
		Idle()
		UpdateBlend()

func UIProcess():
	$UI/Profile/Healthbar.max_value = maxHealth
	$UI/Profile/Healthbar.value = health
	$UI/Profile/Healthbar/healthlabel.text = str(health) + "/" + str(maxHealth)
	$UI/Profile/Expbar.value = currentxp
	$UI/Profile/Expbar.max_value = requiredxp
	$UI/Profile/LevelLabel.text = "Level: " + str(level)


#endregion


#region StateMachine


enum {
	IDLE,
	WANDER,
	COMBAT,
	BEACON,
	PICKUP,
}


var currentState
@onready var StateTimer = $Timers/StateTimeout
func StateMachine():
	match currentState:
		IDLE:
			#print("Idle")
			Idle()
		WANDER:
			print("Wander")
			Wander()
		COMBAT:
			#print("Combat")
			Combat()
	#if currentState == IDLE:
		#currentState = WANDER


#endregion


#region Idle and Wander


var IdleTime = randf_range(1, 8)
@onready var poi = $"../POI"
@onready var idle_timer = $Timers/IdleTimer

func Idle():
	velocity = Vector2.ZERO
	SetWalking(false)
	UpdateBlend()
	idle_timer.start(IdleTime)
	print(idle_timer.time_left)


func IdleTimeout():
	currentState = WANDER
	StateMachine()


var went: bool = false
func ChooseDirection():
	pass

func Wander():
	var visionmarker
	var memorymarker
	if !vision.is_empty():
		vision.shuffle()
		visionmarker = vision.front()
		went = true
		NavAgent.target_position = visionmarker.global_position
		print(visionmarker)
		vision.erase(vision.front())
	elif vision.is_empty() and went == true:
		memory.shuffle()
		memorymarker = memory.front()
		NavAgent.target_position = memorymarker.global_position
	else:
		currentState = IDLE
		StateTimer.start(IdleTime)
	SetWalking(true)
	UpdateBlend()


func MakePath():
	if currentState == WANDER:
		direction = to_local(NavAgent.get_next_path_position()).normalized()
		velocity = direction * speed
		SetWalking(true)
		UpdateBlend()
		if NavAgent.distance_to_target() <= 5:
			currentState = IDLE
			StateMachine()


func Visual(area):
	if area.is_in_group("POI"):
		vision.append(area)
		memory.append(area)


func NotVisual(area):
	if area.is_in_group("POI"):
		vision.erase(area)
		if area.is_in_group("potion"):
			memory.erase(area)

#endregion


#region Combat

func EnemyDetected(area):
	if area.get_parent().is_in_group("Enemy"):
		var enemy = area.get_parent()
		DetectedArray.append(enemy)
		currentState = COMBAT
		CombatStance(true)
		StateMachine()


var enemytarget
func Combat():
	for enemy in DetectedArray:
		if enemy != null:
			if enemy.is_in_group("Enemy"):
					enemytarget = enemy
					direction = enemytarget.position
					if enemytarget.health <= 0:
						enemytarget = null
					velocity = Vector2.ZERO
					VoidBolt(true)
					if enemytarget == null:
						velocity = Vector2.ZERO
						VoidBolt(false)
						currentState = IDLE
		StateTimer.start(0.5)

const VOID_BOLT = preload("res://Scenes/Abilities/VoidBolt.tscn")
func FireVoidBolt():
	var vbolt = VOID_BOLT.instantiate()
	if enemytarget == null:
		velocity = Vector2.ZERO
		VoidBolt(false)
		currentState = IDLE
		StateTimer.start(0.5)
	if enemytarget != null:
		direction = enemytarget.position
		StateTimer.start(0.5)
		UpdateBlend()
		add_child(vbolt)
		vbolt.global_position = $".".global_position
		var enemydirection = (enemytarget.global_position - global_position).normalized()
		vbolt.velocity = enemydirection * vbolt.speed


func TakeDamage(area):
	if area.get_parent().is_in_group("Enemy"):
		var enemy = area.get_parent()
		health -= enemy.damage
		Knockback(enemy, area)


#endregion


#region Items

var item
func ItemDetection(area):
	if area.is_in_group("Pickup"):
		item = area
		currentState = PICKUP

var PotionNearby: bool = false
var healthpotions: int = 5
func UsePotion():
	if health <= (maxHealth / 2) and healthpotions >= 1:
		healthpotions -= 1
		health = maxHealth
		print("Used Potion!")

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

func Knockback(target, _area, reverse: bool = false):
	var pushback = (target.global_position - global_position).normalized() * 30
	if reverse:
		pushback = -pushback
	var KnockbackTween = create_tween()
	if target.is_inside_tree() and target != null:
		KnockbackTween.tween_property(target, "position", target.position + pushback, 0.2)

func Death():
	if health <= 0:
		get_tree().quit()

#endregion


#region Animations


@onready var AnimTree = $AnimationTree
@onready var AnimPlayer = $AnimationPlayer

func SetWalking(value):
	AnimTree["parameters/conditions/Idle"] = not value
	AnimTree["parameters/conditions/Walking"] = value


func VoidBolt(value: bool):
	AnimTree["parameters/conditions/VoidBolt"] = value
	AnimTree["parameters/conditions/Reset"] = not value

func CombatStance(value: bool):
	AnimTree["parameters/conditions/Combat"] = value


func UpdateBlend():
	AnimTree["parameters/Idle/blend_position"] = direction
	AnimTree["parameters/Walking/blend_position"] = direction
	#AnimTree["parameters/CombatStance/blend_position"] = direction
	#AnimTree["parameters/VoidBolt/blend_position"] = direction

#endregion


