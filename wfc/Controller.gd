extends Node2D
@onready var sample_layer : TileMapLayer = get_node("%new_sample");
@onready var output_layer : TileMapLayer = get_node("%new_ouput");

@onready var WFC : WFC_Solver = get_node("%WFC");

var rng : RandomNumberGenerator
var defn_maker : Defn_Factory;
var defn : Tiled_Rules;
var model : Tiled_Model;

var first_run : bool = true;
var time_stamp : int;

func _ready() -> void:
	rng = RandomNumberGenerator.new();
	rng.seed = hash("WORK PLEASE") * randi_range(0, 6969696969);
	
	
	#defn_maker = Defn_Factory.new(sample_layer, Vector2(47, 22), "F", true, false);
	#defn = defn_maker.setup();
	#print_debug("Finished building definition.")
	#print_debug(Time.get_ticks_msec());
	#sample_layer.visible = false;
	#ResourceSaver.save(defn_maker.new_definition, "res://test_rules.tres");
	
	defn = load("res://tilesets/kenney/kenney_defn.tres");
	#model = Tiled_Model.new(defn, 40, 23);
	#model.setup();
	#print_debug("Finished building rules.");
	#print_debug(Time.get_ticks_msec());
	#ResourceSaver.save(model, "res://tilesets/kenney/kenney_model.tres");
	model = load("res://tilesets/kenney/kenney_model.tres");
	
	#WFC.model = model;
	#WFC.pre_initialize(rng, output_layer, true);
	#print_debug(Time.get_ticks_msec());
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Refresh"):
		if (first_run):
			return
		print_debug("Beginning WFC!");
		time_stamp = Time.get_ticks_msec();
		var new_rng = RandomNumberGenerator.new();
		WFC.pre_initialize(new_rng, null);
		
		print_debug("Run of WFC finished in:");
		print_debug(Time.get_ticks_msec() - time_stamp);
	if event.is_action_pressed("definition"):
		create_def();
	if event.is_action_pressed("model"):
		create_model();
	if event.is_action_pressed("wfc"):
		run_wfc();
		
		
func create_def() -> void:
	print_debug("Beginning definition building!");
	time_stamp = Time.get_ticks_msec();
	defn_maker = Defn_Factory.new(sample_layer, Vector2(47, 22), "F", true, false);
	defn = defn_maker.setup();
	ResourceSaver.save(defn_maker.new_definition, "res://test_rules.tres");
	print_debug("Finished building definition in:");
	print_debug(Time.get_ticks_msec() - time_stamp);
	
func create_model() -> void:
	print_debug("Beginning rules building!");
	time_stamp = Time.get_ticks_msec();
	defn = load("res://tilesets/kenney/kenney_defn.tres");
	model = Tiled_Model.new(defn, 40, 23);
	model.setup();
	ResourceSaver.save(model, "res://tilesets/kenney/kenney_model.tres");
	print_debug("Finished building rules in:");
	print_debug(Time.get_ticks_msec() - time_stamp);
	
func run_wfc() -> void:
	if first_run:
		print_debug("Beginning WFC!");
		time_stamp = Time.get_ticks_msec();
		model = load("res://tilesets/kenney/kenney_model.tres");
		
		WFC.model = model;
		WFC.pre_initialize(rng, output_layer, true);
		first_run = false;
		print_debug("First run of WFC finished in:");
		print_debug(Time.get_ticks_msec() - time_stamp);
