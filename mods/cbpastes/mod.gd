extends ContentInfo

const PasteParser = preload("res://mods/cbpastes/scripts/PasteParser.gd")

const ExportButtonInjector = preload("res://mods/cbpastes/scripts/ExportButtonInjector.gd")

const IMPORT_PASTE_MENU = preload("res://mods/cbpastes/menus/PasteInputMenu.tscn")

const PATH_PREFIX = "user://pastes/"

const SUCCESS_AUDIO = preload("res://sfx/ui/exp_up.wav")

const PATCHES = {
	"party_menu": preload("res://mods/cbpastes/patches/PartyMenuPatch.gd"),
	"tape_storage_menu": preload("res://mods/cbpastes/patches/TapeStorageMenuPatch.gd"),
	"party_tape_ui": preload("res://mods/cbpastes/patches/PartyTapeUIPatch.gd"),
	"input_mapped_button": preload("res://mods/cbpastes/patches/InputMappedButtonPatch.gd"),
}

var import_errors: int = 0


func init_content():
	for patch_script in PATCHES.values():
		patch_script.patch()
	DLC.get_tree().connect("node_added", self, "_on_node_added")
	create_paste_dir()

	Console.register("import_paste", {
			"description":"Imports a paste and generates a tape out of it",
			"args":[],
			"target":[self, "import_paste"]
		})


func create_paste_dir():
	var directory = Directory.new()
	if directory.dir_exists(PATH_PREFIX):
		return
	var err = directory.make_dir(PATH_PREFIX)
	if err != OK:
		push_error("Unable to create directory at %s" % PATH_PREFIX)


func _on_node_added(node: Node):
	var node_name = node.name
	if node_name == "PartyMenu":
		ExportButtonInjector.inject_export_button(node)
		return
	if node_name == "TapeStorageMenu":
		ExportButtonInjector.inject_export_button(node)
		return
	if node_name == "PartyTapeUI":
		ExportButtonInjector.inject_basic_export_button(node)
		return


func import_paste():
	Console.toggleConsole()
	WorldSystem.push_flags(0)
	import_errors = 0
	
	var menu = IMPORT_PASTE_MENU.instance()
	MenuHelper.add_child(menu)
	var result = yield (menu.run_menu(), "completed")
	
	if result != null:
		var tapes:Array = PasteParser.import_pastes(result)
		if import_errors > 0:
			yield (GlobalMessageDialog.show_message(Loc.trf("CBPASTE_IMPORT_ERROR", [import_errors]), true, true), "completed")
		var can_replace_party:bool = tapes.size() > 0 and tapes.size() <= 6
		if can_replace_party:
			yield (GlobalMessageDialog.show_message(Loc.tr("CBPASTE_IMPORT_SWAP_PARTY_CONFIRM"), false, true), "completed")
			var choice:int = yield (GlobalMenuDialog.show_menu([Loc.tr("UI_BUTTON_YES"), Loc.tr("UI_BUTTON_NO")], 0), "completed")
			GlobalMessageDialog.hide()
			if choice == 0:
				replace_party_tapes(tapes)
				GlobalMessageDialog.message_dialog.audio = SUCCESS_AUDIO
				yield (GlobalMessageDialog.show_message(Loc.tr("CBPASTE_IMPORT_SWAP_PARTY_SUCCESS"), true, true), "completed")
				WorldSystem.pop_flags()
				menu.queue_free()
				return
		var is_passive:bool = tapes.size() > 6
		for tape in tapes:
			tape.favorite = not is_passive
			var co = MenuHelper.give_tape(tape, is_passive)
			if co is GDScriptFunctionState:
				print("Imported %s" % tape.get_name())
				yield (co, "completed")
		if is_passive:
			GlobalMessageDialog.message_dialog.audio = SUCCESS_AUDIO
			yield (GlobalMessageDialog.show_message(Loc.tr("CBPASTE_IMPORT_MASS_SUCCESS"), true, true), "completed")
	WorldSystem.pop_flags()
	menu.queue_free()


func replace_party_tapes(tapes: Array):
	assert (tapes.size() <= 6)
	var current_tapes: Array = _get_party_tapes()
	for i in tapes.size():
		if i >= current_tapes.size():
			current_tapes.push_back(tapes[i])
		else:
			var old_tape = current_tapes[i]
			SaveState.tape_collection.add_tape(old_tape)
			current_tapes[i] = tapes[i]
		print("Imported %s" % tapes[i].get_name())
	_set_party_tapes(current_tapes)


func _get_party_tapes(output := []) -> Array:
	var party = SaveState.party
	
	for character in party.characters:
		output.append_array(character.tapes)
	# reorders them so that the partner tape is in index 1 instead of the last slot
	if party.characters.size() > 1:
		var partner_tape = output.pop_back()
		output.insert(1, partner_tape)
	return output


func _set_party_tapes(tapes: Array):
	if SaveState.party.characters.size() > 1:
		var partner_tape = tapes.pop_at(1)
		SaveState.party.get_partner().tapes = [partner_tape]
	SaveState.party.get_player().tapes = tapes
