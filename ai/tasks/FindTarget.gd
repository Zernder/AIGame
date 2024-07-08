extends BTAction

@export var group: StringName
@export var targetVar: StringName = "target"

var target: Node

func _tick(delta: float) -> Status:
	if group == "enemy":
		target = getEnemyNode()
		if target and target.global_position.distance_to(agent.global_position) <= 100:
			blackboard.set_var(targetVar, target)
			return SUCCESS
		else:
			return FAILURE
	elif group == "player":
		target = getPlayerNode()
		if target and target.global_position.distance_to(agent.global_position) <= 100:
			blackboard.set_var(targetVar, target)
			return SUCCESS
		else:
			return FAILURE
	else:
		return FAILURE

func getEnemyNode() -> Node:
	var nodes: Array[Node] = agent.get_tree().get_nodes_in_group(group)
	if nodes.size() >= 2:
		nodes.shuffle()
		for node in nodes:
			if not agent.checkSelf(node):
				return node
	return null

func getPlayerNode() -> Node:
	var nodes: Array[Node] = agent.get_tree().get_nodes_in_group(group)
	if nodes.size() > 0:
		return nodes[0]
	return null
