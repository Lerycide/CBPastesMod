# dynamically adds a new button whenever the party menu is loaded
static func inject_export_button(node:Node):
	if has_export_button("ExportButton"):
		return
	var export_button = InputMappedButton.new()
	stylize_button(export_button)

	var back_button_panel = node.find_node("BackButtonPanel")
	if not back_button_panel:
		return
	back_button_panel.get_child(0).add_child(export_button, true)
	var index:int = back_button_panel.get_child(0).get_child_count()
	back_button_panel.get_child(0).move_child(export_button, index - 2)
	back_button_panel.call_deferred("force_relayout")
	if not export_button.is_connected("pressed", node, "_on_ExportButton_pressed"):
		export_button.connect("pressed", node, "_on_ExportButton_pressed")


static func inject_basic_export_button(node:Node):
	if has_export_button("SimpleExportButton"):
		return
	var export_button = Button.new()
	export_button.set_name("SimpleExportButton")
	export_button.text = "CBPASTE_EXPORT_BUTTON"
	var buttons_container = node.find_node("Buttons")
	if not buttons_container:
		return
	buttons_container.add_child(export_button, true)
	var index:int = buttons_container.get_child_count()
	buttons_container.move_child(export_button, index - 2)
	if not export_button.is_connected("pressed", node, "_on_SimpleExportButton_pressed"):
		export_button.connect("pressed", node, "_on_SimpleExportButton_pressed")


static func stylize_button(button:InputMappedButton):
	button.set_name("ExportButton")
	button.action = "ui_action_2"
	button.expand_icon = true
	button.text = "CBPASTE_MASS_EXPORT"
	button.hide_if_disabled = true
	button.set("custom_styles/hover", StyleBoxEmpty.new())
	button.set("custom_styles/pressed", StyleBoxEmpty.new())
	button.set("custom_styles/focus", StyleBoxEmpty.new())
	button.set("custom_styles/disabled", StyleBoxEmpty.new())
	button.set("custom_styles/normal", StyleBoxEmpty.new())


static func has_export_button(key:String) -> bool:
	var result = MenuHelper.find_node(key, true, false)
	if result:
		return true
	return false
