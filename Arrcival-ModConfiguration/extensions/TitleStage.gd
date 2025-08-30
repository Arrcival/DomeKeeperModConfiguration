extends "res://stages/title/TitleStage.gd"

var modConfigurationButton: Button


func build(data: Array):

	var additionalButtons: Node = find_child("AdditionalButtons")


	var currentFirstButton: Node = additionalButtons.get_child(0)

	modConfigurationButton = Button.new()
	modConfigurationButton.name = "ModConfigurationButton"
	modConfigurationButton.text = "Mods configuration"
	
	
	add_child_first(additionalButtons, modConfigurationButton)
	super.build(data)
	
	currentFirstButton.set_focus_neighbor(Side.SIDE_TOP, NodePath(modConfigurationButton.get_path()))
	
	var prestigeButton = find_child("ToggleBoardButton")
	modConfigurationButton.set_focus_neighbor(Side.SIDE_TOP, NodePath(prestigeButton.get_path()))

	modConfigurationButton.pressed.connect(self._on_ModConfigurationButton_pressed)


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
