/*
 * Author: johnb43
 * Spawns a module that allows a Zeus who has admin access (must be logged in) to remove Zeus access of others.
 */

[LSTRING(moduleCategoryUtility), LSTRING(deleteZeusModuleName), {
    private _isLoggedInAdmin = call BIS_fnc_admin == 2;

    if (isMultiplayer && {!_isLoggedInAdmin}) exitWith {
        [LSTRING(deleteZeusNoAdminAccessMessage)] call zen_common_fnc_showMessage;
    };

    private _curators = allCurators apply {[_x, getAssignedCuratorUnit _x]};

    [LSTRING(deleteZeusModuleName), _curators apply {["TOOLBOX", [format ["%1: %2", str (_x select 0), name (_x select 1)], "str_a3_argumentcurator"], [0, 1, 3, ["str_3den_attributes_default_unchanged_text", "STR_A3_Subtitle_Unassign", "STR_3DEN_Delete"]], true]}, {
        // Execute on server, so that we can use 'admin' command
        ["zen_common_execute", [{
            params ["_results", "_args"];
            _args params ["_curators", "_isLoggedInAdmin"];

            private _deleteZeus = false;

            {
                if (_results select _forEachIndex == 0) then {
                    continue;
                };

                _x params ["_logic", "_unit"];

                // If owner is admin, don't take away access, unless person who called it is logged in admin himself
                if (!isNull _logic && {_isLoggedInAdmin || {admin owner _unit == 0}}) then {
                    _deleteZeus = _results select _forEachIndex == 2;

                    if (!_deleteZeus) then {
                        unassignCurator _logic;
                    };

                    ["zen_common_execute", [{
                        params ["_logic", "_unit", "_deleteZeus"];

                        private _display = findDisplay IDD_RSCDISPLAYCURATOR;

                        // Kick the player out of zeus interface
                        if (!isNull _display) then {
                            _display closeDisplay IDC_CANCEL;
                        };

                        if !(_deleteZeus && {!isNull _logic}) exitWith {};

                        // For ZEN
                        private _zeusVarName = format ["zen_common_zeus_%1", getPlayerUID _unit];
                        private _zeus = missionNamespace getVariable _zeusVarName;

                        if (!isNil "_zeus") then {
                            if (!isNull _zeus) then {
                                deleteVehicle _zeus;
                            };

                            missionNamespace setVariable [_zeusVarName, nil];
                        };

                        // For ACE
                        if (!isNil "ace_zeus_zeus") then {
                            if (!isNull ace_zeus_zeus) then {
                                deleteVehicle ace_zeus_zeus;
                            };

                            ace_zeus_zeus = nil;
                        };

                        // If curator logic still hasn't been deleted, do it here
                        if (!isNull _logic) then {
                            deleteVehicle _logic;
                        };
                    }, [_logic, _unit, _deleteZeus]], [_unit, _logic] select (isNull _unit)] call CBA_fnc_targetEvent;
                };
            } forEach _curators;
        } call FUNC(sanitiseFunction), _this]] call CBA_fnc_serverEvent;

        [LSTRING(deleteZeusChangedMessage)] call zen_common_fnc_showMessage;
    }, {}, [_curators, _isLoggedInAdmin]] call zen_dialog_fnc_create;
}, ICON_REMOTECONTROL] call zen_custom_modules_fnc_register;
