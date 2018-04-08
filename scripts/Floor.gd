extends StaticBody2D

onready var _shape = get_node("CollisionShape2D")
onready var _sprite = get_node("CollisionShape2D/Sprite")

func _ready():
	_sprite.region_enabled = true
	_sprite.region_rect = \
			Rect2(Vector2(0, 0), Vector2(_shape.shape.extents.x * 2, _shape.shape.extents.y * 2))
	_sprite.position = Vector2(0, 0)
	_sprite.scale = Vector2(1, 1)
	_sprite.texture.flags = Texture.FLAG_FILTER | Texture.FLAG_REPEAT