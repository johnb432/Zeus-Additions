#include "..\script_component.hpp"
/*
 * Author: Kex (based on cobra4v320's AI HALO Jump script), johnb43
 * Adds a parachute to the unit if necessary, then deletes it once the unit is on the ground.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Position ATL <ARRAY>
 * 2: Give unit parachute <BOOL> (default: true)
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, (getPosATL player) vectorAdd [0, 0, 1000]] call zeus_additions_main_fnc_addParachute;
 *
 * Public: No
 */

params ["_unit", "_posATL", ["_giveUnitParachute", true]];

// Execute where unit is local
if (!local _unit) exitWith {
    [QGVAR(executeFunction), [QFUNC(addParachute), _this], _unit] call CBA_fnc_targetEvent;
};

// Hide unit during preparation
private _isObjectHidden = isObjectHidden _unit;

if (!_isObjectHidden) then {
    ["zen_common_hideObjectGlobal", [_unit, true]] call CBA_fnc_serverEvent;
};

private _showTransition = _unit == call CBA_fnc_currentUnit;

// If not player controlled, don't do transition screen or inform about paradrop
if (_showTransition) then {
    cutText ["You are being paradropped...", "BLACK OUT", 2, true];
    hint "The parachute will automatically deploy if you haven't deployed it before reaching 150m above ground level. Your backpack will be returned upon landing.";
};

private _backpackClass = backpack _unit;
private _packHolder = objNull;

// If unit has a backpack, drop it
if (_backpackClass != "" && {_giveUnitParachute}) then {
    _packHolder = createVehicle ["GroundWeaponHolder", [0, 0, 0], [], 0, "CAN_COLLIDE"];

    // Add temp magazine, so that ground holder doesn't automatically get deleted
    _packHolder addMagazineCargo ["30Rnd_556x45_Stanag", 1];

    // Drop bag into weapon holder
    _unit action ["DropBag", _packHolder, _backpackClass];
};

[{
    // Wait until unit has dropped its backpack
    params ["_unit", "", "_giveUnitParachute"];

    backpack _unit == "" || {!_giveUnitParachute}
}, {
    params ["", "", "", "", "_packHolder"];

    // Remove temp magazine
    _packHolder addMagazineCargo ["30Rnd_556x45_Stanag", -1];

    [{
        params ["_unit", "_posATL", "_giveUnitParachute", "_backpackClass", "_packHolder", "_isObjectHidden", "_showTransition"];

        _unit setPosATL _posATL;

        if (_showTransition) then {
            cutText ["", "BLACK IN", 2, true];
        };

        // Unhide unit
        if (!_isObjectHidden) then {
            ["zen_common_hideObjectGlobal", [_unit, false]] call CBA_fnc_serverEvent;
        };

        [{
            // Wait until the unit is <150m AGL or dead
            (getPos _this) select 2 < 150 || {!alive _this}
        }, {
            // If parachute is already open or unit is unconscious or dead, don't deploy parachute
            if ((((objectParent _this) call BIS_fnc_objectType) select 1) == "Parachute" || {!((lifeState _this) in ["HEALTHY", "INJURED"])}) exitWith {};

            _this action ["OpenParachute", _this];
        }, _unit] call CBA_fnc_waitUntilAndExecute;

        // Monitor unit
        if (!_giveUnitParachute) exitWith {
            [{
                // Wait until unit is on ground or dead
                isTouchingGround _this || {(getPos _this) select 2 < 1} || {!alive _this}
            }, {
                // Unit is no longer paradropping
                _this setVariable [QGVAR(isParadropping), nil, true];
            }, _unit] call CBA_fnc_waitUntilAndExecute;
        };

        // If the unit doesn't have a backpack, give one to unit
        if (_backpackClass == "") exitWith {
            // If the unit had no backpack, just add parachute
            _unit addBackpack "B_Parachute";

            [{
                // Wait until unit is on ground or dead
                isTouchingGround _this || {(getPos _this) select 2 < 1} || {!alive _this}
            }, {
                // Remove parachute
                removeBackpack _this;

                // Unit is no longer paradropping
                _this setVariable [QGVAR(isParadropping), nil, true];
            }, _unit] call CBA_fnc_waitUntilAndExecute;
        };

        // If the unit already has a chute, exit
        if (getText (configFile >> "CfgVehicles" >> _backpackClass >> "parachuteClass") != "") exitWith {};

        _unit addBackpack "B_Parachute";

        [{
            // Wait until unit has changed into free fall animation
            params ["_unit"];
            (getUnitFreefallInfo _unit) params ["_isFalling", "_isInFreeFallPose"];

            !alive _unit || {_isFalling && {_isInFreeFallPose}}
        }, {
            params ["_unit", "_packHolder"];

            // Add old backpack model to the front of the player and attach it there
            _packHolder attachTo [_unit, [-0.12, -0.02, -0.74], "pelvis"];

            // Remove from JIP if object is deleted
            [["zen_common_setVectorDirAndUp", [_packHolder, [[0, -1, -0.05], [0, 0, -1]]], QGVAR(parachute_) + hashValue _packHolder] call CBA_fnc_globalEventJIP, _packHolder] call CBA_fnc_removeGlobalEventJIP;

            [{
                // Wait until unit has deployed parachute or crashed or is dead
                params ["_unit"];
                (getUnitFreefallInfo _unit) params ["_isFalling", "_isInFreeFallPose"];

                !alive _unit || {_isFalling && {!_isInFreeFallPose}} || {isTouchingGround _unit} || {(getPos _unit) select 2 < 1}
            }, {
                params ["_unit", "_packHolder"];

                // Change attaching position of the backpack
                _packHolder attachTo [vehicle _unit, [-0.07, 0.67, -0.13]];
                ["zen_common_setVectorDirAndUp", [_packHolder, [[0, -0.2, -1], [0, 1, 0]]], QGVAR(parachute_) + hashValue _packHolder] call CBA_fnc_globalEventJIP;

                [{
                    // Wait until unit has landed or is dead
                    params ["_unit"];

                    !alive _unit || {isTouchingGround _unit} || {(getPos _unit) select 2 < 1}
                }, {
                    params ["_unit", "_packHolder", "_backpackClass"];

                    // Reattach to fix buggy behaviour
                    _packHolder attachTo [_unit, [-0.07, 0.67, -0.13], "pelvis", true];
                    ["zen_common_setVectorDirAndUp", [_packHolder, [[0, -0.2, -1], [0, 1, 0]]], QGVAR(parachute_) + hashValue _packHolder] call CBA_fnc_globalEventJIP;

                    // Unit is no longer paradropping
                    _unit setVariable [QGVAR(isParadropping), nil, true];

                    if (!alive _unit) exitWith {};

                    // Remove parachute
                    removeBackpack _unit;

                    // Pick up old bag
                    _unit action ["AddBag", _packHolder, _backpackClass];

                    // Try picking up bag until success
                    [{
                        (_this select 0) params ["_unit", "_packHolder", "_backpackClass"];

                        _unit action ["AddBag", _packHolder, _backpackClass];

                        // Wait until the backpack has been picked up
                        if (backpack _unit != _backpackClass) exitWith {};

                        // Stop checking loop
                        (_this select 1) call CBA_fnc_removePerFrameHandler;
                    }, 1, [_unit, _packHolder, _backpackClass]] call CBA_fnc_addPerFrameHandler;
                }, _this] call CBA_fnc_waitUntilAndExecute;
            }, _this] call CBA_fnc_waitUntilAndExecute;
        }, [_unit, _packHolder, _backpackClass]] call CBA_fnc_waitUntilAndExecute;
    }, _this, 2] call CBA_fnc_waitAndExecute;
}, [_unit, _posATL, _giveUnitParachute, _backpackClass, _packHolder, _isObjectHidden, _showTransition]] call CBA_fnc_waitUntilAndExecute;
