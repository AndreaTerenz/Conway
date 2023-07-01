class_name Conway
extends Object

var grid : Array[bool] = []
var grid_size := Vector2i.ZERO
var nrows := 0
var ncols := 0
#var nrows : int :
#	get:
#		return grid_size.y
#var ncols : int :
#	get:
#		return grid_size.x

func _init(g_size: Vector2i):
	grid_size = g_size
	nrows = grid_size.y
	ncols = grid_size.x
	
	grid.resize(nrows * ncols)
	grid.fill(false)
	
	for i in len(grid):
		grid[i] = (randf() > 0.5)
		
func step():
	var next_grid := grid.duplicate()
	
	for col in ncols:
		for row in nrows:
			var alive_here := get_cell_at(row, col)
			var neigbhors := get_cell_neighbors(row, col)
			
			var live := neigbhors.count(true)
			var dead := 8 - live
			
			var next_value := alive_here
			
			if alive_here:
				# Die with less than 2 neighbors
				# Die with more than 3 neighbors
				if live < 2 or live > 3: 
					next_value = false
			else:
				# Come alive with exactly 3 neighbors
				if live == 3:
					next_value = true
					
			var idx := gridpos_to_idx(row, col)
			next_grid[idx] = next_value
			
	grid = next_grid

func check_gridpos(r: int, c: int):
	return (r in range(0, nrows) and c in range(0, ncols))
		
func get_cell_neighbors(r: int, c: int) -> Array[bool]:
	if not check_gridpos(r, c):
		return []
		
	var here := Vector2i(c,r)
	var output : Array[bool] = []
	
	for col_d in [-1, 0, 1]:
		for row_d in [-1, 0, 1]:
			# Skip current cell
			if (col_d == 0 and row_d == 0):
				continue
				
			var n_pos := here + Vector2i(col_d, row_d)
			output.append(get_cell_at(n_pos.y, n_pos.x))
	
	return output
		
func get_cell_at(r: int, c: int) -> bool:
	var i := gridpos_to_idx(r, c)
	
	return grid[i] and (i != -1)

func gridpos_to_idx(r: int, c: int) -> int:
	if not check_gridpos(r,c):
		return -1
		
	var i := r * ncols + c
	
	assert(i < len(grid), "INVALID INDEX (%d) FOR POSITION (%d %d) | %d" % [i, r, c, len(grid)])
	
	return i
	
func idx_to_gridpos(idx: int) -> Vector2i:
	if not idx in range(0, len(grid)):
		return -1 * Vector2i.ONE
	
	var r : int = idx / ncols
	var c := idx % ncols
	
	return Vector2i(r,c)
