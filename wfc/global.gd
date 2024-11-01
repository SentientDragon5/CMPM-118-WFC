extends Node
var test_tilemap : TileMapLayer;

const cardinality_transformations: Dictionary = {
	1: TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V,
	2: TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V,
	3: TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H,
	4: TileSetAtlasSource.TRANSFORM_FLIP_H,
	5: TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V,
	6: TileSetAtlasSource.TRANSFORM_FLIP_V,
	7: TileSetAtlasSource.TRANSFORM_TRANSPOSE
}

const decoratable_tiles: Dictionary = {
									Vector2(12, 2): [Vector2(10, 12), Vector2(9, 12), Vector2(9, 11)], # Grass
									Vector2(12, 7): [Vector2(10, 13), Vector2(6, 8)], # Sand
									Vector2(7, 12): [Vector2(10, 13), Vector2(11, 4), Vector2(6, 4)], # Dirt
									Vector2(0, 4): [Vector2(9, 7)]
									  };

func _ready() -> void:
	pass;

func _draw_debug_tiles(tiles : Array) -> void:
	#1 rot TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V
	#2 rot TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V
	#3 rot TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H
	#refl  TileSetAtlasSource.TRANSFORM_FLIP_H
	#1 rot refl TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V
	#2 rot refl TileSetAtlasSource.TRANSFORM_FLIP_V
	#3 rot refl TileSetAtlasSource.TRANSFORM_TRANSPOSE
	var posX = 0;
	for tile in tiles:
		var cardinality : int = 0;
		match tile[1]:
			1:
				cardinality = TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V;
			2:
				cardinality = TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V;
			3:
				cardinality = TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H;
			4:
				cardinality = TileSetAtlasSource.TRANSFORM_FLIP_H;
			5:
				cardinality = TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V
			6:
				cardinality = TileSetAtlasSource.TRANSFORM_FLIP_V
			7:
				cardinality = TileSetAtlasSource.TRANSFORM_TRANSPOSE
		print_debug(cardinality);
		test_tilemap.set_cell(Vector2(0, posX), 0, tile[0], cardinality);
		posX += 1;
