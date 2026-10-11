extends "res://stages/title/TitleStage.gd"

var modConfigurationButton: Button

func beforeStart():
	super.beforeStart()

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


func build(data: Array):

	var additionalButtons: Node = find_child("AdditionalButtons")


	var currentFirstButton: Node = additionalButtons.get_child(0)

	modConfigurationButton = Button.new()
	modConfigurationButton.name = "ModConfigurationButton"
	modConfigurationButton.text = "Mods configuration"
	
	
	add_child_first(additionalButtons, modConfigurationButton)
	
	currentFirstButton.set_focus_neighbor(Side.SIDE_TOP, NodePath(modConfigurationButton.get_path()))
	modConfigurationButton.connect("focus_entered", on_additional_menu_button_entered.bind(modConfigurationButton))
	
	modConfigurationButton.pressed.connect(self._on_ModConfigurationButton_pressed)
	$Canvas / AdditionalMenu.set_anchors_preset(Control.LayoutPreset.PRESET_BOTTOM_LEFT, true)
	super.build(data)


	Style.init($Canvas / AdditionalMenu)


func _on_ModConfigurationButton_pressed() -> void:
	Audio.sound("gui_title_options")
	var i = preload("res://systems/options/OptionsInputProcessor.gd").new()
	i.blockAllKeys = true
	i.popup = preload("res://mods-unpacked/Arrcival-ModConfiguration/content/ModConfigurationPanel.tscn").instantiate()
	i.stickReceiver = i.popup
	$Canvas.add_child(i.popup)
	i.integrate(self)
	i.connect("onStop", Callable(self, "panelClosed").bind(i.popup))
	i.popup.connect("close", Callable(i, "desintegrate"))
	find_child("Overlay").showOverlay()


func panelClosed(popup):
	InputSystem.grabFocus(modConfigurationButton)
	$Canvas.remove_child(popup)
	popup.queue_free()
	find_child("Overlay").hideOverlay()
	if not isMenuIn:
		moveMenuIn(0.4)


func add_child_first(node: Node, child: Node):
	node.add_child(child)
	node.move_child(child, 0)
