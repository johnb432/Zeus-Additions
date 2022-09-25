#include "script_component.hpp"

/*
 * Author: Kex (based on cobra4v320's AI HALO Jump script), johnb43
 * Adds a parachute to the unit (if necessary), then deletes it once the unit is on the ground.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Give unit parachute <BOOLEAN>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, true] call zeus_additions_main_fnc_addParachute;
 *
 * Public: No
 */

params ["_unit", "_giveUnitParachute"];

// If the units is <100m AGL, deploy parachute to prevent them splatting on the ground
[{
    (getPos _this) select 2 < 100 || {!alive _this}
}, {
    // If parachute is already open or unit is unconscious or dead, don't do action
    if ((((objectParent _this) call BIS_fnc_objectType) select 1) == "Parachute" || {_this getVariable ["ACE_isUnconscious", false] || {(lifeState _this) == "INCAPACITATED" || {!alive _this}}}) exitWith {};

    _this action ["OpenParachute", _this];
}, _unit] call CBA_fnc_waitUntilAndExecute;

if (!_giveUnitParachute) exitWith {};

private _backpackClass = backpack _unit;

// If the unit already has a chute, exit
if (getText (configFile >> "CfgVehicles" >> _backpackClass >> "backpackSimulation") == "ParachuteSteerable") exitWith {};

// If the unit doesn't have a chute, give one to unit
if (_backpackClass != "") then {
    // This script does not account for backpacks within backpacks
    private _container = backpackContainer _unit;
    private _packHolder = createVehicle ["groundWeaponHolder", [0, 0, 0], [], 0, "CAN_COLLIDE"];
    _packHolder addBackpackCargoGlobal [_backpackClass, 1];

    // If player has changes into free fall animation, add old backpack model to the front of the player and attach it there
    [{
        params ["_unit"];
        (getUnitFreefallInfo _unit) params ["_isFalling", "_isInFreeFallPose"];

        !alive _unit || {_isFalling && {_isInFreeFallPose}}
    }, {
        params ["_unit", "_packHolder"];

        _packHolder attachTo [_unit, [-0.12, -0.02, -0.74], "pelvis"];
        _packHolder setVectorDirAndUp [[0, -1, -0.05], [0, 0, -1]];

        // If unit has deployed parachute (or has crashed, but survived), change attaching position of the backpack
        [{
            params ["_unit"];
            (getUnitFreefallInfo _unit) params ["_isFalling", "_isInFreeFallPose"];

            !alive _unit || {_isFalling && {!_isInFreeFallPose}} || {isTouchingGround _unit} || {(getPos _unit) select 2 < 1}
        }, {
            params ["_unit", "_packHolder"];

            _packHolder attachTo [vehicle _unit, [-0.07, 0.67, -0.13], "pelvis"];
            _packHolder setVectorDirAndUp [[0, -0.2, -1], [0, 1, 0]];

            // When unit lands, remove parachute as well as backpack displayed on the unit's front and add old backpack on unit's back
            [{
                params ["_unit"];

                !alive _unit || {isTouchingGround _unit} || {(getPos _unit) select 2 < 1}
            }, {
                params ["_unit", "_packHolder", "_backpackClass", "_weaponItemsCargo", "_magazinesAmmoCargo", "_itemCargo"];
                _itemCargo params ["_items", "_itemsCount"];

                // Unit is no longer paradropping
                _unit setVariable [QGVAR(isParadropping), nil, true];

                removeBackpack _unit;
                deleteVehicle _packHolder;

                // Add old backpack, make sure to remove any linked items in class
                _unit addBackpack _backpackClass;
                clearAllItemsFromBackpack _unit;

                // Add all old items back
                private _container = backpackContainer _unit;

                {
                    _container addWeaponWithAttachmentsCargoGlobal [_x, 1];
                } forEach _weaponItemsCargo;

                {
                    _container addMagazineAmmoCargo [_x select 0, 1, _x select 1];
                } forEach _magazinesAmmoCargo;

                {
                    _container addItemCargoGlobal [_x, _itemsCount select _forEachIndex];
                } forEach _items;
            }, _this] call CBA_fnc_waitUntilAndExecute;
        }, _this] call CBA_fnc_waitUntilAndExecute;
    }, [_unit, _packHolder, _backpackClass, weaponsItemsCargo _container, magazinesAmmoCargo _container, getItemCargo _container]] call CBA_fnc_waitUntilAndExecute;

    // Add parachute to unit
    removeBackpack _unit;
    _unit addBackpack "B_Parachute";
} else {
     // If the unit has no backpack, just wait until he lands and remove it
     _unit addBackpack "B_Parachute";

     [{isTouchingGround _this || {(getPos _this) select 2 < 1} || {!alive _this}}, {
         removeBackpack _this;

         // Unit is no longer paradropping
         _this setVariable [QGVAR(isParadropping), nil, true];
     }, _unit] call CBA_fnc_waitUntilAndExecute;
};
