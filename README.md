# CrazyForCats
WoW addon which provides a slash command to summon a random pet out of a predefined table

## Usage
In *CrazyForCats_Tables.lua*, define a table `name = {"Default name of a pet", "Default name of another pet", ...}`. Summon a random pet from this list ingame with the command `/cfc name`.

## File Description
- **CrazyForCats.lua** contains the main code
- **CrazyForCats.toc** is the standard table-of-contents file containing addon information
- **CrazyForCats_Tables.lua** contains tables with pet names

## Changes
- **1.1b**: Fixed combat check
- **1.1**: Added combat check
- **1.0**: Initial release

## To-Do
- [ ] Don't use a table of tables, use the "inner" tables directly instead
