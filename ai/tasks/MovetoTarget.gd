extends BTAction

@export var targetVar := &"target"
@export var speedVar = 10

@export var tolerance = 30


func _tick(_delta: float) -> Status:
	var target: CharacterBody2D = blackboard.get_var(targetVar)
	if target != null:
		var targetPos = target.global_position
		var dir = agent.global_position.direction_to(targetPos)
		if agent.global_position.distance_to(targetPos) <= tolerance:
			agent.Move(dir, 0)
			return SUCCESS
		else:
			#print(dir, "    ", dir)
			agent.Move(dir, speedVar)
			return RUNNING
	return FAILURE
