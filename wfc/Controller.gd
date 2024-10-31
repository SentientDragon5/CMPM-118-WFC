extends Node2D
@onready var sample_layer : TileMapLayer = get_node("%new_sample");
@onready var output_layer : TileMapLayer = get_node("%new_ouput");

@onready var WFC : WFC_Solver = get_node("%WFC");

var defn_maker : Defn_Factory;
var defn : Tiled_Rules;
var model : Tiled_Model;
var tm: TimeMachine;

var first_run : bool = true;
var time_stamp : int;

var path : String = "res://tilesets/kenney/kenney_model2.tres";

func _ready() -> void:
	pass;
	
	
	#defn_maker = Defn_Factory.new(sample_layer, Vector2(47, 22), "F", true, false);
	#defn = defn_maker.setup();
	#print_debug("Finished building definition.")
	#print_debug(Time.get_ticks_msec());
	#sample_layer.visible = false;
	#ResourceSaver.save(defn_maker.new_definition, "res://test_rules.tres");
	
	#defn = load("res://tilesets/kenney/kenney_defn.tres");
	#model = Tiled_Model.new(defn, 40, 23);
	#model.setup();
	#print_debug("Finished building rules.");
	#print_debug(Time.get_ticks_msec());
	#ResourceSaver.save(model, "res://tilesets/kenney/kenney_model.tres");
	#model = load("res://tilesets/kenney/kenney_model.tres");
	
	#WFC.model = model;
	#WFC.pre_initialize(rng, output_layer, true);
	#print_debug(Time.get_ticks_msec());
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Refresh"):
		if (first_run):
			return
		print_debug("Beginning WFC!");
		time_stamp = Time.get_ticks_msec();
		WFC.pre_initialize(model, null);
		
		#Clear old tm sprites
		tm.delete_all_blend_sprites();
		tm = WFC.generate_with_time_machine()
		if tm:
			tm.draw_map();
		
		print_debug("Run of WFC finished in:");
		print_debug(Time.get_ticks_msec() - time_stamp);
	if event.is_action_pressed("definition"):
		create_def();
	if event.is_action_pressed("model"):
		create_tiled_model();
	if event.is_action_pressed("AGAHHAHA"):
		create_special_model();
	if event.is_action_pressed("wfc"):
		run_wfc();
	if event.is_action("tm_mv_forward"):
		tm.moveForward();
	if event.is_action("tm_mv_backward"):
		tm.moveBackward();
		
func create_def() -> void:
	print_debug("Beginning definition building!");
	time_stamp = Time.get_ticks_msec();
	defn_maker = Defn_Factory.new(sample_layer, Vector2(47, 22), true, false);
	defn = defn_maker.setup();
	ResourceSaver.save(defn_maker.new_definition, "res://tilesets/kenney/kenney_defn2.tres");
	print_debug("Finished building definition in:");
	print_debug(Time.get_ticks_msec() - time_stamp);
	
func create_tiled_model() -> void:
	print_debug("Beginning rules building!");
	time_stamp = Time.get_ticks_msec();
	defn = load("res://tilesets/kenney/kenney_defn.tres");
	model = Tiled_Model.new(defn, 40, 23);
	model.setup();
	ResourceSaver.save(model, "res://tilesets/kenney/kenney_model.tres");
	path = "res://tilesets/kenney/kenney_model.tres";
	print_debug("Finished building rules in:");
	print_debug(Time.get_ticks_msec() - time_stamp);
	
func create_special_model() -> void:
	print_debug("Beginning rules building!");
	time_stamp = Time.get_ticks_msec();
	defn = load("res://tilesets/kenney/kenney_defn2.tres");
	model = Special_Model.new(defn, 40, 23);
	model.setup();
	ResourceSaver.save(model, "res://tilesets/kenney/kenney_model2.tres");
	path = "res://tilesets/kenney/kenney_model2.tres";
	print_debug("Finished building rules in:");
	print_debug(Time.get_ticks_msec() - time_stamp);
	
func run_wfc() -> void:
	if first_run:
		print_debug("Beginning WFC!");
		time_stamp = Time.get_ticks_msec();
		model = load(path);
		
		WFC.pre_initialize(model, output_layer);
		WFC.populate_WFC(output_layer);
		tm = WFC.generate_with_time_machine()
		if tm:
			tm.draw_map();
		first_run = false;
		print_debug("First run of WFC finished in:");
		print_debug(Time.get_ticks_msec() - time_stamp);

func run_wfc_solver() -> void:
	var timestamp = Time.get_unix_time_from_system();
	tm = WFC.generate_with_time_machine();
	tm.draw_map();
	print_debug("Solved WFC in " + str(Time.get_unix_time_from_system() - timestamp) + " seconds.");
