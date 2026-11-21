extends CanvasLayer

@export var margin = 60.0          # extra pixels hidden on each side, 30 is small and 100 is very strong
@export var level_width = 3200.0   # roughly how wide this level is

@onready var rect = $TextureRect

func _process(delta: float) -> void:
	var cam = get_viewport().get_camera_2d()
	if cam == null:
		return
	var view = get_viewport().get_visible_rect().size
	rect.size = view + Vector2(margin * 2, margin * 2)

	var progress = clamp(cam.get_screen_center_position().x / level_width, 0.0, 1.0)
	rect.position = Vector2(-margin * 2 * progress, -margin)
