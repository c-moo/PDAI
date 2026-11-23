extends Node2D
signal level_completed
var finished = false

# code can jsut be copied for the rest of the levels too
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var exit = get_node_or_null("Exit")
	if exit:
		exit.set_deferred("monitoring", false)
		exit.body_entered.connect(_on_exit_body_entered)
		await get_tree().physics_frame
		await get_tree().physics_frame
		exit.monitoring = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_exit_body_entered(body: Node2D) -> void:
	print("touched exit: ", body.name)
	if finished:
		return
	if body is Player:
		finished = true
		level_completed.emit()
