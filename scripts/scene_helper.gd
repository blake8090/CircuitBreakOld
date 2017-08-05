
extends Node

func setScene(scene):
    var currentScene = get_tree().get_root().get_child(get_tree().get_root().get_child_count() -1)
    currentScene.queue_free()
    get_tree().change_scene(scene)
