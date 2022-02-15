/*
 * Author: johnb43
 * Creates modules that can change time acceleration.
 */

["Zeus Additions - Utility", "Pause Time", {
    ["Pause time", [
        ["TOOLBOX:ENABLED", ["Pause Time", "Sets time acceleration to a minimum and reverts time every 100s. Disable whilst skipping time."], false]
    ],
    {
        params ["_results"];

        private _string = if (_results select 0) then {
            if (isNil {GETMVAR(QGVAR(setTimeAcc),nil)}) then {
                // Get old time multiplier
                private _timeMult = timeMultiplier;
                0.1 remoteExecCall ["setTimeMultiplier", 2];

                ["zen_common_execute", [{
                    [{
                        // Wait for new time multiplier to be active
                        timeMultiplier isNotEqualTo _this;
                    }, {

                        private _pfhID = [{
                            params ["_startSeconds", "_pfhID"];

                            // If time acceleration has been changed, stop
                            if (timeMultiplier > 0.11) exitWith {
                                _pfhID call CBA_fnc_removePerFrameHandler;

                                SETMVAR(QGVAR(setTimeAcc),nil,true);

                                ["[Zeus Additions]: Unpaused time because time acceleration has been changed!"] remoteExecCall ["zen_common_fnc_showMessage", allCurators];
                            };

                            // Looking just at the seconds is enough
                            private _deltaSec = (parseNumber ((([] call BIS_fnc_timeToString) splitString ":") select 2)) - (parseNumber _startSeconds);

                            if (_deltaSec < 0) then {
                                _deltaSec = _deltaSec + 60;
                            };

                            (-_deltaSec / 3600) remoteExecCall ["skipTime", 0];
                        }, 100, (([] call BIS_fnc_timeToString) splitString ":") select 2] call CBA_fnc_addPerFrameHandler;

                        SETMVAR(QGVAR(setTimeAcc),_pfhID,true);
                    }, _this, 10] call CBA_fnc_waitUntilAndExecute;
                }, _timeMult]] call CBA_fnc_serverEvent;

                "Time paused";
            } else {
                playSound "FD_Start_F";
                "Time already paused!";
            };
        } else {
            private _pfhID = GETMVAR(QGVAR(setTimeAcc),nil);

            if (!isNil "_pfhID") then {
                _pfhID remoteExecCall ["CBA_fnc_removePerFrameHandler", 2];
                1 remoteExecCall ["setTimeMultiplier", 2];

                SETMVAR(QGVAR(setTimeAcc),nil,true);

                "Time reverted back to normal (1x)";
            } else {
                playSound "FD_Start_F";
                "Time already normal (1x)!";
            };
        };

        [_string] call zen_common_fnc_showMessage;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }] call zen_dialog_fnc_create;
}, ICON_TIME] call zen_custom_modules_fnc_register;
