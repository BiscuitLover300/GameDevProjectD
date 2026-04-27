extends CanvasLayer

@export var darkness_alpha: float = 0.85

@onready var darkness_rect: ColorRect = $DarknessRect

func _ready() -> void:
	darkness_rect.color = Color(0, 0, 0, darkness_alpha)
	darkness_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	darkness_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
