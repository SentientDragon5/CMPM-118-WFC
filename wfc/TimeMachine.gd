class_name TimeMachine

var history: Array[TimeCapsule] = []
var current_frame: int = 0
# A clone of important stuff needed to draw the tilemap
var tilemap: TileMapLayer = null;
var tileset: TileSet = null;
var map_size_x: int;
var map_size_y: int;
var tiles: Array = [];
var node: Node;

var sprite_arr:Array = []
var tileDict:Dictionary = {}


var blend_shader = load("res://shaders/blend.gdshader")


func _init():
	pass;



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

	# Clear the tilemap and old sprites before redrawing
	tilemap.clear();
	delete_sprites()

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
				var possible_tiles: Array = history[frame].get_first_two_possible_tiles(index);
				if possible_tiles.size() == 1:
					var tile_data = tiles[possible_tiles[0]];
					var transform = cardinality_transformations.get(tile_data[1], 0);
					tilemap.set_cell(Vector2i(tile_x, tile_y), 1, tile_data[0], transform);
				else:
					# Draw the sprites to represent the possible tiles
					draw_blend_sprites(Vector2(tile_x+.5,tile_y+.5) * 64, possible_tiles);
			index += 1;
			
			
func draw_blend_sprites(tile_pos: Vector2, possible_tiles: Array):
	#Create sprite at location of the missing tile
	var sprite33: Sprite2D = Sprite2D.new();
	sprite33.position = tile_pos;
	sprite33.scale = Vector2(.3,.3);
	sprite33.texture = load("res://icon.svg")
	
	#Create the shader (or attempt to anyway)
	var blend_material = ShaderMaterial.new()
	blend_material.shader = blend_shader;

	blend_material.set_shader_parameter("tex1", get_cell_texture(tiles[possible_tiles[0]][0]))
	blend_material.set_shader_parameter("tex2", get_cell_texture(tiles[possible_tiles[1]][0]))
	
	#Apply the material and draw the sprite
	sprite33.material = blend_material
	sprite_arr.append(sprite33)
	node.add_child(sprite33)
			

func delete_sprites():
	if !sprite_arr.is_empty():
		for sprite in sprite_arr:
			if node.has_node(sprite.get_path()):
				sprite.queue_free();
				node.remove_child(sprite)
		sprite_arr.clear()

func get_cell_texture(coord:Vector2i) -> Texture:
	if tileDict.get(coord) != null:
		return tileDict.get(coord);

	var source:TileSetAtlasSource = tileset.get_source(1) as TileSetAtlasSource
	var rect := source.get_tile_texture_region(coord)
	var image:Image = source.texture.get_image()
	var tile_image := image.get_region(rect)
	tileDict[coord] = ImageTexture.create_from_image(tile_image)
	return tileDict[coord]


#TODO: Implement this in a good way (builder pattern?)
func add_capsule() -> TimeCapsule:
	var new_capsule = TimeCapsule.new();
	history.append(new_capsule);
	current_frame += 1;
	return new_capsule;


class TimeCapsule:
	var collapsed: Array = [];
	var wave: Array = [];

	#TILE POSITION STARTS FROM 0
	func get_first_two_possible_tiles(tile_position: int):
		#This can probably be done better, but filters dont work thanks to us using the index as the tile
		var valid_tile_ids = [];

		for i in wave[tile_position].size():
			if wave[tile_position][i] == true:
				valid_tile_ids.append(i);

		return valid_tile_ids;
