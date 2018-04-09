extends CanvasLayer

const HINTS = [
	'Hold LEFT or RIGHT to move',
	'Press LEFT or RIGHT to jump',
	'Double tap LEFT or RIGHT to dash',
	'Hold both LEFT and RIGHT then release to do a bigger vertical jump',
	'While in the air hold both LEFT and RIGHT to kite',
	'While in the air double tap LEFT or RIGHT to dash'
]

const NEXT_HINT = 'Press SPACE to show next hint'
const START_GAME = 'Press ENTER to start the game'
const LOADING = 'LOADING...'

onready var _hint = get_node('Hint')
onready var _prompt = get_node('Prompt')

var _current_hint = 0
var _tutorial_finished = false

func _ready():
	_hint.text = HINTS[_current_hint]
	_prompt.text = NEXT_HINT


func _process(delta):
	if not _tutorial_finished and Input.is_action_just_pressed('select'):
		if _current_hint < HINTS.size() - 1:
			_current_hint += 1
			_hint.text = HINTS[_current_hint]
		else:
			_hint.hide()
			_prompt.text = START_GAME
			_prompt.get_font('font').set_size(30)
			_tutorial_finished = true

	if _tutorial_finished and Input.is_action_just_pressed('accept'):
		_prompt.text = START_GAME
		get_tree().change_scene('res://Game.tscn')