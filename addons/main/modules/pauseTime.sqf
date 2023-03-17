/*
 * Author: johnb43
 * Creates modules that can change time acceleration.
 */

["Zeus Additions - Utility", "Pause Time", {
    ["Pause time", [
        ["TOOLBOX:YESNO", ["Time is paused", "Sets time acceleration to a minimum and reverts time every 100s. Disable whilst skipping time."], !isNil {GETMVAR(QGVAR(setTimeAcc),nil)}, true]
    ], {
        params ["_results"];

        private _string = if (_results select 0) then {
            if (isNil {GETMVAR(QGVAR(setTimeAcc),nil)}) then {
                ["zen_common_execute", [{
                    // Set time to slowest possible
                    setTimeMultiplier 0.1;

                    private _pfhID = GETMVAR(QGVAR(setTimeAcc),nil);

                    if (!isNil "_pfhID") exitWith {};

                    _pfhID = [{
                        params ["_startTime", "_pfhID"];

                        private _deltaTime = dayTime - _startTime;

                        // Check if a day has passed
                        if (_deltaTime < 0) then {
                            _deltaTime = _deltaTime + 24;
                        };

                        // If time acceleration has been changed or more than 15 seconds have gone by in game, stop
                        if (timeMultiplier > 0.1 || {(abs _deltaTime) >= (15 / 3600)}) exitWith {
                            _pfhID call CBA_fnc_removePerFrameHandler;

                            SETMVAR(QGVAR(setTimeAcc),nil,true);

                            ["[Zeus Additions]: Unpaused time because time acceleration has been changed."] remoteExecCall ["zen_common_fnc_showMessage", allCurators];
                        };

                        // Revert time
                        -_deltaTime remoteExecCall ["skipTime", 0];
                    }, 100, dayTime] call CBA_fnc_addPerFrameHandler;

                    SETMVAR(QGVAR(setTimeAcc),_pfhID,true);
                }, []]] call CBA_fnc_serverEvent;

                "Time paused"
            } else {
                "Time already paused"
            };
        } else {
            private _pfhID = GETMVAR(QGVAR(setTimeAcc),nil);

            if (!isNil "_pfhID") then {
                // Set everything back to normal
                ["zen_common_execute", [{
                    _this call CBA_fnc_removePerFrameHandler;
                    setTimeMultiplier 1;

                    SETMVAR(QGVAR(setTimeAcc),nil,true);
                }, _pfhID]] call CBA_fnc_serverEvent;

                "Time reverted back to normal (1x)"
            } else {
                "Time already normal (1x)"
            };
        };

        [_string] call zen_common_fnc_showMessage;
    }] call zen_dialog_fnc_create;
}, ICON_TIME] call zen_custom_modules_fnc_register;
