extends Resource
class_name DataTable


## This is a variant of DataTable implementation.[br]
##
## [param Note: in the descriptions the DataTable class or instances may be represented as DT.][br]
##
## To create new DataTable, make theese steps:[br]
## - Extend [DataTable] class;[br]
## - Set new script [code]class_name[/code];[br]
## - Overload [method Object._init] method setting [member _fields] property with desired fields;[br]
## - Add rows with [method new_row] and set its values with [method set_row_data].[br]
## [br]
## To access an existing DT row data, use dictionary-like syntax.
## Then you can get field-specified value from it, but assignment is disallowed at this way.
## Use [method set_row_data] instead:
## [codeblock]
## print(data_table.row_name.field_name)               # Output: "some_value"
## data_table.row_name.field_name = "another_value"    # Causes error
## [/codeblock]
## Keep in mind that data tables aren't absolutely the data bases. DTs only [i]contains[/i] structured data,
## but can't be used for calculations and requests until you implement it by yourself.


var _fields: Dictionary
var _rows: Dictionary
var _read_only = false


func _validate() -> bool:
	if self._fields.size() == 0:
		return false
	var row_names: Array[StringName] = []
	row_names.assign(self._rows.keys())
	row_names.sort()
	for i in row_names.size() - 1:
		if row_names[i] == row_names[i + 1]:
			return false
	return true


## Returns a number of configured rows.
func row_count() -> int:
	return self._rows.size()


## Returns a number of fields defined in the data table.
func field_count() -> int:
	return self._fields.size()


func _get(property: StringName) -> Variant:
	print(self._rows)
	if property in self._rows:
		var row = self._rows[property].duplicate()
		row.make_read_only()
		return row
	return null


## Returns a read-only copy of the data table.
func get_read_only():
	var DT = load(get_script().resource_path).new()
	DT._fields = self._fields.duplicate()
	DT._rows = self._rows.duplicate()
	DT._fields.make_read_only()
	DT._rows.make_read_only()
	DT._read_only = true
	return DT


## Returns [code]true[/code] if the data table is read-only.
func is_read_only() -> bool:
	return self._read_only


func _to_string() -> String:
	return "Data table \"{0}\"{1}: {2} ({3})".format([
		self.get_class(),
		" [read-only]" if self.is_read_only() else "",
		self._fields,
		(func(c := self.row_count()):
			if c == 0:
				return "empty"
			if c == 1:
				return "1 entry"
			return String.num_int64(c) + " entries")
	])


## Adds new row at the end of the data table, setting all values to defaults then remaps it by [param init_values] dictionary.
## Returns OK on success, [enum Error] code otherwise.
func new_row(row_name: StringName, init_values := {}) -> Error:
	#if !row_name.is_valid_identifier():
		#return ERR_INVALID_PARAMETER
	if self.is_read_only():
		return ERR_DATABASE_CANT_WRITE
	if self._rows.has(row_name):
		return ERR_ALREADY_EXISTS
	self._rows[row_name] = self._fields.duplicate()
	var err = set_row_data(row_name, init_values)
	return OK if err in [OK, ERR_SKIP] else err


## If a row with given [param row_name] was represented in the data table, erases it. Returns [enum Error] code.
func erase_row(row_name: StringName) -> Error:
	if self.is_read_only():
		return ERR_DATABASE_CANT_WRITE
	if row_name not in self._rows:
		return ERR_DOES_NOT_EXIST
	self._rows.erase(row_name)
	return OK


## If the data table is editable, remaps every [param row] values found in [param map]. Returns [enum Error] code.
func set_row_data(row: StringName, map: Dictionary):
	if map.is_empty():
		return ERR_SKIP
	if self.is_read_only():
		return ERR_DATABASE_CANT_WRITE
	if (row not in self._rows):
		return ERR_INVALID_PARAMETER
	for field in map:
		if field in self._fields:
			self._rows[row][field] = map[field]
	return OK
