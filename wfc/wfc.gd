extends Node #Does the wfc

@export var model : Node;

func _ready() -> void:
	#generate_mapping();
	#validate();
	#log_debug_info();
	pass;

func generate_mapping() -> bool:
	return true;

# not defined?
var weights = []


var fmx = 0
var fmy = 0
var fmx_x_fmy = 0
var t = 0;
var n = 0
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

var propagator = null;
var observed = null;
var distribution = null;

var stack = null;
var stack_size = 0;

var dx = [-1,0,1,0];
var dy = [0,1,0,-1];
var opposite = [2,3,0,1];

func initialize():
	distribution = []; # of t length
	wave = []; # of fmx_x_fmy len
	compatible = []; # of fmx_x_fmy len
	
	for i in range(fmx_x_fmy):
		wave.append([])
		compatible.append([])
		for _t in t:
			wave[i].append(0)
			compatible[i].append([0,0,0,0])
	
	weight_log_weights = []
	for _t in range(t):
		weight_log_weights.append(0)
	sums_of_weights = 0;
	sum_of_weight_log_weights = 0;
	
	for _t in range(t):
		weight_log_weights.append(weights[_t] * log(weights[_t]))
		sums_of_weights += weights[_t];
		sums_of_weights_log_weights += weight_log_weights[_t];
		
	starting_entropy = log(sums_of_weights) - sums_of_weights_log_weights / sums_of_weights
	
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

func observe(rng : RandomNumberGenerator) -> bool:
	var min = 1000;
	var argmin = -1;
	for i in range(fmx_x_fmy):
		if model.on_boundary(i % fmx, i / fmx | 0):
			continue;
		var amount = sums_of_ones[i];
		if amount == 0:
			return false;
		var entropy = entropies[i]
		if amount>1 && entropy <= min:
			var noise = 0.000001 * rng.randf_range(0,1); # DOUBLE CHECK
			if entropy + noise < min:
				min = entropy + noise;
				argmin = i;
	# search for the minimum entropy.
	if argmin == -1:
		observed = []
		for i in range(fmx_x_fmy):
			for _t in range(t):
				if wave[i][_t]:
					observed[i] = t;
					break;
		return true;
	
	for _t in range(t):
		distribution[_t] = weights[_t] if wave[argmin][_t] else 0;
	#var r = randomIndice(distribution, rng())
	var r = 0 # REPLACE
	var w = wave[argmin];
	for _t in range(t):
		if w[_t] != (t==r):
			ban(argmin, t)
	return false

func propagate():
	while stack_size > 0:
		var e1 = stack[stack_size-1]
		stack_size-=1
		
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
			var p = propagator[d][e1[1]]
			var compat = compatible[i2]
			
			for l in range(p):
				var t2 = p[l]
				var comp = compat[t2]
				comp[d]-=1
				if comp[d]==0:
					ban(i2,t2)
	
func singleIteration(rng : RandomNumberGenerator):
	var result = observe(rng)
	if result != null:
		generation_complete = result
		return result
	propagate()
	return null
	
func iterate(iterations, rng) -> bool:
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
			return result
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
	
	stack[stack_size] = [i,t]
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
				compatible[i][t][d] = propagator[opposite[d]][_t].length;
		sums_of_ones[i] = weights.lenths;
		sums_of_weights[i] = sum_of_weights;
		sums_of_weights_log_weights = sum_of_weight_log_weights;
		entropies[i] = starting_entropy
	
	initialized_field = true
	generation_complete = false
	
