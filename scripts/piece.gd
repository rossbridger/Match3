extends Node2D
class_name Piece

@export var color: PieceColor.PieceColor

func move(target):
	var move_tween = create_tween()
	move_tween.tween_property(self,"position", target, 0.3) \
			  .set_trans(Tween.TRANS_SINE) \
			  .set_ease(Tween.EASE_OUT)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
