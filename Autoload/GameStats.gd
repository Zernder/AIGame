class_name GameStats extends CharacterBody2D


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

var direction: Vector2
@onready var NavAgent = $NavigationAgent2D

var healthPotion: int = 1
var staminaPotion: int = 1
var manaPotion: int = 1

@onready var EnemyArray: Array = []

#endregion

#region The Runtimes

func _process(_delta):
	LevelUp()

func _physics_process(_delta):
	Death()


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


func RegenerationTimeout():
	if mana < maxMana:
		mana += min(3, maxMana - mana)
	if health < maxHealth:
		health += min(1, maxHealth - health)
	if stamina < maxStamina:
		stamina += min(10, maxStamina - stamina)


#endregion
