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

var weight_even : bool = true;

var path : String = "res://tilesets/kenney/kenney_model2.tres";

func _ready() -> void:
	pass;
	

func refresh():
	if (first_run):
		return
	print_debug("Beginning WFC!");
	time_stamp = Time.get_ticks_msec();
	WFC.pre_initialize(model, null);

	tm = WFC.generate_with_time_machine()
	if tm:
		tm.animate_map(.001);
	
	print_debug("Run of WFC finished in:");
	print_debug(Time.get_ticks_msec() - time_stamp);

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Refresh"):
		refresh()
	if event.is_action_pressed("definition"):
		create_def();
	if event.is_action_pressed("model"):
		create_tiled_model();
	if event.is_action_pressed("AGAHHAHA"):
		create_special_model();
	if event.is_action_pressed("wfc"):
		run_wfc();
	if event.is_action_pressed("weighting"):
		weight_even = !weight_even;
	if event.is_action("tm_mv_forward"):
		if tm:
			tm.move_forward();
	if event.is_action("tm_mv_backward"):
		if tm:
			tm.move_backward();
	if event.is_action("quit"):
		get_tree().quit()
		
func create_def() -> void:
	print_debug("Beginning definition building!");
	time_stamp = Time.get_ticks_msec();
	defn_maker = Defn_Factory.new(sample_layer, Vector2(47, 22), weight_even, false);
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
			tm.animate_map(.001);
		first_run = false;
		print_debug("First run of WFC finished in:");
		print_debug(Time.get_ticks_msec() - time_stamp);

func run_wfc_solver() -> void:
	var timestamp = Time.get_unix_time_from_system();
	tm = WFC.generate_with_time_machine();
	tm.draw_map();
	print_debug("Solved WFC in " + str(Time.get_unix_time_from_system() - timestamp) + " seconds.");


func _on_definition_button_down() -> void:
	create_def();


func _on_tiled_button_down() -> void:
	create_tiled_model();


func _on_special_button_down() -> void:
	create_special_model()


func _on_run_wfc_button_down() -> void:
	run_wfc()


func _on_step_back_button_down() -> void:
	if tm:
		tm.moveBackward();


func _on_step_forward_button_down() -> void:
	if tm:
		tm.moveForward();


func _on_regen_button_down() -> void:
	refresh()


func _on_weighting_button_down() -> void:
	weight_even = !weight_even;
