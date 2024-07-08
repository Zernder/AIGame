class_name PlayerScene extends CharacterBody2D

@export var health: float
@export var maxHealth: float
@export var level: int
@export var damage: float
@export var speed: float
var direction: Vector2

@onready var navAgent = $NavigationAgent2D

func _physics_process(delta):
	if navAgent.is_navigation_finished():
		return
	
	var nextPos = navAgent.get_next_path_position()
	var newVelocity = global_position.direction_to(nextPos) * speed
	velocity = newVelocity
	move_and_slide()
	direction = velocity.normalized()
	UpdateBlend()
	SetWalking(velocity.length() > 0)
	
	queue_redraw()  # For debug drawing

func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
	move_and_slide()

func _ready():
	navAgent.max_speed = speed
	navAgent.path_desired_distance = 4.0
	navAgent.target_desired_distance = 4.0
	navAgent.velocity_computed.connect(self._on_velocity_computed)


func Move(direction: Vector2, speed: float):
	if direction != Vector2.ZERO:
		var intended_velocity = direction.normalized() * speed
		navAgent.set_velocity(intended_velocity)
	else:
		navAgent.set_velocity(Vector2.ZERO)
	
	print("PlayerScene: Move called with direction ", direction, " and speed ", speed)  # Debug print



func checkSelf(node):
	if node == self:
		return true
	else:
		return false




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

