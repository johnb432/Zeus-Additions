/*
 * Author: johnb43
 * Spawns a module that allows a Zeus who has admin access to remove Zeus access of others.
 */

["Zeus Additions - Utility", "[WIP] Remove Zeus from units", {
    private _admin = call BIS_fnc_admin;

    if (isMultiplayer && {_admin == 0}) exitWith {
        ["You must be an admin to be able to use this module"] call zen_common_fnc_showMessage;
    };

    private _curators = allCurators apply {[_x, getAssignedCuratorUnit _x]};

    ["Remove Zeus from Unit (requires admin privileges)", _curators apply {["TOOLBOX:YESNO", [format ["%1: %2", str (_x select 0), name (_x select 1)], "Logic: unit"], false, true]}, {
        // Execute on server, so that we can use 'admin' command
        ["zen_common_execute", [{
            params ["_results", "_args"];
            _args params ["_curators", "_isLoggedInAdmin"];

            {
                _x params ["_logic", "_unit"];

                // If owner is admin, don't take away access, unless person who called it is logged in admin himself
                if ((_results select _forEachIndex) && {!isNull _logic} && {_isLoggedInAdmin || {admin owner _unit == 0}}) then {
                    ["zen_common_execute", [{
                        params ["_logic", "_unit"];

                        // Only if a player is using the logic
                        if (!isNull _unit) then {
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

                            // Kick the player out of zeus interface
                            if (!isNull findDisplay IDD_RSCDISPLAYCURATOR) then {
                                (findDisplay IDD_RSCDISPLAYCURATOR) closeDisplay IDC_CANCEL;
                            };
                        };

                        // If curator logic still hasn't been deleted, do it here
                        if (!isNull _logic) then {
                            deleteVehicle _logic;
                        };
                    }, _x], _x] call CBA_fnc_targetEvent;
                };
            } forEach _curators;
        }, _this]] call CBA_fnc_serverEvent;

        ["Changed zeus status"] call zen_common_fnc_showMessage;
    }, {}, [_curators, _admin == 2]] call zen_dialog_fnc_create;
}, ICON_REMOTECONTROL] call zen_custom_modules_fnc_register;
