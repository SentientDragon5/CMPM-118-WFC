class_name TimeMachine extends Resource

var wfc_history: Array[TimeCapsule] = [];
var current_frame: int = 0;

# Tilemap data required to draw the tiles / sprites
var tilemap: TileMapLayer = null;
var tileset: TileSet = null;
var map_size_x: int;
var map_size_y: int;
var tiles: Array = [];
var node: Node;

# Sprite data required to draw the blend sprites. Also has cache for textures because they are soooo slow
var blend_sprite_array: Array = [];
var tileDict: Dictionary = {};

var blend_shader = load("res://shaders/blend.gdshader");

func _init(map_layer: TileMapLayer, new_tileset, new_tiles, size_x, size_y, parent_node) -> void:
	tilemap = map_layer;
	tileset = new_tileset;
	tiles = new_tiles;
	map_size_x = size_x;
	map_size_y = size_y;
	node = parent_node;

#Replaces the timemachine's tilemap with the output of the wfc algoritm at a given frame
func draw_map(frame: int = wfc_history.size() - 1) -> void:
	tilemap.tile_set = tileset;

	# Get the collapsed tiles from the time capsule
	var collapsed_tiles: Array = wfc_history[frame].collapsed;

	# Clear the tilemap and old sprites before redrawing
	tilemap.clear();
	delete_all_blend_sprites();
	
	var is_collapsed_complete = !collapsed_tiles.has(-1);

	var index: int = 0
	for tile_y in range(map_size_y):
		for tile_x in range(map_size_x):
			if !collapsed_tiles.is_empty() and is_collapsed_complete:
				# Draw directly if all tiles are collapsed
				var tile_data = tiles[collapsed_tiles[index]];
				var transform = Global.cardinality_transformations.get(tile_data[1], 0);
				tilemap.set_cell(Vector2i(tile_x, tile_y), 1, tile_data[0], transform);
			else:
				# Draw from wave if not all tiles are collapsed
				var possible_tiles: Array = wfc_history[frame].get_valid_tiles(index);
				if possible_tiles.size() == 1:
					var tile_data = tiles[possible_tiles[0]];
					var transform = Global.cardinality_transformations.get(tile_data[1], 0);
					tilemap.set_cell(Vector2i(tile_x, tile_y), 1, tile_data[0], transform);
				else:
					# Draw the sprites to represent the possible tiles
					draw_blend_sprites(Vector2(tile_x+.5,tile_y+.5) * 64, possible_tiles);
			index += 1;

func moveForward() -> void:
	if current_frame < wfc_history.size() - 1:
		current_frame += 1;
		draw_map(current_frame);
		return;
	print_debug("Cannot go forward in time any further");

func moveBackward() -> void:
	if current_frame > 0:
		current_frame -= 1;
		draw_map(current_frame);
		return;
	print_debug("Cannot go back in time any further");

func draw_blend_sprites(tile_pos: Vector2, possible_tiles: Array):
	#Create sprite at location of the missing tile
	var blended_sprite: Sprite2D = Sprite2D.new();
	blended_sprite.position = tile_pos;
	blended_sprite.scale = Vector2(.3,.3);
	blended_sprite.texture = load("res://icon.svg");
	
	#Create the shader (or attempt to anyway)
	var blend_material = ShaderMaterial.new();
	blend_material.shader = blend_shader;

	blend_material.set_shader_parameter("tex1", get_cell_texture(tiles[possible_tiles[0]][0]));
	blend_material.set_shader_parameter("tex2", get_cell_texture(tiles[possible_tiles[1]][0]));
	
	#Apply the material and draw the sprite
	blended_sprite.material = blend_material;
	blend_sprite_array.append(blended_sprite);
	node.add_child(blended_sprite);
			

func delete_all_blend_sprites():
	if !blend_sprite_array.is_empty():
		for sprite in blend_sprite_array:
			if node.has_node(sprite.get_path()):
				sprite.queue_free();
				node.remove_child(sprite);
		blend_sprite_array.clear();

func get_cell_texture(coord:Vector2i) -> Texture:
	if tileDict.get(coord) != null:
		return tileDict.get(coord);

	var source:TileSetAtlasSource = tileset.get_source(1) as TileSetAtlasSource;
	var rect := source.get_tile_texture_region(coord);
	var image:Image = source.texture.get_image();
	var tile_image := image.get_region(rect);
	tileDict[coord] = ImageTexture.create_from_image(tile_image);
	return tileDict[coord];

func add_capsule() -> TimeCapsule:
	var new_capsule = TimeCapsule.new();
	wfc_history.append(new_capsule);
	current_frame += 1;
	return new_capsule;

class TimeCapsule:
	var collapsed: Array = [];
	var wave: Array = [];

	#TILE POSITION STARTS FROM 0
	func get_valid_tiles(tile_position: int):
		var valid_tile_ids = [];

		for i in wave[tile_position].size():
			if wave[tile_position][i] == true:
				valid_tile_ids.append(i);

		return valid_tile_ids;
