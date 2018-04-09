extends RigidBody2D

enum STATES {IDLE, JUMPING, CHARGING_JUMP, LAUNCHING, KITING, DASHING, ROLLING}
enum ACTIONS {LEFT_PRESSED, RIGHT_PRESSED, BOTH_PRESSED, LEFT_DOUBLE_TAPPED, RIGHT_DOUBLE_TAPPED, LEFT_HELD, RIGHT_HELD}

const Floor = preload('Floor.gd')
const GRAVITY_DEFAULT = 10
const GRAVITY_KITING = 1
const DASH_DURATION = 0.2
const DOUBLE_TAP_DELAY = 0.17

var _state = IDLE
var _button_pressed_last
var _button_pressed_previously
var _time_since_last_press = 0
var _dash_time = 0
var _waiting_for_double_tap = false
var _already_air_dashed = false

func _ready():
	gravity_scale = GRAVITY_DEFAULT


func _integrate_forces(s):
	var action = _resolve_action(s.step)

	_resolve_state(action, s)


func _resolve_action(delta):
	if _waiting_for_double_tap:
		_time_since_last_press += delta
		if _just_pressed() == _button_pressed_last and not _both_pressed() and _time_since_last_press <= DOUBLE_TAP_DELAY:
			_waiting_for_double_tap = false
			_button_pressed_previously = _button_pressed_last
			_button_pressed_last = _just_pressed()
			return LEFT_DOUBLE_TAPPED if _just_pressed() == 'ui_left' else RIGHT_DOUBLE_TAPPED
		elif _just_pressed() and _both_pressed():
			_waiting_for_double_tap = false
			_button_pressed_previously = _button_pressed_last
			_button_pressed_last = _just_pressed()
			return BOTH_PRESSED
		elif _time_since_last_press > DOUBLE_TAP_DELAY or (_just_pressed() and _just_pressed() != _button_pressed_last):
			if _just_pressed():
				_button_pressed_previously = _button_pressed_last
				_button_pressed_last = _just_pressed()
			_waiting_for_double_tap = false
			if Input.is_action_pressed(_button_pressed_last):
				return LEFT_HELD if _button_pressed_last == 'ui_left' else RIGHT_HELD
			else:
				return LEFT_PRESSED if _button_pressed_last == 'ui_left' else RIGHT_PRESSED
		else:
			return -1

	if _just_pressed():
		_button_pressed_previously = _button_pressed_last
		_button_pressed_last = _just_pressed()
		if not _both_pressed():
			_waiting_for_double_tap = true
			_time_since_last_press = 0
			return -1

	if _both_pressed():
		return BOTH_PRESSED
	if Input.is_action_pressed('ui_left'):
		return LEFT_HELD
	if Input.is_action_pressed('ui_right'):
		return RIGHT_HELD

	return -1


func _resolve_state(action, body_state):
	var on_floor = _is_on_floor(body_state)
	
	match _state:
		IDLE:
			if action == BOTH_PRESSED:
				_state = CHARGING_JUMP
			elif action == LEFT_DOUBLE_TAPPED or action == RIGHT_DOUBLE_TAPPED:
				var direction = -1 if action == LEFT_DOUBLE_TAPPED else 1
				set_axis_velocity(Vector2(direction * 400, 0))
				_state = DASHING
			elif action == LEFT_PRESSED or action == RIGHT_PRESSED:
				var direction = -1 if action == LEFT_PRESSED else 1
				set_axis_velocity(Vector2(direction * 100, -400))
				_state = LAUNCHING
				on_floor = false
			elif action == LEFT_HELD or action == RIGHT_HELD:
				_state = ROLLING
		JUMPING:
			if on_floor:
				_state = IDLE
				_already_air_dashed = false
			elif action == BOTH_PRESSED and body_state.linear_velocity.y >= 0:
				gravity_scale = GRAVITY_KITING
				_state = KITING
			elif (action == LEFT_DOUBLE_TAPPED or action == RIGHT_DOUBLE_TAPPED) and not _already_air_dashed:
				var direction = -1 if action == LEFT_DOUBLE_TAPPED else 1
				set_axis_velocity(Vector2(direction * 200, 0))
				_already_air_dashed = true
		CHARGING_JUMP:
			if not _both_pressed() and on_floor:
				set_axis_velocity(Vector2(0, -600))
				_state = LAUNCHING
				on_floor = false
		LAUNCHING:
			if not on_floor:
				_state = JUMPING
		KITING:
			if on_floor:
				gravity_scale = GRAVITY_DEFAULT
				_state = IDLE
			elif not _both_pressed():
				gravity_scale = GRAVITY_DEFAULT
				_state = JUMPING
		DASHING:
			_dash_time += body_state.step
			if _dash_time >= DASH_DURATION and not Input.is_action_pressed(_button_pressed_last):
				_state = IDLE
				_dash_time = 0
		ROLLING:
			if action == LEFT_HELD or action == RIGHT_HELD:
				var direction = -1 if action == LEFT_HELD else 1
				friction = 0
				linear_velocity.x = direction * 150
			else:
				friction = 1
				linear_velocity.x = 0
				_state = IDLE


func _just_pressed():
	if Input.is_action_just_pressed('ui_right'):
		return 'ui_right'
	elif Input.is_action_just_pressed('ui_left'):
		return 'ui_left'
	else:
		return ''


func _both_pressed():
	return Input.is_action_pressed('ui_right') and Input.is_action_pressed('ui_left')


func _is_on_floor(s):
	for i in range(s.get_contact_count()):
		var obj = s.get_contact_collider_object(i)
		if obj is Floor:
			if s.get_contact_local_normal(i).y == -1:
				return true
	return false
