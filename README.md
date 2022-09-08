**Zeus Additions** adds a handful of modules to the Zeus interface. Requires ZEN on all clients. This mod is a client side mod.

<h2>Modules</h2>

* **Add ACE Drag and Carry Options:** Allows the Zeus to set object to be ACE draggable and carriable. The module can also set whether weight limits should be respected when trying to drag or carry the selected object.
* **Add ACE Drag Body Option:** Allows the Zeus to give players the option to drag corpses.
* **Change AI Crew Behaviour:** Can prevent AI from dismounting in combat and also when their vehicle is immobilized. Allows the Zeus to change if AI can turn out or not.
* **Change Captivity status:** Makes an AI unit drop their inventory and weapons at their feet and stops them from moving.
* **Change Channel Visibility:** Allows the Zeus to enable and disable specific channels including custom ones, both chat and VON.
* **Change Grass Rendering:** Allows the Zeus to change grass rendering on players. Use Low (Off) to turn off grass completely, Standard is recommended if you wish to turn it on (The others are there in case you want to use them).
* **Change RHS APS:** Allow the Zeus to enable or disable the APS (Active Protection System) on the RHS T-14 and T-15 vehicles.
* **Change TFAR Radio Range:** Allows the Zeus to change TFAR radio transmission & reception distances.
* **Configure Doors (Extended):** Allows the Zeus to set doors on a building to be open, locked, unlocked or locked and breachable. You can define your own explosives that are needed for breaching.
* **Create ACE Medical Injuries:** Allows the Zeus to create ACE Medical injuries on AI or players, either dead or alive. Also can create random wounds, taking a damage value and type you are able to set. Random damage can only be applied to a living unit. When applied to players, it will notify the player in question that they have been injured. This is to avoid abuse.
* **Delete Object (forced):** Allows the Zeus to delete an object when he gets the "insufficient resources" error when trying to delete an object.
* **End Mission with Player Modifier:** Ends the mission with all players except Zeuses having the chosen modifier applied to them.
* **Give Death Stare Ability:** If used this module grants the chosen unit to have a "death stare". The unit uses an ACE self-interaction whilst looking at the desired target. The result of the action will the inducing pain the target and doing some sort of harm, depending on the settings.
* **Loadout: Apply to group:** Applies predetermined loadouts to the entire group of unit that the module was placed on. It will try to apply various loadouts based on their roles (it will try at least, as there no good way of determining an exact role as it isn't very precise).
* **Loadout: Apply to single unit:** Applies a predetermined loadout to a single unit. If that loadout isn't defined, it will fall back onto the group defined loadouts.
* **Loadout: Set:** Allows the Zeus to set loadouts for the "Loadout: Apply to group" and "Loadout: Apply to single unit" modules. These are saved on a profile basis, which means they stick around, allowing you to use them on various servers.
* **Loadout: Presets:** Allows the Zeus to create, delete, import, export and select presets.
* **Open ACE Medical Menu:** Allows the Zeus to open a unit's medical menu.
* **Pause Time:** Allows the Zeus to effectively stop time. It sets time acceleration to a minimum and reverts time every 100 seconds to when the module was placed.
* **Place Map Markers:** Allows the Zeus to place markers in every channel, including most custom ones. If a side is selected, Zeus can mark markers on that side. If a group is selected, Zeus can mark both in that side and group.
* **Paradrop Unit Action:** Allows the Zeus to make a scroll wheel interaction for players to paradrop using the map. Module can be placed on an object to give interaction. If not placed on an object, it will spawn in a flag pole.
* **Paradrop Units:** Allows the Zeus to paradrop units, vehicles and boxes.
* **Prevent Vehicle from Exploding:** This module makes vehicles not able to blow up, but still allows them to take damage.
* **Remove Grenades from AI:** This module removes all types of grenade from the selected AI.
* **Show Mission Object Counter:** This module prints what the Zeus has placed in the mission so far if the functionality is enabled (see CBA settings).
* **Spawn ACE Medical Resupply:** Spawns an ACE medical resupply. If the module is placed on an object, it can put the resupply in the inventory of the object and clear out the inventory prior to that if wanted.
* **Spawn Ammo Resupply for Players:** Spawns a magazine resupply using the unit's weapons. The unit is either chosen by placing the module on the unit or the choosing a player from the menu. If multiple players are chosen from the menu, only the chronologically first selected one will be used. If the module is placed on a unit and you choose a player from the menu, the menu selection will take priority. If the module is placed on an object, it can put the resupply in the inventory of the object and clear out the inventory prior to that if wanted. It can use a blacklist which can be defined in the CBA settings. Supports the FK arsenal blacklist.
* **Spawn Ammo Resupply for Players (Selection):** Spawns a magazine resupply using the list predefined in the CBA settings and another UI that is opened after the first window which allows the Zeus to pick magazines in a more precise fashion for resupplying given units. If no units are specified, it will show all groups of magazines. If the module is placed on an object, it can put the resupply in the inventory of the object and clear out the inventory prior to that if wanted.
* **Toggle Consciousness (forced):** Allows the Zeus to toggle a unit's consciousness state. This disregards any wake up conditions such as stable vitals, except if the unit is a player and they are in cardiac arrest. When applied to a player, it will notify them that their consciousness has been toggled. This is to avoid abuse.
* **Toggle Dust Storm Script:** Allows the Zeus to apply a dust storm script to players.
* **Track Unit Death:** Allows the Zeus to select units to track. When a selected unit dies, the Zeus will be notified the way he set it.
* **Unload ACE Cargo:** Allows the Zeus to unload ACE Cargo items from a vehicle.

**Numerous CBA settings to customize modules:** To change them, go to Options -> Addon Options -> Zeus Additions - Main

Inputs are arrays of strings.
* **Blacklist:** Allows the user to set up a list of ammo that won't be put in the resupply using the "Spawn Ammo Resupply for unit" module.
* **X Ammunition:** Allows the user to set up custom arrays of ammunition to give to users using the "Spawn Ammo Resupply" module.
* **Enable automatic blacklist detection for FK servers:** FK is a gaming community.
* **Enable leave unconscious unit:** Allows the user to leave an unconscious remote controlled unit when pressing the ESCAPE key. Handy for people who have their Zeus key bound to a double tap.
* **Enable no curator found hint:** If enabled, it will hint if no curator was found for JIP and object counter features.
* **Enable Snow Script missing addon hint:** If enabled, it will hint if CUP Core is missing.
* **Enable TFAR missing addon hint:** If enabled, it will hint if TFAR is missing.
* **Enable JIP features:** If enabled, it will add JIP functionality to the server, if the player is a curator.
* **Enable Mission Object Counter:** This will only work if the player is a curator. If enabled, it will count what you have placed down as a curator. If disabled, it will remove the counter, but not reset it.

This mod also adds:
    - the ability to drag dead corpses as Zeus. In order to do so, you must be in the map screen.

<h2>How to - Spawn Ammo Resupply</h2>

* Select initial option in the first window. If you cancel in the first window, it will not open up the second one.
* If you select units, it will limit the magazine groups in the second window to the groups that are compatible with the units' weapons. If no units are selected, it will display all magazine groups.
* In the second window, select a category (magazine well) of magazines you want to look at. It will then list all of the magazines in that category.
    * Double click a magazine to add to the other column (works in both directions).
    * Select one or multiple (for multiple use shift) magazine and use the arrow button.
    * Use the other arrow button to remove your choice of magazines from the "selected" list. Trash can removes all.
    * You can add as many magazines from different categories as you want.
* In the "selected" window, you can select one, multiple or no items and change how many there are using the "+" and "-" buttons:
    * "Shift" modifies the amount by 5.
    * "Control" modifies the amount by 10.
    * "Control" + "shift" modifies the amount by 50.
* When you press ok, it will spawn the magazines.

<h2>JIP feature</h2>

Only 1 client needs it to be enabled for it to be added to the server. If multiple clients have Zeus Additions, one or more have it turned on but the others not, the latter can still set JIP features in modules.

<h2>Credit</h2>

Mod by johnb43<br/>
[GitHub](https://github.com/johnb432/Zeus-Additions)

Gear script originally made by cineafx, revamped by johnb43.<br/>
Snow script made by JW & AZCoder, reworked by johnb43.<br/>
Dog attack module made by Fred, reworked by johnb43.<br/>
Parachute drop script by Kex & cobra4v320, reworked by johnb43.

Thanks to [sh4rdknight](https://gitlab.com/sh4rdknight) for enduring testing sessions.

<h2>License</h2>

See LICENSE.

<h2>How to create PBOs</h2>

* Download and install hemtt from [here](https://github.com/BrettMayson/HEMTT)
* Open command terminal, navigate to said folder (Windows: cd 'insert path')
* Type "hemtt build" for pbo, "hemtt build --release" for entire release
