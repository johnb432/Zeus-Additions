/*
 * Author: johnb43
 * Adds a module can set a unit captive or not.
 * Does not work on players.
 */

[LSTRING(moduleCategoryAI), LSTRING_ZEN(context_Actions,toggleCaptive), {
    params ["", "_unit"];

    [LSTRING_ZEN(context_Actions,toggleCaptive), [
        ["TOOLBOX:YESNO", ["str_a3_cfgvehicles_modulemode_f_arguments_captive_0", LSTRING(captiveDesc)], false],
        ["SIDES", [LSTRING_ZEN(context_Actions,selected), LSTRING(captiveSelectedDesc)], []],
        ["TOOLBOX:YESNO", [LSTRING_ZEN(modules,suppressiveFire_EntireGroup), LSTRING(includeGroupDesc)], false]
    ], {
        params ["_results", "_unit"];
        _results params ["_setCaptive", "_sides", "_doGroup"];

        // If opening on a vehicle; effectiveCommander returns objNull when unit is dead
        if (alive _unit) then {
            _unit = effectiveCommander _unit;
        };

        if (isNull _unit && {_sides isEqualTo []}) exitWith {
            [LSTRING_ZEN(modules,noUnitSelected)] call zen_common_fnc_showMessage;
        };

        // If no units are selected at all
        if (!alive _unit && {_sides isEqualTo []}) exitWith {
            [LSTRING_ZEN(modules,onlyAlive)] call zen_common_fnc_showMessage;
        };

        // If module was placed on a player
        if (!_doGroup && {isPlayer _unit}) exitWith {
            [LSTRING(selectAiUnits)] call zen_common_fnc_showMessage;
        };

        private _units = [];
        private _string = LSTRING(captiveChangedUnitsMessage);

        if (!isNull _unit) then {
            if (_doGroup) exitWith {
                _units = units _unit;

                _string = LSTRING(captiveChangedGroupMessage);
            };

            _units pushBack _unit;

            _string = LSTRING(captiveChangedUnitMessage);
        };

        if (_sides isNotEqualTo []) then {
            {
                _units insert [-1, units _x, true];
            } forEach _sides;
        };

        _units = _units select {!isPlayer _x && {alive _x}};

        if (_units isEqualTo []) exitWith {
            [LSTRING(captiveNoUnitsFoundMessage)] call zen_common_fnc_showMessage;
        };

        if (_setCaptive) then {
            // Only send function to all clients if script is enabled
            if (isNil QFUNC(setCaptive)) then {
                DFUNC(setCaptive) = [{
                    _this stop true;
                    _this setBehaviour "CARELESS";
                    _this setUnitPos "UP";
                    _this playMove "aidlpercmstpsraswrfldnon_ai";
                    _this setCaptive true;
                }, true] call FUNC(sanitiseFunction);

                DFUNC(dropInventory) = [{
                    removeAllWeapons _this;
                    removeAllAssignedItems _this;
                    removeAllItemsWithMagazines _this;

                    if (isNil "ace_captives") exitWith {};

                    [_this, true] call ace_captives_fnc_setHandcuffed;
                }, true] call FUNC(sanitiseFunction);

                SEND_MP(setCaptive);
                SEND_MP(dropInventory);
            };

            private _weaponHolder = objNull;
            private _backpackClass = "";

            {
                [QGVAR(executeFunction), [QFUNC(setCaptive), _x], _x] call CBA_fnc_targetEvent;

                // Drop all weapons
                _weaponHolder = createVehicle ["WeaponHolderSimulated", (getPosATL _x) vectorAdd [0, 0, 0.05], [], 0, "CAN_COLLIDE"];

                {
                    switch (_forEachIndex) do {
                        // Primary, secondary, handgun weapons and binoculars
                        case 0;
                        case 1;
                        case 2;
                        case 8: {
                            if (_x isNotEqualTo []) then {
                                _weaponHolder addWeaponWithAttachmentsCargoGlobal [_x, 1];
                            };
                        };
                        // Uniforms, vests (backpacks are dropped instead)
                        case 3;
                        case 4: {
                            {
                                // Containers are not handled, to avoid losing containers within containers
                                switch (true) do {
                                    // Items
                                    case (_x isEqualTypeArray ["", 0]): {
                                        _weaponHolder addItemCargoGlobal _x;
                                    };
                                    // Magazines
                                    case (_x isEqualTypeArray ["", 0, 0]): {
                                        _weaponHolder addMagazineAmmoCargo _x;
                                    };
                                    // Weapons
                                    case (_x isEqualTypeArray [[], 0]): {
                                        _weaponHolder addWeaponWithAttachmentsCargoGlobal _x;
                                    };
                                };
                            } forEach (_x param [1, []]);
                        };
                        // Assigned items
                        case 9: {
                            {
                                _weaponHolder addItemCargoGlobal [_x, 1];
                            } forEach _x;
                        };
                    };
                } forEach (getUnitLoadout _x);

                _backpackClass = backpack _x;

                // If a unit has a backpack, drop it
                if (_backpackClass != "") then {
                    _x action ["DropBag", _weaponHolder, _backpackClass];
                };

                [{
                    // Wait until unit has dropped its backpack
                    backpack _this == ""
                }, {
                    [QGVAR(executeFunction), [QFUNC(dropInventory), _this], _this] call CBA_fnc_targetEvent;
                }, _x] call CBA_fnc_waitUntilAndExecute;
            } forEach (_units select {!captive _x});
        } else {
            // Only send function to all clients if script is enabled
            if (isNil QFUNC(releaseCaptive)) then {
                DFUNC(releaseCaptive) = [{
                    _this setCaptive false;
                    _this stop false;
                    _this setBehaviour "AWARE";
                    _this setUnitPos "AUTO";

                    if (isNil "ace_captives") exitWith {};

                    [_this, false] call ace_captives_fnc_setHandcuffed;
                }, true] call FUNC(sanitiseFunction);

                SEND_MP(releaseCaptive);
            };

            {
                [QGVAR(executeFunction), [QFUNC(releaseCaptive), _x], _x] call CBA_fnc_targetEvent;
            } forEach (_units select {captive _x});
        };

        [_string] call zen_common_fnc_showMessage;
    }, {}, _unit] call zen_dialog_fnc_create;
}, ICON_PERSON] call zen_custom_modules_fnc_register;
