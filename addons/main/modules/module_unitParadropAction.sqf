/*
 * Author: johnb43
 * Spawns a module that allows players to paradrop.
 */

[LSTRING(moduleCategoryUtility), LSTRING(paradropActionModuleName), {
    [LSTRING(paradropActionModuleName), [
        ["TOOLBOX", "str_a3_cfgvehicles_modulecuratoraddaddons_f_arguments_mode", [0, 1, 2, [LSTRING_ZEN(common,add), LSTRING_ZEN(common,remove)]]]
    ], {
        params ["_results", "_args"];
        _args params ["_pos", "_object"];

        // If no object was selected, make a teleport pole
        if (isNull _object) then {
            _object = "FlagPole_F" createVehicle _pos;

            _object call zen_common_fnc_updateEditableObjects;
        };

        // Add action
        private _string = if ((_results select 0) == 0) then {
            if (!isNil {_object getVariable QGVAR(paradropActionJIP)}) exitWith {
                LSTRING(paradropActionAlreadyAdded)
            };

            // Only send function to all clients if script is enabled
            if (isNil QFUNC(addParachute)) then {
                PREP_SEND_MP(addParachute);
            };

            if (isNil QFUNC(addParachuteAction)) then {
                PREP_SEND_MP(addParachuteAction);
            };

            private _jipID = [QGVAR(executeFunction), [QFUNC(addParachuteAction), _object]] call FUNC(globalEventJIP);
            [_jipID, _object] call FUNC(removeGlobalEventJIP);

            _object setVariable [QGVAR(paradropActionJIP), _jipID, true];

            LSTRING(paradropActionAdded)
        } else {
            private _jipID = _object getVariable QGVAR(paradropActionJIP);

            if (isNil "_jipID") exitWith {
                LSTRING(paradropActionAlreadyRemoved)
            };

            _jipID call FUNC(removeGlobalEventJIP);

            _object setVariable [QGVAR(paradropActionJIP), nil, true];

            // Remove action from object; actionIDs are not the same on all clients
            ["zen_common_execute", [{
                _this removeAction (_this getVariable [QGVAR(paradropActionID), -1]);
                _this setVariable [QGVAR(paradropActionID), nil];
            } call FUNC(sanitiseFunction), _object]] call CBA_fnc_globalEvent;

            LSTRING(paradropActionRemoved)
        };

        [_string] call zen_common_fnc_showMessage;
    }, {}, _this] call zen_dialog_fnc_create;
}, ICON_PARADROP] call zen_custom_modules_fnc_register;
