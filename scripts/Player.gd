extends KinematicBody2D

enum STATES {IDLE, JUMPING, CHARGING_JUMP, KITING, DASHING, WALKING}
enum ACTIONS {LEFT_PRESSED, RIGHT_PRESSED, BOTH_PRESSED, LEFT_DOUBLE_TAPPED, RIGHT_DOUBLE_TAPPED, LEFT_HELD, RIGHT_HELD}

const GRAVITY_DEFAULT = 1500
const GRAVITY_KITING = 300
const DASH_DURATION = 0.2
const DOUBLE_TAP_DELAY = 0.17
const DASH_FORCE = 700
const HORIZONTAL_JUMP_FORCE = 200
const VERTICAL_JUMP_FORCE = -700
const CHARGED_JUMP_FORCE = -800
const WALK_FORCE = 300

onready var _start_pos = get_node('../StartPosition')
onready var _animation_player = get_node('AnimationPlayer')

var _state = IDLE
var _button_pressed_last
var _button_pressed_previously
var _time_since_last_press = 0
var _dash_time = 0
var _waiting_for_double_tap = false
var _already_air_dashed = false
var _velocity = Vector2()
var _gravity_scale = GRAVITY_DEFAULT
var _sleeping = false

func ready():
	_animation_player.play('idle')


func _physics_process(delta):
	if _sleeping:
		return

	var action = _resolve_action(delta)

	_resolve_state(action, delta)
	_velocity.y += delta * _gravity_scale
	_velocity = move_and_slide(_velocity, Vector2(0, -1))


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


func _resolve_state(action, delta):
	match _state:
		IDLE:
			if action == BOTH_PRESSED:
				_state = CHARGING_JUMP
			elif action == LEFT_DOUBLE_TAPPED or action == RIGHT_DOUBLE_TAPPED:
				var direction = -1 if action == LEFT_DOUBLE_TAPPED else 1
				_velocity = Vector2(direction * DASH_FORCE, 0)
				_state = DASHING
			elif action == LEFT_PRESSED or action == RIGHT_PRESSED:
				var direction = -1 if action == LEFT_PRESSED else 1
				_velocity = Vector2(direction * HORIZONTAL_JUMP_FORCE, VERTICAL_JUMP_FORCE)
				_state = JUMPING
				_animation_player.play('launch')
				_animation_player.queue('idle')
			elif action == LEFT_HELD or action == RIGHT_HELD:
				_state = WALKING
		JUMPING:
			if is_on_floor():
				_state = IDLE
				_already_air_dashed = false
				_velocity.x = 0
			elif action == BOTH_PRESSED and _velocity.y >= 0:
				_gravity_scale = GRAVITY_KITING
				_state = KITING
				_animation_player.play('kite')
			elif (action == LEFT_DOUBLE_TAPPED or action == RIGHT_DOUBLE_TAPPED) and not _already_air_dashed:
				var direction = -1 if action == LEFT_DOUBLE_TAPPED else 1
				_velocity += Vector2(direction * DASH_FORCE, -100)
				_already_air_dashed = true
		CHARGING_JUMP:
			if not _both_pressed() and is_on_floor():
				_velocity = Vector2(0, CHARGED_JUMP_FORCE)
				_state = JUMPING
				_animation_player.play('launch')
				_animation_player.queue('idle')
		KITING:
			if is_on_floor():
				_gravity_scale = GRAVITY_DEFAULT
				_velocity.x = 0
				_state = IDLE
				_animation_player.play('idle')
			elif not _both_pressed():
				_gravity_scale = GRAVITY_DEFAULT
				_state = JUMPING
				_animation_player.play('idle')
		DASHING:
			_dash_time += delta
			if _dash_time >= DASH_DURATION and not Input.is_action_pressed(_button_pressed_last):
				_state = IDLE
				_dash_time = 0
				_velocity.x = 0
		WALKING:
			if action == LEFT_HELD or action == RIGHT_HELD:
				var direction = -1 if action == LEFT_HELD else 1
				_velocity.x = direction * WALK_FORCE
			else:
				_velocity.x = 0
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
		if s.get_contact_local_normal(i).dot(Vector2(0, -1)) > 0.6:
			return true
	return false


func _on_Game_over():
	_sleeping = true


func _on_Game_win():
	_sleeping = true


func _on_Game_started():
	global_position.x = _start_pos.position.x
	global_position.y = _start_pos.position.y
	_gravity_scale = GRAVITY_DEFAULT
	_sleeping = false
