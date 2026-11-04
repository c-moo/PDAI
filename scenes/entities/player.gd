extends CharacterBody2D

var direction_x: float
@export var SPEED := 150
@export var JUMP_STRENGTH = -200
@export var GRAVITY := 10
@export var coins := 0

func get_input():
	direction_x = Input.get_axis("left", "right")
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_STRENGTH

func apply_gravity():
	velocity.y += GRAVITY 
	
func _physics_process(_delta: float) -> void:
	
	get_input()
	velocity.x = direction_x * SPEED
	apply_gravity()
	move_and_slide()
