static func patch():
	var script_path = "res://menus/party/PartyMenu.gd"
	var patched_script : GDScript = preload("res://menus/party/PartyMenu.gd")

	if !patched_script.has_source_code():
		var file : File = File.new()
		var err = file.open(script_path, File.READ)
		if err != OK:
			push_error("Check that %s is included in Modified Files"% script_path)
			return
		patched_script.source_code = file.get_as_text()
		file.close()

	var code_lines:Array = patched_script.source_code.split("\n")
		
	# hides export feature while in battle
	var code_index = code_lines.find("func update_ui():")
	if code_index >= 0:
		code_lines.insert(code_index + 1, get_code("check_export_button"))
	
	# adds proper signal for pressing the button
	code_lines.push_back(get_code("export_button_pressed"))
	
	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"

	var err = patched_script.reload(true)
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return

static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}
	code_blocks["check_export_button"] = """
	var export_button = find_node("ExportButton", true, false)
	if export_button:
		if battle != null:
			export_button.visible_override = false
		else:
			export_button.visible_override = null
"""

	code_blocks["export_button_pressed"] = """
func _on_ExportButton_pressed():
	var export_menu = load("res://mods/cbpastes/menus/PasteExportMenu.tscn").instance()
	MenuHelper.add_child(export_menu)
	export_menu.characters = characters
	yield (export_menu.run_menu(), "completed")
	MenuHelper.remove_child(export_menu)
	export_menu.queue_free()
"""
	return code_blocks[block]
