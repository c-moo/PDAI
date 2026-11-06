extends CharacterBody2D

var direction_x: float
@export var SPEED := 150
@export var JUMP_STRENGTH = -250
@export var GRAVITY := 10
@export var coins := 0
@export var MAX_JUMPS := 2

var jumps_left := MAX_JUMPS
const WALL_JUMP_STRENGTH:= 0.75
var wall_jumping := false
var wall_jump_timer := 0.0

func get_input():
	direction_x = Input.get_axis("left", "right")
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jumps_left = MAX_JUMPS
		if is_on_wall():
			velocity.x = get_wall_normal().x * SPEED * WALL_JUMP_STRENGTH
			velocity.y = -SPEED * WALL_JUMP_STRENGTH
			wall_jumping = true
			wall_jump_timer = 0.3
		if jumps_left > 0:
			velocity.y = JUMP_STRENGTH
			jumps_left -= 1
		
			
func apply_gravity():
	velocity.y += GRAVITY
	
func _physics_process(_delta: float) -> void:
	
	get_input()
	if wall_jumping:
		wall_jump_timer -= _delta

		if wall_jump_timer <= 0:
			wall_jumping = false
	else:
		velocity.x = direction_x * SPEED
		
	apply_gravity()
	move_and_slide()
	
func _ready():
	Global.playerBody = self
