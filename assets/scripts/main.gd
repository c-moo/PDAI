extends Node

const LEVELS = [
	"res://scenes/levels/first-level.tscn",
	"res://scenes/levels/2nd-level.tscn",
	"res://scenes/levels/level.tscn",
]

var current_index = 0

@onready var world: Node = $World
@onready var player: Player = $CharacterBody2D

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	load_level(0)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_level(index: int) -> void:
	for child in world.get_children():
		child.queue_free()

	current_index = index
	var level: Node = load(LEVELS[index]).instantiate()
	world.add_child(level)
	
	
	
	var spawn = level.get_node_or_null("PlayerSpawn")
	print("spawn found: ", spawn != null)
	if spawn:
		player.global_position = spawn.global_position
		player.velocity = Vector2.ZERO

	var exit = level.get_node_or_null("Exit")
	print("player at: ", player.global_position)
	if exit:
		print("exit at: ", exit.global_position)
	
	if level.has_signal("level_completed"):
		level.level_completed.connect(_on_level_completed)
	else:
		push_warning("Level has no level_completed signal: " + LEVELS[index])



func _on_level_completed() -> void:
	if current_index + 1 < LEVELS.size():
		await get_tree().create_timer(1.0).timeout
		load_level(current_index + 1)
