extends CharacterBody2D


const SPEED = 200.0
func _ready() -> void:
	PlayerData.player_can_move = true
	if PlayerData.should_use_return_position:
		global_position = PlayerData.return_position
		PlayerData.should_use_return_position = false	


func _physics_process(delta):
	if PlayerData.player_can_move == false:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var directionx = Input.get_axis("ui_left", "ui_right")
	var directiony = Input.get_axis("ui_up", "ui_down")
	velocity.x = directionx*SPEED
	velocity.y = directiony*SPEED
		
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * SPEED
		if $WalkSound.playing == false:
			$WalkSound.play()
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		$WalkSound.stop()
		
	
	if velocity.y != 0:
		
		if velocity.y < 0:
			$AnimatedSprite2D.animation = "up"
		else:
			$AnimatedSprite2D.animation = "down"
	elif velocity.x != 0:
		if velocity.x < 0:
			$AnimatedSprite2D.animation = "left"
		else:
			$AnimatedSprite2D.animation = "right"

	move_and_slide()
