# DomeKeeperModConfiguration
A mod to handle configuration of other mods with an in-game UI

This mod doesn't add any content to Dome Keeper, and is only here for the user to have a central place to configurate every mods installed. Having one central place to handle configuration also helps compatibility between mods.

## How to use (as a modder)

The mod is quite straight-forward to have it working :
- Update your manifest.json schema with the properties you want to have configurable. Use [this documentation](https://wiki.godotmodding.com/guides/modding/config_json/) to see how to fill the schema. Currently, the configuration supports :
  * Numbers (number) with a slider
  * Texts (string) with a textbox
  * Booleans (boolean) with a checkbox

- Add the mod configuration mod as a dependency in your manifest.json (Arrcival-ModConfiguration) and on the steam workshop on your mod. This is actually optional, but if you want the mod configuration mod to come nicely and be also added when someone subscribes to your mod, this is necessary
If you do not, the default configuration would be used.


And you're then good to go, actually.
To retrieve a property value, you need to first retrieve your current mod configuration using
```cs
var config = ModLoaderConfig.get_current_config(YOUR_MOD_ID)
```
and then retrieve the value you need
```cs
var property_value = config[VALUE_ID] 
```
or
```cs
var property_value = config.value_id
```

## How to use (as a player)

The mod add a "Mod configuration" button on top of the "Modding" one, open it to change configurable properties.

### Warning : Default preset cannot be edited.