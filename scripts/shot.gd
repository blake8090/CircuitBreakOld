
extends Area2D

var velocity = Vector2(0,0)

func _ready():
	set_process(true)

func set_velocity(vel):
	velocity = vel
	
func _process(delta):
	translate(velocity * delta)

func _on_shot_body_enter(body):
	if body.get_name() != "ship":
		queue_free()
