/*
 * Author: johnb43
 * Adds a module can set a unit captive or not.
 * Does not work on players.
 */

["Zeus Additions - AI", "Change Captivity status", {
    params ["", "_unit"];

    ["Change Captivity status", [
        ["TOOLBOX:YESNO", ["Set Captive", "Sets the captivity status of the selected unit."], false],
        ["SIDES", ["AI selected", "Select AI from the list to change captivity status."], []],
        ["TOOLBOX:YESNO", ["Include Group", "Includes the entire group of the AI on which the module was placed."], false]
    ], {
        params ["_results", "_unit"];
        _results params ["_setCaptive", "_sides", "_doGroup"];

        // If opening on a vehicle; effectiveCommander returns objNull when unit is dead
        if (alive _unit) then {
            _unit = effectiveCommander _unit;
        };

        // If no units are selected at all
        if (!alive _unit && {_sides isEqualTo []}) exitWith {
            ["Select a side or place on living unit"] call zen_common_fnc_showMessage;
        };

        // If module was placed on a player
        if (!_doGroup && {isPlayer _unit}) exitWith {
            ["Select AI units"] call zen_common_fnc_showMessage;
        };

        private _units = [];
        private _string = "Changed units' captivity status";

        if (!isNull _unit) then {
            if (_doGroup) exitWith {
                _units = units _unit;

                _string = "Changed units' captivity status in group";
            };

            _units pushBack _unit;

            _string = "Changed unit's captivity status";
        };

        if (_sides isNotEqualTo []) then {
            {
                _units insert [-1, units _x, true];
            } forEach _sides;
        };

        _units = _units select {!isPlayer _x && {alive _x}};

        if (_units isEqualTo []) exitWith {
            ["No alive AI units were found"] call zen_common_fnc_showMessage;
        };

        if (_setCaptive) then {
            {
                if (!captive _x) then {
                    ["zen_common_execute", [{
                        _this setBehaviour "CARELESS";
                        _this setUnitPos "UP";
                        _this playMove "aidlpercmstpsraswrfldnon_ai";
                        _this stop true;
                        _this setCaptive true;

                        if (isNil "ace_captives") exitWith {};

                        [{
                            // Wait until unit has dropped its backpack
                            backpack _this == ""
                        }, {
                            [_this, true] call ace_captives_fnc_setHandcuffed;
                        }, _this] call CBA_fnc_waitUntilAndExecute;
                    }, _x], _x] call CBA_fnc_targetEvent;

                    // Drop all weapons
                    private _weaponHolder = createVehicle ["WeaponHolderSimulated", (getPosATL _x) vectorAdd [0, 0, 0.05], [], 0, "CAN_COLLIDE"];

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

                    private _backpackClass = backpack _x;

                    // If a unit has a backpack, drop it
                    if (_backpackClass != "") then {
                        _x action ["DropBag", _weaponHolder, _backpackClass];
                    };

                    [{
                        // Wait until unit has dropped its backpack
                        backpack _this == ""
                    }, {
                        ["zen_common_execute", [{
                            removeAllWeapons _this;
                            removeAllAssignedItems _this;
                            removeAllItemsWithMagazines _this;
                        }, _this], _this] call CBA_fnc_targetEvent;
                    }, _x] call CBA_fnc_waitUntilAndExecute;
                };
            } forEach _units;
        } else {
            {
                if (captive _x) then {
                    ["zen_common_execute", [{
                        _this setCaptive false;
                        _this stop false;
                        _this setBehaviour "AWARE";
                        _this setUnitPos "AUTO";

                        if (isNil "ace_captives") exitWith {};

                        [_this, false] call ace_captives_fnc_setHandcuffed;
                    }, _x], _x] call CBA_fnc_targetEvent;
                };
            } forEach _units;
        };

        [_string] call zen_common_fnc_showMessage;
    }, {}, _unit] call zen_dialog_fnc_create;
}, ICON_PERSON] call zen_custom_modules_fnc_register;
