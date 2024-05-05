@icon("res://addons/data_table/data_table.png")
extends Resource
class_name DataTable


## A variant of DataTable implementation.[br]
##
## [param Note: the DataTable class or its instances may be represented as DT in docs below.][br]
## [br]
## To create a new DataTable, follow these steps:[br]
## - Extend [DataTable] class;[br]
## - Set new script [code]class_name[/code];[br]
## - Overload [method Object._init] with setting desired fields with [metbod setup_fields];[br]
## - Add rows with [method new_row] and set its values with [method set_row_data].[br]
## [br]
## Row name must be a [i]valid[/i] identifier, i.e.
## it has to consist of latin letters, decimals or underscore, but can't start with an underscore or a digit.
## To access an existing DT row data, use [method Object.get] (or instance-dot-member syntax):
## [codeblock]
## # We have a DT instance named "table" and a row named "row_1".
## print(table.row_1)
## print(table.get("row_1"))
## var field_name = "row_1"
## print(table.get(row_name))
## [/codeblock]
## Then you can get field-specified value from the row, but assignment is disallowed at this way.
## Use [method modify] instead:
## [codeblock]
## print(data_table.row_name.field_name)               # Output: "some_value"
## data_table.row_name.field_name = "another_value"    # Causes error
## data_table.modify({"row_name", 
## [/codeblock]
## Keep in mind that data tables aren't absolutely the data bases. DTs only [i]contains[/i] structured data,
## but can't be used for calculations and requests until you implement it by yourself.[br]
## [br]
## The simple preview opens on double-click the DT script file in the FileSystem and shows a table with the text-converted DT values.[br]
## Popping-up the preview can be toggled in [i]Project -> Tools -> Enable/Disable DT Preview[/i] (will reset on re-enable the plugin).


var _fields: Dictionary
var _rows: Dictionary
var _read_only = false


## Used for get DT class name by instance.
func get_class() -> String:
	if !self._is_valid_DT(): return ""
	var classes = ProjectSettings.get_global_class_list()
	for i in classes:
		if i.language == "GDScript" \
				and i.base == "DataTable" \
				and i.path == self.get_script().resource_path:
			return i.class
	return "DataTable"


## Used for configure the DT's field names and default values basing on given [param map] dictionary.
func setup_fields(map: Dictionary):
	if !self._is_valid_DT(): return {}
	self._fields = map.duplicate()
	self._fields.make_read_only()


## Returns a number of configured rows.
func row_count() -> int:
	if !self._is_valid_DT(): return 0
	return self._rows.size()


## Returns a number of fields defined in the data table.
func field_count() -> int:
	if !self._is_valid_DT(): return 0
	return self._fields.size()


func _get(property: StringName) -> Variant:
	if !self._is_valid_DT(): return null
	if property in self._rows:
		var row = self._rows[property].duplicate()
		row.make_read_only()
		return row
	return null


func _is_valid_DT() -> bool:
	if get_class() == "DataTable":
		push_error("DataTable hasn't a valid class_name! Rejected.")
		return false
	return true


## Returns a read-only copy of the data table.
func get_read_only():
	if !self._is_valid_DT(): return null
	var DT = load(get_script().resource_path).new()
	DT._fields = self._fields.duplicate()
	DT._rows = self._rows.duplicate()
	DT._fields.make_read_only()
	DT._rows.make_read_only()
	DT._read_only = true
	return DT


## Returns [code]true[/code] if the data table is read-only.
func is_read_only() -> bool:
	if !self._is_valid_DT(): return true
	return self._read_only


func _to_string() -> String:
	if !self._is_valid_DT(): return "<null>"
	return "Table <{CLASS}> ({ELEMS})".format({
		"CLASS": self.get_class(),
		"ELEMS": (func(c):
			return "size " + String.num_int64(c)
			).call(self.row_count())
		})


## Returns a [String] of fields in next format: [code]<class>: { field<type>, ...}[/code][br]
func get_signature(include_filename := true) -> String:
	if !self._is_valid_DT(): return ""
	var list = []
	for field in self._fields:
		list.push_back("%s<%s>" % [ field, type_string(typeof(self._fields[field])) ])
	return "%s : { %s }" % [self.get_class(), ", ".join(list)]


## Adds new row at the end of the data table, setting all values to defaults then remaps it by [param init_values] dictionary.
## Parameter [param row_name] must be a valid identifier (see [method String.is_valid_identifier]).
## Returns OK on success, [enum Error] code otherwise.
func new_row(row_name: StringName, init_values := {}) -> Error:
	if !self._is_valid_DT(): return ERR_UNCONFIGURED
	if !row_name.is_valid_identifier():
		return ERR_INVALID_PARAMETER
	if self.is_read_only():
		return ERR_DATABASE_CANT_WRITE
	if self._rows.has(row_name):
		return ERR_ALREADY_EXISTS
	self._rows[row_name] = self._fields.duplicate()
	var err = modify({row_name: init_values})
	return OK if err in [OK, ERR_SKIP] else err


## If a row with given [param row_name] was represented in the data table, erases it. Returns [enum Error] code.
func erase_row(row_name: StringName) -> Error:
	if !self._is_valid_DT(): return ERR_UNCONFIGURED
	if self.is_read_only():
		return ERR_DATABASE_CANT_WRITE
	if row_name not in self._rows:
		return ERR_DOES_NOT_EXIST
	self._rows.erase(row_name)
	return OK


## If the data table is editable, remaps each [code]row.field[/code] values of two-dimensional [param map] found in the DT. Explicit paths will be ignored.
## Return value is an [enum Error] code.
func modify(map: Dictionary) -> Error:
	if !self._is_valid_DT(): return ERR_UNCONFIGURED
	if map.is_empty():
		return ERR_SKIP
	if self.is_read_only():
		return ERR_DATABASE_CANT_WRITE
	for row in map:
		if row in self._rows:
			for field in map[row]:
				if field in self._rows[row]:
					self._rows[row][field] = map[row][field]
	return OK
