@tool
extends EditorPlugin


const EDITOR = preload("res://addons/data_table/editor/dt_editor.scn.scn")
var editor: Control
var show_preview := true:
	set(value):
		var prev = show_preview
		show_preview = value
		if show_preview:
			if !prev:
				remove_tool_menu_item("Enable DT Preview")
				add_tool_menu_item("Disable DT Preview", func(): show_preview = false)
		if !show_preview:
			if prev:
				remove_tool_menu_item("Disable DT Preview")
				add_tool_menu_item("Enable DT Preview", func(): show_preview = true)
			if editor.is_inside_tree():
				remove_control_from_bottom_panel(editor)
			editor.edited_table = null


func _enter_tree() -> void:
	editor = EDITOR.instantiate()
	if show_preview:
		add_tool_menu_item("Disable DT Preview", func(): show_preview = false)
	else:
		add_tool_menu_item("Enable DT Preview", func(): show_preview = true)


func _exit_tree() -> void:
	if show_preview:
		remove_tool_menu_item("Disable DT Preview")
	else:
		remove_tool_menu_item("Enable DT Preview")
	if editor.is_inside_tree():
		remove_control_from_bottom_panel(editor)


func _handles(object: Object) -> bool:
	if !show_preview:
		return false
	if object is GDScript:
		var inst = object.new()
		if inst is DataTable and inst.get_class() != "DataTable":
			return true
	return false


func _edit(object: Object) -> void:
	if object:
		if !editor.is_inside_tree():
			add_control_to_bottom_panel(editor, "Data Table")
		make_bottom_panel_item_visible(editor)
		editor.edited_table = object.new()
		await get_tree().process_frame
		editor.grab_focus()
		return
	if editor.is_inside_tree():
		remove_control_from_bottom_panel(editor)
	editor.edited_table = null

