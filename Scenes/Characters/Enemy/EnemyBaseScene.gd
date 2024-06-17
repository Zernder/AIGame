class_name EnemyBaseScene extends CharacterBody2D



@export var health: float
@export var damage: float
@export var speed: float

var direction: Vector2 = Vector2()
var Entity: Array = []
var enemyinRange: bool = false

enum States {
	IDLE,
	COMBAT
}

var currentState = States.IDLE

func _physics_process(_delta):
	Death()
	Move()
	Attack()
	move_and_slide()


func Move():
	velocity = direction * speed


func Idle():
	var chooseDirection = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
	chooseDirection.shuffle()
	direction = chooseDirection.front()


func _on_state_timeout_timeout():
	if currentState == States.IDLE:
		Idle()
	if currentState == States.COMBAT:
		Attack()


func Attack():
	if currentState == States.COMBAT and enemyinRange == true:
		for i in Entity:
			if i.is_in_group("Ally"):
				var target = i.global_position
				velocity = (target - global_position).normalized() * speed
				if global_position.distance_to(target) <= 10:
					velocity = -direction * speed


func _on_detectbox_area_entered(area):
	var character = area.get_parent()
	if character.is_in_group("Ally"):
		Entity.append(character)
		enemyinRange = true
		currentState = States.COMBAT


func _on_detectbox_area_exited(area):
	var character = area.get_parent()
	if character.is_in_group("Ally"):
		Entity.erase(character)
		enemyinRange = Entity.size() > 0 and Entity.any(func(e): return e.is_in_group("Warrior"))
		if Entity.is_empty():
			currentState = States.IDLE


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
