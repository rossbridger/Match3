extends Node2D

@export_category("Grid Variables")
@export var width: int
@export var height: int
@export var x_start: int
@export var y_start: int
@export var offset: int
@export var all_pieces: Array[Array]

@onready var possible_pieces = {
	PieceColor.PieceColor.blue: preload("res://scenes/blue_piece.tscn"),
	PieceColor.PieceColor.green: preload("res://scenes/green_piece.tscn"),
	PieceColor.PieceColor.light_green: preload("res://scenes/light_green_piece.tscn"),
	PieceColor.PieceColor.orange: preload("res://scenes/orange_piece.tscn"),
	PieceColor.PieceColor.pink: preload("res://scenes/pink_piece.tscn"),
	PieceColor.PieceColor.yellow: preload("res://scenes/yellow_piece.tscn")
}

func make_2d_array() -> Array[Array]:
	var array: Array[Array] = []
	for i: int in width:
		array.append([])
		for j: int in height:
			array[i].append(null)
	return array

func grid_to_pixel(column, row):
	var new_x = x_start + offset * column
	var new_y = y_start - offset * row
	return Vector2(new_x, new_y)

func spawn_pieces() -> void:
	for i in width:
		for j in height:
			# TODO: There is a deterministic way to assign the color
			var rand
			var a = PieceColor.PieceColor.values()
			a.shuffle()
			while a.size() > 0:
				rand = a.pop_front()
				if match_at(i, j, rand) == false:
					break
			var piece = possible_pieces[rand].instantiate()
			add_child(piece)
			piece.set_position(grid_to_pixel(i, j))
			all_pieces[i][j] = piece

func match_at(i: int, j: int, color: PieceColor.PieceColor) -> bool:
	if i > 1:
		if all_pieces[i - 1][j] != null && all_pieces[i - 2][j] != null:
			if all_pieces[i - 1][j].color == color && all_pieces[i - 2][j].color == color:
				return true
	if j > 1:
		if all_pieces[i][j - 1] != null && all_pieces[i][j - 2] != null:
			if all_pieces[i][j - 1].color == color && all_pieces[i][j - 2].color == color:
				return true
	return false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	all_pieces = make_2d_array()
	spawn_pieces()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
