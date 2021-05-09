Zeus Additions
<h3>README</h3>

Adds a handful of modules to the Zeus interface. Requires ZEN.

<h3>HOW TO</h3>
<h4>Modules</h4>

* **Change AI dismounting behaviour:** Can prevent AI from dismounting in combat and also when their vehicle is immobilized.
* **Change AI mine detecting behaviour:** Theoretically should change their ability to detect mines. However in practice it doesn't seem to do anything, so feedback and more work is needed.
* **Change grass rendering:** Allows the Zeus to change grass rendering on clients. Use Low (Off) to turn off grass completely, Standard is recommended if you wish to turn it on (The others are there in case you want to use them).
* **Create injuries:** Allows the Zeus to create injuries on any types of unit, be it AI or players. When applied to players, it will notify the player in question that they have been injured. This is to avoid abuse.
* **Create random injuries:** Creates random wounds, taking a damage value and type you are able to set.
* **Disable Channels:** Allows the Zeus to disable specific channels, both writing and VON.
* **End mission with player modifier:** Ends the mission with all player having the chosen modifier applied to them. You can choose if it's a mission fail or success and the modifier, but nothing else.
* **Force consciousness change:** Allows the Zeus to toggle a unit's consciousness state. This disregards any wake up conditions such as stable vitals.
* **Force delete object:** Allows the Zeus to delete an object when he gets the "insufficient resources" error when trying to delete an object.
* **Give death stare ability:** If used this module grants the chosen unit to have a "death stare". The unit uses an ACE self-interaction whilst looking at the desired target. The result of the action will the inducing pain the target and doing some sort of harm, depending on the settings.
* **Loadout: Apply to group:** Applies a predetermined loadout to the entire group of unit that the module was placed on. It will try to apply various loadouts based on their roles (it will try at least, as there no good way of determining an exact role it isn't very precise).
* **Loadout: Apply to single unit:** Applies a predetermined loadout to a single unit. If that loadout isn't defined, it will fall back onto the group defined loadouts.
* **Loadout: Set:** Allows you to set loadouts for the "Loadout: Apply to group" and "Loadout: Apply to single unit" modules. These are saved on a profile basis, which means they stick around, allowing you to use them on various servers.
* **Lock building doors:** Allows the Zeus to set doors on a building to be locked, unlocked or locked and breachable. You can define your own explosives that are needed for breaching.
* **Open ACE Medical Menu:** Allows the Zeus to open a unit's medical menu more easily.
* **Pause time:** Allows the Zeus to nearly stop time. It sets time acceleration to a minimum and reverts time every 100 seconds.
* **Paradrop units:** Allows the Zeus to have units and vehicles be paradropped.
* **Prevent vehicle from blowing up:** This module makes vehicles not able to blow up, but still allows them to take damage.
* **Set player modifier at mission end:** ***RECOMMEND PLACING THIS MODULE ONLY NEAR MISSION END.*** It checks every frame if the end screen has popped up, which can be performance consuming.
* **Spawn Ammo Resupply Crate:** Spawns a magazine resupply crate using lists predefined in the CBA settings.
* **Spawn Ammo Resupply for unit:** Spawns a magazine resupply crate using the unit's weapons. The unit is either chosen by placing the module on the unit or the choosing a player from the menu. If multiple players are chosen from the menu, only the chronologically first selected one will be used. If the module is placed on a unit and you choose a player from the menu, the menu selection will take priority. It can use a blacklist which can be defined in the CBA settings. Future support for direct access to the FK blacklist is being waited on, as the FK framework has to update.
* **Spawn Medical Resupply Crate:** Spawns a medical resupply crate
* **TFAR Radio Range Multiplier:** Allows the Zeus to change radio transmission distances.
* **Toggle Snow Script:** Allows the Zeus to apply a snow script to players.

**Numerous CBA settings to customize modules:** To change them, go to Options -> Addon Options -> Zeus Additions - Main

  Inputs are arrays of strings.
  * **Blacklist:** Allows the user to set up a list of ammo that won't be put in the resupply using the "Spawn Ammo Resupply for unit" module.
  * **X Magazines:** Allows the user to set up custom arrays of ammunition to give to users using the "Spawn Ammo Resupply Crate" module.
  * **Enable automatic blacklist detection for FK servers:** FK is a gaming community.
  * **Enable leave unconscious unit:** Allows the user to leave an unconscious remote controlled unit when pressing the ESCAPE key. Handy for people who have their Zeus key bound to a double tap.
  * **Enable Snow Script missing addon hint:** If enabled, it will hint if CUP Core is missing.
  * **Enable TFAR missing addon hint:** If enabled, it will hint if TFAR is missing.

<h3>CREDITS</h3>

Mod by johnb43<br/>
[GitHub](https://github.com/johnb432/Zeus-Additions)

Gearscript originally made by cineafx, revamped by johnb43.
Snow script made by JW & AZCoder, reworked by johnb43.

Thanks to sh4rdknight for enduring testing sessions.

<h3>LICENSE</h3>
See LICENSE.txt

This mod is a client side mod, although some features will unlock if it's on the server too (such as JIP features for modules).

<h3>Known issues</h3>

* When tabbing out whilst having the snow script applied, it will lose the wind effect.
