extends Area2D

@export var enemy_name = "slime"
@export var battle_id = "dungeon_f_1_battle1"
@export var battle_scene_path = "res://battle.tscn"
@export var return_scene_path = "res://dungeon_f_1.tscn"

@export var shadow_start_offset = Vector2(120, 0)
@export var shadow_run_time = 0.6

var triggered = false


func _ready() -> void:
	if PlayerData.cleared_battles.has(battle_id):
		queue_free()
	
	$AnimatedSprite2D.visible = false


func _on_body_entered(body: Node2D) -> void:
	if triggered:
		return
	
	if body.is_in_group("player"):
		triggered = true
		PlayerData.player_can_move = false
		
		PlayerData.enemy_to_load = enemy_name
		PlayerData.last_battle_id = battle_id
		PlayerData.return_scene_path = return_scene_path
		PlayerData.return_position = body.global_position
		PlayerData.should_use_return_position = true
		
		await shadow_attack_player(body)
		await FadeTransition.change_scene(battle_scene_path)


func shadow_attack_player(player: Node2D) -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.global_position = player.global_position + shadow_start_offset
	
	if $AnimatedSprite2D is AnimatedSprite2D:
		$AnimatedSprite2D.play("run")
	
	var tween = create_tween()
	
	tween.tween_property(
		$AnimatedSprite2D,
		"global_position",
		player.global_position,
		shadow_run_time
	)
	
	await tween.finished
	
	if $AnimatedSprite2D is AnimatedSprite2D:
		$AnimatedSprite2D.play("hit")
		await get_tree().create_timer(0.25).timeout
