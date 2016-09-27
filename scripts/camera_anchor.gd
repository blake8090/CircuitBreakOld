
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"
var target = "ship"
var root = null

func _ready():
	root = get_tree().get_root().get_node("game")
	set_process(true)

func _process(delta):
	if root.has_node(target):
		set_global_pos(root.get_node(target).get_global_pos())

func set_target(name):
	target = name


