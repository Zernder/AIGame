class_name EnemyBaseScene extends CharacterBody2D


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

var direction: Vector2
@onready var NavAgent = $NavigationAgent2D

#endregion



#region The Runtimes


func _ready():
	currentState = IDLE
	StateMachine()
	health = maxHealth


func _process(_delta):
	pass


func _physics_process(delta):
	Death()
	var collision = move_and_collide(velocity * delta)
	if collision:
		Idle()


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
@onready var statetimer = $Timers/StateTimer
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


var IdleTime = randf_range(1, 3)
@onready var poi = $"../../POI"
@onready var idle_timer = $Timers/IdleTimer

func Idle():
	velocity = Vector2.ZERO
	idle_timer.start(IdleTime)


func IdleTimeout():
	if currentState != COMBAT:
		currentState = WANDER
		StateMachine()


var went: bool = false
func Wander():
	var VisionArraymarker
	var MemoryArraymarker
	if !VisionArray.is_empty():
		VisionArray.shuffle()
		VisionArraymarker = VisionArray.front()
		went = true
		NavAgent.target_position = VisionArraymarker.global_position

		VisionArray.erase(VisionArray.front())
	elif VisionArray.is_empty() and went == true:
		MemoryArray.shuffle()
		MemoryArraymarker = MemoryArray.front()
		if MemoryArraymarker != null:
			NavAgent.target_position = MemoryArraymarker.global_position
	else:
		currentState = IDLE
		statetimer.start(IdleTime)


func MakePath():
	if currentState == WANDER:
		direction = to_local(NavAgent.get_next_path_position()).normalized()
		velocity = direction * speed
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


func Combat():
	for i in EnemyArray:
		if i.is_in_group("player"):
			var target = i.global_position
			velocity = (target - global_position).normalized() * speed
			if global_position.distance_to(target) <= 10:
				velocity = -direction * speed


func EnemyDetected(area):
	var character = area.get_parent()
	if character.is_in_group("Player"):
		EnemyArray.append(character)
		currentState = COMBAT


func EnemyLost(area):
	var character = area.get_parent()
	if character.is_in_group("Player"):
		EnemyArray.erase(character)
		if EnemyArray.is_empty():
			currentState = IDLE


func Death():
	if health <= 0:
		queue_free()



func Knockback(enemy, _area, reverse: bool = false):
	var pushback = (enemy.global_position - global_position).normalized() * 30
	if reverse:
		pushback = -pushback
	var KnockbackTween = create_tween()
	if enemy.is_inside_tree() and enemy != null:
		KnockbackTween.tween_property(enemy, "position", enemy.position + pushback, 0.2)


func _on_hurtbox_area_entered(area):
	Knockback($".", area)






