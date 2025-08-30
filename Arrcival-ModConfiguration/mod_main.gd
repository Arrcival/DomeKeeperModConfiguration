extends Node

const MYMODNAME_MOD_DIR = "Arrcival-ModConfiguration/"
const MYMODNAME_ID = "Arrcival-ModConfiguration"

const EXTENSIONS_DIR = "extensions/"
const HOOKS_DIR = "hooks/"

func _init(modLoader = ModLoader):
	ModLoaderLog.info("init starting", MYMODNAME_ID)
	var dir = ModLoaderMod.get_unpacked_dir() + MYMODNAME_MOD_DIR
	var ext_dir = dir + EXTENSIONS_DIR
	
	# Add extensions
	loadExtension(ext_dir, "TitleStage.gd")
	
	ModLoaderLog.info("init done", MYMODNAME_ID)

func _ready():
	ModLoaderLog.info("_ready starting", MYMODNAME_ID)
	add_to_group("mod_init")
	ModLoaderLog.info("_ready done", MYMODNAME_ID)

func modInit():
	pass

func loadExtension(ext_dir, fileName):
	ModLoaderMod.install_script_extension(ext_dir + fileName)

func loadHook(vanilla_class, hooks_dir, fileName):
	ModLoaderMod.install_script_hooks(vanilla_class, hooks_dir + fileName)

