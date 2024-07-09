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
@onready var StateTimer = $Timers/StateTimer
func StateMachine():
	match currentState:
		IDLE:
			Idle()
		WANDER:
			Wander()
		COMBAT:
			Combat()


#endregion


#region Idle and Wander

@onready var VisitedArray: Array = []
@onready var VisionArray: Array = []

var IdleTime = randf_range(1, 3)
@onready var idle_timer = $Timers/IdleTimer

func Idle():
	velocity = Vector2.ZERO
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


func MakePath():
	if currentState == WANDER:
		direction = to_local(NavAgent.get_next_path_position()).normalized()
		velocity = direction * speed
		if NavAgent.distance_to_target() <= 10:
			currentState = IDLE
			StateMachine()


func Visual(area):
	if area.is_in_group("POI") and !VisitedArray.has(area):
		VisionArray.append(area)


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






