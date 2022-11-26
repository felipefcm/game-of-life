extends Node2D

@export var world_size: Vector2i = Vector2i(50, 37)
@export var tickDuration: float = 0.25

@onready var tileMap := $TileMap as TileMap

const WHITE = Vector2i(0, 0)
const BLACK = Vector2i(1, 0)

var timeAcc := 0.0
var currentGen: Array = []
var nextGen: Array = []

func _ready():
	initGen(currentGen)
	initGen(nextGen)
	
	seedCurrentGen()


func _process(delta: float):
	timeAcc += delta

	if(timeAcc >= tickDuration):
		print('TICK')

		calculateNextGen()
		updateTileMap(nextGen)
		
		copyGen(nextGen, currentGen)
		
		timeAcc = 0


func initGen(gen: Array):
	gen.resize(world_size.y)

	for row in range(world_size.y):
		gen[row] = []
		gen[row].resize(world_size.x)

		for col in range(world_size.x):
			gen[row][col] = 0


func seedCurrentGen():
	for row in range(world_size.y):
		for col in range(world_size.x):
			currentGen[row][col] = isLiveSeedTile(col, row)


func updateTileMap(gen: Array):
	for row in range(world_size.y):
		for col in range(world_size.x):
			setTileLive(col, row, gen[row][col])


func calculateNextGen():
	for row in range(world_size.y):
		for col in range(world_size.x):
			var numLiveNeighbours := calculateNumberOfLiveNeighbours(currentGen, col, row)
			
			if(isLive(currentGen, col, row)):
				nextGen[row][col] = 1 if(numLiveNeighbours == 2 || numLiveNeighbours == 3) else 0
			else:
				nextGen[row][col] = 1 if(numLiveNeighbours == 3) else 0


func calculateNumberOfLiveNeighbours(gen: Array, x: int, y: int) -> int:
	var num := 0

	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			if(dx == 0 && dy == 0): continue

			var nx = x + dx
			var ny = y + dy

			if(nx < 0 || nx >= world_size.x): continue
			if(ny < 0 || ny >= world_size.y): continue

			if(gen[ny][nx] == 1): num += 1

	return num


func isLive(gen: Array, x: int, y: int) -> int:
	return gen[y][x] == 1


func setTileLive(x: int, y: int, live: int):
	tileMap.set_cell(
		0, Vector2i(x, y), 0,
		WHITE if live == 1 else BLACK
	)


func isLiveSeedTile(x: int, y: int) -> int:
	var tile := tileMap.get_cell_atlas_coords(0, Vector2i(x, y))
	return 1 if tile.x == WHITE.x else 0


func copyGen(srcGen: Array, dstGen: Array):
	for row in range(world_size.y):
		for col in range(world_size.x):
			dstGen[row][col] = srcGen[row][col]

