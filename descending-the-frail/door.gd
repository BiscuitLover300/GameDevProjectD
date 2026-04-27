extends Area2D

@export var next_scene_path = "res://dungeon_f_1.tscn"

var triggered = false


func _on_body_entered(body: Node2D) -> void:
	if triggered:
		return
	
	if body.is_in_group("player"):
		triggered = true
		PlayerData.player_can_move = false
		await FadeTransition.change_scene(next_scene_path)
