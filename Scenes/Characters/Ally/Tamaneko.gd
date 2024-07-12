extends CharacterBody2D


#region The Variables

@export_category("Stats")
@export var health: float = 100
@export var maxHealth: float = 100
@export var stamina: float = 120
@export var maxStamina: float = 120
@export var mana: float = 100
@export var maxMana: float = 100
@export var level: int = 1
@export var skillPoints: int = 5

@export var physicalDamage: float = 10
@export var magicalDamage: float = 5
@export var physicalDefense: float = 3
@export var magicalDefense: float = 3

@export var speed: float = 10
@onready var currentxp: int = 0
@onready var requiredxp: int = 1 * level

var direction: Vector2

@onready var Autumn = get_tree().get_first_node_in_group("Autumn")


#endregion


#region The Runtimes

func _ready():
	pass


func _process(_delta):
	LevelUp()


func _physics_process(_delta):
	Movement()
	Death()
	move_and_slide()


func _input(_event):
	Commands()

#endregion


#region Movement

func Movement():
	direction = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	velocity = direction * speed
	if velocity == Vector2.ZERO:
		SetWalking(false)
		UpdateBlend()
	else:
		SetWalking(true)
		UpdateBlend()

#endregion


#region Animations

@onready var AnimTree = $AnimationTree
@onready var AnimPlayer = $AnimationPlayer

func SetWalking(value):
	AnimTree["parameters/conditions/Idle"] = not value
	AnimTree["parameters/conditions/Walking"] = value

func SwingKatana(value: bool):
	AnimTree["parameters/conditions/Swing"] = value

func ThrowShuriken(value: bool):
	AnimTree["parameters/conditions/Throw"] = value

func UpdateBlend():
	AnimTree["parameters/Idle/blend_position"] = direction
	AnimTree["parameters/Walking/blend_position"] = direction
	AnimTree["parameters/Primary/blend_position"] = direction
	AnimTree["parameters/Secondary/blend_position"] = direction


#endregion


func Commands():
	if Input.is_action_just_pressed("FollowTama"):
		if Autumn.followTama == false:
			print("Come to me Autumn!")
			Autumn.followTama = true
		else:
			Autumn.followTama = false



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


func RegenerationTimeout():
	if mana < maxMana:
		mana += min(3, maxMana - mana)
	if health < maxHealth:
		health += min(1, maxHealth - health)
	if stamina < maxStamina:
		stamina += min(10, maxStamina - stamina)


func Death():
	if health <= 0:
		get_tree().quit()


#endregion

