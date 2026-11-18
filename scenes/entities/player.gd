
extends CharacterBody2D

class_name Player

@onready var jump_sound = $Sounds/jump_sound
@onready var hurt_sound = $Sounds/hurt_sound
@onready var coin_sound = $Sounds/coin_sound
@onready var attack_sound = $Sounds/attack_sound

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var body: Node2D = $body

var direction_x: float

@export var MOVEMENT_MULTIPLIER: float = 0.5
@export_group("Movement")

@export var SPEED: float = 400.0 * MOVEMENT_MULTIPLIER
@export var ACCELERATION: float = 1800.0 * MOVEMENT_MULTIPLIER
@export var FRICTION: float = 2200.0
@export var AIR_ACCELERATION: float = 1100.0 * MOVEMENT_MULTIPLIER
@export var AIR_FRICTION: float = 350.0

@export_group("Jump")

@export var JUMP_STRENGTH: float = -450 * MOVEMENT_MULTIPLIER
@export var GRAVITY: float = 1200.0 * MOVEMENT_MULTIPLIER
@export var MAX_FALL_SPEED: float = 900.0
@export var MAX_JUMPS: int = 1
@export var JUMP_CUT: float = 0.5

var jumps_left: int = 1

@export_group("Wall Movement")
@export var WALL_SLIDE_SPEED: float = 100.0  * MOVEMENT_MULTIPLIER
@export var WALL_SLIDE_GRAVITY: float = 350.0
@export var WALL_JUMP_FORCE_X: float = 450.0 * MOVEMENT_MULTIPLIER
@export var WALL_JUMP_FORCE_Y: float = -450.0 * MOVEMENT_MULTIPLIER
@export var WALL_JUMP_LOCK: float = 0.15

var is_wall_sliding: bool = false
var wall_jump_timer: float = 0.0

@export_group("Combat")
@export var attack_damage: int = 25
@export var attack_duration: float = 0.15
@export var attack_cooldown: float = 0.30
@export var damage_cooldown: float = 1.0

var health = 100
var dead: bool
var can_take_damage: bool = true

var is_attacking: bool = false
var can_attack: bool = true
var hit_enemies: Array[Enemy] = []


func get_input():
	direction_x = Input.get_axis("left", "right")

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jumps_left = MAX_JUMPS

		if jumps_left > 0:
			jump_sound.play()
			velocity.y = JUMP_STRENGTH
			jumps_left -= 1
			
	if Input.is_action_just_pressed("attack"):
		attack()
		
func handle_jump() -> void:

	if not Input.is_action_just_pressed("jump"):
		return

	# Wall jump
	if is_wall_sliding:
		wall_jump()
		return

	# Normal and double jumps
	if is_on_floor():
		jumps_left = MAX_JUMPS

	if jumps_left > 0:
		jump_sound.play()
		velocity.y = JUMP_STRENGTH
		jumps_left -= 1

func handle_horizontal_movement(delta: float) -> void:

	# Briefly prevent horizontal input from cancelling
	# the wall jump.
	if wall_jump_timer > 0.0:
		wall_jump_timer -= delta
		return

	var target_speed = direction_x * SPEED

	if direction_x != 0:
		var acceleration = ACCELERATION

		if not is_on_floor():
			acceleration = AIR_ACCELERATION

		velocity.x = move_toward(
			velocity.x,
			target_speed,
			acceleration * delta
		)

	else:
		var friction = FRICTION

		if not is_on_floor():
			friction = AIR_FRICTION

		velocity.x = move_toward(
			velocity.x,
			0.0,
			friction * delta
		)

func apply_gravity(delta: float) -> void:

	if is_wall_sliding:
		velocity.y += WALL_SLIDE_GRAVITY * delta
	else:
		velocity.y += GRAVITY * delta

	velocity.y = min(velocity.y, MAX_FALL_SPEED)

func handle_jump_cut() -> void:

	# Releasing jump early produces a shorter jump.
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= JUMP_CUT

func handle_wall_slide() -> void:

	is_wall_sliding = (
		is_on_wall()
		and not is_on_floor()
		and velocity.y > 0
	)

	if is_wall_sliding:
		velocity.y = min(velocity.y, WALL_SLIDE_SPEED)
	
func wall_jump() -> void:

	var wall_direction = get_wall_normal().x

	jump_sound.play()

	# Launch away from the wall.
	velocity.x = wall_direction * WALL_JUMP_FORCE_X
	velocity.y = WALL_JUMP_FORCE_Y

	# Prevent immediate horizontal input cancellation.
	wall_jump_timer = WALL_JUMP_LOCK

	# Reset jumps after wall jumping.
	jumps_left = MAX_JUMPS

	is_wall_sliding = false

	# Face away from the wall.
	body.scale.x = sign(wall_direction) * abs(body.scale.x)

func update_facing() -> void:

	if direction_x > 0:
		body.scale.x = abs(body.scale.x)

	elif direction_x < 0:
		body.scale.x = -abs(body.scale.x)
		
func _physics_process(delta: float) -> void:

	if dead:
		return

	get_input()

	# Determine wall sliding before processing jump input.
	handle_wall_slide()

	handle_jump()
	handle_jump_cut()

	handle_horizontal_movement(delta)
	apply_gravity(delta)
	
	update_facing()

	move_and_slide()

	# Reset jumps when grounded.
	if is_on_floor():
		jumps_left = MAX_JUMPS

	Global.playerHitbox = $CharacterHitbox



func attack():
	if !can_attack or dead:
		return

	can_attack = false
	is_attacking = true

	hit_enemies.clear()

	for area in $DamageZone.get_overlapping_areas():
		damage_enemy(area)
		attack_sound.play()

	await get_tree().create_timer(attack_duration).timeout
	is_attacking = false

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true


func _on_damage_area_area_entered(area: Area2D):
	if is_attacking:
		damage_enemy(area)


func damage_enemy(area: Area2D):
	if !is_attacking:
		return

	var enemy = area.get_parent()

	if enemy is Enemy:
		if hit_enemies.has(enemy):
			return

		if enemy.dead:
			hurt_sound.play()
			return

		hit_enemies.append(enemy)
		enemy.take_damage(attack_damage)
		print("dealt ", attack_damage, "damage")


func take_damage(damage):
	if damage <= 0 or !can_take_damage or dead:
		return

	health -= damage

	print("Player health: ", health)

	if health <= 0:
		health = 0
		dead = true
		Global.characterAlive = false
		print("dead")
		return

	reset_damage_cooldown()


func reset_damage_cooldown():
	can_take_damage = false
	await get_tree().create_timer(damage_cooldown).timeout

	if !dead:
		can_take_damage = true


func _ready():
	Global.playerBody = self
	Global.playerDamageZone = $DamageZone
	Global.playerHitbox = $CharacterHitbox
	animation_player.play("idle")
	dead = false
	can_take_damage = true
	can_attack = true
	Global.characterAlive = true
