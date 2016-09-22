
extends Area2D

var velocity = Vector2(0,0)
var shooter

func _ready():
	set_process(true)

func init(shooter, velocity):
	self.shooter = shooter
	self.velocity = velocity 

func set_velocity(vel):
	velocity = vel
	
func _process(delta):
	translate(velocity * delta)
	if not get_node("VisibilityNotifier2D").is_on_screen():
		queue_free()

func _on_shot_body_enter(body):
	if body.get_name() != shooter.get_name():
		queue_free()
