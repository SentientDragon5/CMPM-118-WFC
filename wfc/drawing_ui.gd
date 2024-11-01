extends Control


@onready var tex = preload("res://tilesets/kenney/mapPack_spritesheet.png")
@export var tilemap : TileMapLayer

@export var cursor: Sprite2D

var brush = 1;
var model : Tiled_Model;
const cardinality_transformations: Dictionary = {
	1: TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V,
	2: TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V,
	3: TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H,
	4: TileSetAtlasSource.TRANSFORM_FLIP_H,
	5: TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V,
	6: TileSetAtlasSource.TRANSFORM_FLIP_V,
	7: TileSetAtlasSource.TRANSFORM_TRANSPOSE
}

var brushes = [
	Vector2i(0,4),
	Vector2i(12,7),
	Vector2i(12,2),
	Vector2i(7,12)
]

func _ready() -> void:
	var i = 0
	for b in brushes:
		var button = TextureButton.new()
		$VBoxContainer.add_child(button)
		var atlas =  AtlasTexture.new()
		atlas.atlas = tex;
		atlas.region = Rect2(Vector2(64*b.x,64*b.y), Vector2(64,64))
		button.texture_normal = atlas;
		var set_instance = func():
			set_brush(i)
		button.button_down.connect(set_instance)
		i+=1
	set_brush(0)

func set_brush(b : int):
	brush = b;
	print("brush = ", b)
	var atlas =  AtlasTexture.new()
	atlas.atlas = tex;
	atlas.region = Rect2(Vector2(64*brushes[brush].x,64*brushes[brush].y), Vector2(64,64))
	cursor.texture = atlas

func _process(delta: float) -> void:
	cursor.global_position = get_global_mouse_position() + Vector2(50,50)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		$VBoxContainer.visible = !$VBoxContainer.visible
	if Input.is_mouse_button_pressed( 1 ): # Left click
		var cell_pos = tilemap.local_to_map(get_global_mouse_position());
		tilemap.set_cell(cell_pos, 1, brushes[brush]);
	if Input.is_mouse_button_pressed( 2 ): # Right click
		var cell_pos = tilemap.local_to_map(get_global_mouse_position());
		tilemap.set_cell(cell_pos, 1, Vector2i(-1,-1));

func _on_hide_button_down() -> void:
	$VBoxContainer.visible = !$VBoxContainer.visible
