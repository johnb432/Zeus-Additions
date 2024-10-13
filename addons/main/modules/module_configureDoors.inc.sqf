/*
 * Author: johnb43, with help from scripts from mharis001 (ZEN) & Kex (Achilles)
 * Adds a module allows you to change if people can open doors on buildings.
 */

[LSTRING(moduleCategoryUtility), LSTRING_ZEN(doors,configure), {
    [LSTRING_ZEN(doors,configure), [
        ["TOOLBOX", LSTRING_ZEN(doors,doorState), [0, 1, 4, [LSTRING(configureDoorsUnbreachable), LSTRING(configureDoorsBreachable), "STR_a3_to_editTerrainObject21", "STR_a3_to_editTerrainObject22"]], false],
        ["EDIT", ["str_a3_cfgeditorsubcategories_edsubcat_explosives0", LSTRING(configureDoorsExsplosivesDesc)], GETMVAR(QGVAR(explosivesBreach),GETPRVAR(QGVAR(explosivesBreach),str ['DemoCharge_Remote_Mag'])), true],
        ["CHECKBOX", [LSTRING(configureDoorsApplyList), LSTRING(configureDoorsApplyListDesc)], false, true],
        ["CHECKBOX", [LSTRING(configureDoorsSaveList), LSTRING(configureDoorsSaveListDesc)], false, true],
        ["CHECKBOX", [LSTRING(configureDoorsResetList), LSTRING(configureDoorsResetListDesc)], false, true]
    ], {
        params ["_results", "_args"];
        _results params ["_mode", "_explosives", "_apply", "_save", "_reset"];
        _args params ["_pos", "_building"];

        if (_reset) exitWith {
            SETPRVAR(QGVAR(explosivesBreach),str ['DemoCharge_Remote_Mag']);
            SETMVAR(QGVAR(explosivesBreach),["DemoCharge_Remote_Mag"],true);

            [LSTRING(configureDoorsResetList)] call zen_common_fnc_showMessage;
        };

        _explosives = parseSimpleArray _explosives;

        if (_save) then {
            // Save all items (including non-existing ones)
            SETPRVAR(QGVAR(explosivesBreach),str _explosives);
        };

        // Convert to config case and remove non-existent items
        _explosives = (_explosives apply {configName (_x call CBA_fnc_getItemConfig)}) - [""];

        if (_apply || {isNil QGVAR(explosivesBreach)}) then {
            SETMVAR(QGVAR(explosivesBreach),_explosives,true);
        };

        // Use passed object if valid
        if (isNull _building || {!(_building isKindOf "Building")}) then {
            private _buildings = nearestObjects [ASLToAGL _pos, ["Building"], 50, true];

            _building = _buildings param [_buildings findIf {alive _x && {!isObjectHidden _x} && {(_x buildingPos -1) isNotEqualTo []}}, objNull];
        };

        if (isNull _building) exitWith {
            [LSTRING_ZEN(modules,buildingTooFar)] call zen_common_fnc_showMessage;
        };

        // Find doors; Done with help from scripts from mharis001 (ZEN) & Kex (Achilles)
        private _selectionNames = ((selectionNames _building) apply {toLowerANSI _x}) select {"door" in _x && {!("handle" in _x)} && {!("doorlocks" in _x )}};

        // If no doors found, exit
        if (_selectionNames isEqualTo []) exitWith {
            [LSTRING_ZEN(doors,noDoors)] call zen_common_fnc_showMessage;
        };

        _selectionNames sort true;

        private _lock = switch (_mode) do {
            case 2: {0};
            case 3: {2};
            default {1};
        };

        private _jipID = "";

        // Close doors and remove old JIP handlers
        {
            [_building, _forEachIndex + 1, _lock] call zen_doors_fnc_setState;

            _jipID = _building getVariable (format [QGVAR(doorJIP_%1_%2), _x, _forEachIndex + 1]);

            // Remove action from JIP
            if (!isNil "_jipID") then {
                _jipID call FUNC(removeGlobalEventJIP);

                _building setVariable [format [QGVAR(doorJIP_%1_%2), _x, _forEachIndex + 1], nil, true];
            };
        } forEach _selectionNames;

        if (isNil QFUNC(breachingRemoveAction)) then {
            DFUNC(breachingRemoveAction) = [{
                if (!hasInterface) exitWith {};

                params ["_building", "_door"];

                private _code = if (isNil "_door") then {
                    {true}
                } else {
                    {_door == (_actionParams select 12)}
                };

                private _actionParams = [];

                {
                    _actionParams = _building actionParams _x;

                    if ("Breach door using explosives" in (_actionParams select 0) && _code) then {
                        _building removeAction _x;
                    };
                } forEach (actionIDs _building);
            }, true] call FUNC(sanitiseFunction);

            SEND_MP(breachingRemoveAction);
        };

        // Remove all previous breaching actions from building
        [QGVAR(executeFunction), [QFUNC(breachingRemoveAction), _building]] call CBA_fnc_globalEvent;

        [([LSTRING(configureDoorsUnbreachableMessage), LSTRING(configureDoorsBreachableMessage), LSTRING(configureDoorsUnlockedMessage), LSTRING(configureDoorsOpenedMessage)] select _mode)] call zen_common_fnc_showMessage;

        // 0 unbreachable, 1 breachable, 2 closed, 3 open
        if (_mode != 1) exitWith {};

        // Only send function to all clients if script is enabled
        if (isNil QFUNC(breachingAddAction)) then {
            PREP_SEND_MP(breachingAddAction);
            PREP_SEND_MP(breachingEffects);
            PREP_SEND_MP(breachingEffectsVisual);
        };

        {
            _jipID = [QGVAR(executeFunction), [QFUNC(breachingAddAction), [_building, _x, _forEachIndex + 1]]] call FUNC(globalEventJIP);
            [_jipID, _building] call FUNC(removeGlobalEventJIP);

            _building setVariable [format [QGVAR(doorJIP_%1_%2), _x, _forEachIndex + 1], _jipID, true];
        } forEach _selectionNames;
    }, {}, _this] call zen_dialog_fnc_create;
}, "\a3\ui_f\data\igui\cfg\actions\open_door_ca.paa"] call zen_custom_modules_fnc_register;
