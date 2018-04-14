extends Node

signal started
signal over
signal win

enum STATES {STARTED, STOPPED}

onready var _player = get_node('Player')
onready var _lava = get_node('Lava')
onready var _win_pos = get_node('WinPosition')

var _current_scene = null
var _state = STARTED

func _ready():
	emit_signal('started')


func _process(delta):
	if _state == STARTED:
		if _player.global_position.y >= _lava.global_position.y:
			emit_signal('over')
			_state = STOPPED
		if (abs(_player.global_position.y - _win_pos.position.y) <= 64 and
				abs(_player.global_position.x - _win_pos.position.x) <= 64):
			emit_signal('win')
			_state = STOPPED
	elif _state == STOPPED:
		if Input.is_action_just_pressed('accept'):
			emit_signal('started')
			_state = STARTED
