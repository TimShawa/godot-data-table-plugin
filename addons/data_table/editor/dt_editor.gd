@tool
extends Control


signal requested_to_update(data: DataTable)


var edited_table: DataTable:
	set(value):
		edited_table = value
		emit_signal("requested_to_update", edited_table)
		%Header.text = edited_table.get_signature()
