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

["Zeus Additions - Utility", "Pause Time", {
    ["Pause time", [
        ["TOOLBOX:ENABLED", ["Pause Time", "Sets time acceleration to a minimum and reverts time every 100s. Disable whilst skipping time."], false]
    ],
    {
        params ["_results"];
        _results params ["_setPaused"];

        private _string = "Time paused";

        if (_setPaused) then {
            if (isNil {missionNamespace getVariable QGVAR(setTimeAcc)}) then {
                // Get old time multiplier
                private _timeMult = timeMultiplier;
                0.1 remoteExecCall ["setTimeMultiplier", 2];

                // Do on server in case client disconnects
                ["zen_common_execute", [
                    CBA_fnc_waitUntilAndExecute, [
                        {
                            // Wait for new time multiplier to be active
                            timeMultiplier isNotEqualTo _this;
                        }, {
                            missionNamespace setVariable [QGVAR(setTimeAcc),
                                [{
                                    params ["_startSeconds", "_handleID"];

                                    // If time acceleration has been changed, stop
                                    if (timeMultiplier > 0.11) exitWith {
                                        _handleID call CBA_fnc_removePerFrameHandler;

                                        missionNamespace setVariable [QGVAR(setTimeAcc), nil, true];

                                        ["zen_common_execute", [zen_common_fnc_showMessage, ["[Zeus Additions]: Unpaused time because time acceleration has been changed."]], allCurators] call CBA_fnc_targetEvent;
                                    };

                                    // Looking just at the seconds is enough
                                    private _deltaSec = (parseNumber ((([daytime] call BIS_fnc_timeToString) splitString ":") select 2)) - (parseNumber _startSeconds);

                                    if (_deltaSec < 0) then {
                                        _deltaSec = _deltaSec + 60;
                                    };

                                    (-_deltaSec / 3600) remoteExecCall ["skipTime", 0];
                                }, 100, (([daytime] call BIS_fnc_timeToString) splitString ":") select 2] call CBA_fnc_addPerFrameHandler, true
                            ];
                        }, _timeMult, 10
                    ]
                ]] call CBA_fnc_serverEvent;
            } else {
                _string = "Time already paused!";
                playSound "FD_Start_F";
            };
        } else {
            if (!isNil {missionNamespace getVariable QGVAR(setTimeAcc)}) then {
                (missionNamespace getVariable QGVAR(setTimeAcc)) call CBA_fnc_removePerFrameHandler;

                1 remoteExecCall ["setTimeMultiplier", 2];

                missionNamespace setVariable [QGVAR(setTimeAcc), nil, true];

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
    }] call zen_dialog_fnc_create;
}, ICON_TIME] call zen_custom_modules_fnc_register;
