class_name AutumnScene extends GameStats


#region The Variables

@onready var Tamaneko = get_tree().get_first_node_in_group("Tamaneko")
var followTama: bool = false
var DistanceToTama: int = 0


#endregion


#region The Runtimes

func _ready():
	currentState = IDLE
	StateMachine()
	health = maxHealth

func _physics_process(delta):
	super._physics_process(delta)
	var collision = move_and_collide(velocity * delta)
	if collision:
		Idle()
		UpdateBlend()

func _input(event):
	CharacterSheet()


#endregion


#region StateMachine

#region Setup

enum {
	IDLE,
	EXPLORE,
	COMBAT,
	FOLLOW,
}


var currentState
@onready var StateTimer = $Timers/StateTimeout
func StateMachine():
	Whatif()
	match currentState:
		IDLE:
			Idle()
		EXPLORE:
			Explore()
			#print("Explore")
		COMBAT:
			Combat()
		FOLLOW:
			FollowTama()


var ExploreDecision: Array = [EXPLORE, EXPLORE, IDLE,]
func Whatif():
	if Tamaneko and followTama:
		currentState = FOLLOW
	elif !EnemyArray.is_empty():
		currentState = COMBAT
		wordsin_speech_bubble.text = "Entering Combat!"
	else:
		ExploreDecision.shuffle()
		var choose = ExploreDecision.front()
		currentState = choose

#endregion


#region States

#region Idle

var IdleTime = randf_range(1, 3)
@onready var idle_timer = $Timers/IdleTimer

func Idle():
	SetWalking(false)
	UpdateBlend()
	idle_timer.start(IdleTime)
	wordsin_speech_bubble.text = "Hanging out"


func IdleTimeout():
	StateMachine()

#endregion


#region Explore

@onready var wordsin_speech_bubble = $SpeechBubble/WordsinSpeechBubble
func FollowTama():
		DistanceToTama = global_position.distance_to(Tamaneko.global_position)
		NavAgent.target_position = Tamaneko.global_position
		wordsin_speech_bubble.text = "Following Tama"
		SetWalking(true)
		UpdateBlend()

var whichfloor = 1
var Room
@onready var waypoints = $"../Waypoints"
@onready var ExploreArray: Array = []
@onready var area_one = $"../Waypoints/AreaOne"
@onready var bedroom_one = $"../Waypoints/BedroomOne"


func Explore():
	ExploreArray.clear()
	if ExploreArray.is_empty():
		if whichfloor == 1:
			Room = area_one
		elif whichfloor == 2:
			Room = bedroom_one
		for child in Room.get_children():
			if child.is_in_group("POI"):
				ExploreArray.append(child)
	ExploreArray.shuffle()
	var Marker = ExploreArray.pop_back()
	print(Marker)
	NavAgent.target_position = Marker.global_position
	wordsin_speech_bubble.text = "Exploring"
	ExploreArray.clear()
	SetWalking(true)
	UpdateBlend()

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
			followTama = false
			enemytarget = enemy
			var enemyDistance = global_position.distance_to(enemytarget.global_position)
			if enemytarget.health <= 0:
				EnemyArray.erase(enemytarget)
				enemytarget.queue_free()
				StateMachine()
				break
			if enemyDistance >= 30 and mana >= 20:
				wordsin_speech_bubble.text = "Casting Voidbolt!"
				VoidBolt(true)
				UpdateBlend()
				break
			elif enemyDistance < 10:
				wordsin_speech_bubble.text = "VOID PUNCH!"
				SwingVoidPunch()
				UpdateBlend()
				break
			else:
				StateTimer.start(0.5)
	if enemytarget == null:
		EnemyArray.erase(enemytarget)
		CombatStance(false)
		VoidBolt(false)
		StateTimer.start(0.8)
		currentState = IDLE



func SwingVoidPunch():
	var enemyDistance = global_position.distance_to(enemytarget.global_position)
	if enemyDistance < 30:
		enemytarget.health -= (magicalDamage - enemytarget.physicalDefense)
		VoidPunch(false)
		currentState = IDLE
		StateTimer.start(0.5)


const VOID_BOLT = preload("res://Scenes/Abilities/VoidBolt.tscn")
func FireVoidBolt():
	for enemy in EnemyArray:
		if enemy != null and mana >= 20:
			direction = global_position.direction_to(enemytarget.global_position)
			UpdateBlend()
			var vbolt = VOID_BOLT.instantiate()
			add_child(vbolt)
			vbolt.global_position = global_position
			var enemydirection = (enemytarget.global_position - global_position).normalized()
			vbolt.velocity = enemydirection * vbolt.speed
			mana -= 20
			break
	StateTimer.start(1) 


func TakeDamage(area):
	if area.get_parent().is_in_group("enemy"):
		var enemy = area.get_parent()
		health -= enemy.physicalDamage
		Knockback(enemy, area)


#endregion

#endregion

#endregion


#region Navigation

func MakePath():
	if currentState == EXPLORE or currentState == FOLLOW:
		direction = to_local(NavAgent.get_next_path_position()).normalized()
		velocity = direction * speed
		SetWalking(true)
		UpdateBlend()
		if NavAgent.distance_to_target() <= 10:
			StateMachine()
	elif currentState == COMBAT or currentState == IDLE:
		velocity = Vector2.ZERO
		SetWalking(false)
		UpdateBlend()

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


#region Character Sheet

@onready var character_sheet = $"UI/Character Sheet"
var mouseEntered: bool = false
func MouseEntered():
	mouseEntered = true
	print(mouseEntered)

func MouseExited():
	mouseEntered = false
	print(mouseEntered)

func CharacterSheet():
	if Input.is_action_just_pressed("LeftClick") and mouseEntered == true:
		if character_sheet.visible:
			character_sheet.hide()
		else:
			character_sheet.show()


#endregion


