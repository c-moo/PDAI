extends CharacterBody2D

class_name Enemy

const speed = 20
var is_enemy_chase: bool = false
var health = 100 #tarvitsee health bar sit

var dead: bool = false

var damage_to_deal = 10
var knockback = 100

var dir: Vector2
const gravity = 100

var is_roaming: bool = true

func _process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0
	move(delta)
	move_and_slide()
	
func move(delta):
	if !dead:
		if !is_enemy_chase:
			velocity += dir * speed * delta
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
