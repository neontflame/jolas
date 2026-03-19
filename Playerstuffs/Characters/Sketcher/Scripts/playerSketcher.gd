extends PlayerObject

@export_category('Sketcher params')
@export var SLIDE_FRICTION := 1.0
@export var ELEC_GAUGE_MAX := 10.0

var ELECTRICITY := 10.0

func _process(delta: float) -> void:
	if ELECTRICITY > ELEC_GAUGE_MAX:
		ELECTRICITY = ELEC_GAUGE_MAX

func hasElec():
	return (ELECTRICITY > 0.0)
