class_name t1 extends Tiled_Rules

func _init() -> void:
	tilesize = 16;
	tileset = preload("res://tilesets/corners_n_crossings/CCTileset.tres");
	
	tiles = [
		{"name":"corner", "symmetry":"L", "atlas_coords": Vector2(0, 0)},
		{"name":"cross", "symmetry":"X", "atlas_coords": Vector2(1, 0)},
		{"name":"blank", "symmetry":"X", "atlas_coords": Vector2(0, 1)},
		{"name":"straight", "symmetry":"I", "atlas_coords": Vector2(1,1)},
		{"name":"Debug", "symmetry":"F", "atlas_coords": Vector2(2,0)}
	];

	neighbors = [
		{"left":"corner 0", "right":"cross 0"},
		{"left":"corner 0", "right":"straight 1"},
		{"left":"corner 0", "right":"corner 1"},
		{"left":"corner 0", "right":"corner 2"},
		
		{"left":"corner 1", "right":"blank 0"},
		{"left":"corner 1", "right":"straight 0"},
		{"left":"corner 1", "right":"corner 0"},
		{"left":"corner 1", "right":"corner 3"},
		
		{"left":"corner 2", "right":"blank 0"},
		{"left":"corner 2", "right":"straight 0"},
		{"left":"corner 2", "right":"corner 0"},
		{"left":"corner 2", "right":"corner 3"},
		
		{"left":"corner 3", "right":"cross 0"},
		{"left":"corner 3", "right":"straight 1"},
		{"left":"corner 3", "right":"corner 1"},
		{"left":"corner 3", "right":"corner 2"},
		
		{"left":"cross 0", "right":"straight 1"},
		{"left":"cross 0", "right":"cross 0"},
		
		{"left":"blank 0", "right":"straight 0"},
		{"left":"blank 0", "right":"blank 0"},
		
		{"left":"straight 0", "right":"straight 0"},
		{"left":"straight 1", "right":"straight 1"}
	];
