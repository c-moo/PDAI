extends CharacterBody2D

class_name Enemy

const speed = 80
var is_enemy_chase: bool = true
var health: int = 100 #health bar sit

var dead: bool = false
var taking_damage: bool = false
var can_damage_player: bool = true
var player_overlapping: bool = false

@export var damage_to_deal: int = 25
@export var enemy_attack_cooldown: float = 1.0

var knockback = -200

var dir: Vector2
const gravity = 100

var is_roaming: bool = true

var player: CharacterBody2D

func _ready():
	Global.enemyDamageAmount = damage_to_deal
	Global.enemyDamageArea = $DamageAreaEnemy

func _process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0
		
	if Global.characterAlive:
		is_enemy_chase = true
	else:
		is_enemy_chase = false
	
	player = Global.playerBody
	
	if player != null:
		move(delta)
		
	move_and_slide()
	
func move(delta):
	if !dead:
		if !is_enemy_chase:
			velocity += dir * speed * delta
		elif is_enemy_chase and !taking_damage:
			var dir_to_player = position.direction_to(player.position) * speed
			velocity.x = dir_to_player.x
		elif taking_damage:
			var knockback_dir = position.direction_to(player.position) * knockback
			velocity.x = knockback_dir.x
		is_roaming = true
	else:
		velocity.x = 0
func _on_enemy_hitbox_area_entered(area: Area2D):
	if area == Global.playerDamageZone:
		var damage = Global.playerDamageAmount
		take_damage(damage)
		
func take_damage(damage: int):
	if dead or damage <= 0: 
		return
		
	health -= damage
	taking_damage = true
	
	print("Enemy health: ", health)
	if health <= 0:
		health = 0
		dead = true
		$DamageAreaEnemy.set_deferred("monitoring", false)
		$HitboxEnemy.set_deferred("monitorable", false)
		velocity.x = 0
		print("Enemy dead")
	else:
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
	if !is_enemy_chase:
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x = 0
		
func choose(array):
	array.shuffle()
	return array.front()
	
