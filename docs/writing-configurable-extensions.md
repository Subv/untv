Writing Configurable Extensions
===============================

When building an extension, it's `manifest.json` can be defined in a way that talks to the `SettingsRegistry` (see *about-settings-registry.md*). The `SettingsRegistry` parses the `config` property in the manifest file and provides an interface for modifying the configuration properties defined.

The built-in **Settings & Preferences** extension uses the global `SettingsRegistry` to display the different extension configurations as well as allowing the user to modify them.

## Manifest Config 

The `config` property should always be an object. Each property corresponds to a value that, depending on it's definition, may or may not be configurable by the user and/or other extensions.

A simple `config` that is static (non-configurable) might look like this:

```json
{
    "config": {
        "remember_selections": true,
        "default_genre": "Sci-Fi"
    }
}
```

These properties are statically configured and aren't touched by the `SettingsRegistry`. In order to allow the registry to consume and expose it's configuration interface for a given property, we set the value to an object with specific keys:

```json
{
    "config": {
        "default_genre": {
            "register": true,
            "is_toggle": false,
            "default": "Sci-Fi",
            "options": [
                "Action", "Adventure", "Biography",
                "Comedy", "Horror"
            ]
        }
    }
}
```

As seen in the example above, we have 4 keys:

* **register** - `Boolean` indicating whether or not to register the property with the `SettingsRegistry`
* **is_toggle** - `Boolean` indicating whether or not this value is a simple on/off toggle (default must be a Boolean)
* **default** - `Mixed` type value indicating the default setting for this property
* **options** - `Array` of possible values for the property, or pass a `String` wildcard (`"*"`) to indicate that any string value can be set.

## Accessing Configuration from Extension

When the `GlobalMenu` loads your extension, it first "pre-processes" your manifest's `config`. It does this by checking `localStorage` for values that are not equal the `default` specified but exist in the `options` array. When it finds one, it simply overrides the value that gets passed to the extension. If an override does not exist, it simply replaces the value with the default specified.

So for instance, using the example above, I would access the value of `default_genre` like so:

```coffeescript
module.exports = (env) ->
    config = env.manifest.config
    console.log config.default_genre 
    # "Sci-Fi"
```



