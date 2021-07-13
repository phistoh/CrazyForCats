# CrazyForCats
WoW addon which provides a slash command to summon a random pet out of a predefined table

## Usage
Select pets via checkbox in the pet journal from which one will randomly be chosen. Summon a random pet from this list ingame with the command `/crazyforcats` or `/cfc` or use the provided option to assign a keybind.

## File Description
- **CrazyForCats.lua** contains the main code
- **CrazyForCats.toc** is the standard table-of-contents file containing addon information
- **Bindings.xml** is needed to provide keybinds
- **paw.tga** is used as background for the checkbox

## Changes
- **2.1.4**: Update for Chains of Domination (9.1.0) (new interface number)
- **2.1.3**: Fixed a bug with the 'auto summon' checkbox not being checked on opening the journal
- **2.1.2**: Fixed a bug where the addon name was not passed while handling the 'ADDON_LOADED' event
- **2.1.1**: Update for Shadowlands (9.0.5) (new interface number)
- **2.1**: Pet in pet journal scroll list now show icons if they're marked as personal favorites; also implements an option to automatically summon personal favorites
- **2.0b**: Table of pets is now generated ingame (checkboxes in the pet journal) and saved per character (using WoW's saved variables)
- **1.1b**: Fixed combat check
- **1.1**: Added combat check
- **1.0**: Initial release

## To-Do
- [ ] Filtering/searching of personal favorites
- [x] Mark selected pets in the scroll list
- [ ] *(Maybe)* **Rematch** integration
- [x] *(Maybe)* Automatic summoning of pets when non is summoned
- [ ] ~~Don't use a table of tables, use the "inner" tables directly instead~~