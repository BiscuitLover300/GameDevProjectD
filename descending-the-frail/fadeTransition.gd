extends CanvasLayer

var fade_rect: ColorRect
var fade_time = 0.5


func _ready() -> void:
	layer = 100
	
	fade_rect = ColorRect.new()
	fade_rect.color = Color.BLACK
	fade_rect.modulate.a = 0.0
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	add_child(fade_rect)
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.visible = false


func fade_out() -> void:
	fade_rect.visible = true
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, fade_time)
	await tween.finished


func fade_in() -> void:
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, fade_time)
	await tween.finished
	
	fade_rect.visible = false


func change_scene(scene_path: String) -> void:
	await fade_out()
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	await fade_in()
