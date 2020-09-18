extends TouchScreenButton

# SHOUTOUT GONKEE
# Change these based on the size of your button and outer sprite
var radius = Vector2(25, 25)
var boundary = 50

var ongoing_drag = -1

var return_accel = 20

var deadzone = 1

var count = 0

enum JoystickMode {FIXED, DYNAMIC, FOLLOWING}

export(JoystickMode) var joystick_mode := JoystickMode.FIXED

func _process(delta):
	count = count + 1
	"""
	if (count == 100) :
		print(get_button_pos())
		print(get_direction())
		print(get_value())
		count = 0 
	"""
	if ongoing_drag == -1:
		var pos_difference = (Vector2(0, 0) - radius) - position
		position += pos_difference * return_accel * delta
		

func get_button_pos():
	return position + radius
	
func get_direction():
	var x = get_button_pos()[0]
	var y = get_button_pos()[1]	
	var r
	var degrees
	if (y>=0):
		if (x==0):
			r=PI/2
		else:
			r=atan(y/x)
	elif (y<0):
		if (x==0):
			r=PI/2+PI
		else:
			r=atan(y/x)+PI
	degrees = r*360/(PI*2) #(0~360)
	return degrees

func _input(event):
	if event is InputEventScreenDrag or (event is InputEventScreenTouch and event.is_pressed()):
		var event_dist_from_centre = (event.position - get_parent().global_position).length()

		if event_dist_from_centre <= boundary * global_scale.x or event.get_index() == ongoing_drag:
			set_global_position(event.position - radius * global_scale)

			if get_button_pos().length() > boundary:
				set_position( get_button_pos().normalized() * boundary - radius)

			ongoing_drag = event.get_index()

	if event is InputEventScreenTouch and !event.is_pressed() and event.get_index() == ongoing_drag:
		ongoing_drag = -1

func get_value():
	if get_button_pos().length() > deadzone:
		return get_button_pos().normalized()
	return Vector2(0, 0)
