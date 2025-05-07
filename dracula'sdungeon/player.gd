extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const ROTATION = 0.015
const FIREBALL=preload("res://fireball.tscn")
@export var soul=0;

@onready var camera = $Camera3D
@onready var playerAnimation = $AnimationPlayer
@onready var weaponHitbox = $Camera3D/WeaponPivot/WeaponMesh/Hitbox
@onready var castPoint = $SpellCastPoint
@onready var batSwingNoise =$BatSwingSound
@onready var FireballNoise = $FireballSound
@onready var label = $SoulUi

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	weaponHitbox.monitoring=false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * ROTATION)
		camera.rotate_x(-event.relative.y * ROTATION)
		camera.rotation.x=clamp(camera.rotation.x, -PI/4, PI/4)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("attack"):
		if playerAnimation.current_animation == "idle":
			batSwingNoise.play()
		playerAnimation.play("attack_animation")
		weaponHitbox.monitoring=true
	if Input.is_action_just_pressed("shoot"):
		_shoot_fireball()
	label.set_text(str(soul));


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="attack_animation":
		playerAnimation.play("idle")
		weaponHitbox.monitoring=false

func _shoot_fireball() -> void:
	if(soul>0):
		var fireball_node=FIREBALL.instantiate()
		get_parent().add_child(fireball_node)
		fireball_node.global_position=castPoint.global_position
		soul-=1;
		FireballNoise.play()


func _on_hitbox_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		soul=soul+1
