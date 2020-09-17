extends Control


var _player_name = ""

func _on_TextField_text_changed(new_text):
	_player_name = new_text

func _on_CreateButton_pressed():
	if _player_name == "" or _player_name.length() >= 10:
		return
	Network.create_server(_player_name)
	_load_game()

func _on_JoinButton_pressed():
	if _player_name == "" or _player_name.length() >= 10:
		return
	Network.connect_to_server(_player_name)
	_load_game()

func _load_game():
	get_tree().change_scene('res://Game.tscn')
