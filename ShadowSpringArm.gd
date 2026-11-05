extends SpringArm3D

@onready var drop_shadow: MeshInstance3D = $DropShadow
@onready var shadow_mat: Gradient = drop_shadow.get_active_material(0).albedo_texture.gradient


func _ready() -> void:
	#print(shadow_mat)
	pass 


func _process(_delta: float) -> void:
	var length = abs(1.5 - clampf(get_hit_length(), 0.5, 1.0))
	drop_shadow.scale = Vector3(length,length,length)
	change_shadow_opacity(length)
	#print(length)
	#print(drop_shadow.scale)
	if get_hit_length() >= spring_length:
		drop_shadow.hide()
	else:
		drop_shadow.show()


func change_shadow_opacity(length) -> void:
	shadow_mat.set_color(0, Color(0, 0, 0, length / 2))
