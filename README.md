# CrazyForCats
WoW addon which provides a slash command to summon a random pet out of a predefined table

## Usage
Select pets via checkbox in the pet journal from which one will randomly be chosen. Summon a random pet from this list ingame with the command `/crazyforcats` or `/cfc` or use the provided option to assign a keybind.

## File Description
- **CrazyForCats.lua** contains the main code
- **CrazyForCats.toc** is the standard table-of-contents file containing addon information
- **Bindings.xml** is needed to provide keybinds
- **paw.tga** is used as background for the checkbox

## To-Do
- [ ] Filtering/searching of personal favorites
- [x] Mark selected pets in the scroll list
- [ ] *(Maybe)* **Rematch** integration
- [x] *(Maybe)* Automatic summoning of pets when non is summoned
- [ ] ~~Don't use a table of tables, use the "inner" tables directly instead~~

## Known Bugs
- Personal favorite icons only update when scrolling with mouse wheel, not when dragging the scroll bar