extends "res://menus/BaseMenu.gd"

export (String) var title:String
export (String) var default_text:String

onready var title_label = find_node("TitleLabel")
onready var text_edit = find_node("TextEdit")

func _ready():
	title_label.text = title
	text_edit.text = default_text

func grab_focus():
	text_edit.grab_focus()

func _on_SubmitButton_pressed():
	choose_option(text_edit.text)
