Settings Registry API
=====================

Extensions will often want to remember some sort of user data whether it's authentication tokens for a remote API or simple configuration preferences. In an effort to standardize the way extensions can define options the user may configure, we created the `SettingsRegistry` class.

The `GlobalMenu` creates a single instance of this class before any extensions are loaded. During extension registration, the extension manifest file gets fed to the `SettingsRegistry`, where it parses the `config` property to determine which settings you have defined as **user configurable** (*see writing-configurable-extensions.md*). 

The `SettingsRegistry` instance uses a `localStorage` adapter to sync changes made to the setting and first looks for the value to your configuration key there (else your specified default is used). Then the value in your configuration is replaced. So for example if my extension's config is defined like so:

```json
{
    "config": {
        "debug_mode": {
            "register": true,
            "default": false,
            "is_toggle": true
        }
    }
}
```

After passing through the `SettingsRegistry`, it get's provided to the extension as:

```json
{
    "config": {
        "debug_mode": false
    }
}
```

Unless, of course, the user has changed it via the Settings Extension. 

> The bundled Settings Extension provides the global interface for modifying configuration for all extensions that are registered in this way. It does this by getting "privileged" context from the `GlobalMenu` (by passing the settings for all extensions with the `ExtensionEnvironment` object).

## Class: Setting(key, spec)

Represents a single configurable value that is stored and recalled.

#### Spec

* register: `Boolean` - Indicates to the `SettingsRegistry` that this option is configurable
* default: `Mixed` - The default value for this setting
* options: `Array` - Possible values for this option or use `["*"]` for any
* is_toggle: `Boolean` - Whether or not this setting is simply on/off
* description: `String` - Human-friendly description of setting (shown in Settings Extension) - defaults to `key`

#### Core Methods

##### toggle()

If the instance's `is_toggle` is `true`, this set the value of the instance to the inverse of it's current value.

##### set(value)

Sets the value of the instance to the indicated `value` or if none is specified it is reset to it's `default`. This value is automatically persisted if a `persistence_key` exists.

##### persistTo(key)

Sets the instance's `persistence_key` for the value.


## Class: SettingsRegistry(storage_namespace)

Creates a sort of "registry" for `Setting`s that are defined via the specification documented in *writing-configurable-extensions.md*. The `storage_namespace` is required for using the built-in persistence adapter.

#### Core Methods

##### register(extension_manifest)

Registers an extension's settings and transforms the configuration to represent user-modified values before the extension is loaded.

##### resetDefaults()

Resets all extensions configuration back to their default values.
