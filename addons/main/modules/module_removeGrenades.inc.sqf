/*
 * Author: johnb43
 * Spawns a module that allows Zeus to remove grenades from AI.
 */

[LSTRING(moduleCategoryAI), LSTRING(removeGrenadesAiModuleName), {
    params ["", "_unit"];

    [LSTRING(removeGrenadesAiModuleName), [
    ["SIDES", [LSTRING_ZEN(context_Actions,selected), LSTRING(removeGrenadesSelectionDesc)], []],
    ["TOOLBOX:YESNO", [LSTRING_ZEN(modules,suppressiveFire_EntireGroup), LSTRING(includeGroupDesc)], false]
    ], {
        params ["_results", "_unit"];
        _results params ["_sides", "_doGroup"];

        // If opening on a vehicle; effectiveCommander returns objNull when unit is dead
        if (alive _unit) then {
            _unit = effectiveCommander _unit;
        };

        // If no units are selected at all
        if (isNull _unit && {_sides isEqualTo []}) exitWith {
            [LSTRING_ZEN(modules,noUnitSelected)] call zen_common_fnc_showMessage;
        };

        // If module was placed on a player
        if (!_doGroup && {isPlayer _unit}) exitWith {
            [LSTRING(selectAiUnits)] call zen_common_fnc_showMessage;
        };

        private _units = [];
        private _string = LSTRING(removedGrenadesUnitsMessage);

        if (!isNull _unit) then {
            if (_doGroup) exitWith {
                _units = units _unit;

                _string = LSTRING(removedGrenadesGroupMessage);
            };

            _units pushBack _unit;

            _string = LSTRING(removedGrenadesUnitMessage)
        };

        if (_sides isNotEqualTo []) then {
            {
                _units insert [-1, units _x, true];
            } forEach _sides;
        };

        _units = _units select {!isPlayer _x};

        if (_units isEqualTo []) exitWith {
            [LSTRING(removeGrenadesNoUnitsFoundMessage)] call zen_common_fnc_showMessage;
        };

        private _throwables = [];

        // Remove grenades from all AI units
        {
            _unit = _x;
            _throwables = (throwables _unit) apply {_x select 0};

            {
                _unit removeMagazines _x;
            } forEach (_throwables arrayIntersect _throwables);
        } forEach _units;

        [_string] call zen_common_fnc_showMessage;
    }, {}, _unit] call zen_dialog_fnc_create;
}, "x\zen\addons\context_actions\ui\grenade_ca.paa"] call zen_custom_modules_fnc_register;
