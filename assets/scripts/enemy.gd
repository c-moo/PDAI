extends CharacterBody2D

class_name Enemy

const speed = 80
var is_enemy_chase: bool = true
var health: int = 20 #health bar sit
var health_max = 100
var health_min = 0

@onready var sprite: Sprite2D = $Sprite2D
@onready var Ground_Detector: RayCast2D = $GroundDetector

var lager_pack_texture = preload("res://assets/enemies/lager_pack.png")

var dead: bool = false
var taking_damage: bool = false
var can_damage_player: bool = true
var player_overlapping: bool = false

@export var damage_to_deal: int = 25
@export var enemy_attack_cooldown: float = 1.0

var knockback = 200
var direction: int = 1

var dir: Vector2
const gravity = 160

var is_roaming: bool = true

var player: CharacterBody2D

func _ready():
	Global.enemyDamageAmount = damage_to_deal
	Global.enemyDamageArea = $DamageAreaEnemy
func _physics_process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		
	Ground_Detector.position.x = abs(Ground_Detector.position.x) * direction
	if is_on_floor() and !Ground_Detector.is_colliding() and !dead:
		velocity.y = -125
		direction *= -1
	if !dead and is_on_wall() and is_on_floor():
		velocity.y = -125
		direction *= -1
		
	if Global.characterAlive:
		is_enemy_chase = true
	else:
		is_enemy_chase = false
	
	player = Global.playerBody
	
	if player != null:
		move(delta)
	if dead:
		velocity.x = move_toward(velocity.x, 0, 300 * delta)
	move_and_slide()
	
func move(delta):
	if !dead:
		if !is_enemy_chase:
			velocity += dir * speed * delta
		elif is_enemy_chase and !taking_damage:
			direction = sign(player.global_position.x - global_position.x)
			velocity.x = direction * speed
		elif taking_damage:
			var knockback_dir = player.global_position.direction_to(global_position) * knockback
			velocity.x = knockback_dir.x
			velocity.y = -50
		is_roaming = true
		
func apply_knockback():
	if player == null:
		return
	var knockback_dir = player.global_position.direction_to(global_position) * knockback
	velocity.x = knockback_dir.x
	velocity.y = -50
	
func _on_hitbox_enemy_area_entered(area: Area2D):
	if area == Global.playerDamageZone:
		print("Enemy was hit! Dead: ", dead)
		var damage = Global.playerDamageAmount
		take_damage(damage)
		
func take_damage(damage: int):
	if damage <= 0: 
		return
		
	if dead:
		apply_knockback()
		return
		
	health -= damage
	taking_damage = true
	
	print("Enemy health: ", health)
	if health <= 0:
		health = 0
		dead = true
		apply_knockback()
		print("Enemy dead")
		sprite.texture = lager_pack_texture
	else:
		apply_knockback()
		await get_tree().create_timer(0.3).timeout
		if !dead:
			taking_damage = false
			
func _on_damage_area_enemy_area_entered(area: Area2D):
	if area == Global.playerHitbox:
		player_overlapping = true
		attack_player_loop()
func _on_damage_area_enemy_area_exited(area: Area2D):
	if area == Global.playerHitbox:
		player_overlapping = false
		
func attack_player_loop():
	if !can_damage_player:
		return
	can_damage_player = false
	while player_overlapping and !dead and Global.characterAlive:
		if Global.playerBody == null:
			break
		Global.playerBody.take_damage(damage_to_deal)
		print("Enemy dealt ", damage_to_deal, " damage")
		await get_tree().create_timer(enemy_attack_cooldown).timeout
	can_damage_player = true
	
func _on_direction_timer_timeout():
	$DirectionTimer.wait_time = 2
	if !is_enemy_chase and !dead:
		direction = choose([-1, 1])
		velocity.x = 0
		
func choose(array):
	array.shuffle()
	return array.front()
	
