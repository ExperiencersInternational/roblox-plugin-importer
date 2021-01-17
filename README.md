# Plugin Importer
> Quickly re-download a plugin's source code into your game.

[![Plugin Importer](https://doy2mn9upadnk.cloudfront.net/uploads/default/f6cad402b72c666d8af255a8594c7d00d2ec4de2)]((https://www.roblox.com/library/336673829/Plugin-Importer))

Plugin Importer is a free plugin for Roblox that gives developers, and the curious, an easy way to grab and insert the source code of any plugin, and plop it straight into their game.

Source code imported with Plugin Importer is inserted into `ServerStorage` and will be contained within a folder named `Plugin_{{pluginId}}`. Once imported successfully, the plugin will be automatically selected in your Explorer window.

Plugin Importer is built with [Roact](https://github.com/Roblox/roact) and [BasicState](https://github.com/ClockworkSquirrel/BasicState), and supports both light and dark modes!

# Installation
* [**Download from the Roblox website/toolbox**](https://www.roblox.com/library/336673829/Plugin-Importer) (recommended)
* [Download a copy from the Releases tab](https://github.com/ClockworkSquirrel/roblox-plugin-importer/releases)
* Sync into your game [with Rojo](https://github.com/rojo-rbx/rojo)
* ~~Import with Plugin Importer~~

# Features
* Import plugins using their asset ID or library page URL
* See a list of plugins you've previously imported (up to 100 items)
* Import directly from your own personal catalogue of published plugins (requires HTTP permissions)

# Basic Usage
1. Copy and paste a plugin ID or URL from the website.
    * Example 1: `https://www.roblox.com/library/336673829/Plugin-Importer`
    * Example 2: `336673829`
2. Paste it into the text box on the "Recent" tab, and press <kbd>Enter</kbd>.
3. The plugin will be automatically inserted to `ServerStorage`, inside a Folder named `"Plugin_"` followed by the plugin's ID, and will be selected in the Explorer window.

# License
Plugin Importer is provided under the MIT License. See [LICENSE](/LICENSE) for more details.
