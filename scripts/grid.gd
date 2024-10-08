extends Node2D

@export_category("Grid Variables")
@export var width: int
@export var height: int
@export var x_start: int
@export var y_start: int
@export var offset: int
@export var all_pieces: Array[Array]

@onready var possible_pieces = [
	preload("res://scenes/blue_piece.tscn"),
	preload("res://scenes/green_piece.tscn"),
	preload("res://scenes/light_green_piece.tscn"),
	preload("res://scenes/orange_piece.tscn"),
	preload("res://scenes/pink_piece.tscn"),
	preload("res://scenes/yellow_piece.tscn")
]

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

func spawn_pieces():
	for i in width:
		for j in height:
			# choose a random number
			var rand = randi_range(0, possible_pieces.size() - 1)
			var piece = possible_pieces[rand].instantiate()
			add_child(piece)
			piece.set_position(grid_to_pixel(i, j))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	all_pieces = make_2d_array()
	spawn_pieces()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
