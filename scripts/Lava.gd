extends Sprite

var _speed = 0

func _process(delta):
	position.y -= delta * _speed
	pass


func _on_Game_started():
	position.x = 0
	position.y = 900
	_speed = 45


func _on_Game_over():
	_speed = 0


func _on_Game_win():
	_speed = 0
