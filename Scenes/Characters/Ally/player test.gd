class_name PlayerTestScene extends CharacterBody2D


#region The Variables

@export_category("Stats")
@export var health: float
@export var maxHealth: float
@export var level: int

@export var physicalDamage: float
@export var magicalDamage: float
@export var physicalDefense: float
@export var magicalDefense: float

@export var speed: float
@onready var currentxp: int = 0
@onready var requiredxp: int = 1 * level

@onready var VisionArray: Array = []
@onready var MemoryArray: Array = []
@onready var EnemyArray: Array = []

@onready var tilemap = $"../TileMap"
var direction: Vector2
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
			print("Idle")
			Idle()
		WANDER:
			print("Wander")
			Wander()
		COMBAT:
			print("Combat")
			Combat()


#endregion


#region Idle and Wander


var IdleTime = randf_range(1, 3)
@onready var poi = $"../POI"
@onready var idle_timer = $Timers/IdleTimer

func Idle():
	velocity = Vector2.ZERO
	SetWalking(false)
	UpdateBlend()
	idle_timer.start(IdleTime)


func IdleTimeout():
	if currentState != COMBAT:
		currentState = WANDER
		StateMachine()

var visitedPositions: Array = []
var went: bool = false
func Wander():
	var VisionArraymarker
	var MemoryArraymarker
	if !VisionArray.is_empty():
		VisionArray.shuffle()
		VisionArraymarker = VisionArray.front()
		if VisionArraymarker.global_position not in visitedPositions:
			visitedPositions.append(VisionArraymarker.global_position)
			NavAgent.target_position = VisionArraymarker.global_position
		else:
			currentState = IDLE
			StateMachine()
		#for marker in VisionArray:
			#if marker and marker.global_position not in visitedPositions:
				#VisionArraymarker = marker
				#break
		#if VisionArraymarker:
			#went = true
			#
			#VisionArray.erase(VisionArraymarker)
			#visitedPositions.append(VisionArraymarker.global_position)
	#elif VisionArray.is_empty() and went == true:
		#MemoryArray.shuffle()
		#for marker in MemoryArray:
			#if marker != null:
				#if marker and marker.global_position not in visitedPositions:
					#MemoryArraymarker = marker
					#break
		#if MemoryArraymarker:
			#NavAgent.target_position = MemoryArraymarker.global_position
			#visitedPositions.append(MemoryArraymarker.global_position)
		#else:
			#visitedPositions.shuffle()
			#for marker in visitedPositions:
				#if marker and marker.global_position:
					#MemoryArraymarker = marker
					#break
			#if MemoryArraymarker:
				#NavAgent.target_position = MemoryArraymarker.global_position
	#else:
		#currentState = IDLE
		#StateTimer.start(IdleTime)
	#SetWalking(true)
	#UpdateBlend()


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
	if area.is_in_group("POI") and !MemoryArray.has(area):
		VisionArray.append(area)
		MemoryArray.append(area)

func NotVisual(area):
	if area.is_in_group("POI"):
		VisionArray.erase(area)
		if area.is_in_group("potion"):
			MemoryArray.erase(area)

#endregion


#region Combat

func EnemyDetected(area):
	if area.get_parent().is_in_group("enemy"):
		var enemy = area.get_parent()
		EnemyArray.append(enemy)
		currentState = COMBAT
		CombatStance(true)
		StateMachine()


var enemytarget
func Combat():
	for enemy in EnemyArray:
		if enemy != null:
			if enemy.is_in_group("enemy"):
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
		StateTimer.start(0.8)
	if enemytarget != null:
		direction = enemytarget.position
		StateTimer.start(0.5)
		UpdateBlend()
		add_child(vbolt)
		vbolt.global_position = $".".global_position
		var enemydirection = (enemytarget.global_position - global_position).normalized()
		vbolt.velocity = enemydirection * vbolt.speed


func TakeDamage(area):
	if area.get_parent().is_in_group("enemy"):
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
		physicalDamage += 5
		magicalDamage += 5
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


