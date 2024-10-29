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
	
	
	defn_maker = Defn_Factory.new(sample_layer, Vector2(47, 22), "F", true, false);
	defn = defn_maker.setup();
	print_debug("Finished building definition.")
	print_debug(Time.get_ticks_msec());
	sample_layer.visible = false;
		
	model = Tiled_Model.new(defn, 40, 23);
	model.setup();
	print_debug("Finished building rules.");
	print_debug(Time.get_ticks_msec());
	
	WFC.model = model;
	WFC.pre_initialize(rng, output_layer, true);
	print_debug(Time.get_ticks_msec());
