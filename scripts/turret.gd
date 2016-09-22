
extends Area2D

var root = null
onready var shoot_timer = get_node("shoot_timer")

export var bullet_speed = 500
var can_shoot = false

func _ready():
	root = get_tree().get_root().get_node("game")

func _fixed_process(delta):
	var space_state = get_world_2d().get_direct_space_state()
	var ship = root.get_node("ship")
	var ship_pos = ship.get_global_pos()
	var pos = get_global_pos()
	var result = space_state.intersect_ray(pos, ship_pos, [self])
	
	if not result.empty():
		if result.collider.get_name() == "ship":
			var angle = atan2(pos.x - ship_pos.x, pos.y - ship_pos.y)
			set_rot(angle)
			
			if can_shoot:
				ObjectFactory.create_obj_bullet(self, get_node("shoot_pos").get_global_pos(), calc_velocity_from_angle(get_rotd(), bullet_speed))
				shoot_timer.set_wait_time(randi()%4+1) # random int 1-3
				shoot_timer.start()
				can_shoot = false

func hit(bullet):
	pass

func _on_visibility_enter_screen():
	set_fixed_process(true)
	shoot_timer.set_wait_time(1)
	shoot_timer.start()

func _on_visibility_exit_screen():
	set_fixed_process(false)

func _on_shoot_timer_timeout():
	can_shoot = true

# TODO: Generalize this code...
func calc_velocity_from_angle(angle, speed):
	var angleRad = (angle * PI) / 180
	var velocity = Vector2(0,0)
	velocity.x -= sin(angleRad) * speed
	velocity.y -= cos(angleRad) * speed
	return velocity
