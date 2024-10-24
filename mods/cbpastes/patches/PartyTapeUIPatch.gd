static func patch():
	var script_path = "res://menus/party_tape/PartyTapeUI.gd"
	var patched_script : GDScript = preload("res://menus/party_tape/PartyTapeUI.gd")

	if !patched_script.has_source_code():
		var file : File = File.new()
		var err = file.open(script_path, File.READ)
		if err != OK:
			push_error("Check that %s is included in Modified Files"% script_path)
			return
		patched_script.source_code = file.get_as_text()
		file.close()

	var code_lines:Array = patched_script.source_code.split("\n")

	var code_index = code_lines.find("onready var rename_btn = find_node(\"RenameBtn\")")
	if code_index >= 0:
		code_lines.insert(code_index + 1, get_code("find_simple_export_button"))

	code_index = code_lines.find("	buttons.setup_focus()")
	if code_index >= 0:
		code_lines.insert(code_index, get_code("adjust_button_size"))

	code_index = code_lines.find("		stickers_btn.text = \"UI_PARTY_VIEW_MOVES\"")
	if code_index >= 0:
		code_lines.insert(code_index + 1, get_code("remove_export_button"))

	# adds proper signal for pressing the button
	code_lines.push_back(get_code("simple_export_button_pressed"))
	
	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"

	var err = patched_script.reload(true)
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return

static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}

	code_blocks["find_simple_export_button"] = """
onready var simple_export_button = find_node("SimpleExportButton", true, false)
"""

	code_blocks["adjust_button_size"] = """
	if buttons.get_child_count() <= 5:
		buttons.get_parent().set("custom_constants/margin_bottom", -278)
	else:
		var excess:int = buttons.get_child_count() - 5
		var new_margin:int = -278 - 62*excess
		buttons.get_parent().set("custom_constants/margin_bottom", new_margin)
"""

	code_blocks["remove_export_button"] = """
		if simple_export_button:
			buttons.remove_child(simple_export_button)
			simple_export_button.queue_free()
			simple_export_button = null
"""

	code_blocks["simple_export_button_pressed"] = """
func _on_SimpleExportButton_pressed():
	var export_menu = load("res://mods/cbpastes/menus/SinglePasteExportMenu.tscn").instance()
	export_menu.tape = tape
	MenuHelper.add_child(export_menu)
	yield (export_menu.run_menu(), "completed")
	MenuHelper.remove_child(export_menu)
	export_menu.queue_free()
"""

	return code_blocks[block]
