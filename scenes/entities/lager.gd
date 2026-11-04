extends Area2D

var player: CharacterBody2D

func _on_body_entered(body: CharacterBody2D) -> void:
	player = body
	player.coins += 1
	print(player.coins)
	queue_free()
