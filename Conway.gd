class_name Conway
extends Object

enum NEIGHBORHOOD_MODE {
	VNEUMANN,
	MOORE
}

var grid : Array[bool]
var next_grid : Array[bool]
var grid_A : Array[bool] = []
var grid_B : Array[bool] = []
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
	
	for g in [grid_A, grid_B]:
		g.resize(nrows * ncols)
		g.fill(false)
	
		for i in len(g):
			g[i] = (randf() > 0.5)
			
	grid = grid_A
	next_grid = grid_B
		
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
	
	for idx in range(len(grid)):
		var here := idx_to_gridpos(idx)
		var row := here.y
		var col := here.x
		var alive_here := get_cell_at(row, col)
		
		var alive := 0
		
		var left := len(deltas)
		for delta in deltas:
			var n_pos := here + delta
			var n_val := get_cell_at(n_pos.y, n_pos.x)
				
			alive += int(n_val)
			left -= 1
			
			if not alive_here:
				# Too few max possible alive neighbors to activate cell
				# (definetely underpopulated)
				if (alive + left) < birth_list.min():
					break
			else:
				# Already too many alive neighbors to survive
				# (definetely overpopulated)
				if alive > survive_list.max():
					break
		
		var survive := (alive_here and alive in survive_list)
		var born := (not alive_here and alive in birth_list)
		var next_value := survive or born
		
		next_grid[idx] = next_value
	
	var tmp = grid
	grid = next_grid
	next_grid = tmp

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
	
	return Vector2i(c,r)

