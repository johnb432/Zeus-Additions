/*
 * Author: johnb43
 * Creates modules that can change time acceleration.
 */

[LSTRING(moduleCategoryUtility), LSTRING(pauseTimeModuleName), {
    [LSTRING(pauseTimeModuleName), [
        ["TOOLBOX:YESNO", [LSTRING(enableTimePause), LSTRING(enableTimePauseDesc)], !isNil QGVAR(setTimeAcc), true]
    ], {
        params ["_results"];

        private _string = if (_results select 0) then {
            if (isNil QGVAR(setTimeAccPfhID)) then {
                ["zen_common_execute", [{
                    if (!isNil QGVAR(setTimeAccPfhID)) exitWith {};

                    // Set time to slowest possible
                    setTimeMultiplier 0.1;

                    GVAR(setTimeAccPfhID) = [{
                        private _deltaTime = dayTime - (_this select 0);

                        // Check if a day has passed
                        if (_deltaTime < 0) then {
                            _deltaTime = _deltaTime + 24;
                        };

                        // If time acceleration has been changed or more than 15 seconds have gone by in game, stop
                        if (timeMultiplier > 0.1 || {(abs _deltaTime) >= (15 / 3600)}) exitWith {
                            (_this select 1) call CBA_fnc_removePerFrameHandler;

                            GVAR(setTimeAccPfhID) = nil;
                            publicVariable QGVAR(setTimeAccPfhID);

                            ["[Zeus Additions]: Unpaused time because time acceleration has been changed."] remoteExecCall ["zen_common_fnc_showMessage", allCurators];
                        };

                        // Revert time
                        -_deltaTime remoteExecCall ["skipTime", 0];
                    }, 100, dayTime] call CBA_fnc_addPerFrameHandler;

                    publicVariable QGVAR(setTimeAccPfhID);
                } call FUNC(sanitiseFunction), []]] call CBA_fnc_serverEvent;

                LSTRING(enableTimePauseMessage)
            } else {
                LSTRING(enableTimePauseAlreadyMessage)
            };
        } else {
            if (!isNil QGVAR(setTimeAccPfhID)) then {
                // Set everything back to normal
                ["zen_common_execute", [{
                    GVAR(setTimeAccPfhID) call CBA_fnc_removePerFrameHandler;

                    setTimeMultiplier 1;

                    GVAR(setTimeAccPfhID) = nil;
                    publicVariable QGVAR(setTimeAccPfhID);
                } call FUNC(sanitiseFunction), []]] call CBA_fnc_serverEvent;

                LSTRING(disableTimePauseMessage)
            } else {
                LSTRING(disableTimePauseAlreadyMessage)
            };
        };

        [_string] call zen_common_fnc_showMessage;
    }] call zen_dialog_fnc_create;
}, "\a3\Modules_F_Curator\Data\portraitTimeAcceleration_ca.paa"] call zen_custom_modules_fnc_register;
