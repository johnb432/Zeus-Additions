#include "script_component.hpp"

/*
 * Author: johnb43
 * Spawns a module that allows Zeus to enable and disable AI turning out of vehicles.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_allowTurnOutAI;
 *
 * Public: No
 */

["Zeus Additions - AI", "[WIP] Allow AI to Turn Out", {
    params ["", "_object"];

    if (!(_object isKindOf "AllVehicles") || {(crew _object select {!isPlayer _x}) isEqualTo []}) exitWith {
        ["Select a vehicle with AI crew!"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    };

    ["Allow AI to Turn Out", [
        ["TOOLBOX:YESNO", ["Allow AI to Turn Out", "Makes the AI able to turn out or not."], true, false]
    ],
    {
        params ["_results", "_object"];
        _results params ["_allowTurnOut"];

        {
            if (!isPlayer _x) then {
                // Execute where AI is local
                [
                    [_x, _allowTurnOut],
                    {
                        params ["_unit", "_allowTurnOut"];

                        _unit enableAIFeature ["AUTOCOMBAT", _allowTurnOut];
                        _unit setCombatBehaviour (["COMBAT", "SAFE"] select _allowTurnOut);
                    }
                ] remoteExecCall ["call", _x];
            };
        } forEach (crew _object);

        ["Changed turning out ability on AI crew members"] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _object] call zen_dialog_fnc_create;
}, ICON_TRUCK] call zen_custom_modules_fnc_register;
