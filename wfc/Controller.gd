extends Node2D
@onready var sample_layer : TileMapLayer = get_node("%new_sample");
@onready var output_layer : TileMapLayer = get_node("%new_ouput");

@onready var WFC : WFC_Solver = get_node("%WFC");

var defn_maker : Defn_Factory;
var defn : Tiled_Rules;
var model : Tiled_Model;

func _ready() -> void:
	var rng : RandomNumberGenerator = RandomNumberGenerator.new();
	rng.seed = hash("WORK PLEASE") * randi_range(0, 6969696969);
	
	
	defn_maker = Defn_Factory.new();
	defn_maker.sample_layer = sample_layer;
	defn_maker.weight_evenly = true;
	defn_maker.sample_size = Vector2(40, 22);
	defn_maker.force_symmetry = "F";
	defn_maker.periodic = false;
	defn = defn_maker.setup();
	print_debug("Finished building definition.")
	sample_layer.visible = false;
		
	model = Tiled_Model.new();
	model.rules_definition = defn;
	model.final_height = 16;
	model.final_width = 16;
	model.setup();
	print_debug("Finished building rules.")
	WFC.model = model;
	WFC.pre_initialize(rng, output_layer);
