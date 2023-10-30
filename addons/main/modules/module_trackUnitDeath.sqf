/*
 * Author: johnb43
 * Adds a module that can inform the Zeus when a unit dies.
 */

GVAR(trackUnits) = [];

[LSTRING(moduleCategoryUtility), LSTRING(unitDeathTrackingModuleName), {
    params ["", "_unit"];

    [LSTRING(unitDeathTrackingModuleName), [
        ["OWNERS", [LSTRING_ZEN(context_Actions,selected), LSTRING(unitTrackingSelectionDesc)], [[], [], [], 2], true],
        ["TOOLBOX:ENABLED", [LSTRING(unitDeathTracking), LSTRING(unitDeathTrackingDesc)], false],
        ["TOOLBOX:YESNO", [LSTRING(unitDeathTrackingDisplayHint), LSTRING(unitDeathTrackingDisplayHintDesc)], true],
        ["TOOLBOX:YESNO", [LSTRING(unitDeathTrackingDisplaySystemChat), LSTRING(unitDeathTrackingDisplaySystemChatDesc)], false],
        ["TOOLBOX:YESNO", [LSTRING(unitDeathTrackingDisplayZeusBanner), LSTRING(unitDeathTrackingDisplayZeusBannerDesc)], false],
        ["TOOLBOX:YESNO", [LSTRING(unitDeathTrackingDisplayLog), LSTRING(unitDeathTrackingDisplayLogDesc)], false]
    ], {
        params ["_results", "_unit"];
        _results params ["_selected", "_add", "_hint", "_systemChat", "_zeusBanner", "_log"];
        _selected params ["", "", "_players"];

        // If no unit was selected in the dialog, check if module was placed on a unit
        _unit = _players param [0, _unit];

        if (isNull _unit) exitWith {
            [LSTRING_ZEN(modules,noUnitSelected)] call zen_common_fnc_showMessage;
        };

        if (!alive _unit) exitWith {
            [LSTRING_ZEN(modules,onlyAlive)] call zen_common_fnc_showMessage;
        };

        if !(_unit isKindOf "CAManBase" && {!(_unit isKindOf "VirtualCurator_F")}) exitWith {
            [LSTRING_ZEN(modules,onlyInfantry)] call zen_common_fnc_showMessage;
        };

        // If remove EH
        if (!_add) exitWith {
            GVAR(trackUnits) deleteAt (GVAR(trackUnits) find _unit);

            // Remove EH if unit tracking is empty
            if (GVAR(trackUnits) isEqualTo [] && {!isNil QGVAR(trackUnitDeathEhID)}) then {
                removeMissionEventHandler ["EntityKilled", GVAR(trackUnitDeathEhID)];
                GVAR(trackUnitDeathEhID) = nil;
            };

            [LSTRING(disableUnitDeathTrackingMessage)] call zen_common_fnc_showMessage;
        };

        // If no method of notification was selected, exit
        if (!_hint && {!_systemChat} && {!_zeusBanner} && {!_log}) exitWith {
            [LSTRING(unitDeathTrackingSelectNotification)] call zen_common_fnc_showMessage;
        };

        _unit setVariable [QGVAR(displayDeath), [_hint, _systemChat, _zeusBanner, _log]];

        if (isNil QGVAR(trackUnitDeathEhID)) then {
            GVAR(trackUnitDeathEhID) = addMissionEventHandler ["EntityKilled", {
                params ["_unit", "_killer", "_instigator"];

                if !(_unit in GVAR(trackUnits)) exitWith {};

                private _nameUnit = name _unit;

                _killer = if (!isNull _killer) then {name _killer} else {"NONE"};
                _instigator = if (!isNull _instigator) then {name _instigator} else {"NONE"};

                private _notification = _unit getVariable [QGVAR(displayDeath), [false, false, false, false]];

                if (_notification select 0) then {
                    hint format ["[Zeus Additions]: " + LLSTRING(unitDeathTrackingMessage), _nameUnit, _killer, _instigator];
                };

                if (_notification select 1) then {
                    systemChat format ["[Zeus Additions]: " + LLSTRING(unitDeathTrackingMessage), _nameUnit, _killer, _instigator];
                };

                if (_notification select 2) then {
                    ["[Zeus Additions]: " + LLSTRING(unitDeathTrackingMessage), _nameUnit, _killer, _instigator] call zen_common_fnc_showMessage;
                };

                if (_notification select 3) then {
                    INFO_ZA(FORMAT_3(LSTRING(unitDeathTrackingMessage),_nameUnit,_killer,_instigator));
                };

                GVAR(trackUnits) deleteAt (GVAR(trackUnits) find _unit);

                // Remove EH if unit tracking is empty
                if (GVAR(trackUnits) isNotEqualTo []) exitWith {};

                removeMissionEventHandler [_thisEvent, _thisEventHandler];
                GVAR(trackUnitDeathEhID) = nil;
            }];
        };

        // Add unit to tracking
        [[LSTRING(enableUnitDeathTrackingMessage), LSTRING(unitDeathTrackingAlreadyTracking)] select ((GVAR(trackUnits) pushBackUnique _unit) == -1)] call zen_common_fnc_showMessage;
    }, {}, _unit] call zen_dialog_fnc_create;
}, ICON_RADIO] call zen_custom_modules_fnc_register;
