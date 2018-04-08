extends Node

signal started
signal over

onready var _player = get_node('Player')
onready var _lava = get_node('Lava')

func _ready():
	emit_signal('started')


func _process(delta):
	if _player.global_position.y >= _lava.global_position.y:
		emit_signal('over')