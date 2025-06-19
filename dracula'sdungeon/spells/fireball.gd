extends Area3D

@export var speed := 30
var acceleration := 10
var dir=Vector3.ZERO
var damage := 10
@onready var boomNoise =$boom
func _ready() -> void:
		connect("body_entered", self._on_body_entered)


func _process(delta: float) -> void:
	global_position += dir*speed*delta
	speed+=acceleration*delta

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		remove_child(boomNoise)
		get_tree().current_scene.add_child(boomNoise)
		boomNoise.play()
		var enemy = body as Enemy
		enemy.take_damage(damage, Vector3.ZERO)
		queue_free()
	else: if not body.is_in_group("player"): queue_free()
