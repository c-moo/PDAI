extends CharacterBody2D

class_name Enemy

const speed = 80
var is_enemy_chase: bool = true
var health = 100 #tarvitsee health bar sit

var dead: bool = false
var taking_damage: bool = false

var damage_to_deal = 10
var knockback = -50

var dir: Vector2
const gravity = 100

var is_roaming: bool = true

var player: CharacterBody2D
var player_in_area = false

func _process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0
		
	player = Global.playerBody
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
	elif dead:
		velocity.x = 0

func _on_direction_timer_timeout():
	$DirectionTimer.wait_time = 2
	if !is_enemy_chase:
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x = 0

func choose(array):
	array.shuffle()
	return array.front()
	
func _on_enemy_hitbox_area_entered(ared):
	pass #WIP
