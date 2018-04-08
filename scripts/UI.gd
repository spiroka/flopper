extends Node

const GO = 'GO'
const GAME_OVER = 'GAME OVER'

onready var _label = get_node('Label')
var _message_time = 0


func _process(delta):
	_message_time -= delta
	if _message_time < 0:
		_label.hide()


func _show_message(text, duration):
	_label.text = text
	_label.show()
	_message_time = duration


func _on_Game_started():
	_show_message(GO, 2)


func _on_Game_over():
	_show_message(GAME_OVER, 2)
