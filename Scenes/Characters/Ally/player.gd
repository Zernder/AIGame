class_name AutumnScene extends CharacterBody2D


#region The Variables

@export_category("Stats")
@export var health: float
@export var maxHealth: float
@export var stamina: float
@export var maxStamina: float
@export var mana: float
@export var maxMana: float
@export var level: int
@export var skillPoints: int

@export var physicalDamage: float
@export var magicalDamage: float
@export var physicalDefense: float
@export var magicalDefense: float

@export var speed: float
@onready var currentxp: int = 0
@onready var requiredxp: int = 1 * level

@onready var EnemyArray: Array = []

var direction: Vector2
@onready var NavAgent = $NavigationAgent2D

var healthPotion: int = 1
var staminaPotion: int = 1
var manaPotion: int = 1

#endregion


#region The Runtimes


func _ready():
	currentState = IDLE
	StateMachine()
	health = maxHealth


func _process(_delta):
	#UsePotion()
	UIProcess()
	LevelUp()


func _physics_process(delta):
	Death()
	var collision = move_and_collide(velocity * delta)
	if collision:
		Idle()
		UpdateBlend()

func _input(_event):
	CharacterSheet()
	ItemsList()

@onready var health_bar = $"UI/Profile/Health Bar"
@onready var stamina_bar = $"UI/Profile/Stamina Bar"
@onready var mana_bar = $"UI/Profile/Mana Bar"
@onready var expbar = $UI/Profile/Expbar

@onready var level_label = $UI/Profile/LevelLabel
@onready var health_label = $"UI/Profile/Health Bar/Health Label"
@onready var stamina_label = $"UI/Profile/Stamina Bar/Stamina Label"
@onready var mana_label = $"UI/Profile/Mana Bar/Mana Label"

func UIProcess():
	level_label.text = "Level: " + str(level)
	health_bar.value = health
	health_bar.max_value = maxHealth
	health_label.text = str(health) + "/" + str(maxHealth)
	
	stamina_bar.value = stamina
	stamina_bar.max_value = maxStamina
	stamina_label.text = str(stamina) + "/" + str(maxStamina)
	
	mana_bar.value = mana
	mana_bar.max_value = maxMana
	mana_label.text = str(mana) + "/" + str(maxMana)
	
	expbar.value = currentxp
	expbar.max_value = requiredxp



#endregion


#region StateMachine

enum {
	IDLE,
	WANDER,
	COMBAT,
}


var currentState
@onready var StateTimer = $Timers/StateTimeout
func StateMachine():
	match currentState:
		IDLE:
			#print("Idle")
			Idle()
		WANDER:
			#print("Wander")
			Wander()
		COMBAT:
			#print("Combat")
			Combat()


#endregion


#region Idle and Wander

@onready var VisitedArray: Array = []
@onready var VisionArray: Array = []

var IdleTime = randf_range(1, 3)
@onready var poi = $"../POI"
@onready var idle_timer = $Timers/IdleTimer

func Idle():
	velocity = Vector2.ZERO
	SetWalking(false)
	UpdateBlend()
	idle_timer.start(0.5)


func IdleTimeout():
	if currentState != COMBAT:
		currentState = WANDER
		StateMachine()


func Wander():
	var VisionArraymarker
	var visitedArrayMarker
	if !VisionArray.is_empty():
		for marker in VisionArray:
			if marker and marker.global_position not in VisitedArray:
				VisionArraymarker = marker
				break
		if VisionArraymarker:
			NavAgent.target_position = VisionArraymarker.global_position
			VisitedArray.append(VisionArraymarker)
			VisionArray.erase(VisionArraymarker)
	elif VisionArray.is_empty():
		VisitedArray.shuffle()
		for marker in VisitedArray:
			if marker and marker.global_position:
				visitedArrayMarker = marker
				break
		if visitedArrayMarker:
			NavAgent.target_position = visitedArrayMarker.global_position
		else:
			VisitedArray.shuffle()
			for marker in VisitedArray:
				if marker:
					visitedArrayMarker = marker
					break
			if visitedArrayMarker:
				NavAgent.target_position = visitedArrayMarker
	else:
		var Rest: Array = [IDLE, WANDER, WANDER, WANDER]
		Rest.shuffle()
		var ShouldIRest = Rest.front()
		currentState = ShouldIRest
		StateTimer.start(0.2)
		if ShouldIRest == WANDER:
			pass
	SetWalking(true)
	UpdateBlend()


func MakePath():
	if currentState == WANDER:
		direction = to_local(NavAgent.get_next_path_position()).normalized()
		velocity = direction * speed
		SetWalking(true)
		UpdateBlend()
		if NavAgent.distance_to_target() <= 10:
			currentState = IDLE
			StateMachine()
	#elif currentState == COMBAT:
		#direction = to_local(NavAgent.get_next_path_position()).normalized()
		#velocity = -direction * speed
		##SetWalking(true)
		##UpdateBlend()


func Visual(area):
	if area.is_in_group("POI") and !VisitedArray.has(area):
		VisionArray.append(area)

#endregion


#region Combat

func EnemyDetected(body):
	if body.is_in_group("enemy"):
		var enemy = body
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
				direction = enemytarget.global_position
				NavAgent.target_position = enemytarget.global_position
				velocity = Vector2.ZERO
				if enemytarget.health <= 0:
					enemytarget = null
				if enemytarget != null:
					var distance_to_enemy = NavAgent.distance_to_target()
					if distance_to_enemy >= 100 and mana >= 20:
						direction = enemytarget.global_position
						velocity = Vector2.ZERO
						VoidBolt(true)
						UpdateBlend()
						print(mana)
					elif distance_to_enemy > 30 and mana < 20:
						await AnimTree.animation_finished
						direction = (NavAgent.get_next_path_position() - global_position).normalized()
						velocity = direction * speed
						SetWalking(true)
						UpdateBlend()
					elif distance_to_enemy <= 20 and mana < 20:
						VoidBolt(false)
						await AnimTree.animation_finished
						SwingVoidPunch()
						UpdateBlend()
					if enemytarget.health <= 0:
						enemytarget = null
						velocity = Vector2.ZERO
						VoidBolt(false)
						await AnimTree.animation_finished
						currentState = IDLE
						StateTimer.start(0.2)
				StateTimer.start(2)


func SwingVoidPunch():
	print("Falcon PUNCH!")
	enemytarget.health -= (physicalDamage - enemytarget.physicalDefense)
	StateTimer.start(0.5)


const VOID_BOLT = preload("res://Scenes/Abilities/VoidBolt.tscn")
func FireVoidBolt():
	if mana >= 20:
		var vbolt = VOID_BOLT.instantiate()
		if enemytarget == null:
			velocity = Vector2.ZERO
			VoidBolt(false)
			currentState = IDLE
			StateTimer.start(0.8)
		if enemytarget != null:
			velocity = Vector2.ZERO
			direction = enemytarget.position
			StateTimer.start(0.5)
			UpdateBlend()
			add_child(vbolt)
			vbolt.global_position = $".".global_position
			var enemydirection = (enemytarget.global_position - global_position).normalized()
			vbolt.velocity = enemydirection * vbolt.speed
			mana -= 20
			if enemytarget == null:
				velocity = Vector2.ZERO
				VoidBolt(false)
				currentState = IDLE
				StateTimer.start(0.8)
	else:
		StateTimer.start(0.5)


func TakeDamage(area):
	if area.get_parent().is_in_group("enemy"):
		var enemy = area.get_parent()
		health -= enemy.physicalDamage
		Knockback(enemy, area)


#endregion


#region Items

#var item
#func ItemDetection(area):
	#if area.is_in_group("Pickup"):
		#item = area
		#currentState = PICKUP

#var PotionNearby: bool = false


#func UsePotion():
	#if health <= (maxHealth / 2) and healthpotions >= 1:
		#healthpotions -= 1
		#health = maxHealth
		#print("Used Potion!")

#endregion


#region other

func LevelUp():
	if currentxp >= requiredxp:
		level += 1
		skillPoints += 5
		health = maxHealth
		physicalDamage += 5
		magicalDamage += 5
		speed += 1
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

func VoidPunch(value: bool):
	AnimTree["parameters/conditions/VoidPunch"] = value
	AnimTree["parameters/conditions/Reset"] = not value


func VoidBolt(value: bool):
	AnimTree["parameters/conditions/VoidBolt"] = value
	AnimTree["parameters/conditions/Reset"] = not value


func CombatStance(value: bool):
	AnimTree["parameters/conditions/Combat"] = value


func UpdateBlend():
	AnimTree["parameters/Idle/blend_position"] = direction
	AnimTree["parameters/Walking/blend_position"] = direction
	AnimTree["parameters/CombatStance/blend_position"] = direction
	AnimTree["parameters/VoidBolt/blend_position"] = direction
	AnimTree["parameters/VoidPunch/blend_position"] = direction

#endregion


#region Character Sheet and UI

@onready var character_sheet = $"UI/Character Sheet"
func CharacterSheet():
	if Input.is_action_just_pressed("Character Sheet"):
		if character_sheet.visible:
			character_sheet.hide()
		else:
			character_sheet.show()


@onready var items = $UI/Items
func ItemsList():
	if Input.is_action_just_pressed("Inventory"):
		if items.visible:
			items.hide()
		else:
			items.show()


#endregion


func RegenerationTimeout():
	if mana < maxMana:
		mana += min(3, maxMana - mana)
	if health < maxHealth:
		health += min(1, maxHealth - health)
	if stamina < maxStamina:
		stamina += min(10, maxStamina - stamina)


