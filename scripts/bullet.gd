
extends Area2D

var velocity = Vector2(0,0)
var shooter

func _ready():
	set_process(true)

func init(shooter, velocity):
	self.shooter = shooter
	self.velocity = velocity 

func _process(delta):
	translate(velocity * delta)
	if not get_node("VisibilityNotifier2D").is_on_screen():
		queue_free()

func _on_shot_body_enter(body):
	hit_object(body)

func _on_bullet_area_enter(area):
	hit_object(area)

func hit_object(obj):
	if obj.get_name() != shooter.get_name():
		# check if colliding with instance of self
		if not obj.has_method("is_bullet"):
			if obj.has_method("hit"):
				obj.hit(self)
			queue_free()

# dummy function for self-identification among duplicates
func is_bullet():
	pass
