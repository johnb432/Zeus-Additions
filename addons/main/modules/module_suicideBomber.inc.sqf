/*
 * Author: johnb43
 * Creates a module that can creates suicide bombers.
 */

[LSTRING(moduleCategoryUtility), LSTRING_ZEN(modules,moduleSuicideBomber), {
    params ["", "_unit"];

    if (isNull _unit) exitWith {
        [LSTRING_ZEN(modules,noUnitSelected)] call zen_common_fnc_showMessage;
    };

    if (!alive _unit) exitWith {
        [LSTRING_ZEN(modules,onlyAlive)] call zen_common_fnc_showMessage;
    };

    if !(_unit isKindOf "CAManBase" && {getNumber ((configOf _unit) >> "isPlayableLogic") == 0}) exitWith {
        [LSTRING_ZEN(modules,onlyInfantry)] call zen_common_fnc_showMessage;
    };

    [LSTRING_ZEN(modules,moduleSuicideBomber), [
        ["TOOLBOX:YESNO", [LSTRING_ZEN(modules,moduleSuicideBomber), LSTRING(enableSuicideBomberDesc)], !(_unit isNil QGVAR(suicideBomberActionJIP)), true],
        ["TOOLBOX:YESNO", [LSTRING_ZEN(modules,moduleSuicideBomber_DeadManSwitch), LSTRING(enableDeadmanSwitchDesc)], !(_unit isNil QGVAR(suicideBomberDeadManSwitchJIP)), true]
    ], {
        params ["_results", "_unit"];
        _results params ["_makeIntoSuicideBomber", "_deadManSwitchEnabled"];

        // Check again, in case something has changed since dialog's opening
        if (isNull _unit) exitWith {
            [LSTRING_ZEN(modules,noUnitSelected)] call zen_common_fnc_showMessage;
        };

        if (!alive _unit) exitWith {
            [LSTRING_ZEN(modules,onlyAlive)] call zen_common_fnc_showMessage;
        };

        // Only send function to all clients if script is enabled
        if (isNil QFUNC(removeSuicideBomberIDs)) then {
            PREP_SEND_MP(removeSuicideBomberIDs);
        };

        if (_makeIntoSuicideBomber) then {
            if (_unit isNil QGVAR(suicideBomberActionJIP)) then {
                if (isNil QFUNC(addDetonateAction)) then {
                    #include "module_suicideBomber_init.inc.sqf"
                };

                // Create explosives around player
                [QGVAR(executeFunction), [QFUNC(addExplosives), _unit], _unit] call CBA_fnc_targetEvent;

                // Add detonate scroll wheel action
                private _jipID = [QGVAR(executeFunction), [QFUNC(addDetonateAction), _unit]] call FUNC(globalEventJIP);
                [_jipID, _unit] call FUNC(removeGlobalEventJIP);

                _unit setVariable [QGVAR(suicideBomberActionJIP), _jipID, true];
            };

            // Dead man switch abilities
            if (_deadManSwitchEnabled) then {
                if !(_unit isNil QGVAR(suicideBomberDeadManSwitchJIP)) exitWith {};

                if (isNil QFUNC(addSuicideEh)) then {
                    #include "module_suicideBomber_deadMan_init.inc.sqf"
                };

                private _jipID = [QGVAR(executeFunction), [QFUNC(addSuicideEh), _unit]] call FUNC(globalEventJIP);
                [_jipID, _unit] call FUNC(removeGlobalEventJIP);

                _unit setVariable [QGVAR(suicideBomberDeadManSwitchJIP), _jipID, true];
            } else {
                // Remove JIP and EHs, but not action
                [_unit, false] call FUNC(removeSuicideBomberIDs);
            };

            [LSTRING(enableSuicideBomberMessage)] call zen_common_fnc_showMessage;
        } else {
            // Remove explosives
            deleteVehicle (_unit getVariable [QGVAR(suicideBomberExplosives), []]);

            // Remove JIP, action and EHs
            _unit call FUNC(removeSuicideBomberIDs);

            [LSTRING(disableSuicideBomberMessage)] call zen_common_fnc_showMessage;
        };
    }, {}, _unit] call zen_dialog_fnc_create;
}, ICON_EXPLOSION] call zen_custom_modules_fnc_register;
