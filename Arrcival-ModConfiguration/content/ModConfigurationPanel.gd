extends CenterContainer


signal close


var modContainerBox: Node

var list_conf: Array[Dictionary]


func _ready():
	modContainerBox = find_child("ModContainerBox")

	var every_mods: Dictionary = ModLoaderMod.get_mod_data_all()
	var current_profile_name: String = ModLoaderUserProfile.get_current().name

	for mod_id: String in every_mods.keys():

		var current_mod: ModData = every_mods[mod_id]
		# Mod isn't active
		if not current_mod.is_active:
			continue

		# Mod doesn't have any configuration -> cause it doesn't have any schema
		# Gets in if the mod doesn't have any schema EVEN if there's a save (a property that gets removed)
		if not ModLoaderConfig.has_current_config(mod_id):
			continue
		
		var mod_config = ModLoaderConfig.get_current_config(mod_id)
		var default_config = ModLoaderConfig.get_default_config(mod_id)

		# This shouldn't occur but occurs if you create a new profile without restarting
		# For example, with the same mods of the precedent config. So we just create a new one and assign default config
		# Same thing if you open the game without having any conf file for that profile
		if mod_config == null or mod_config.name != current_profile_name:
			# Just making sure that the config doesn't already exist
			if ModLoaderConfig.has_config(mod_id, current_profile_name):
				mod_config = ModLoaderConfig.get_config(mod_id, current_profile_name)
			
			else:
				mod_config = ModLoaderConfig.create_config(mod_id, current_profile_name, default_config.data.duplicate(true))
				if mod_config == null:
					continue
			ModLoaderConfig.set_current_config(mod_config)

		var mod_properties: Dictionary = mod_config.schema.properties

		# Mod has no configuration schema (should never occur, but "just to be sure")
		if mod_properties == null:
			continue

		var mod_name = current_mod.manifest.name


		var panelContainer = PanelContainer.new()
		panelContainer.name = "PanelContainer " + mod_name

		var everyconfigVertical = VBoxContainer.new()
		panelContainer.add_child(everyconfigVertical)

		var title = Label.new()
		title.text = mod_name
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.label_settings = load("res://gui/fontsettings/LargeFontSettings.tres")
		everyconfigVertical.add_child(title)

		var readonly_warning = Label.new()
		readonly_warning.text = "You cannot edit configuration on a default profile."
		readonly_warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		readonly_warning.visible = false
		modContainerBox.add_child(readonly_warning)


		var mod_data: Dictionary = mod_config.data

		for value_id in mod_properties:
			var hBox = HBoxContainer.new()

			var value_config: Dictionary = mod_properties[value_id]

			var value_data
			if mod_data.has(value_id):
				value_data = mod_data[value_id]
			elif default_config.data.has(value_id):
				value_data = default_config.data[value_id]
			else:
				continue

			var mod_name_label = Label.new()
			mod_name_label.text = value_config["title"]
			hBox.add_child(mod_name_label)

			var value_type = value_config["type"]
			var read_only = mod_config.name == ModLoaderConfig.DEFAULT_CONFIG_NAME
			if read_only:
				readonly_warning.visible = true

			if value_type == "boolean":
				var checkbox = CheckBox.new()
				checkbox.button_pressed = value_data
				remember_conf(mod_config, value_id, checkbox)
				hBox.add_child(checkbox)

				checkbox.disabled = read_only

			elif value_type == "number":
				var slider = HSlider.new()
				slider.value = value_data
				slider.min_value = value_config["minimum"]
				slider.max_value = value_config["maximum"]
				slider.step = value_config["multipleOf"]
				slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL | Control.SIZE_EXPAND
				slider.editable = not read_only
				hBox.add_child(slider)

				var text_label = Label.new()
				text_label.text = str(value_data)
				slider.value_changed.connect(self.slider_value_changed.bind(text_label))
				remember_conf(mod_config, value_id, slider)
				hBox.add_child(text_label)
			elif value_type == "string":
				var lineEdit = LineEdit.new()
				lineEdit.text = value_data
				lineEdit.expand_to_text_length = true
				lineEdit.editable = not read_only
				lineEdit.custom_minimum_size = Vector2(300, 0)
				remember_conf(mod_config, value_id, lineEdit)
				fix_line_edit(lineEdit)
				hBox.add_child(lineEdit)
			everyconfigVertical.add_child(hBox)


		modContainerBox.add_child(panelContainer)


	InputSystem.grabFocus(find_child("CancelButton"))
	Style.init(self)


func slider_value_changed(value: float, text_label: Label) -> void:
	text_label.text = str(value)

func _on_ButtonCancel_pressed() -> void:
	Audio.sound("gui_cancel")
	close_popup()

func _on_ButtonApply_pressed() -> void:
	Audio.sound("gui_apply")

	for element in list_conf:
		var mod_config: ModConfig = element["mod_config"]
		if mod_config.name == ModLoaderConfig.DEFAULT_CONFIG_NAME:
			continue

		var cur_node = element["node"]
		var value_id = element["value_id"]
		if cur_node is LineEdit:
			mod_config.data[value_id] = (cur_node as LineEdit).text
		elif cur_node is CheckBox:
			mod_config.data[value_id] = (cur_node as CheckBox).button_pressed
		elif cur_node is Slider:
			mod_config.data[value_id] = float((cur_node as Slider).value)

		ModLoaderConfig.update_config(mod_config)

		
	
	close_popup()


func close_popup() -> void:
	for l in get_tree().get_nodes_in_group("gamepadListeners"):
		l.onInputMethodChanged()

	emit_signal("close")


func remember_conf(mod_config: ModConfig, value_id: String, node: Node) -> void:
	list_conf.append({
		"mod_config": mod_config,
		"value_id": value_id,
		"node": node
	})

#region line edit input stuff
func fix_line_edit(line_edit: LineEdit) -> void:
	line_edit.focus_entered.connect(_on_line_edit_focus_entered.bind(line_edit))

func _on_line_edit_focus_entered(line_edit: LineEdit) -> void:
	# get the cancel events now just in case they were rebound inbetween
	var cancel_events := InputMap.action_get_events(&"ui_cancel")
	line_edit.focus_exited.connect(restore_ui_cancel_keybinds.bind(cancel_events))
	
	# We always want at least one ui element to have focus to not break controllers,
	# so removing all binds to defocus is fine
	InputMap.action_erase_events(&"ui_cancel")


func restore_ui_cancel_keybinds(input_events: Array[InputEvent]) -> void:
	for event in input_events:
		InputMap.action_add_event(&"ui_cancel", event)
#endregion
