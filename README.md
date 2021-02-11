# Changelog for Zeus Additions 11.2.2021

- Fixed and updated gear script modules to work better

# Changelog for Zeus Additions 7.2.2021

- Initial release


---


Zeus Additions
<h3>README</h3>

Adds a handful of modules to the Zeus interface. Requires ZEN.

<h3>HOW TO</h3>
<h4>Modules</h4>

* **Create Injuries:** Allows the Zeus to create injuries on any types of unit, be it AI or players. When applied to players, it will notify the player in question that they have been injured. This is to avoid abuse.
* **Loadout: Apply to group:** Applies a predetermined loadout to the entire group of unit that the module was placed on. It will try to apply various loadouts based on their roles (it will try at least, as there no good way of determining an exact role it isn't very precise).
* **Loadout: Apply to single unit:** Applies a predetermined loadout to a single unit. If that loadout isn't defined, it will fall back onto the group defined loadouts.
* **Loadout: Set:** Allows you to set loadouts for the "Loadout: Apply to group" and "Loadout: Apply to single unit" modules. These are saved on a profile basis, which means they stick around, allowing you to use them on various servers.
* **Spawn Ammo Resupply Crate:** Spawns a magazine resupply crate using lists predefined in the CBA settings.
* **Spawn Ammo Resupply for unit:** Spawns a magazine resupply crate using the unit's weapons. The unit is either chosen by placing the module on the unit or the choosing a player from the menu. If multiple players are chosen from the menu, only the chronologically first selected one will be used. If the module is placed on a unit and you choose a player from the menu, the menu selection will take priority. It can use a blacklist which can be defined in the CBA settings. Future support for direct access to the FK blacklist is being waited on, as the FK framework has to update.
* **Spawn Medical Resupply Crate:** Spawns a medical resupply crate

**Numerous CBA settings to customize modules:** To change them, go to Options -> Addon Options -> Zeus Additions - Main

  Inputs are arrays of strings.
  * **Blacklist:** Allows the user to set up a list of ammo that won't be put in the resupply using the "Spawn Ammo Resupply for unit" module.
  * **X Magazines:** Allows the user to set up custom arrays of ammunition to give to users using the "Spawn Ammo Resupply Crate" module.

<h3>CREDITS</h3>

Mod by johnb43<br/>
[GitHub](https://github.com/johnb432/Zeus-Additions)
