extends CharacterBody3D

const JUMP_VELOCITY := 4.5
const ROTATION := 0.015
const FIREBALL=preload("res://spells/fireball.tscn")

var hp
var max_hp :=22.0
var enemy_knockback := 5
var attack_strenght := 1
var speed := 10.0
var minimum_soul := 1
var soul_gathering := 2
@export var soul=0;
@onready var camera = $Camera3D
@onready var playerAnimation = $AnimationPlayer
@onready var weaponHitbox = $Camera3D/WeaponPivot/WeaponMesh/Hitbox
@onready var castPoint = $SpellCastPoint
@onready var batSwingNoise =$BatSwingSound
@onready var walkingNoise =$WalkingSound
@onready var hurtNoise =$HurtSound
@onready var FireballNoise = $FireballSound
@onready var enemyHurtNoise = $EnemySound
@onready var label = $SoulUi

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	weaponHitbox.monitoring=false
	hp=max_hp

func _unhandled_input(event: InputEvent) -> void: #camera rotation
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * ROTATION)
		camera.rotate_x(-event.relative.y * ROTATION)
		camera.rotation.x=clamp(camera.rotation.x, -PI/4, PI/4)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"): #quit game
		get_tree().quit()

	if Input.is_action_just_pressed("attack"): #attack
		if playerAnimation.current_animation == "idle":
			batSwingNoise.play()
			playerAnimation.play("attack_animation")
		weaponHitbox.monitoring=true

	if Input.is_action_just_pressed("shoot"): #shoot
		_shoot_fireball()
	
	if Input.is_action_just_pressed("restart") or hp<0:
		get_tree().reload_current_scene()
	label.set_text(str(soul));


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	move_and_slide()
	if not velocity.x and not velocity.y: 		walkingNoise.play()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="attack_animation":
		playerAnimation.play("idle")
		weaponHitbox.monitoring=false

func _shoot_fireball() -> void:
	if(soul>=minimum_soul): 
		var fireball_node=FIREBALL.instantiate() #instantiate the fireball
		get_parent().add_child(fireball_node)
		
		fireball_node.global_transform.origin = castPoint.global_transform.origin #cast point as original point
		var forward_dir: Vector3 = -camera.global_transform.basis.z #camera direction
		forward_dir = forward_dir.normalized()
		fireball_node.dir = forward_dir
		soul-=minimum_soul;
		FireballNoise.play()


func _on_hitbox_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		var enemy = body as Enemy
		var forward_dir: Vector3 = -camera.global_transform.basis.z #camera direction
		forward_dir = forward_dir.normalized()
		forward_dir*=enemy_knockback
		if enemy.cooldown_inv<=0: 
			soul=soul+soul_gathering
			enemyHurtNoise.play()
		enemy.take_damage(attack_strenght, forward_dir)
		weaponHitbox.monitoring=false
	if body.is_in_group("reward"):
		body.queue_free()
		speed=speed*2

func take_damage(dmg: float, dir: Vector3) -> void:
	hp-=dmg
	hurtNoise.play()
