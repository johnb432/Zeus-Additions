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

["Zeus Additions - AI", "Change AI Dismount Behaviour", {
    params ["", "_object"];

    if (!(_object isKindOf "AllVehicles") || {isNull (driver _object)}) exitWith {
        ["Select a vehicle!"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    };

    ["Change AI dismounting behaviour", [
        ["TOOLBOX:ENABLED", ["Passenger dismount in combat", "Allow passengers to dismount while in combat."], false],
        ["TOOLBOX:ENABLED", ["Crew dismount in combat", "Allow crews to dismount while in combat."], false],
        ["TOOLBOX:ENABLED", ["Crew stay in immobile vehicles", "Allow crews to stay in immobile vehicles."], false]
    ],
    {
        params ["_results", "_object"];
        _results params ["_dismountPassengers", "_dismountCrew", "_stayCrew"];

        _object setUnloadInCombat [_dismountPassengers, _dismountCrew];
        _object allowCrewInImmobile _stayCrew;

        ["Changed dismount behaviour on vehicle"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _object] call zen_dialog_fnc_create;
}, ICON_TRUCK] call zen_custom_modules_fnc_register;

["Zeus Additions - AI", "[WIP] Change AI Mine Detecting Behaviour", {
    params ["", "_unit"];

    ["[WIP] Change AI Mine Detecting Behaviour (broken?)", [
        ["SIDES", ["AI selected", "Select AI from the list to change mine detection capabilities."], []],
        ["TOOLBOX:YESNO", ["Include Group", "Includes the entire group of the AI on which the module was placed."], false],
        ["TOOLBOX:YESNO", ["Allow AI to detect mines", "You can either disable or reenable mine detection."], false]
    ],
    {
        params ["_results", "_unit"];
        _results params ["_sides", "_doGroup", "_allowMinedetection"];

        if (_sides isEqualTo [] && {isNull _unit}) exitWith {
            ["Select a side!"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        };

        private _function = ["zen_common_disableAI", "zen_common_enableAI"] select _allowMinedetection;

        if (isNull _unit) then {
            {
                {
                    if (!isPlayer _x) then {
                        [_function, [_x, "MINEDETECTION"], _x] call CBA_fnc_targetEvent;
                    };
                } forEach (units _x);
            } forEach _sides;

            ["Changed mine detecting behaviour"] call zen_common_fnc_showMessage;
        } else {
            if (_doGroup) exitWith {
                {
                    if (!isPlayer _x) then {
                        [_function, [_x, "MINEDETECTION"], _x] call CBA_fnc_targetEvent;
                    };
                } forEach (units (group _unit));

                ["Changed mine detecting behaviour on group"] call zen_common_fnc_showMessage;
            };

            if (!isPlayer _unit) then {
                [_function, [_unit, "MINEDETECTION"], _unit] call CBA_fnc_targetEvent;
                ["Changed mine detecting behaviour on unit"] call zen_common_fnc_showMessage;
            } else {
                ["Select an AI unit!"] call zen_common_fnc_showMessage;
                playSound "FD_Start_F";
            };
        };
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _unit] call zen_dialog_fnc_create;
}, ICON_EXPLOSION] call zen_custom_modules_fnc_register;
