extends KinematicBody2D

var Network
const MOVE_SPEED = 10.0
const MAX_HP = 100

enum MoveDirection { UP, DOWN, LEFT, RIGHT, NONE }

puppet var puppet_position = Vector2()
puppet var puppet_movement = MoveDirection.NONE

var health_points = MAX_HP

func _ready():
	_update_health_bar()

func _physics_process(delta):
	var direction = MoveDirection.NONE
	if is_network_master():
		if Input.is_action_pressed('left'):
			direction = MoveDirection.LEFT
		elif Input.is_action_pressed('right'):
			$Sprite/AnimationPlayer.play("LeftToRight")
			direction = MoveDirection.RIGHT
		elif Input.is_action_pressed('up'):
			direction = MoveDirection.UP
		elif Input.is_action_pressed('down'):
			direction = MoveDirection.DOWN
		
		rset_unreliable('puppet_position', position)
		rset('puppet_movement', direction)
		_move(direction)
	else:
		_move(puppet_movement)
		position = puppet_position
	
	if get_tree().is_network_server():
		Network.update_position(int(name), position)

func _move(direction):
	match direction:
		MoveDirection.NONE:
			return
		MoveDirection.UP:
			move_and_collide(Vector2(0, -MOVE_SPEED))
		MoveDirection.DOWN:
			move_and_collide(Vector2(0, MOVE_SPEED))
		MoveDirection.LEFT:
			move_and_collide(Vector2(-MOVE_SPEED, 0))
			_rifle_left()
		MoveDirection.RIGHT:
			move_and_collide(Vector2(MOVE_SPEED, 0))
			_rifle_right()

func _rifle_right():
	$Rifle.position.x = abs($Rifle.position.x)
	$Rifle.flip_h = false

func _rifle_left():
	$Rifle.position.x = -abs($Rifle.position.x)
	$Rifle.flip_h = true

func _update_health_bar():
	$GUI/HealthBar.value = health_points

func damage(value):
	health_points -= value
	if health_points <= 0:
		health_points = 0
		rpc('_die')
	_update_health_bar()

sync func _die():
	$RespawnTimer.start()
	set_physics_process(false)
	$Rifle.set_process(false)
	for child in get_children():
		if child.has_method('hide'):
			child.hide()
	$CollisionShape2D.disabled = true

func _on_RespawnTimer_timeout():
	set_physics_process(true)
	$Rifle.set_process(true)
	for child in get_children():
		if child.has_method('show'):
			child.show()
	$CollisionShape2D.disabled = false
	health_points = MAX_HP
	_update_health_bar()

func init(nickname, start_position, is_puppet):
	$GUI/Nickname.text = nickname
	global_position = start_position
	if is_puppet:
		$Sprite.texture = load('res://player/sprite.png')
