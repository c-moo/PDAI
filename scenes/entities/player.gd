extends CharacterBody2D

class_name Player


@onready var jump_sound = $Sounds/jump_sound
@onready var hurt_sound = $Sounds/hurt_sound
@onready var coin_sound = $Sounds/coin_sound
@onready var attack_sound = $Sounds/attack_sound
var direction_x: float

@export var SPEED := 400
@export var JUMP_STRENGTH = -250
@export var GRAVITY := 10
@export var coins := 0
@export var MAX_JUMPS := 200

@export var attack_damage: int = 25
@export var attack_duration: float = 0.15
@export var attack_cooldown: float = 0.30
@export var damage_cooldown: float = 1.0

var jumps_left := MAX_JUMPS
const WALL_JUMP_STRENGTH:= 0.75
var wall_jumping := false
var wall_jump_timer := 0.0

var health = 100
var health_max = 100
var health_min = 0
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
		if is_on_wall():
			velocity.x = get_wall_normal().x * SPEED * WALL_JUMP_STRENGTH
			velocity.y = -SPEED * WALL_JUMP_STRENGTH
			wall_jumping = true
			wall_jump_timer = 0.1
		if jumps_left > 0:
			jump_sound.play()
			velocity.y = JUMP_STRENGTH
			jumps_left -= 1
		
			
func apply_gravity():
	velocity.y += GRAVITY
	
func _physics_process(_delta: float) -> void:
	
	get_input()
	if Input.is_action_just_pressed("attack"):
		attack()
	
	if wall_jumping:
		wall_jump_timer -= _delta

		if wall_jump_timer <= 0:
			wall_jumping = false
	else:
		velocity.x = direction_x * SPEED
		
	apply_gravity()
	move_and_slide()
	
	Global.playerHitbox = $CharacterHitbox
	
func attack ():
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
	if damage <=0 or !can_take_damage or dead:
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
	
	dead = false
	can_take_damage = true
	can_attack = true
	Global.characterAlive = true
