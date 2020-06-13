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
