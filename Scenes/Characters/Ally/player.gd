class_name PlayerBaseScene extends CharacterBody2D

#region The Variables


@export var health: float
@export var maxHealth: float
@export var level: int
@export var damage: float
@export var speed: float

@onready var currentxp: int = 0
@onready var requiredxp: int = 1 * level
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
		UpdateBlend()
		Wander()


func UIProcess():
	$UI/Profile/Healthbar.max_value = maxHealth
	$UI/Profile/Healthbar.value = health
	$UI/Profile/Healthbar/healthlabel.text = str(health) + "/" + str(maxHealth)
	$UI/Profile/Expbar.value = currentxp
	$UI/Profile/Expbar.max_value = requiredxp
	$UI/Profile/LevelLabel.text = "Level: " + str(level)


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
	AnimTree["parameters/CombatStance/blend_position"] = direction
	AnimTree["parameters/VoidBolt/blend_position"] = direction


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
			#print("Combat")
			Combat()
	if currentState == IDLE or currentState == WANDER:
		CheckMovement()
	if currentState == COMBAT:
		Combat()


#endregion


#func MouseMovement():
	#if Input.is_action_just_pressed("move"):
		#var idpath = tilemap.astar.get_id_path(tilemap.local_to_map(global_position), tilemap.local_to_map(get_global_mouse_position())).slice(1)
		#if idpath.is_empty() == false:
			#currentidpath = idpath


#func GridMovement():
	#if currentidpath.is_empty():
		#return
	#var targetposition = tilemap.map_to_local(currentidpath.front())
	#global_position = global_position.move_toward(targetposition, 1)
	#if global_position == targetposition:
		#currentidpath.pop_front()


#region Idle and Wander

var wandertime = randf_range(1, 3)

func CheckMovement():
	var ChooseWalk = [WANDER, WANDER, WANDER, IDLE]
	ChooseWalk.shuffle()
	var Choice = ChooseWalk.front()
	if Choice == IDLE:
		currentState = IDLE
	if Choice == WANDER:
		currentState = WANDER


func Idle():
	velocity = Vector2.ZERO
	SetWalking(false)
	UpdateBlend()
	StateTimer.start(wandertime)

@onready var nav_markers = $"../NavMarkers"

func Wander():
	var chosendirection: Array = nav_markers.get_children()
	print(chosendirection)
	chosendirection.shuffle()
	var chosen_marker: Node2D = chosendirection.front()
	NavAgent.target_position += chosen_marker.global_position
	SetWalking(true)
	UpdateBlend()
	#var direction =  to_local(NavAgent.get_next_path_position()).normalized()
	velocity = direction * speed
	StateTimer.start(wandertime)


func MakePath():
	pass

#func SeenCoords():
	#var current_tile = round(position / 16)
	#if !seencoords.has(current_tile):
		#seencoords.append(current_tile)
#
#
#var seencoords: Array = []
#func Seenreset():
	#seencoords = []

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


const VOID_BOLT = preload("res://Scenes/Abilities/VoidBolt.tscn")
func FireVoidBolt():
	var vbolt = VOID_BOLT.instantiate()
	if enemytarget == null:
		velocity = Vector2.ZERO
		VoidBolt(false)
		currentState = IDLE
		SetWalking(true)
		velocity = Vector2.ZERO
	if enemytarget != null:
		direction = enemytarget.position
		StateTimer.start(3)
		UpdateBlend()
		add_child(vbolt)
		vbolt.global_position = $".".global_position
		var enemydirection = (enemytarget.global_position - global_position).normalized()
		vbolt.velocity = enemydirection * vbolt.speed
		direction = enemytarget.position


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


#func test():
	#for x in tilemap.tilemapsize.x:
		#for y in tilemap.tilemapsize.y:
			#var tilepos = Vector2i(x, y)
			#var tiledata = tilemap.get_cell_tile_data(0, tilepos)
			#if tilemap.tiledata and tilemap.tiledata.get_custom_data('Type') == "Potion":
				#print("part working")
				#if detectbox.get_overlapping_areas():
					#print("Found Potion")
					




