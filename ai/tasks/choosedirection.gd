extends BTAction

@export var wanderDistanceMin: float = 40.0
@export var wanderDistanceMax: float = 60.0

@export var posVar: StringName = "pos"
@export var dirVar: StringName = "dir"
var dir: Vector2

func _tick(delta: float) -> Status:
	dir = randomDir()
	var pos: Vector2 = randomPosition(dir)
	blackboard.set_var(posVar, pos)
	agent.navAgent.set_target_position(pos)  # Add this line
	print("Wander: New target set to ", pos)  # Debug print
	return SUCCESS

func randomPosition(dir: Vector2) -> Vector2:
	var distance: float = randf_range(wanderDistanceMin, wanderDistanceMax)
	var finalPosition: Vector2 = agent.global_position + dir * distance
	
	# Check if the position is valid (not inside a wall)
	var space_state = agent.get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(agent.global_position, finalPosition)
	var result = space_state.intersect_ray(query)
	
	if result:
		# If there's an obstacle, adjust the position
		finalPosition = result.position - dir * agent.navAgent.radius
	
	return finalPosition

func randomDir() -> Vector2:
	var dirArray: Array = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
	dirArray.shuffle()
	var chosenDir: Vector2 = dirArray[0]
	blackboard.set_var(dirVar, chosenDir)
	return chosenDir
