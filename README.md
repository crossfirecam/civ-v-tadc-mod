# 'TADC Civ Pack' for Civilization V (Release Version 1)
A mod for Civilization V. Adds 4 Civilizations to the game based on The Amazing Digital Circus. Requires G&K and BNW expansions.

## How to download/install the mod
- https://steamcommunity.com/sharedfiles/filedetails/?id=3299764540
- Check the Steam Workshop listing for details! This git repo is provided for access to the mod's source code

## Contributions
- I'm open to accepting pull-requests for localising this mod to other languages, to fix bugs, or to add support for other mods (where incompatibility is found)
- Suggestions for gameplay balance can be made in the Issues tab

## Dev Process
- Requires the use of the Modbuddy tool for development & building. Instructions for how to use this software can be found elsewhere
- To test changes to the mod as they're made:
    - Civ V needn't be re-opened after every build in Modbuddy. Just return to the main menu to make the game unload the old build
    - Enable logging in the game's config. Then open these log files under 'My Games/Sid Mier's Civilization V/logs': Database.log, Lua.log, & xml.log
    - In Civ V click 'Mods', 'Agree', and select 'TADC Civ Pack'
    - In the log files, any errors that appear (which are not Firaxis' default errors) should be noted
- To build the mod for multiplayer, check out this Steam Workshop mod by ciero225: https://steamcommunity.com/sharedfiles/filedetails/?id=361391109

## Base directory
- attributions.txt: Full credits for images, audio and code
- /resources: Files used for creating art assets
- /src: Source code for the project