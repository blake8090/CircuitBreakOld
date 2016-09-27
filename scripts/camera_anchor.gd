
extends Node2D

var root = null

export var default_target = "ship"
var target = ""

var _target_zoom = 1
var _current_zoom = 1
var _zoom_speed = 0.1

func _ready():
	root = get_tree().get_root().get_node("game")
	set_target(default_target)
	get_node("Camera2D").make_current()
	set_process(true)

func _process(delta):
	if root.has_node(target):
		set_global_pos(root.get_node(target).get_global_pos())
	
	if _current_zoom != _target_zoom:
		_current_zoom = lerp(_current_zoom, _target_zoom, _zoom_speed)
		get_node("Camera2D").set_zoom(Vector2(_current_zoom, _current_zoom))

func set_target(name, do_lerp = false):
	target = name
	if root.has_node(target):
		set_global_pos(root.get_node(target).get_global_pos())

func set_target_zoom(zoom, speed):
	if zoom != _target_zoom:
		_target_zoom = zoom
		_zoom_speed = speed
