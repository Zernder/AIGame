class_name AllyBaseScene extends CharacterBody2D


@export var health: float
@export var maxHealth: float
@export var level: int
@export var damage: float
@export var speed: float
@export var Points: int

@onready var currentxp: int = 0
@onready var requiredxp: int = 100 * level

@onready var profile = $Profile
@onready var label = $Profile/Label
@onready var healthbar = $Profile/Healthbar
@onready var expbar = $Profile/Expbar
@onready var navagent = $NavigationAgent2D
@onready var points = $CanvasLayer/Panel/Points
@onready var directions = $CanvasLayer/Panel/Directions
@onready var state_timeout = $Timers/StateTimeout


var target
var direction: Vector2 = Vector2()
var Entity: Array = []
var enemy
var enemyinRange: bool = false
var beaconinRange: bool = false


enum States {
	WANDER,
	COMBAT,
	BEACON,
}


var currentState = States.WANDER

func _ready():
	healthbar.max_value = maxHealth
	health = maxHealth

func _process(_delta):
	healthbar.max_value = maxHealth
	healthbar.value = health
	expbar.value = currentxp
	expbar.max_value = requiredxp
	label.text = "Level: " + str(level)
	points.text = "Points: " + str(Points)
	directions.text = "Place Beacon: 2 Points" + "\n" + "Remove Beacon: 1 Points"
	LevelUp()

func _physics_process(delta):
	Death()
	Attack()
	BeaconFinder()
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = -velocity


#region States

func Wander():
	if currentState == States.WANDER:
		var chooseDirection = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
		chooseDirection.shuffle()
		direction = chooseDirection.front()
		var wandertime = randf_range(0.5,3)
		state_timeout.wait_time = wandertime
		velocity = direction * speed

func Attack():
	if currentState == States.COMBAT and enemyinRange:
		for i in Entity:
			if i.is_in_group("Enemy"):
				target = to_local(navagent.get_next_path_position()).normalized()
				velocity = target * speed
	else:
		currentState = States.WANDER


func BeaconFinder():
	if beaconinRange == true and currentState == States.BEACON:
		target = to_local(navagent.get_next_path_position()).normalized()
		velocity = target * speed
	else:
		currentState = States.WANDER

#endregion


func _on_state_timeout_timeout():
	if currentState == States.WANDER:
		Wander()
	if currentState == States.COMBAT:
		Attack()
	if currentState == States.BEACON:
		BeaconFinder()

func _on_detectbox_area_entered(area):
	var character = area.get_parent()
	if character.is_in_group("Enemy"):
		enemy = character
		Entity.append(character)
		enemyinRange = true
		currentState = States.COMBAT

func _on_detectbox_area_exited(area):
	var character = area.get_parent()
	if character.is_in_group("Enemy"):
		Entity.erase(character)
		enemy = null
		enemyinRange = Entity.size() > 0 and Entity.any(func(e): return e.is_in_group("Enemy"))
		if Entity.is_empty():
			currentState = States.WANDER

func _on_hurtbox_area_entered(area):
	if area.get_parent().is_in_group("Enemy"):
		enemy = area.get_parent()
		enemy.health -= damage
		if enemy != null:
			Knockback(enemy, area)
		if enemy != null and enemy.health <= 0:
			currentxp += 30

func _on_hitbox_area_entered(area):
	if area.get_parent().is_in_group("Enemy"):
		enemy = area.get_parent()
		health -= enemy.damage
		Knockback($".", area)
	elif area.is_in_group("Blocks"):
		Knockback($".", area)

func LevelUp():
	if currentxp >= requiredxp:
		level += 1
		maxHealth += 10
		damage += 5
		requiredxp = 100 * level
		currentxp = 0

@onready var spawn = $"../Spawn"

func Death():
	if health <= 0:
		get_tree().quit()

func Knockback(enemy, _area, reverse: bool = false):
	var pushback = (enemy.global_position - global_position).normalized() * 30
	if reverse:
		pushback = -pushback
	var KnockbackTween = create_tween()
	if enemy.is_inside_tree() and enemy != null:
		KnockbackTween.tween_property(enemy, "position", enemy.position + pushback, 0.2)


func MakePath():
	if enemyinRange == true:
		navagent.target_position =  target.position
	if beaconinRange == true  and enemyinRange == false:
		navagent.target_position = target.position


func _on_beason_points_timeout():
	Points += 1


var beacon
func BeaconDetected(area):
	if area.is_in_group("Beacon"):
		print("Beacon")
		beaconinRange = true
		currentState = States.BEACON
		beacon = area

func BeaconLost(area):
	if area.is_in_group("Beacon"):
		beaconinRange = false
		currentState = States.WANDER
		beacon = null
