class_name Utils extends Node

enum ORIENTATION {NONE = 0, NORTH = 1, EAST = 2, SOUTH = 3, WEST = 4}


## Transforms an ORIENTATION into angle
static func OrientationToAngle(orientation : ORIENTATION , origin : ORIENTATION = ORIENTATION.NORTH) -> float:
	var toNorthAngle : float = 0
	match orientation:
		ORIENTATION.NORTH:
			toNorthAngle = 0.0
		ORIENTATION.EAST:
			toNorthAngle = 90.0
		ORIENTATION.SOUTH:
			toNorthAngle = 180.0
		ORIENTATION.WEST:
			toNorthAngle = 270.0
		_:
			toNorthAngle = 270.0
	
	if origin == ORIENTATION.NORTH:
		return toNorthAngle
	
	var originToNorthAngle = OrientationToAngle(origin, ORIENTATION.NORTH)
	return Repeat(toNorthAngle - originToNorthAngle, 360.0)


static func Repeat(t : float, length : float) -> float:
	while t >= length:
		t -= length
	return t
	
# Function to transform door direction based on rotation
static func transform_directions(original_directions: Array[Utils.ORIENTATION], rotation_angle: int) -> Array[Utils.ORIENTATION]:
	# Map each direction to a numerical index
	var direction_indices = { Utils.ORIENTATION.NORTH: 0, Utils.ORIENTATION.EAST: 1, Utils.ORIENTATION.SOUTH: 2, Utils.ORIENTATION.WEST: 3 }
	
	var transformed : Array[Utils.ORIENTATION]
	for original_direction in original_directions:
		# Get the index of the original direction
		var original_index = direction_indices[original_direction]
		
		# Calculate the new index based on rotation (90° = +1, 180° = +2, etc.)
		var steps = rotation_angle / 90
		var new_index = (original_index + steps) % 4
		
		# Append the transformed direction
		transformed.append((new_index + 1) as Utils.ORIENTATION) # Ad 1 because 0 would be ORIENTATION.NONE
	
	return transformed
	
static func get_opposite_direction(direction: ORIENTATION) -> ORIENTATION:
	match direction:
		ORIENTATION.NORTH:
			return ORIENTATION.SOUTH
		ORIENTATION.SOUTH:
			return ORIENTATION.NORTH
		ORIENTATION.EAST:
			return ORIENTATION.WEST
		ORIENTATION.WEST:
			return ORIENTATION.EAST
		_:
			return ORIENTATION.NONE # Handle invalid input if needed

static func direction_to_vector(direction: Utils.ORIENTATION) -> Vector2:
	match direction:
		Utils.ORIENTATION.NORTH:
			return Vector2(0, -1)
		Utils.ORIENTATION.SOUTH:
			return Vector2(0, 1)
		Utils.ORIENTATION.EAST:
			return Vector2(1, 0)
		Utils.ORIENTATION.WEST:
			return Vector2(-1, 0)
		_:
			return Vector2.ZERO # Default case for invalid input

static func get_direction(offset: Vector2) -> Utils.ORIENTATION:
	if offset == Vector2(0, -1):
		return Utils.ORIENTATION.NORTH
	elif offset == Vector2(1, 0):
		return Utils.ORIENTATION.EAST
	elif offset == Vector2(0, 1):
		return Utils.ORIENTATION.SOUTH
	elif offset == Vector2(-1, 0):
		return Utils.ORIENTATION.WEST
	return Utils.ORIENTATION.NONE

## Transforms an angle into ORIENTATION
static func AngleToOrientation(angle : float, origin : ORIENTATION = ORIENTATION.NORTH) -> ORIENTATION:
	var roundAngle = round(rad_to_deg(angle) / 90.0)
	roundAngle.to_int()
	match origin:
		ORIENTATION.NORTH:
			roundAngle = 0
		ORIENTATION.EAST:
			roundAngle = 1
		ORIENTATION.SOUTH:
			roundAngle = 2
		ORIENTATION.WEST:
			roundAngle = 3
	
	roundAngle = roundAngle % 4
	if roundAngle < 0:
		roundAngle += 4

	match roundAngle:
		0:
			return ORIENTATION.NORTH
		1:
			return ORIENTATION.EAST
		2:
			return ORIENTATION.SOUTH
		3:
			return ORIENTATION.WEST
	
	return ORIENTATION.NONE


## Transforms an ORIENTATION into direction (Vector2Int)
static func OrientationToDir(orientation : ORIENTATION) -> Vector2i:
	match orientation:
		ORIENTATION.NORTH:
			return Vector2i(0, 1)
		ORIENTATION.EAST:
			return Vector2i(1, 0)
		ORIENTATION.SOUTH:
			return Vector2i(0, -1)
		ORIENTATION.WEST:
			return Vector2i(-1, 0)
	
	return Vector2i(0, 0)


## Gets opposit orientation for a given orientation
static func OppositeOrientation(orientation : ORIENTATION) -> ORIENTATION:
	match orientation:
		ORIENTATION.NORTH:
			return ORIENTATION.SOUTH
		ORIENTATION.EAST:
			return ORIENTATION.WEST
		ORIENTATION.SOUTH:
			return ORIENTATION.NORTH
		ORIENTATION.WEST:
			return ORIENTATION.EAST
	
	return ORIENTATION.NONE


## Transforms an angle into a discrete angle.
static func DiscreteAngle(angle : float, step : float) -> float:
	angle = rad_to_deg(angle)
	return deg_to_rad(round(angle / step) * step)


static func get_closest_point_rect2(bounds : Rect2, point : Vector2) -> Vector2:
	var bottom_left = Vector2(bounds.position.x, bounds.end.y)
	var top_right = Vector2(bounds.end.x, bounds.position.y)
	
	var closestPoint : Vector2 = Geometry2D.get_closest_point_to_segment(point, bounds.position, bottom_left)
	var newPoint : Vector2 = Geometry2D.get_closest_point_to_segment(point, bounds.position, top_right)
	if newPoint.distance_to(point) < closestPoint.distance_to(point):
		closestPoint = newPoint

	newPoint = Geometry2D.get_closest_point_to_segment(point, bottom_left, bounds.end)
	if newPoint.distance_to(point) < closestPoint.distance_to(point):
		closestPoint = newPoint
	newPoint = Geometry2D.get_closest_point_to_segment(point, top_right, bounds.end)
	if newPoint.distance_to(point) < closestPoint.distance_to(point):
		closestPoint = newPoint

	return closestPoint
