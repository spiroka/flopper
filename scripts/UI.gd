extends Node

const GO = 'GO'
const GAME_OVER = 'GAME OVER'
const WIN = 'YOU WON'
const RESTART = 'Press ENTER to restart'

onready var _label = get_node('Label')
onready var _hint = get_node('Hint')

var _message_time = 0


func _process(delta):
	_message_time -= delta
	if _message_time < 0:
		_label.hide()


func _show_message(text, duration):
	_label.text = text
	_label.show()
	_message_time = duration


func _show_hint(text):
	_hint.text = text
	_hint.show()


func _on_Game_started():
	_show_message(GO, 2)
	_hint.hide()


func _on_Game_over():
	_show_message(GAME_OVER, 2)
	_show_hint(RESTART)


func _on_Game_win():
	_show_message(WIN, 2)
	_show_hint(RESTART)
