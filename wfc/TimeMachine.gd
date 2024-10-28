class_name TimeMachine

var history: Array[TimeCapsule] = []
var current_frame: int = 0
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
		current_frame += 1;
		drawTiles(current_frame);
		return;
	print_debug("Cannot go forward in time any further");


#Replaces the timemachine's tilemap with the output of the wfc algoritm at a given frame
func drawTiles(frame: int = history.size() - 1) -> void:
	const cardinality_transformations = Global.cardinality_transformations;
	tilemap.tile_set = tileset;

	# Get the collapsed tiles from the time capsule
	var collapsed_tiles: Array = history[frame].collapsed;

	# Clear the tilemap before drawing
	tilemap.clear();

	var index: int = 0
	for tile_y in range(map_size_y):
		for tile_x in range(map_size_x):
			if !collapsed_tiles.is_empty() and !collapsed_tiles.has(-1):
				# Draw directly if all tiles are collapsed
				var tile_data = tiles[collapsed_tiles[index]];
				var transform = cardinality_transformations.get(tile_data[1], 0);
				tilemap.set_cell(Vector2i(tile_x, tile_y), 1, tile_data[0], transform);
			else:
				# Draw from wave if not all tiles are collapsed
				var possible_tiles: Array = history[frame].get_possible_tiles(index);
				if possible_tiles.size() == 1:
					var tile_data = tiles[possible_tiles[0]];
					var transform = cardinality_transformations.get(tile_data[1], 0);
					tilemap.set_cell(Vector2i(tile_x, tile_y), 1, tile_data[0], transform);
				else:
					# Placeholder for multiple possible tiles
					pass;
			index += 1;


#TODO: Implement this in a good way (builder pattern?)
func add_capsule() -> TimeCapsule:
	var new_capsule = TimeCapsule.new();
	history.append(new_capsule);
	current_frame += 1;
	return new_capsule;


class TimeCapsule:
	var collapsed: Array = [];
	var wave: Array = [];

	#Keeps track of the entropy of each tile position. THe aglorithm will visit the one with the least amount of entropy first.
	# This is used to determine which tile to collapse next. The tile is then chosen with a weighted random
	var entropy = null;


	#TILE POSITION STARTS FROM 0
	func get_possible_tiles(tile_position: int):
		#This can probably be done better, but filters dont work thanks to us using the index as the tile
		var valid_tile_ids = [];

		for i in wave[tile_position].size():
			if wave[tile_position][i] == true:
				valid_tile_ids.append(i);

		return valid_tile_ids;
