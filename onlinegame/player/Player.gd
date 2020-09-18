extends KinematicBody2D

const MOVE_SPEED = 4
enum MoveDirection { UP, DOWN, LEFT, RIGHT, NONE }
var movedir = Vector2(0,0)

onready var joystick = get_parent().get_node("Joystick/Joystick_Button")
puppet var puppet_position = Vector2()
puppet var puppet_movement = MoveDirection.NONE

func _ready():
	pass

func _process(delta):
	if is_network_master():
		var dist = sqrt((joystick.get_button_pos()[0]*joystick.get_button_pos()[0])+(joystick.get_button_pos()[1]*joystick.get_button_pos()[1]))
		move_and_slide(joystick.get_value() * MOVE_SPEED * dist)
		var velocity = movedir * MOVE_SPEED
		if (joystick.get_button_pos()[0] > 0.5) :
			$Sprite/AnimationPlayer.play("LeftToRight")
			$Sprite.flip_h = false
		if (joystick.get_button_pos()[0] < -0.5) :
			$Sprite.flip_h = true
			$Sprite/AnimationPlayer.play("LeftToRight")
	else: 
		pass
		#_move(puppet_movement)
		#The _move function won't work yet as it expects feedback from
		# the keys and not the joystick
		#position = puppet_position
	if get_tree().is_network_server():
		Network.update_position(int(name), position)


func _physics_process(_delta):
	var direction = MoveDirection.NONE
	if is_network_master():
		movedir.x = -Input.get_action_strength("ui_left") + Input.get_action_strength("ui_right")
		movedir.y = +Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
		var velocity = movedir * MOVE_SPEED
		velocity = move_and_slide(velocity)
		
		rset_unreliable('puppet_position', position)
		rset('puppet_movement', direction)
		#_move(direction)
	else:
		_move(puppet_movement)
		position = puppet_position
	
	if get_tree().is_network_server():
		Network.update_position(int(name), position)

#func _physics_process(_delta):
	#var direction = MoveDirection.NONE
	#if is_network_master():
		#if Input.is_action_pressed('left'):
			#direction = MoveDirection.LEFT
		#elif Input.is_action_pressed('right'):
			#$Sprite/AnimationPlayer.play("LeftToRight")
			#direction = MoveDirection.RIGHT
		#elif Input.is_action_pressed('up'):
			#direction = MoveDirection.UP
		#elif Input.is_action_pressed('down'):
			#direction = MoveDirection.DOWN
		
		#rset_unreliable('puppet_position', position)
		#rset('puppet_movement', direction)
		#_move(direction)
	#else:
		#_move(puppet_movement)
		#position = puppet_position
	
	#if get_tree().is_network_server():
		#Network.update_position(int(name), position)

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

		MoveDirection.RIGHT:
			move_and_collide(Vector2(MOVE_SPEED, 0))
			
func _move_joy(direction) :
	direction = joystick.get_direction()
	

func init(nickname, start_position, is_puppet):
	$GUI/Nickname.text = nickname
	global_position = start_position
	if is_puppet:
		$Sprite.texture = load('res://player/sprite.png')
