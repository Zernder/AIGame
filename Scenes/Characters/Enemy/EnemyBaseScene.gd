class_name EnemyBaseScene extends GameStats



#region The Runtimes

func _ready():
	currentState = IDLE
	StateMachine()
	health = maxHealth


func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		Idle()

#endregion


#region StateMachine

enum {
	IDLE,
	EXPLORE,
	COMBAT,
}


var currentState
func StateMachine():
	if !EnemyArray.is_empty():
		currentState = COMBAT
	match currentState:
		IDLE:
			Idle()
		EXPLORE:
			Explore()
		COMBAT:
			Combat()

#endregion


#region Idle and LOOKAROUND

var IdleTime = randf_range(1, 5)
@onready var idle_timer = $Timers/IdleTimer

func Idle():
	idle_timer.start(IdleTime)


func IdleTimeout():
	currentState = EXPLORE
	StateMachine()


@onready var waypoints = $"../../Waypoints"
@onready var bedroom_one = $"../../Waypoints/BedroomOne"
@onready var area_one = $"../../Waypoints/AreaOne"

@onready var ExploreArray: Array = []

func Explore():
	ExploreArray.clear()
	if ExploreArray.is_empty():
		for child in bedroom_one.get_children():
			if child.is_in_group("POI"):
				ExploreArray.append(child)
	ExploreArray.shuffle()
	var Marker = ExploreArray.pop_back()
	NavAgent.target_position = Marker.global_position


func MakePath():
	if currentState == EXPLORE:
		direction = to_local(NavAgent.get_next_path_position()).normalized()
		velocity = direction * speed
		if NavAgent.distance_to_target() <= 10:
			StateMachine()
	elif currentState == COMBAT or currentState == IDLE:
		velocity = Vector2.ZERO

#endregion


#region Combat

func Combat():
	for i in EnemyArray:
		if i.is_in_group("player"):
			var target = i.global_position
			NavAgent.target_position = target
			break


func EnemyDetected(body):
	var character = body
	if character.is_in_group("player"):
		print("Combat!")
		EnemyArray.append(character)
		currentState = COMBAT
		StateMachine()


func Knockback(enemy, _area, reverse: bool = false):
	var pushback = (enemy.global_position - global_position).normalized() * 30
	if reverse:
		pushback = -pushback
	var KnockbackTween = create_tween()
	if enemy.is_inside_tree() and enemy != null:
		KnockbackTween.tween_property(enemy, "position", enemy.position + pushback, 0.2)

#endregion

func _on_hurtbox_area_entered(area):
	Knockback($".", area)




