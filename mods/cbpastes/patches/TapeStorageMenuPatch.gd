static func patch():
	var script_path = "res://menus/tape_storage/TapeStorageMenu.gd"
	var patched_script : GDScript = preload("res://menus/tape_storage/TapeStorageMenu.gd")

	if !patched_script.has_source_code():
		var file : File = File.new()
		var err = file.open(script_path, File.READ)
		if err != OK:
			push_error("Check that %s is included in Modified Files"% script_path)
			return
		patched_script.source_code = file.get_as_text()
		file.close()

	var code_lines:Array = patched_script.source_code.split("\n")

	var code_index = code_lines.find("		elif option == \"trade\":")
	if code_index >= 0:
		code_lines.insert(code_index, get_code("choose_option_export"))

	# adds proper signal for pressing the button
	code_lines.push_back(get_code("export_button_pressed"))
	code_lines.push_back(get_code("get_export_tape"))
	
	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"

	var err = patched_script.reload(true)
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return

static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}

	code_blocks["export_button_pressed"] = """
func _on_ExportButton_pressed():
	var export_menu = load("res://mods/cbpastes/menus/PasteExportMenu.tscn").instance()
	MenuHelper.add_child(export_menu)
	yield (export_menu.run_menu(), "completed")
	MenuHelper.remove_child(export_menu)
	export_menu.queue_free()
"""

	code_blocks["get_export_tape"] = """
func _get_export_tape(current_tape):
	var export_menu = load("res://mods/cbpastes/menus/PasteExportMenu.tscn").instance()
	MenuHelper.add_child(export_menu)
	yield (export_menu.run_menu(), "completed")
	MenuHelper.remove_child(export_menu)
	export_menu.queue_free()
"""

	code_blocks["choose_option_export"] = """
		elif option == "export_paste":
			_get_export_tape(current_tape)
"""

	return code_blocks[block]
