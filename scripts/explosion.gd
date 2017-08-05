
extends Particles2D

var timer;
onready var tween = get_node("Tween")

func _ready():
    # delete after 1 second
    tween.interpolate_callback(self, 1, "queue_free")
    tween.start()
