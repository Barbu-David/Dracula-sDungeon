extends Area3D

@export var speed = 10
var dir

func _ready() -> void:
	dir = -get_tree().get_first_node_in_group("player").global_transform.basis.z.normalized()

func _process(delta: float) -> void:
	global_position += dir*speed*delta

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		queue_free()
