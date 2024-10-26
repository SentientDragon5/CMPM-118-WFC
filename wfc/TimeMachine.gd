class_name TimeMachine

var history : Array[TimeCapsule] = []
var current_frame : int = 0

# A clone of important stuff needed to draw the tilemap
var tilemap: TileMapLayer = null;
var tileset: TileSet = null;
var map_size_x: int = 16;
var map_size_y: int = 16;
var tiles: Array = [];


func moveBackward() -> void:
	if current_frame > 0:
		current_frame -= 1;
		drawTiles(current_frame);
		return;
	print_debug("Cannot go back in time any further");

func moveForward() -> void:
	if current_frame < history.size() - 1:
		current_frame += 1
		drawTiles(current_frame);
		return;
	print_debug("Cannot go forward in time any further");

#Replaces the timemachine's tilemap with the output of the wfc algoritm at a given frame
func drawTiles(frame: int = history.size() - 1) -> void:
	const cardinality_transformations = Global.cardinality_transformations;
	tilemap.tile_set = tileset;

	#Get the collapsed tiles from the time capsule
	var collapsed_tiles = history[frame].collapsed;

	var index: int = 0;


	for tile_y in range(map_size_y):
		for tile_x in range (map_size_x):
			#if collapsed_tiles[index] == -1:
				#TODO: Show tiles that dont exist in a cool way
				
				
			var tile_data = tiles[collapsed_tiles[index]];
			var transform = cardinality_transformations.get(tile_data[1], 0);
			tilemap.set_cell(Vector2i(tile_x, tile_y), 1, tile_data[0], transform);
			index += 1;

#TODO: Implement this in a good way (builder pattern?)
func add_capsule() -> TimeCapsule:
	var new_capsule = TimeCapsule.new()
	history.append(new_capsule)
	current_frame += 1
	return new_capsule


class TimeCapsule:
	var collapsed = null
	var wave = null
