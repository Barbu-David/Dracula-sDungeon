extends CharacterBody3D
class_name Enemy

#Class state
@export var max_hp: int = 3
@export var speed: float = 2.0
@export var detection_radius: float = 30.0
@export var attack_range: float = 1.5
@export var attack_cooldown_max: float = 1.0
@export var pwr=6

#Internal state
var hp: float
var cooldown_attack: float = 0.0
var state: String = "idle"
var target: Node3D = null

var knockback := Vector3.ZERO
var direction := Vector3.ZERO
var knockback_resistance := 5.0
var knockback_down_pull := -1.0
var knockback_down_pull_strength := 0.1
const cooldown_inv_max :=0.1
var cooldown_inv :=0

func _ready() -> void:
	hp = max_hp
	target = get_tree().get_nodes_in_group("player").front()

func _die()->void:
		queue_free()

func _process(delta: float) -> void:
	if hp<=0:
		_die()
		return
	cooldown_attack = max(cooldown_attack - delta, 0)
	cooldown_inv = max(cooldown_inv - delta, 0)
	var to_player = target.global_transform.origin - global_transform.origin
	var dist = to_player.length()

	match state:
		"idle":
			if dist < detection_radius:
				state = "chasing"
		"chasing":
			if dist < attack_range:
				state = "attacking"
			elif dist > detection_radius:
				state = "idle"
		"attacking":
			if cooldown_attack == 0:
				_attack()
				cooldown_attack = attack_cooldown_max
			if dist > attack_range:
				state = "chasing"

		
func take_damage(dmg: float, kb: Vector3) ->void:
	if cooldown_inv<=0:
		hp=hp-dmg;
		knockback=kb;
		cooldown_inv=cooldown_inv_max

func _physics_process(delta: float) -> void:
	var move_vec = Vector3.ZERO
	if state == "chasing":
		move_vec = (target.global_transform.origin - global_transform.origin).normalized() * speed
	velocity = move_vec * speed 
	knockback=knockback.move_toward(Vector3.ZERO, knockback_resistance * delta)
	if not is_on_floor():
		velocity += get_gravity() * delta
		knockback.y=move_toward(knockback.y, knockback_down_pull, knockback_down_pull_strength)
	velocity += knockback
	move_and_slide()

func _attack() -> void:
	var from = global_transform.origin
	var to   = from.direction_to(target.global_transform.origin) * attack_range + from

	# 1) Create and configure the ray‐query object
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from             = from
	ray_query.to               = to
	ray_query.exclude          = [ self ]               # don’t hit yourself
	ray_query.collision_mask   = 1 << 0                 # e.g. layer 1; adjust to your “Player” layer
	ray_query.collide_with_bodies = true
	ray_query.collide_with_areas  = false

	# 2) Cast the ray
	var result = get_world_3d().direct_space_state.intersect_ray(ray_query)
	if result:
		var col = result.collider
		if col.is_in_group("player"):
			# apply damage + optional knockback
			col.take_damage(pwr, Vector3.ZERO)
