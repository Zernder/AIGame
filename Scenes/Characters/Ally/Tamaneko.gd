extends CharacterBody2D


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

var healthPotion: int = 1
var staminaPotion: int = 1
var manaPotion: int = 1

#endregion


#region The Runtimes


func _ready():
	pass


func _process(_delta):
	UIProcess()
	LevelUp()


func _physics_process(delta):
	Movement()
	Death()
	move_and_slide()

func _input(_event):
	ComeHere()



@onready var health_bar = $"UI/Profile/Health Bar"
@onready var stamina_bar = $"UI/Profile/Stamina Bar"
@onready var mana_bar = $"UI/Profile/Mana Bar"
@onready var expbar = $UI/Profile/Expbar

@onready var level_label = $UI/Profile/LevelLabel
@onready var health_label = $"UI/Profile/Health Bar/Health Label"
@onready var stamina_label = $"UI/Profile/Stamina Bar/Stamina Label"
@onready var mana_label = $"UI/Profile/Mana Bar/Mana Label"

func UIProcess():
	level_label.text = "Name: Fuyuki" + "\n" + "Level: " + str(level)
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


func Movement():
	direction = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	velocity = direction * speed
	if velocity == Vector2.ZERO:
		SetWalking(false)
		UpdateBlend()
	else:
		SetWalking(true)
		UpdateBlend()

@onready var Autumn = get_tree().get_first_node_in_group("Autumn")
func ComeHere():
	if Input.is_action_just_pressed("FollowTama"):
		if Autumn.followTama == false:
			print("Come here Autumn!")
			Autumn.followTama = true
			print(Autumn)
			Autumn.currentState = Autumn.FOLLOWTAMA
		else:
			print("Nvm Autumn")
			Autumn.followTama = false
			Autumn.currentState = Autumn.IDLE
			Autumn.StateMachine()

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


#region Character Sheet and UI

@onready var character_sheet = $"UI/Character Sheet"
func CharacterSheet():
	if Input.is_action_just_pressed("Character Sheet") and Autumn.global_position <= 5:
		if character_sheet.visible:
			character_sheet.hide()
		else:
			character_sheet.show()
	elif Input.is_action_just_pressed("Character Sheet") and Autumn.global_position >= 5:
		ItemsList()


@onready var items = $UI/Items
func ItemsList():
	if Input.is_action_just_pressed("Inventory"):
		if items.visible:
			items.hide()
		else:
			items.show()


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
