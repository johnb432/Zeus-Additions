/*
 * Author: johnb43
 * Spawns a module that paradrops units, vehicles and crates.
 * With some help from https://github.com/zen-mod/ZEN/blob/master/addons/modules/functions/fnc_moduleCreateMinefield.sqf
 */

[LSTRING(moduleCategoryUtility), LSTRING(paradropUnitsModuleName), {
    params ["_pos"];

    [LSTRING(paradropUnitsModuleName), [
        ["OWNERS", [LSTRING_ZEN(context_Actions,selected), LSTRING(paradropUnitsSelectionDesc)], [[], [], [], 0], true],
        ["TOOLBOX:YESNO", [LSTRING(paradropUnitsIncludeContextMenu), LSTRING(paradropUnitsIncludeContextMenuDesc)], false, true],
        ["TOOLBOX:YESNO", [LSTRING_ZEN(Modules,ModuleTeleportPlayers_IncludeVehicles), LSTRING(paradropUnitsIncludeVehiclesDesc)], false],
        ["TOOLBOX:YESNO", [LSTRING(paradropUnitsIncludePlayers), LSTRING(paradropUnitsIncludePlayersDesc)], false],
        ["SLIDER", ["str_a3_rscuavwprootmenu_items_altitude0", LSTRING(paradropUnitsAltitudeDesc)], [150, 5000, 1000, 0]],
        ["SLIDER", ["str_a3_mdl_poster_probability", LSTRING(paradropUnitsDensityDesc)], [10, 100, 40, 0]],
        ["TOOLBOX:YESNO", [LSTRING(paradropUnitsGiveParachutes), LSTRING(paradropUnitsGiveParachutesDesc)], true]
    ], {
        params ["_results", "_pos"];
        _results params ["_selected", "_includeContextMenu", "_includeVehicles", "_includePlayersInVehicles", "_height", "_density", "_giveUnitsParachutes"];
        _selected params ["_sides", "_groups", "_players"];

        // Check for selected units
        if (!_includeContextMenu && {_sides isEqualTo []} && {_groups isEqualTo []} && {_players isEqualTo []}) exitWith {
            [LSTRING_ZEN(modules,noUnitSelected)] call zen_common_fnc_showMessage;
        };

        // Only send function to all clients if script is enabled
        if (isNil QFUNC(addParachute)) then {
            PREP_SEND_MP(addParachute);
        };

        // Set height on position
        _pos set [2, _height];

        private _unitList = [];
        private _vehicleList = [];
        private _objectList = [];
        private _vehicle = objNull;

        // Find all players from the list
        {
            _vehicle = objectParent _x;

            if (_includePlayersInVehicles || {isNull _vehicle}) then {
                _unitList pushBack _x;
            };

            if (!_includeVehicles) then {
                continue;
            };

            if (_vehicle isKindOf "LandVehicle" || {_vehicle isKindOf "Ship"}) then {
                _vehicleList pushBackUnique _vehicle;
            };
        } forEach ((call CBA_fnc_players) select {(side _x) in _sides || {(group _x) in _groups} || {_x in _players}});

        // Add context menu selection of entities
        if (_includeContextMenu) then {
            if (!isNil QGVAR(selectedParadropUnits)) then {
                _unitList insert [-1, GVAR(selectedParadropUnits), true];
            };

            if (!isNil QGVAR(selectedParadropVehicles)) then {
                _vehicleList insert [-1, GVAR(selectedParadropVehicles), true];
            };

            if (!isNil QGVAR(selectedParadropMisc)) then {
                _objectList append GVAR(selectedParadropMisc);
            };

            // Reset choice for the next time
            GVAR(selectedParadropUnits) = nil;
            GVAR(selectedParadropVehicles) = nil;
            GVAR(selectedParadropMisc) = nil;
        };

        // Try to make a square of parachuting units
        private _unitCount = count _unitList;
        private _vicCount = count _vehicleList;
        private _objectCount = count _objectList;
        private _vicObjCount = _vicCount + _objectCount;
        private _allCount = _unitCount + _vicCount + _objectCount;

        _vehicleList append _objectList;

        private _sqrt = sqrt _allCount;
        private _width = round _sqrt;
        private _height = ceil _sqrt;

        if (_width * _height < _allCount) then {
            _width = _width + 1;
        };

        // Starting position
        private _topLeft = _pos vectorAdd [-_width / 2, -_height / 2, 0];
        private _indexUnits = 0;
        private _indexVics = 0;
        private _unit = objNull;

        // Iterate through each spot in the rectangle
        for "_i" from 0 to (_width - 1) * _density step _density do {
            for "_j" from 0 to (_height - 1) * _density step _density do {
                if (_allCount == (_indexUnits + _indexVics)) exitWith {};

                // Spawn infantry
                if (_indexUnits != _unitCount) then {
                    _unit = _unitList select _indexUnits;

                    // If unit is already paradropping, don't TP
                    if (_unit getVariable [QGVAR(isParadropping), false]) then {
                        continue;
                    };

                    _unit setVariable [QGVAR(isParadropping), true, true];

                    // Start paradrop
                    [_unit, _topLeft vectorAdd [_i, _j, 0], _giveUnitParachute] call FUNC(addParachute);

                    _indexUnits = _indexUnits + 1;
                } else {
                    // Spawn vehicles
                    if (_indexVics != _vicObjCount) then {
                        _vehicle = _vehicleList select _indexVics;
                        _vehicle setPosATL (_topLeft vectorAdd [_i, _j, 0]);

                        private _bbr = boundingBoxReal _vehicle;

                        // Attach parachute to the middle (in height)
                        _vehicle attachTo [createVehicle ["i_parachute_02_f", getPosATL _vehicle, [], 0, "CAN_COLLIDE"], [0, 0, ((_bbr select 1 select 2) - (_bbr select 0 select 2)) / 2]];

                        _indexVics = _indexVics + 1;
                    };
                };
            };
        };

        [LSTRING(paradropUnitsMessage), _unitCount, _vicCount, _objectCount] call zen_common_fnc_showMessage;
    }, {}, _pos] call zen_dialog_fnc_create;
}, ["x\zen\addons\modules\ui\heli_ca.paa", "\z\ace\addons\zeus\ui\Icon_Module_Zeus_ParadropCargo_ca.paa"] select (!isNil "ace_zeus")] call zen_custom_modules_fnc_register;
