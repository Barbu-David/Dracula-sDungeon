extends CharacterBody3D

const JUMP_VELOCITY = 4.5
var hp=3

func _process(_delta: float) -> void:
	if hp<=0:
		queue_free()

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("fireball"):
		hp=0
		velocity.y = JUMP_VELOCITY	

	if(area.is_in_group("claw")):
		hp=hp-1
