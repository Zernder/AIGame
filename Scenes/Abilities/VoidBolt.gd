extends Area2D

@onready var VoidBolt = $"."
@onready var spelltimeout = $SpellTimeout
@onready var player = get_tree().get_first_node_in_group("player")

var Direction
var velocity = Vector2.RIGHT
var speed: int = 500

func _ready():
	spelltimeout.start(0.6)
	#Direction = player.direction


func _physics_process(delta):
	position += velocity * delta
	rotate(400 * delta)



func EnemyHit(area):
	if area.is_in_group("EnemyHitbox"):
		var enemy = area.get_parent().get_parent()
		enemy.health -= player.magicalDamage
		Knockback(enemy, area)
		if enemy.health <= 0:
			player.currentxp += 1
			enemy.queue_free()
		queue_free()
	else:
		pass


func VoidBoltTimeout():
	VoidBolt.queue_free()


func VoidBoltLeftScreen():
	queue_free()


func TileMapEntered(_body):
	queue_free()



func Knockback(enemy, _area, reverse: bool = false):
	var pushback = (enemy.global_position - global_position).normalized() * 30
	if reverse:
		pushback = -pushback
	var KnockbackTween = create_tween()
	if enemy != null:
		KnockbackTween.tween_property(enemy, "position", enemy.position + pushback, 0.2)

