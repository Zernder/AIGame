extends BTAction

@export var posVar: StringName = "pos"
@export var dirVar: StringName = "dir"

@export var speedVar: float = 5
@export var tolerance: float = 10.0

func _tick(delta: float) -> Status:
	var targetPosition: Vector2 = blackboard.get_var(posVar, Vector2.ZERO)
	
	if agent.global_position.distance_to(targetPosition) <= tolerance:
		agent.Move(Vector2.ZERO, 0)
		print("Move: Reached target")
		return SUCCESS
	
	if not agent.navAgent.is_navigation_finished():
		var nextPathPosition: Vector2 = agent.navAgent.get_next_path_position()
		var direction: Vector2 = agent.global_position.direction_to(nextPathPosition)

		var space_state = agent.get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(agent.global_position, nextPathPosition)
		var result = space_state.intersect_ray(query)
		
		if result:
			agent.navAgent.set_target_position(targetPosition)
			print("Move: Obstacle detected, recalculating")
			return RUNNING
		
		agent.Move(direction, speedVar)
		print("Move: Moving towards ", nextPathPosition)
		return RUNNING
	else:
		print("Move: Navigation finished")
		return SUCCESS
