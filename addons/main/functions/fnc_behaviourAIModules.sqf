#include "script_component.hpp"

/*
 * Author: johnb43
 * Creates modules that can change dismount and mine detecting behaviour on AI.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_behaviourAIModules;
 *
 * Public: No
 */

["Zeus Additions - AI", "[WIP] Change AI dismounting behaviour", {
    params ["", "_unit"];

    if (isNull _unit) exitWith {
        ["Select a unit!"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    };

    ["Change AI dismounting behaviour", [
        ["CHECKBOX", ["Allow passengers to dismount in combat", "Allow passengers to dismount while in combat."], false],
        ["CHECKBOX", ["Allow crew to dismount in combat", "Allow crews to dismount while in combat."], false],
        ["CHECKBOX", ["Allow crew to stay in immobile vehicles", "Allow crews to stay in immobile vehicles."], false]//,
        //["CHECKBOX", ["Force crew to stay in immobile vehicles", "Setting above must be turned on aswell to use this."], false]
    ],
    {
        params ["_results", "_unit"];
        _results params ["_dismountPassengers", "_dismountCrew", "_stayCrew"/*, "_forceStayCrew"*/];
        private _vehicle = vehicle _unit;

        _vehicle setUnloadInCombat [_dismountPassengers, _dismountCrew];
        _vehicle allowCrewInImmobile _stayCrew;

        // If they are forced to stay mounted, disable the "FSM" feature
        /*
        {
            _x enableAIFeature ["FSM", !_forceStayCrew];
        } forEach (crew _vehicle);
        */
        ["Changed dismount behaviour"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _unit] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;

["Zeus Additions - AI", "[WIP] Change AI mine detecting behaviour", {
    params ["", "_unit"];

    ["AI minedetecting capabilities (command doesn't seem to work though)", [
        ["SIDES", ["AI selected", "Select AI from the list to change mine detection capabilities."], east],
        ["CHECKBOX", ["Include Group", "Includes the entire group of the AI on which the module was placed."], false],
        ["CHECKBOX", ["Allow AI to detect mines", "You can either disable or reenable mine detection."], false]
    ],
    {
        params ["_results", "_unit"];
        _results params ["_side", "_doGroup", "_allowMinedetection"];

        if (_side isEqualTo "") exitWith {
            ["Select a side!"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        };

        if (isNull _unit) then {
            {
                if (!isPlayer _x) then {
                    [_x, ["MINEDETECTION", _allowMinedetection]] remoteExecCall ["enableAIFeature", _x];
                };
            } forEach (units _side);
        } else {
            if (_doGroup) exitWith {
                {
                    if (!isPlayer _x) then {
                        [_x, ["MINEDETECTION", _allowMinedetection]] remoteExecCall ["enableAIFeature", _x];
                    };
                } forEach (units (group _unit));
                ["Changed mine detecting behaviour on group"] call zen_common_fnc_showMessage;
            };

            [_unit, ["MINEDETECTION", _allowMinedetection]] remoteExecCall ["enableAIFeature", _unit];
            ["Changed mine detecting behaviour on unit"] call zen_common_fnc_showMessage;
        };

        ["Changed mine detecting behaviour"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _unit] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;
