extends Control
 
var is_visible = false
var mouse_position = Vector2()
var start_sel_pos = Vector2()
const sel_box_col = Color(0, 1, 0)
const sel_box_line_width = 3
 
func _draw():
	if is_visible and start_sel_pos != mouse_position:
		draw_line(start_sel_pos, Vector2(mouse_position.x, start_sel_pos.y), sel_box_col, sel_box_line_width)
		draw_line(start_sel_pos, Vector2(start_sel_pos.x, mouse_position.y), sel_box_col, sel_box_line_width)
		draw_line(mouse_position, Vector2(mouse_position.x, start_sel_pos.y), sel_box_col, sel_box_line_width)
		draw_line(mouse_position, Vector2(start_sel_pos.x, mouse_position.y), sel_box_col, sel_box_line_width)
 
func _process(delta):
	queue_redraw()
