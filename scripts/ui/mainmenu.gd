extends Control


var h1 = preload("res://resources/ui/mainmenu/Heading1.png")
var h2 = preload("res://resources/ui/mainmenu/Heading2.png")


onready var h_pic = $elements/heading_picture

var TextureShrink = VisualServer.texture_set_shrink_all_x2_on_set_data(true)



func _ready() -> void:

	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)




func _on_heading_picture_mouse_entered() -> void:

	h_pic.texture = h2


func _on_heading_picture_mouse_exited() -> void:

	h_pic.texture = h1



func _on_Play_pressed() -> void:
	pass # Replace with function body.


func _on_Options_pressed() -> void:

	$elements.set_visible(false)
	$Options.set_visible(true)
	$Play.set_visible(false)
	$About.set_visible(false)




func _on_About_pressed() -> void:

	$elements.set_visible(false)
	$About.set_visible(true)
	$Options.set_visible(false)
	$Play.set_visible(false)


func _on_Exit_pressed() -> void:

	$elements.set_visible(false)
	$hidden_exit.set_visible(true)


func _on_yes_pressed() -> void:

	get_tree().quit()


func _on_no_pressed() -> void:

	$hidden_exit.set_visible(false)
	$elements.set_visible(true)


func _on_back_pressed() -> void:

	$About.set_visible(false)
	$elements.set_visible(true)
	$Options.set_visible(false)
	$Play.set_visible(false)





func _on_back2_pressed() -> void:

	$Options.set_visible(false)
	$elements.set_visible(true)
	$Play.set_visible(false)
	$About.set_visible(false)


