# Changelog for Zeus Additions 7.5.2022

1.6.3.8
- Cleanup.
- Removed ability to toggle players' consciousness if they are in cardiac arrest (only if ACE medical is loaded). It causes too many issues.

# Changelog for Zeus Additions 2.4.2022

1.6.3.7
- Added the ability to drag dead bodies as a Zeus when in the map.
- Added dust storm effect.
- Removed 30s curator detection period - now curators will be detected when they enter the curator interface.
- Fixed bug with remote controlling module.

# Changelog for Zeus Additions 21.3.2022

1.6.3.6
- Minor bug fix.

# Changelog for Zeus Additions 19.3.2022

1.6.3.5
- Fixed bug in "Configure Doors (Extended)" module

# Changelog for Zeus Additions 18.3.2022

1.6.3.4
- Combined some modules together.
- Removed AI Minedetection module.

# Changelog for Zeus Additions 8.3.2022

1.6.3.3
- Added support for 2.08.
- Added Disabling & Enabling of AI pathing on drivers.
- Fixed multiple issues with the "Remote Control (Switch Unit)" module.

# Changelog for Zeus Additions 15.2.2022

1.6.3.2
- Added the ability to drag dead bodies using a new "Add ACE Drag Body Option" module.
- Added the module "Spawn Ammo Resupply for Units (Selection)" for more tailored selection of magazines for a resupply of given units.
- Added the ability to choose multiple units for the "Spawn Ammo Resupply for Units" module.
- Fixed ACE medical menu context action.
- Fixed numerous unwanted things that could be applied to dead units.
- Fixed ammo resupply interface (decrement & move out of buttons weren't working).
- Fixed Pause Time module (stopped working entirely after last update & it wouldn't reset).
- Fixed multiple various issues.
- Modules are no longer functions, they will only be registered once at postInit.
- General improvements.

# Changelog for Zeus Additions 29.12.2021

1.6.3.1
- Fixed minor bug with mission end module not removing all ammunition in vehicles.
- General improvements.

# Changelog for Zeus Additions 24.12.2021

1.6.3.0
- Removed ACE dependency.
- Added the ability to apply loadouts on units in vehicles.
- Added the ability to turn off ACE dragging or carrying using the module.
- Fixed a bug with the "Track Unit Death" module.
- Fixed grenade explosion effect spamming log entries.
- Fixed multiple MP issues.
- General improvements.

# Changelog for Zeus Additions 13.11.2021

1.6.2.5
- Fixed bug in JIP module.
- General improvements.

# Changelog for Zeus Additions 1.11.2021

1.6.2.4
- Includes check for task force radio (non-beta) now.

# Changelog for Zeus Additions 24.10.2021

1.6.2.3
- Added "Track Unit Death" module which tracks when a unit dies.
- Added "Change RHS APS" module which allows to disable the APS system in RHS T-14 and T-15 vehicles.
- Added "Unload ACE Cargo" module that allows the unloading of ACE cargo items from vehicles.
- Added "Paradrop Unit Action" module that sets up a scroll wheel action to paradrop using the map.
- Reworked "Spawn Ammo Resupply" module and settings.
- Magazine lists for "Spawn Ammo Resupply" update immediately when changing in CBA settings.
- General improvements.

# Changelog for Zeus Additions 21.9.2021

1.6.2.2
- Reworked the "Spawn Attack Dog" module: Major update by Fred, tweaks by johnb43.
- Reworked the "Configure Doors" module: Now players choose if they want to use stun grenades and set the timer duration themselves.
- Added the ability to paradrop boxes using the context menu selection.
- Fixed ammo resupply module.

# Changelog for Zeus Additions 11.9.2021

1.6.2.1
- Fixed and tweaked "Configure Doors" module.
- Added "Remove Grenades from AI" module which removes all types of grenades from AI units.
- Fixed a part of the "Change AI Mine Detecting Behaviour" module (but it still probably does nothing).

# Changelog for Zeus Additions 14.7.2021

1.6.2.0
- Added hemtt support.
- Changed signature (due to thing above).
- Updated to support ZEN 1.11.0.
- Added "Add ACE Drag and Carry Options" module which allows any object apart units to be draggable and carriable.
- Added "Place Map Marker" module which allows easier placements of player markers (and markers from Metis Markers, e.g.).
- Added "Remote Control (Switch Unit)" module which switches the player with the selected AI unit (not the same as remote controlling!). Context menu option exists too (under ZEN's "Remote Control"). To return back to original unit, get to the pause menu by pressing ESCAPE.
- Added "Show Mission Object Counter" which tracks what you as a curator have placed in a mission, if enabled. Results are put into the RPT log.
- Added icons to modules.
- Added custom channel support for the "Change Channel Visibility" module and self option.
- Added self option to the module "Change TFAR Radio Range" module and upped limit to 50x (before 10x).
- Added "Spawn Ammo Box" options to both "Spawn Ammo Resupply for Unit" and "Spawn ACE Medical Resupply" modules.
- Added "Lightning" option to "Death stare" module.
- Added "Turn on pathing", "Name" and peaceful options to "Dog attack" module. Do not select any to be attacked side to make dog peaceful.
- Added "Import" and "Export" options to the "Loadout: Presets" module.
- Added "Debrief text" option to the "End mission with player modifier" module.
- Fixed "Prevent Vehicle from Exploding" module (it would didn't reset hull damage properly).
- Fixed "When tabbing out whilst having the snow script applied, it will lose the wind effect." issue with snow script.
- Reenabled and fixed snow script.
- Removed "Set player modifier at scenario end" module.
- JIP support for modules does not require for the mod to be on the server anymore. In fact, JIP modules are designed *not* to be on the server.
- General improvements.

# Changelog for Zeus Additions 26.5.2021

1.6.1.0
- Added AI pathing enabling & disabling in context menu.
- Fixed bug with context menu related to open medical menu.

# Changelog for Zeus Additions 9.5.2021

1.6.0.0
- Added "Open Medical Menu" module + context menu action.
- Added option to put magazine resupply directly in an inventory.
- Added more options to mission end player modifier.
- FK blacklist detection works now.
- Disabled snow script for now. It doesn't work anymore and I have to figure out why.
- General improvements.

# Changelog for Zeus Additions 4.4.2021

1.5.0.0
- Improved "Lock building doors" module.
- Improved "Paradrop units" module selection.
- General improvements.

# Changelog for Zeus Additions 28.3.2021

1.4.0.0
- Added "Force delete object" module that *should* be able to force delete objects.
- Added "Pause time" module that allows for a "pausing" of time. It sets time acceleration to 0.1 and revert time every 100s by 10s, making the time effective stand still.
- Added "Toggle Snow Script" module that makes snow fall.
- Improved Dog attack module.
- General improvements.

# Changelog for Zeus Additions 15.3.2021

1.3.0.0
- Added "Disable channels" module that can disable various map marking and VON channels
- Added a functionality that allows you to exit unconscious remote controlled units when in Zeus. This fixes the issue where you can't get out of unconscious units when your Zeus key bound to a double tap. Can be enabled in CBA settings, default is off.

# Changelog for Zeus Additions 13.3.2021

1.2.2.0
- Changed loadout system to have a preset system.
- Changed lock building module (should work better).
- Added 2x AI behaviour changing modules (vehicle dismounting and mine detecting)
- Added "Prevent vehicle from blowing up" module that prevents vehicles from blowing up. Tested with ground assets at this time.

# Changelog for Zeus Additions 7.3.2021

1.2.1.0
- Minor code improvements.

# Changelog for Zeus Additions 27.2.2021

1.2.0.0
- Actually added the invincibility modules (never called the function to make the modules...).
- Added "Lock doors" module.

# Changelog for Zeus Additions 23.2.2021

1.1.0.0
- Added "TFAR Range multiplier" module.
- Added "Invincibility at end of mission" modules.
- General simplifications and improvements.

# Changelog for Zeus Additions 14.2.2021

1.0.2.0
- Added "Force consciousness change" module: Forces a unit to go unconscious or to wake up, depending on their previous state. This does not take stable vitals into account.
- Added "Change grass rendering" module: It allows you to change grass rendering on selected sides/groups/players.

# Changelog for Zeus Additions 11.2.2021

1.0.1.0
- Fixed and updated gear script modules to work better.

# Changelog for Zeus Additions 7.2.2021

1.0.0.0
- Initial release.
