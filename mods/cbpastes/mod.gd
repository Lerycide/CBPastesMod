extends ContentInfo

const PasteParser = preload("res://mods/cbpastes/scripts/PasteParser.gd")

const ExportButtonInjector = preload("res://mods/cbpastes/scripts/ExportButtonInjector.gd")

const IMPORT_PASTE_MENU = preload("res://mods/cbpastes/menus/PasteInputMenu.tscn")

const PATH_PREFIX = "user://pastes/"

const PATCHES = {
	"party_menu": preload("res://mods/cbpastes/patches/PartyMenuPatch.gd"),
	"tape_storage_menu": preload("res://mods/cbpastes/patches/TapeStorageMenuPatch.gd"),
	"party_tape_ui": preload("res://mods/cbpastes/patches/PartyTapeUIPatch.gd"),
	"input_mapped_button": preload("res://mods/cbpastes/patches/InputMappedButtonPatch.gd"),
}

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
	var menu = IMPORT_PASTE_MENU.instance()
	MenuHelper.add_child(menu)
	var result = yield (menu.run_menu(), "completed")
	if result != null:
		var tapes:Array = PasteParser.import_pastes(result)
		var is_passive:bool = tapes.size() > 6
		for tape in tapes:
			tape.favorite = not is_passive
			var co = MenuHelper.give_tape(tape, is_passive)
			if co is GDScriptFunctionState:
				print("Imported %s" % tape.get_name())
				yield (co, "completed")
	WorldSystem.pop_flags()
	menu.queue_free()
