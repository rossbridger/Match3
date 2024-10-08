extends Node2D

@export_category("Grid Variables")
@export var width: int
@export var height: int
@export var x_start: int
@export var y_start: int
@export var offset: int

var all_pieces: Array[Array]
var first_touch: Vector2 = Vector2(0, 0)
var final_touch: Vector2 = Vector2(0, 0)
var controlling: bool = false

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

func pixel_to_grid(pixel_x, pixel_y):
	var new_x = round((pixel_x - x_start)/offset)
	var new_y = round((pixel_y - y_start)/-offset)
	return Vector2(new_x, new_y)
	
func is_in_grid(grid_position: Vector2) -> bool:
	var column = grid_position.x
	var row = grid_position.y
	if column >= 0 && column < width:
		if row >= 0 && row < height:
			return true
	return false

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

func touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		var grid_position = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
		if is_in_grid(grid_position):
			first_touch = grid_position
			controlling = true
	if Input.is_action_just_released("ui_touch"):
		var grid_position = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
		if is_in_grid(grid_position) && controlling:
			final_touch = grid_position
			touch_difference(first_touch, final_touch)
		controlling = false

func swap_pieces(column, row, direction):
	var first_piece: Piece = all_pieces[column][row]
	var other_piece: Piece = all_pieces[column + direction.x][row + direction.y]
	if first_piece != null && other_piece != null:
		all_pieces[column][row] = other_piece
		all_pieces[column + direction.x][row + direction.y] = first_piece
		first_piece.move(grid_to_pixel(column + direction.x, row + direction.y))
		other_piece.move(grid_to_pixel(column, row))
		find_matches()

func touch_difference(grid_1, grid_2):
	var difference = grid_2 - grid_1
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(1, 0))
		elif difference.x < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(-1, 0))
	elif abs(difference.y) > abs(difference.x):
		if difference.y > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, 1))
		elif difference.y < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, -1))

func find_matches():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				var current_color = all_pieces[i][j].color
				if i > 0 && i < width - 1:
					if all_pieces[i - 1][j] != null && all_pieces[i + 1][j] != null:
						if all_pieces[i - 1][j].color == current_color && \
						   all_pieces[i + 1][j].color == current_color:
							all_pieces[i - 1][j].matched = true
							all_pieces[i - 1][j].dim()
							all_pieces[i][j].matched = true
							all_pieces[i][j].dim()
							all_pieces[i + 1][j].matched = true
							all_pieces[i + 1][j].dim()
				if j > 0 && j < height - 1:
					if all_pieces[i][j - 1] != null && all_pieces[i][j + 1] != null:
						if all_pieces[i][j - 1].color == current_color && \
						   all_pieces[i][j + 1].color == current_color:
							all_pieces[i][j - 1].matched = true
							all_pieces[i][j - 1].dim()
							all_pieces[i][j].matched = true
							all_pieces[i][j].dim()
							all_pieces[i][j + 1].matched = true
							all_pieces[i][j + 1].dim()
	$"../DestroyTimer".start()

func destroy_matched():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					all_pieces[i][j].queue_free()
					all_pieces[i][j] = null
					$"../CollapseTimer".start()

func collapse_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				for k in range(j + 1, height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].move(grid_to_pixel(i, j))
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null
						break
	# recursively find new matches until no more matches are found
	find_matches()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	all_pieces = make_2d_array()
	spawn_pieces()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	touch_input()

func _on_destroy_timer_timeout() -> void:
	destroy_matched()


func _on_collapse_timer_timeout() -> void:
	collapse_columns()
