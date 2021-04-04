#include "script_component.hpp"

/*
 * Author: johnb43
 * Creates modules that can change time acceleration.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_pauseTime
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

["Zeus Additions - Utility", "[WIP] Pause time", {
    ["[WIP] Pause time", [
        ["CHECKBOX", ["Pause time", "Sets time acceleration to a minimum and reverts time every 100s. Disable whilst skipping time."], true]
    ],
    {
        params ["_results"];
        _results params ["_setPaused"];

        private _string = "Time paused";

        if (_setPaused) then {
            if (isNil QGVAR(setTimeAcc)) then {
                // Get old time multiplier
                private _timeMult = timeMultiplier;
                0.1 remoteExecCall ["setTimeMultiplier", 2];

                [{
                    // Wait for new time multiplier to be active
                    timeMultiplier isNotEqualTo _this
                }, {
                    GVAR(setTimeAcc) = [{
                        params ["_args", "_handleID"];
                        _args params ["_startHours", "_startMinutes", "_startSeconds"];

                        if (timeMultiplier > 0.11) exitWith {
                            [_handleID] call CBA_fnc_removePerFrameHandler;
                            ["Removed time pause because time acceleration has been changed."] call zen_common_fnc_showMessage;
                            GVAR(setTimeAcc) = nil;
                        };

                        (([daytime] call BIS_fnc_timeToString) splitString ":") params ["_currentHours", "_currentMinutes", "_currentSeconds"];

                        private _deltaSec = (parseNumber _currentSeconds) - (parseNumber _startSeconds);

                        if ((((parseNumber _currentHours) - (parseNumber _startHours)) > 0 || {((parseNumber _currentMinutes) - (parseNumber _startMinutes)) > 0}) && {_deltaSec < 0}) then {
                            _deltaSec = _deltaSec + 60;
                        };

                        (-_deltaSec/3600) remoteExecCall ["skipTime", 0];
                    }, 100, ([daytime] call BIS_fnc_timeToString) splitString ":"] call CBA_fnc_addPerFrameHandler;
                }, _timeMult, 10, {}] call CBA_fnc_waitUntilAndExecute;
            } else {
                _string = "Time already paused!";
                playSound "FD_Start_F";
            };
        } else {
            if (!isNil QGVAR(setTimeAcc)) then {
                [GVAR(setTimeAcc)] call CBA_fnc_removePerFrameHandler;
                1 remoteExecCall ["setTimeMultiplier", 2];
                GVAR(setTimeAcc) = nil;
                _string = "Time resumed back to normal (1x)";
            } else {
                _string = "Time already normal (1x)!";
                playSound "FD_Start_F";
            };
        };

        [_string] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }, _unit] call zen_dialog_fnc_create;
}] call zen_custom_modules_fnc_register;
