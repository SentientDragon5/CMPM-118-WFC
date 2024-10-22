extends Node #Does the wfc

@export var model : Tiled_Model;

func _ready() -> void:
	model.model_generated.connect(pre_initialize);
	model.setup();


func generate_mapping() -> bool:
	return true;

# not defined?
var weights = []


var fmx = 0
var fmy = 0
var fmx_x_fmy = 0
var t = 0;
var n = 0;
var initialized_field = false;
var generation_complete = false;

var wave = null;
var compatible = null;
var weight_log_weights = null;
var sum_of_weights = 0;
var sum_of_weight_log_weights = 0;

var starting_entropy = 0;

var sums_of_ones = null;
var sums_of_weights = null;
var sums_of_weights_log_weights = null;
var entropies = null;

var observed = null;
var distribution = null;

var stack = null;
var stack_size = 0;

var dx = [-1,0,1,0];
var dy = [0,1,0,-1];
var opposite = [2,3,0,1];

func pre_initialize(iterations: int, rng : RandomNumberGenerator) -> void:
	fmx = model.final_width;
	fmy = model.final_height;
	fmx_x_fmy = fmx * fmy;
	t = model.num_patterns;
	
	weights = model.weights;
	iterate(iterations, rng);

func initialize():
	distribution = []; # of t length
	distribution.resize(model.num_patterns);
	wave = []; # of fmx_x_fmy len
	compatible = []; # of fmx_x_fmy len
	
	for i in range(fmx_x_fmy):
		wave.append([])
		compatible.append([])
		for _t in t:
			wave[i].append([]);
			wave[i].resize(t);
			compatible[i].append([0,0,0,0])
	
	weight_log_weights = []
	for _t in range(t):
		weight_log_weights.append(0)
	sums_of_weights = 0;
	sum_of_weight_log_weights = 0;
	
	for _t in range(t):
		weight_log_weights[_t] = (weights[_t] * log(weights[_t]))
		sum_of_weights += weights[_t];
		sum_of_weight_log_weights += weight_log_weights[_t];
		
	starting_entropy = log(sum_of_weights) - sum_of_weight_log_weights / sum_of_weights
	
	sums_of_ones = []
	sums_of_weights = []
	sums_of_weights_log_weights = []
	entropies = []
	for a in range(fmx_x_fmy):
		sums_of_ones.append(0)
		sums_of_weights.append(0)
		sums_of_weights_log_weights.append(0)
		entropies.append(0)
	
	stack = []
	stack_size = 0;

func observe(rng : RandomNumberGenerator):
	print_debug("Iteration: Observe");
	var min_noise = 1000;
	var argmin = -1;
	for i in range(fmx_x_fmy):
		if model.on_boundary(i % fmx, i / fmx | 0):
			continue;
		var amount = sums_of_ones[i];
		if amount == 0:
			return false;
		var entropy = entropies[i]
		if amount>1 && entropy <= min_noise:
			var noise = 0.000001 * rng.randf_range(0,1); # DOUBLE CHECK
			if entropy + noise < min_noise:
				min_noise = entropy + noise;
				argmin = i;
	# search for the minimum entropy.
	if argmin == -1:
		observed = []
		observed.resize(fmx_x_fmy);
		for i in range(fmx_x_fmy):
			for _t in range(t):
				if wave[i][_t]:
					observed[i] = t;
					break;
		return true;
	
	for _t in range(t):
		distribution[_t] = weights[_t] if wave[argmin][_t] else 0;
	var r = randomIndice(distribution, rng);
	var w = wave[argmin];
	for _t in range(t):
		if w[_t] != (_t==r):
			ban(argmin, _t)
	return null;

func propagate():
	while stack_size > 0:
		var e1 = stack.pop_front();
		stack_size-=1;
		
		var i1 = e1[0]
		var x1 = i1 % fmx
		var y1 = i1 / fmx | 0
		
		for  d in range(4):
			var _dx = dx[d]
			var _dy = dy[d]
			
			var x2 = x1 + _dx
			var y2 = y1 +_dy
			
			if model.on_boundary(x2,y2):
				continue
			if x2 < 0:
				x2+=fmx
			elif x2 >= fmx:
				x2 -=fmx
			if y2 < 0:
				y2+=fmy
			elif y2 >= fmy:
				y2 -=fmy
				
			var i2 = x2 + y2 * fmx
			var p = model.propagator[d][e1[1]]
			var compat = compatible[i2]
			
			for l in range(p.size()):
				var t2 = p[l]
				var comp = compat[t2]
				comp[d]-=1
				if comp[d]==0:
					ban(i2,t2)
	
func singleIteration(rng : RandomNumberGenerator):
	var result = observe(rng)
	if result != null:
		generation_complete = result;
		return result;
	propagate();
	return null;
	
func iterate(iterations : int, rng) -> bool:
	if wave == null:
		initialize()
	if !initialized_field:
		clear()
	iterations = iterations || 0
	if rng == null:
		rng = RandomNumberGenerator.new()
	var i = 0;
	while i < iterations || iterations == 0:
		var result = singleIteration(rng)
		if result != null:
			print_debug(result);
			return result
	print_debug("Finished.");
	return true
	
func generate():
	var rng = RandomNumberGenerator.new()
	if wave == null:
		initialize()
	clear()
	while true:
		var result = singleIteration(rng)
		if result != null:
			return result

func ban(i,_t):
	var comp = compatible[i][_t];
	for d in range(4):
		comp[d] = 0;
	wave[i][_t] = false
	
	stack.push_back([i,_t]);
	stack_size+=1
	
	sums_of_ones[i] -= 1;
	sums_of_weights[i] -= weights[_t];
	sums_of_weights_log_weights[i] -= weight_log_weights[_t];
	
	var sum = sums_of_weights[i]
	entropies[i] = log(sum) - sums_of_weights_log_weights[i] / sum

func clear():
	for i in range(fmx_x_fmy):
		for _t in range(t):
			wave[i][_t] = true
			for d in range(4):
				compatible[i][_t][d] = model.propagator[opposite[d]][_t].size();
		sums_of_ones[i] = weights.size();
		sums_of_weights[i] = sum_of_weights;
		sums_of_weights_log_weights[i] = sum_of_weight_log_weights;
		entropies[i] = starting_entropy
	
	initialized_field = true
	generation_complete = false
	
func randomIndice(distrib : Array, rng : RandomNumberGenerator) -> int:
	var r : float = rng.randf_range(0, 1);
	var sum : float = 0;
	var x : float = 0;
	var i : int = 0;
	
	for num in distrib:
		sum += num;

	r *= sum;

	while (r != 0 and i < distrib.size()):
		x += distrib[i];
		if (r <= x):
			return i;
		i+=1;
	return 0;
	
