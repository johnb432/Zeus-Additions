#include "..\script_component.hpp"
/*
 * Author: johnb43
 * Allows the Zeus to switch places with the selected AI unit.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * cursorTarget call zeus_additions_main_fnc_switchUnitStart;
 *
 * Public: No
 */

params ["_unit"];

_unit = effectiveCommander _unit;

if (isNull _unit) exitWith {
    ["str_a3_cfgvehicles_moduleremotecontrol_f_errorNull"] call zen_common_fnc_showMessage;
};

if (!alive _unit) exitWith {
    ["str_a3_cfgvehicles_moduleremotecontrol_f_errorDestroyed"] call zen_common_fnc_showMessage;
};

if (isPlayer _unit) exitWith {
    ["str_a3_cfgvehicles_moduleremotecontrol_f_errorPlayer"] call zen_common_fnc_showMessage;
};

if !((side group _unit) in [west, east, independent, civilian]) exitWith {
    ["str_a3_cfgvehicles_moduleremotecontrol_f_errorEmpty"] call zen_common_fnc_showMessage;
};

private _owner = _unit getVariable ["BIS_fnc_moduleRemoteControl_owner", objNull];

if ((!isNull _owner && {_owner in allPlayers}) || {isUAVConnected vehicle _unit}) exitWith {
    ["str_a3_cfgvehicles_moduleremotecontrol_f_errorControl"] call zen_common_fnc_showMessage;
};

if (unitIsUAV _unit) exitWith {
    [LSTRING(switchUnitUAVError)] call zen_common_fnc_showMessage;
};

// Save old player object
private _oldPlayer = player;
BIS_fnc_moduleRemoteControl_unit = _unit;
_unit setVariable ["BIS_fnc_moduleRemoteControl_owner", _oldPlayer, true];

GVAR(switchUnitArgs) = [_oldPlayer, _unit, isDamageAllowed _oldPlayer];

private _group = group _unit;
private _groupID = groupId _unit;
private _teamColor = assignedTeam _unit;

// Make unit local
if (!local _unit) then {
    ["zen_common_execute", [{
        params ["_clientOwner", "_unit", "_group", "_groupID", "_teamColor"];

        // If ownership was transferred successfully, quit
        if (_group setGroupOwner _clientOwner) exitWith {};

        // If unit still isn't local, try other solutions
        if ((count units _unit) > 1) then {
            // Create temp group if not alone
            _unit joinAsSilent [createGroup [side _unit, true], _groupID];
            _unit assignTeam _teamColor;
        } else {
            // Just change locality if alone
            _unit setOwner _clientOwner;
        };
    } call FUNC(sanitiseFunction), [clientOwner, _unit, _group, _groupID, _teamColor]]] call CBA_fnc_serverEvent;
};

[{
    // Wait until unit is local
    local (_this select 0)
}, {
    params ["_unit", "_oldPlayer", "_group", "_groupID", "_teamColor"];

    // Sometimes the unit that is being switched to gets teleported into the air; These are measures to prevent that
    private _pos = getPosASL _unit;

    // Start remote controlling
    selectPlayer _unit;

    // Freeze the old unit & Disable damage until Zeus has control of unit again; AI will take over and do dumb stuff
    _oldPlayer disableAI "ALL";
    _oldPlayer enableAI "ANIM";
    _oldPlayer allowDamage false;

    // If new group had to be created to change locality, add to old group
    if ((group _unit) != _group) then {
        _unit joinAsSilent [_group, _groupID];
        _unit assignTeam _teamColor;
    };

    [{
        // Wait until the Zeus interface is closed
        isNull (findDisplay IDD_RSCDISPLAYCURATOR)
    }, {
        params ["", "_unit"];

        // Check after we have taken over new unit whether it has been teleported; Randomly does that sometimes (could be locality issue)
        [{
            params ["_pos", "_unit"];

            if (isNull objectParent _unit && {_pos distance (getPosASL _unit) > 1}) then {
                _unit setPosASL _pos;
            };
        }, _this, 0.25] call CBA_fnc_waitAndExecute;

        GVAR(switchUnitArgs) append [
            addUserActionEventHandler ["curatorInterface", "Activate", FUNC(switchUnitStop)],
            // For getting out of unconscious units when ACE is loaded
            [{
                if (isNil "ace_common_keyboardInputMain") exitWith {};

                {
                    _x params ["_mainKeyArray", "_comboKeyArray", "_isDoubleTap"];
                    _mainKeyArray params ["_mainDik", "_mainDevice"];

                    // If keybind doesn't contain key combo, it returns empty array; Therefore, return true
                    _comboDikPressed = if (_comboKeyArray isEqualTo []) then {
                        true
                    } else {
                        _comboKeyArray params ["_comboDik", "_comboDevice"];

                        _comboDevice == "KEYBOARD" && {ace_common_keyboardInputMain getOrDefault [_comboDik, false]}
                    };

                    // Check if the necessary keys were pressed for a keybind
                    if (_comboDikPressed &&
                        {_mainDevice == "KEYBOARD"} &&
                        {((ace_common_keyboardInputMain getOrDefault [_mainDik, [false, 0]]) select 1) > ([0, 1] select _isDoubleTap)} // check how many times the main key was pressed
                    ) exitWith {
                        call FUNC(switchUnitStop);
                    };
                } forEach (actionKeysEx "CuratorInterface");
            }, 0.1, []] call CBA_fnc_addPerFrameHandler,
            if (!isNil "ace_medical_status") then {
                ["ace_medical_death", {
                    params ["_unit"];

                    if (_unit != player) exitWith {};

                    call FUNC(switchUnitStop);
                }] call CBA_fnc_addEventHandler
            } else {
                _unit addEventHandler ["HandleDamage", {
                    params ["", "", "_damage", "", "", "", "", "_hitPoint"];

                    if (_damage >= 1 && {_hitPoint isEqualTo ""}) then {
                        call FUNC(switchUnitStop);
                    };
                }]
            }
        ];
    }, [_pos, _unit]] call CBA_fnc_waitUntilAndExecute;
}, [_unit, _oldPlayer, _group, _groupID, _teamColor], 5, {
    // If locality failed to be transferred after 5s, quit
    (_this select 0) setVariable ["BIS_fnc_moduleRemoteControl_owner", nil, true];

    GVAR(switchUnitArgs) = nil;
    BIS_fnc_moduleRemoteControl_unit = nil;

    [LSTRING(switchUnitFailed)] call zen_common_fnc_showMessage;
}] call CBA_fnc_waitUntilAndExecute;
