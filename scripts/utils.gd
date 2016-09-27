static func get_velocity_from_angle(angle, speed):
	var angleRad = (angle * PI) / 180
	var velocity = Vector2(0,0)
	velocity.x -= sin(angleRad) * speed
	velocity.y -= cos(angleRad) * speed
	return velocity

static func scale_to_range(minimum, maximum, value):
	if minimum == 0:
		return value / maximum
	else:
		return (value - minimum) / (maximum - minimum)
