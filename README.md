**Zeus Additions** adds a handful of modules to the Zeus interface. Requires ZEN and ACE. This mod is a client side mod.

<h2>JIP feature</h2>

Only 1 client needs it to be enabled for it to be added to the server. If multiple clients have Zeus Additions, one or more have it turned on but the others not, the latter can still set JIP features in modules.

<h2>Modules</h2>

* **Add ACE Drag and Carry Options:** Allows the Zeus to set object to be ACE draggable and carriable. The module can also set whether weight limits should be respected when trying to drag or carry the selected object.
* **Change AI Dismount Behaviour:** Can prevent AI from dismounting in combat and also when their vehicle is immobilized.
* **Change AI Mine Detecting Behaviour:** Theoretically should change their ability to detect mines. However in practice it doesn't seem to do anything, so feedback and more work is needed.
* **Change Channel Visibility:** Allows the Zeus to enable and disable specific channels including custom ones, both chat and VON.
* **Change Grass Rendering:** Allows the Zeus to change grass rendering on players. Use Low (Off) to turn off grass completely, Standard is recommended if you wish to turn it on (The others are there in case you want to use them).
* **Change TFAR Radio Range:** Allows the Zeus to change TFAR radio transmission distances.
* **Configure Doors:** Allows the Zeus to set doors on a building to be open, locked, unlocked or locked and breachable. You can define your own explosives that are needed for breaching.
* **Create ACE Injuries:** Allows the Zeus to create injuries on AI or players. When applied to players, it will notify the player in question that they have been injured. This is to avoid abuse.
* **Create Random ACE Injuries:** Creates random wounds, taking a damage value and type you are able to set. When applied to players, it will notify the player in question that they have been injured. This is to avoid abuse.
* **Delete Object (forced):** Allows the Zeus to delete an object when he gets the "insufficient resources" error when trying to delete an object.
* **End Mission with Player Modifier:** Ends the mission with all players except Zeuses having the chosen modifier applied to them.
* **Give Death Stare Ability:** If used this module grants the chosen unit to have a "death stare". The unit uses an ACE self-interaction whilst looking at the desired target. The result of the action will the inducing pain the target and doing some sort of harm, depending on the settings.
* **Loadout: Apply to group:** Applies a predetermined loadout to the entire group of unit that the module was placed on. It will try to apply various loadouts based on their roles (it will try at least, as there no good way of determining an exact role as it isn't very precise).
* **Loadout: Apply to single unit:** Applies a predetermined loadout to a single unit. If that loadout isn't defined, it will fall back onto the group defined loadouts.
* **Loadout: Set:** Allows the Zeus to set loadouts for the "Loadout: Apply to group" and "Loadout: Apply to single unit" modules. These are saved on a profile basis, which means they stick around, allowing you to use them on various servers.
* **Loadout: Presets:** Allows the Zeus to create, delete, import, export and select presets.
* **Open ACE Medical Menu:** Allows the Zeus to open a unit's medical menu.
* **Pause Time:** Allows the Zeus to nearly stop time. It sets time acceleration to a minimum and reverts time every 100 seconds.
* **Place Map Markers:** Allows the Zeus to place markers in every channel, including most custom ones. If a side is selected, Zeus can mark markers on that side. If a group is selected, Zeus can mark both in that side and group.
* **Paradrop Units:** Allows the Zeus to paradrop units, vehicles and boxes.
* **Prevent Vehicle from Exploding:** This module makes vehicles not able to blow up, but still allows them to take damage.
* **Remove Grenades from AI:** This module removes all types of grenade from the selected AI.
* **Show Mission Object Counter:** This module prints what the Zeus has placed in the mission so far if the functionality is enabled (see CBA settings).
* **Spawn ACE Medical Resupply:** Spawns an ACE medical resupply. If the module is placed on an object, it can put the resupply in the inventory of the object and clear out the inventory prior to that if wanted.
* **Spawn Ammo Resupply:** Spawns a magazine resupply using lists predefined in the CBA settings. If the module is placed on an object, it can put the resupply in the inventory of the object and clear out the inventory prior to that if wanted.
* **Spawn Ammo Resupply for Unit:** Spawns a magazine resupply using the unit's weapons. The unit is either chosen by placing the module on the unit or the choosing a player from the menu. If multiple players are chosen from the menu, only the chronologically first selected one will be used. If the module is placed on a unit and you choose a player from the menu, the menu selection will take priority. If the module is placed on an object, it can put the resupply in the inventory of the object and clear out the inventory prior to that if wanted. It can use a blacklist which can be defined in the CBA settings. Supports the FK arsenal blacklist.
* **Toggle Consciousness (forced):** Allows the Zeus to toggle a unit's consciousness state. This disregards any wake up conditions such as stable vitals. When applied to a player, it will notify them that their consciousness has been toggled. This is to avoid abuse.
* **Toggle Snow Script:** Allows the Zeus to apply a snow script to players.

**Numerous CBA settings to customize modules:** To change them, go to Options -> Addon Options -> Zeus Additions - Main

Inputs are arrays of strings.
* **Blacklist:** Allows the user to set up a list of ammo that won't be put in the resupply using the "Spawn Ammo Resupply for unit" module.
* **X Magazines:** Allows the user to set up custom arrays of ammunition to give to users using the "Spawn Ammo Resupply" module.
* **Enable automatic blacklist detection for FK servers:** FK is a gaming community.
* **Enable leave unconscious unit:** Allows the user to leave an unconscious remote controlled unit when pressing the ESCAPE key. Handy for people who have their Zeus key bound to a double tap.
* **Enable no curator found hint:** If enabled, it will hint if no curator was found for JIP and object counter features.
* **Enable Snow Script missing addon hint:** If enabled, it will hint if CUP Core is missing.
* **Enable TFAR missing addon hint:** If enabled, it will hint if TFAR is missing.
* **Enable JIP features:** If enabled, it will add JIP functionality to the server, if the player is a curator.
* **Enable Mission Object Counter:** This will only work if the player is a curator. If enabled, it will count what you have placed down as a curator. If disabled, it will remove the counter, but not reset it.

<h2>CREDITS</h2>

Mod by johnb43<br/>
[GitHub](https://github.com/johnb432/Zeus-Additions)

Gear script originally made by cineafx, revamped by johnb43.
Snow script made by JW & AZCoder, reworked by johnb43.
Dog attack module made by Fred, reworked by johnb43.

Thanks to sh4rdknight for enduring testing sessions.

<h2>LICENSE</h2>

See LICENSE

<h2>How to create PBOs</h2>

* Download and install hemtt from [here](https://github.com/BrettMayson/HEMTT)
* Open command terminal, navigate to said folder (Windows: cd 'insert path')
* Type "hemtt build" for pbo, "hemtt build --release" for entire release
