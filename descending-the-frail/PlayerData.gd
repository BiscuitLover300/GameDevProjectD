extends Node



var max_hp = 100
var current_hp = 100

var enemy_to_load = "slime"
var last_battle_id = ""
var return_scene_path = "res://Level1.tscn"



var return_position = Vector2.ZERO

var should_use_return_position = false

var cleared_battles = {}


var player_can_move = true
