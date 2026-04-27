extends Node2D

var player_hp = PlayerData.current_hp
var enemy_damage_multiplier = 1.0

var enemies = {
	"goblin": {
		"name": "Goblin",
		"texture": preload("res://Enemies/goblin.png"),
		"hp": 40,
		"moves": [
			{"name": "Scratch", "damage": 10, "chance": 70},
			{"name": "Bite", "damage": 20, "chance": 25},
			{"name": "Taunt", "damage": 0, "chance": 5}
		]
	},
	"slime": {
		"name": "slime",
		"texture": preload("res://Enemies/slime.png"),
		"hp": 75,
		"moves": [
			{"name": "Tackle", "damage": 15, "chance": 50},
			{"name": "Body Slam", "damage": 25, "chance": 30},
			{"name": "Melt", "damage": 0, "chance": 20}
		]
	},
	"bird": {
		"name": "bird",
		"texture": preload("res://Enemies/slime.png"),
		"hp": 100,
		"moves": [
			{"name": "peck", "damage": 20, "chance": 50},
			{"name": "claw", "damage": 35, "chance": 30},
			{"name": "screech", "damage": 0, "chance": 20}
		]
	},
	"boss": {
		"name": "Boss",
		"texture": preload("res://Enemies/boss.png"),
		"hp": 250,
		"moves": [
			{"name": "Stomp", "damage": 25, "chance": 60},
			{"name": "Crush", "damage": 45, "chance": 25},
			{"name": "Leer", "damage": 0, "chance": 15}
		]
	}
}

var current_enemy
var enemy_hp = 0

var is_player_turn = true
var battle_over = false

var moves = [
	{"name": "Strike", "type": "damage", "damage": 15},
	{"name": "Flay", "type": "random_damage", "min_damage": 5, "max_damage": 30},
	{"name": "Intimidate", "type": "intimidate"},
	{"name": "Heal", "type": "heal", "heal_amount": 20}
]


func _ready() -> void:
	randomize()
	
	if enemies.has(PlayerData.enemy_to_load):
		current_enemy = enemies[PlayerData.enemy_to_load]
	else:
		print("Enemy not found: ", PlayerData.enemy_to_load)
		current_enemy = enemies["slime"]
	
	enemy_hp = current_enemy["hp"]
	player_hp = PlayerData.current_hp
	
	$EnemySprite.texture = current_enemy["texture"]
	
	$Move1Button.text = moves[0]["name"]
	$Move2Button.text = moves[1]["name"]
	$Move3Button.text = moves[2]["name"]
	$Move4Button.text = moves[3]["name"]
	
	update_text()
	start_player_turn()


func start_player_turn() -> void:
	if battle_over:
		return
	
	is_player_turn = true
	$BattleText.text = "Your turn! Choose a move."


func use_move(move_index: int) -> void:
	if battle_over:
		return
	
	if is_player_turn == false:
		return
	
	var move = moves[move_index]

	if move["type"] == "heal":
		player_hp += move["heal_amount"]
		
		if player_hp > PlayerData.max_hp:
			player_hp = PlayerData.max_hp
		
		PlayerData.current_hp = player_hp
		$BattleText.text = "You used Heal and recovered " + str(move["heal_amount"]) + " HP!"

	elif move["type"] == "intimidate":
		if enemy_damage_multiplier > 0.5:
			enemy_damage_multiplier = 0.5
			$BattleText.text = "You intimidated the enemy! Their attack power fell!"
		else:
			$BattleText.text = "The enemy is already intimidated!"

	elif move["type"] == "random_damage":
		var damage = randi_range(move["min_damage"], move["max_damage"])
		enemy_hp -= damage
		
		if enemy_hp < 0:
			enemy_hp = 0
		
		$BattleText.text = "You used Flay for " + str(damage) + " damage!"
		update_text()
		await play_enemy_hit_animation()

	else:
		enemy_hp -= move["damage"]
		
		if enemy_hp < 0:
			enemy_hp = 0
		
		$BattleText.text = "You used Strike for " + str(move["damage"]) + " damage!"
		update_text()
		await play_enemy_hit_animation()
	
	update_text()
	await check_winner()
	
	if battle_over == false:
		is_player_turn = false
		await get_tree().create_timer(1.0).timeout
		await start_enemy_turn()


func start_enemy_turn() -> void:
	if battle_over:
		return
	
	$BattleText.text = current_enemy["name"] + "'s turn..."
	await get_tree().create_timer(1.0).timeout
	
	var move = pick_enemy_move()
	var damage = int(move["damage"] * enemy_damage_multiplier)
	
	player_hp -= damage
	
	if player_hp < 0:
		player_hp = 0
	
	PlayerData.current_hp = player_hp
	
	if damage > 0:
		$BattleText.text = current_enemy["name"] + " used " + move["name"] + " for " + str(damage) + " damage!"
	else:
		$BattleText.text = current_enemy["name"] + " used " + move["name"] + "!"
	
	update_text()
	await check_winner()
	
	if battle_over == false:
		await get_tree().create_timer(1.0).timeout
		start_player_turn()


func pick_enemy_move() -> Dictionary:
	var roll = randi_range(1, 100)
	var current_chance = 0
	
	for move in current_enemy["moves"]:
		current_chance += move["chance"]
		
		if roll <= current_chance:
			return move
	
	return current_enemy["moves"][0]


func play_enemy_hit_animation() -> void:
	var original_position = $EnemySprite.position
	
	var tween = create_tween()
	tween.tween_property($EnemySprite, "position:x", original_position.x + 10, 0.05)
	tween.tween_property($EnemySprite, "position:x", original_position.x - 10, 0.05)
	tween.tween_property($EnemySprite, "position:x", original_position.x + 6, 0.05)
	tween.tween_property($EnemySprite, "position:x", original_position.x, 0.05)
	
	await tween.finished


func check_winner() -> void:
	if enemy_hp <= 0:
		enemy_hp = 0
		battle_over = true
		
		PlayerData.cleared_battles[PlayerData.last_battle_id] = true
		PlayerData.should_use_return_position = true
		
		$BattleText.text = "You won!"
		update_text()
		
		$BattleMusic.stop()
		await get_tree().create_timer(2.0).timeout
		await FadeTransition.change_scene(PlayerData.return_scene_path)
	
	elif player_hp <= 0:
		player_hp = 0
		PlayerData.current_hp = PlayerData.max_hp
		PlayerData.should_use_return_position = false
		battle_over = true
		
		$BattleText.text = "You lost!"
		update_text()
		
		$BattleMusic.stop()
		await get_tree().create_timer(2.0).timeout
		await FadeTransition.change_scene(PlayerData.return_scene_path)


func update_text() -> void:
	$PlayerHPLabel.text = "Player HP: " + str(player_hp)
	$EnemyHPLabel.text = current_enemy["name"] + " HP: " + str(enemy_hp)


func _on_move_1_button_pressed() -> void:
	use_move(0)


func _on_move_2_button_pressed() -> void:
	use_move(1)


func _on_move_3_button_pressed() -> void:
	use_move(2)


func _on_move_4_button_pressed() -> void:
	use_move(3)
