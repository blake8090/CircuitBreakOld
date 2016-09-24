
extends Area2D

var root = null
const Utils = preload("utils.gd")
onready var shoot_timer = get_node("shoot_timer")

export var bullet_speed = 500
var can_shoot = false
var target = null

func _ready():
	root = get_tree().get_root().get_node("game")

func _fixed_process(delta):
	# character is always first priority - if no character exists then target the ship
	if root.has_node("character"):
		target = root.get_node("character")
	elif root.has_node("ship"):
		target = root.get_node("ship")
	else:
		target = null
		
	if not target == null:
		var target_pos = target.get_global_pos()
		var pos = get_global_pos()
		var space_state = get_world_2d().get_direct_space_state()
		var result = space_state.intersect_ray(pos, target_pos, [self])
		
		if not result.empty():
			if result.collider.get_name() == target.get_name():
				var angle = atan2(pos.x - target_pos.x, pos.y - target_pos.y)
				set_rot(angle)
				
				if can_shoot:
					ObjectFactory.create_obj_bullet(self, get_node("shoot_pos").get_global_pos(), Utils.get_velocity_from_angle(get_rotd(), bullet_speed))
					shoot_timer.set_wait_time(randi()%4+1) # random int 1-3
					shoot_timer.start()
					can_shoot = false

func hit(bullet):
	ObjectFactory.create_fx_explosion(get_global_pos())
	queue_free()

func _on_visibility_enter_screen():
	set_fixed_process(true)
	shoot_timer.set_wait_time(1)
	shoot_timer.start()

func _on_visibility_exit_screen():
	set_fixed_process(false)

func _on_shoot_timer_timeout():
	can_shoot = true
