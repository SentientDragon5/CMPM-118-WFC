class_name Tiled_Rules extends Resource
@export var tileset : TileSet; #not using yet
@export var periodic : bool;
@export var tiles : Array[Dictionary]; #{ name:"bridge", symmetry:"I", atlas_coords:Vector2() }
@export var neighbors : Array[Dictionary]; #{ left:"bridge 1", right:"river 1" }
		
#Example from json
#module.exports = {
	#path: './data/castle/',
	#tilesize: 7,
	#unique: bool, //OPTIONAL
	#tiles: [
		#{ name:"bridge", symmetry:"I" }, //OPTIONAL weight:float
		#{ name:"ground", symmetry:"X" },
		#{ name:"river", symmetry:"I" },
		#{ name:"riverturn", symmetry:"L" },
		#{ name:"road", symmetry:"I" },
		#{ name:"roadturn", symmetry:"L" },
		#{ name:"t", symmetry:"T" },
		#{ name:"tower", symmetry:"L" },
		#{ name:"wall", symmetry:"I" },
		#{ name:"wallriver", symmetry:"I" },
		#{ name:"wallroad", symmetry:"I" }
	#],
	#neighbors: [
		#{ left:"bridge 1", right:"river 1" },
		#{ left:"bridge 1", right:"riverturn 1" },
		#{ left:"bridge", right:"road 1" },
		#{ left:"bridge", right:"roadturn 1" },
		#{ left:"bridge", right:"t" },
		#{ left:"bridge", right:"t 3" },
		#{ left:"bridge", right:"wallroad" },
		#{ left:"ground", right:"ground" },
		#{ left:"ground", right:"river" },
		#{ left:"ground", right:"riverturn" },
		#{ left:"ground", right:"road" },
		#{ left:"ground", right:"roadturn" },
		#{ left:"ground", right:"t 1" },
		#{ left:"ground", right:"tower" },
		#{ left:"ground", right:"wall" },
		#{ left:"river 1", right:"river 1" },
		#{ left:"river 1", right:"riverturn 1" },
		#{ left:"river", right:"road" },
		#{ left:"river", right:"roadturn" },
		#{ left:"river", right:"t 1" },
		#{ left:"river", right:"tower" },
		#{ left:"river", right:"wall" },
		#{ left:"river 1", right:"wallriver" },
		#{ left:"riverturn", right:"riverturn 2" },
		#{ left:"road", right:"riverturn" },
		#{ left:"roadturn 1", right:"riverturn" },
		#{ left:"roadturn 2", right:"riverturn" },
		#{ left:"t 3", right:"riverturn" },
		#{ left:"tower 1", right:"riverturn" },
		#{ left:"tower 2", right:"riverturn" },
		#{ left:"wall", right:"riverturn" },
		#{ left:"riverturn", right:"wallriver" },
		#{ left:"road 1", right:"road 1" },
		#{ left:"roadturn", right:"road 1" },
		#{ left:"road 1", right:"t" },
		#{ left:"road 1", right:"t 3" },
		#{ left:"road", right:"tower" },
		#{ left:"road", right:"wall" },
		#{ left:"road 1", right:"wallroad" },
		#{ left:"roadturn", right:"roadturn 2" },
		#{ left:"roadturn", right:"t" },
		#{ left:"roadturn 1", right:"tower" },
		#{ left:"roadturn 2", right:"tower" },
		#{ left:"roadturn 1", right:"wall" },
		#{ left:"roadturn", right:"wallroad" },
		#{ left:"t", right:"t 2" },
		#{ left:"t 3", right:"tower" },
		#{ left:"t 3", right:"wall" },
		#{ left:"t", right:"wallroad" },
		#{ left:"t 1", right:"wallroad" },
		#{ left:"tower", right:"wall 1" },
		#{ left:"tower", right:"wallriver 1" },
		#{ left:"tower", right:"wallroad 1" },
		#{ left:"wall 1", right:"wall 1" },
		#{ left:"wall 1", right:"wallriver 1" },
		#{ left:"wall 1", right:"wallroad 1" },
		#{ left:"wallriver 1", right:"wallroad 1" }
	#]
#};
