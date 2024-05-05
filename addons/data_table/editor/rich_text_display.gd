@tool
extends RichTextLabel


const MAX_CELL_LEN = 80
const PADDING = Rect2(10,7,10,5)


func _enter_tree() -> void:
	if !owner.is_connected("requested_to_update", update):
		owner.connect("requested_to_update", update)


func update(data: DataTable):
	clear()
	if !is_instance_valid(data):
		push_bold_italics()
		add_text("<invalid data table>")
		pop()
		return
	push_table(data.field_count() + 1)
	push_cell()
	set_cell_padding(PADDING)
	push_mono()
	add_text(" ")
	pop(); pop()
	for i in data._fields:
		push_cell()
		set_cell_padding(PADDING)
		push_mono()
		if len(i) <= MAX_CELL_LEN:
			append_text("[b]%s[/b]" % i)
		else:
			append_text("[b]%s…[/b]" % i.left(-1))
		pop()
		pop()
	add_text("\n")
	for row_name in data._rows:
		push_cell()
		set_cell_padding(PADDING)
		push_mono()
		push_underline()
		add_text("%s" % data._rows.keys().find(row_name))
		pop(); pop(); pop()
		for field_name in data._fields:
			push_cell()
			set_cell_padding(PADDING)
			push_italics()
			var value = data.get(row_name).get(field_name)
			add_text(var2str(value))
			pop(); pop()
		add_text("\n")
	add_text("")
	pop()


func var2str(value):
	var text = ""
	match typeof(value):
		TYPE_OBJECT:
			print(value.to_string == Object.to_string)
			text = "Object<%s>" % value.get_class()
			if value.get_script() and value.get_script().resource_path.is_valid_filename():
				text += " (%s)" % value.get_script().resource_path.get_file()
		TYPE_NODE_PATH:
			text = "^\"%s\"" % value
		TYPE_CALLABLE:
			text = "Callable"
		TYPE_SIGNAL:
			text = "Signal"
		TYPE_DICTIONARY:
			text = str(value)
		_:
			text = var_to_str(value)
	if len(text) > MAX_CELL_LEN:
		text = text.left(MAX_CELL_LEN - 1) + "…"
	return text
