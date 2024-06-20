extends Node
	var maxDistance = 1000.0
	var maxDistanceTiles = int(maxDistance / 16.0)
	var potential_positions = []
	for x_offset in range(-maxDistanceTiles, maxDistanceTiles + 1):
		for y_offset in range(-maxDistanceTiles, maxDistanceTiles + 1):
			var potential_pos = round(position / 16) + Vector2(x_offset, y_offset)
			if !seencoords.has(potential_pos):
				potential_positions.append(potential_pos)
	if potential_positions.size() > 0:
		potential_positions.shuffle()
		var new_position = potential_positions.front() * 16
		currentidpath.append(Vector2i(new_position.x,new_position.y))
		#direction = (new_position - position).normalized()
		SetWalking(true)
		UpdateBlend()
		velocity = direction * 1
		UpdateSeenCoords(new_position)
		StateTimer.start(wandertime)
	else:





func Wander():
	var mapSize = tilemap.get_used_rect().end - tilemap.get_used_rect().position
	print("Map size:", mapSize)
	var validPositions = []
	for x in range(mapSize.x):
		for y in range(mapSize.y):
			var tilepos = Vector2i(x, y)
			var tiledata = tilemap.get_cell_tile_data(0, tilepos)
			var tiledata1 = tilemap.get_cell_tile_data(1, tilepos)
			
			if (tiledata and tiledata.get_custom_data('Type') != "Wall") or (tiledata1 and tiledata1.get_custom_data('Type') != "Wall"):
				validPositions.append(tilepos)
	print("Valid positions found:", validPositions.size())
	if validPositions.size() > 0:
		var randIndex = randi() % validPositions.size()
		var randPos = validPositions[randIndex]
		if randPos.x >= 0 and randPos.y >= 0 and randPos.x < mapSize.x and randPos.y < mapSize.y:
			print("Random position chosen:", randPos)
			var tilePosLocal = tilemap.local_to_map(global_position)
			var tilePosWorld = tilemap.map_to_local(randPos)
			print("Current position (local):", tilePosLocal)
			print("Target position (world):", tilePosWorld)
			if tilePosWorld.x >= 0 and tilePosWorld.y >= 0 and tilePosWorld.x < mapSize.x and tilePosWorld.y < mapSize.y:
				var start_id = tilemap.astar.get_closest_point(tilemap.to_global(global_position))
				var end_id = tilemap.astar.get_closest_point(tilemap.to_global(randPos))
				print("Start ID:", start_id, "End ID:", end_id)
				if tilemap.astar.has_point(start_id) and tilemap.astar.has_point(end_id):
					var idpath = tilemap.astar.get_id_path(start_id, end_id).slice(1)
					print("Path found:", idpath)
					if idpath.size() > 0:
						StateTimer.start(wandertime)
						return
					else:
						print("Error: No path found.")
				else:
					print("Error: Start or end point not found in AStar.")
			else:
				print("Error: Destination point is out of bounds or a wall.")
		else:
			print("No valid positions found.")
		
		StateTimer.start(.3)
		print("Unable to proceed with pathfinding.")
