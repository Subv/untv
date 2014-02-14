Architecture and the Global Menu
================================

At it's heart, UNTV is little more than an "app launcher". Really, outside of the handful of components like the `Player`, `Remote`, and `Notifier`, that UNTV exposes to extensions, the primary functionality rests upon what's called the `GlobalMenu`.

## Global Menu

The Global Menu is responsible for registering extensions and generating a user interface that allows for navigating and selecting one to load. In addition, the Global Menu provides a sort of context for the application. It is the equivalent of your "home screen" and thus it also is responsible for managing the state of things.

### Extensions

All extensions get executed in the context of an object that is created from their `manifest.json` file. This file gets parsed and the `main` script path is replaced with the module reference returned from `require()`'ing that file. All of the extensions that are non-passive (*see authoring-extensions.md*) get stored in the `GlobalMenu` . 

When a user selects an item from the menu interface, we:

* Lookup the extension reference by it's corresponding index
* Remove the artifacts of any previously loaded extension (like stylesheets)
* Inject any stylesheets defined in the new extension's manifest
* Create the `ExtensionEnvironment` object (exposes components for use by extensions)
* Execute the referenced extension, passing it the evironment object and close the menu

### Actions

There is another type of "entry" into the `GlobalMenu` called an **action**. An action is looks like another menu item for an extension, except is does not load an extension. When selected, an action simply fires a single "handler" function.

An example of this is the "Quit" menu entry. It would be silly to author an extension that simple closes UNTV, which is why we have added support for these simple handlers.

Currently, registering actions is not exposed as an API to developers and they are managed internally in `lib/menu-actions.coffee`.

## Words on Architecture

This simple architecture was made the foundation of UNTV for the purpose of making it as flexible as possible. Nearly every use-case for UNTV falls under the responsibility of an **extension**. 

Now that might seem a little bit silly, considering that folks have little use for an app launcher with no apps. That is why we bundle a collection of 6 **extensions** that provide the functionality you would expect from a media center. This includes a video library, music player, photo gallery, settings, and an extension manager for installing new extensions. We also provide an instant streaming extension which allows you to browse and stream movies over BitTorrent which is pretty cool.

Another reason I chose to build the application this way was to prove the validity of the extension API. What better way to know that extensions can be built easily and prove it than to build the app as a handful of extensions to a very simple core?

These are the principles of UNTV's architecture. 
