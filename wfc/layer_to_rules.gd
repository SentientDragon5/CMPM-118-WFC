class_name Defn_Factory extends Node
var new_definition : Tiled_Rules;
@export var sample_layer : TileMapLayer;
@export var sample_size : Vector2;
@export var force_symmetry = "L";
@export var weight_evenly : bool = false;
@export var periodic : bool = true;

#enum UNIQUE

var unique_tiles : Dictionary;
var unique_rules : Dictionary;

const cardinality_transformations: Dictionary = {
	0: 0,
	1: TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V,
	2: TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V,
	3: TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H,
	4: TileSetAtlasSource.TRANSFORM_FLIP_H,
	5: TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V,
	6: TileSetAtlasSource.TRANSFORM_FLIP_V,
	7: TileSetAtlasSource.TRANSFORM_TRANSPOSE
}

const cardinality_rotation : Array = [1, 2, 3, 0, 7, 4, 5, 6];

func setup() -> Tiled_Rules:
	new_definition = Tiled_Rules.new();
	#get tile set
	new_definition.tileset = sample_layer.tile_set;
	#Read in tiles and add to tiles[]
	read_tiles();
	#get adjacencies and cardinalities to push to neighbors[]
	get_neighbors();
	return new_definition;
	
func read_tiles() -> void:
	for x in sample_size.x:
		for y in sample_size.y:
			var tile_coords : Vector2 = sample_layer.get_cell_atlas_coords(Vector2(x, y));
			var tile_name : String = get_tile_name(tile_coords);
			if !unique_tiles.has(tile_name):
				unique_tiles[tile_name] = 1;
				new_definition.tiles.push_back({"name": tile_name, "symmetry":force_symmetry, "atlas_coords":tile_coords})
			else:
				unique_tiles[tile_name] += 1;
	for tile in new_definition.tiles:
		if !weight_evenly: #refactor possible
			tile["weight"] = unique_tiles[tile["name"]];
			
func get_neighbors() -> void:#currently generates redundant rules
	#loop through sample x by y
	for x in sample_size.x:
		for y in sample_size.y:
			#for each tile get left and bottom neighbor pair
			#L & r is easy
			var cur_tile : Vector2 = Vector2(x, y);
			#get correct cardinality based on rotations and alt tile id
			if x < sample_size.x - 1: 
				var result : Dictionary = {"left": 0, "right": 0};
				var l_neighbor : String = get_tile_name(sample_layer.get_cell_atlas_coords(cur_tile));
				var l_neighbor_cardinality : int = cardinality_transformations.find_key(sample_layer.get_cell_alternative_tile(cur_tile));
				var right_coords : Vector2 = sample_layer.get_neighbor_cell(cur_tile, TileSet.CELL_NEIGHBOR_RIGHT_SIDE);
				var r_neighbor : String = get_tile_name(sample_layer.get_cell_atlas_coords(right_coords));
				var r_neighbor_cardinality : int = cardinality_transformations.find_key(sample_layer.get_cell_alternative_tile(right_coords));
				result["left"] = l_neighbor + " " + str(l_neighbor_cardinality);
				result["right"] = r_neighbor + " " + str(r_neighbor_cardinality);
				if is_rule_unique(result["left"], result["right"]):
					new_definition.neighbors.push_back(result);
			elif periodic:
				var result : Dictionary = {"left": 0, "right": 0};
				var l_neighbor : String = get_tile_name(sample_layer.get_cell_atlas_coords(cur_tile));
				var l_neighbor_cardinality : int = cardinality_transformations.find_key(sample_layer.get_cell_alternative_tile(cur_tile));
				var right_coords : Vector2 = Vector2(0, cur_tile.y);
				var r_neighbor : String = get_tile_name(sample_layer.get_cell_atlas_coords(right_coords));
				var r_neighbor_cardinality : int = cardinality_transformations.find_key(sample_layer.get_cell_alternative_tile(right_coords));
				result["left"] = l_neighbor + " " + str(l_neighbor_cardinality);
				result["right"] = r_neighbor + " " + str(r_neighbor_cardinality);
				if is_rule_unique(result["left"], result["right"]):
					new_definition.neighbors.push_back(result);
				
			if y < sample_size.y - 1:
				var result : Dictionary = {"left": 0, "right": 0};
				var u_neighbor : String = get_tile_name(sample_layer.get_cell_atlas_coords(cur_tile));
				var u_neighbor_cardinality : int = cardinality_transformations.find_key(sample_layer.get_cell_alternative_tile(cur_tile));
				u_neighbor_cardinality = cardinality_rotation[u_neighbor_cardinality];
				var down_coords : Vector2 = sample_layer.get_neighbor_cell(cur_tile, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE);
				var d_neighbor : String = get_tile_name(sample_layer.get_cell_atlas_coords(down_coords));
				var d_neighbor_cardinality : int = cardinality_transformations.find_key(sample_layer.get_cell_alternative_tile(down_coords));
				d_neighbor_cardinality = cardinality_rotation[d_neighbor_cardinality];
				result["left"] = u_neighbor + " " + str(u_neighbor_cardinality);
				result["right"] = d_neighbor + " " + str(d_neighbor_cardinality);
				if is_rule_unique(result["left"], result["right"]):
					new_definition.neighbors.push_back(result);
				
			elif periodic:
				var result : Dictionary = {"left": 0, "right": 0};
				var u_neighbor : String = get_tile_name(sample_layer.get_cell_atlas_coords(cur_tile));
				var u_neighbor_cardinality : int = cardinality_transformations.find_key(sample_layer.get_cell_alternative_tile(cur_tile));
				u_neighbor_cardinality = cardinality_rotation[u_neighbor_cardinality];
				var down_coords : Vector2 = Vector2(cur_tile.x, 0);
				var d_neighbor : String = get_tile_name(sample_layer.get_cell_atlas_coords(down_coords));
				var d_neighbor_cardinality : int = cardinality_transformations.find_key(sample_layer.get_cell_alternative_tile(down_coords));
				d_neighbor_cardinality = cardinality_rotation[d_neighbor_cardinality];
				result["left"] = u_neighbor + " " + str(u_neighbor_cardinality);
				result["right"] = d_neighbor + " " + str(d_neighbor_cardinality);
				if is_rule_unique(result["left"], result["right"]):
					new_definition.neighbors.push_back(result);

func get_tile_name(atlas_coords:Vector2) -> String:
	return str(atlas_coords.x)+","+str(atlas_coords.y);
	
func is_rule_unique(left : String, right : String) -> bool:
	var rule_name : String = left + " " + right;
	if (unique_rules.has(rule_name)):
		return false;
	else: 
		unique_rules[rule_name] = true;
		return true;
