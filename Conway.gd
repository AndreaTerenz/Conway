class_name Conway
extends Object

enum NEIGHBORHOOD_MODE {
	VNEUMANN,
	MOORE
}

var grid : Array[bool] = []
var grid_size := Vector2i.ZERO
var birth_list := [3]
var survive_list := [2,3]
var neighborhood_mode := NEIGHBORHOOD_MODE.MOORE

var nrows : int :
	get:
		return grid_size.y
var ncols : int :
	get:
		return grid_size.x

func _init(g_size: Vector2i, rule := "B3/S23"):
	grid_size = g_size
	
	grid.resize(nrows * ncols)
	grid.fill(false)
	
	for i in len(grid):
		grid[i] = (randf() > 0.5)
		
	parse_rulestring(rule)
		
func parse_rulestring(rule: String):
	var regex = RegEx.new()
	regex.compile("^B(\\d)*\\/S(\\d)*[VM]?$")
	assert(regex.search(rule), "INVALID RULESTRING '%s'" % rule)
	
	print("Rule: %s" % rule)
	
	rule = rule.trim_prefix("B")
	
	regex.compile(".*V$")
	if regex.search(rule):
		neighborhood_mode = NEIGHBORHOOD_MODE.VNEUMANN
		rule = rule.trim_suffix("V")
	else:
		regex.compile(".*M?$")
		if regex.search(rule):
			neighborhood_mode = NEIGHBORHOOD_MODE.MOORE
			rule = rule.trim_suffix("M")
	
	rule = rule.replace("S", "")
	
	var tmp := rule.split("/")
	var birth_str := tmp[0]
	var survive_str := tmp[1]
	
	birth_list = Array(birth_str.split()).map(func(s): return int(s))
	survive_list = Array(survive_str.split()).map(func(s): return int(s))
	
	print("Neighborhood type: %d" % neighborhood_mode)
	print("Birth list: %s" % [birth_list])
	print("Survival list: %s" % [survive_list])
		
func step():
	var next_grid := grid.duplicate()
	
	var deltas : Array[Vector2i] = [
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.RIGHT
	]
	
	if neighborhood_mode == NEIGHBORHOOD_MODE.MOORE:
		deltas += [
			Vector2i.UP + Vector2i.LEFT,
			Vector2i.UP + Vector2i.RIGHT,
			Vector2i.DOWN + Vector2i.LEFT,
			Vector2i.DOWN + Vector2i.RIGHT,
		]
	
	for row in nrows:
		for col in ncols:
			var here := Vector2i(col, row)
			var alive_here := get_cell_at(row, col)
			
			var alive := 0#count_live_neighbors(row, col)
			
			var left := len(deltas)
			for delta in deltas:
				var n_pos := here + delta
				var n_val := get_cell_at(n_pos.y, n_pos.x)
					
				alive += int(n_val)
			
			var survive := (alive_here and alive in survive_list)
			var born := (not alive_here and alive in birth_list)
			var next_value := survive or born
			
			var idx := gridpos_to_idx(row, col)
			
			next_grid[idx] = next_value
			
	grid = next_grid

func check_gridpos(r: int, c: int):
	return (r in range(0, nrows) and c in range(0, ncols))
		
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

