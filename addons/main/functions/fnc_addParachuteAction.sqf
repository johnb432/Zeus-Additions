#include "..\script_component.hpp"
/*
 * Author: johnb43
 * Adds a scroll wheel interaction to an object that allows players to paradrop.
 * Some code usage from BIS_fnc_locationDescription.
 *
 * Arguments:
 * 0: Object to add action to <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * cursorObject call zeus_additions_main_fnc_addParachuteAction;
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

params ["_object"];

_object setVariable [QGVAR(paradropActionID),
    _object addAction [
        "<t color='#FF0000'>Paradrop (click on map)</t>",
        {
            params ["", "_caller"];

            // If unit is already paradropping, don't do anything
            if (_caller getVariable [QGVAR(isParadropping), false]) exitWith {};

            openMap true;

            if (!isNil {_caller getVariable QGVAR(handleMapParadrop)}) exitWith {};

            _caller setVariable [QGVAR(handleMapParadrop), true];

            addMissionEventHandler ["MapSingleClick", {
                // Remove mapclick EH
                removeMissionEventHandler [_thisEvent, _thisEventHandler];

                [_this select 1, _thisArgs select 0] spawn {
                    params ["_pos", "_unit"];

                    _unit setVariable [QGVAR(handleMapParadrop), nil];

                    // Find the nearest to the given position location with text
                    private _location = locationNull;
                    private _mapCenter = worldSize / 2;

                    {
                        if (text _x != "") exitWith {
                            _location = _x
                        };
                    } forEach nearestLocations [[_mapCenter, _mapCenter], ["NameVillage", "NameCity", "NameCityCapital", "NameLocal", "NameMarine", "Hill", "HandDrawnCamp"], sqrt (2 * _mapCenter ^ 2), _pos];

                    // No suitable location exists
                    private _text = if (isNull _location) then {
                        format [localize "STR_A3_BIS_fnc_locationDescription_grid", mapGridPosition _pos]
                    } else {
                        // Location exists and close
                        if (_pos in _location) exitWith {
                            format [localize "STR_A3_BIS_fnc_locationDescription_near", text _location]
                        };

                        private _locPos = locationPosition _location;

                        // Location exists and not close, format the heading message
                        format [
                            "%1m %2",
                            _pos vectorDistance _locPos,
                            format [
                                localize (switch (round ((_locPos getDir _pos) % 360 / 45)) do {
                                    default {"STR_A3_BIS_fnc_locationDescription_n"};
                                    case 1: {"STR_A3_BIS_fnc_locationDescription_ne"};
                                    case 2: {"STR_A3_BIS_fnc_locationDescription_e"};
                                    case 3: {"STR_A3_BIS_fnc_locationDescription_se"};
                                    case 4: {"STR_A3_BIS_fnc_locationDescription_s"};
                                    case 5: {"STR_A3_BIS_fnc_locationDescription_sw"};
                                    case 6: {"STR_A3_BIS_fnc_locationDescription_w"};
                                    case 7: {"STR_A3_BIS_fnc_locationDescription_nw"};
                                }),
                                text _location
                            ]
                        ]
                    };

                    // Wait for confirmation
                    if !([format ["Are you sure you want to teleport to and paradrop %1?", _text], localize "str_a3_a_hub_misc_mission_selection_box_title", LLSTRING_ZEN(common,yes), LLSTRING_ZEN(common,no)] call BIS_fnc_guiMessage) exitWith {
                        openMap false;
                    };

                    openMap false;

                    // Allow player to give some information about paradrop
                    [LSTRING_ZEN(AI,paradrop), [
                        ["SLIDER", ["str_a3_rscuavwprootmenu_items_altitude0", "Determines how far up you are paradropped over terrain level."], [150, 5000, 1000, 0]],
                        ["TOOLBOX:YESNO", ["Give Yourself a Parachute", "Stores your backpack and gives you a parachute automatically. Upon landing you get your backpacks back."], true]
                    ],
                    {
                        params ["_results", "_args"];
                        _results params ["_height", "_giveUnitParachute"];
                        _args params ["_pos", "_unit"];

                        // If unit is already paradropping, don't TP
                        if (_unit getVariable [QGVAR(isParadropping), false]) exitWith {};

                        _unit setVariable [QGVAR(isParadropping), true, true];

                        // Set correct height
                        _pos set [2, _height];

                        // Start paradrop
                        [_unit, _pos, _giveUnitParachute] call FUNC(addParachute);
                    }, {}, [_pos, _unit]] call zen_dialog_fnc_create;
                }
            }, [_caller]];
        }
    ]
];
