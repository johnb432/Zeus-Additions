/*
 * Author: johnb43
 * Adds a module that can garrison buildings.
 */

[LSTRING(moduleCategoryAI), LSTRING(garrisonBuildingModuleName), {
    params ["_pos", "_building"];

    // Use passed object if valid
    if (isNull _building || {!(_building isKindOf "Building")}) then {
        private _buildings = nearestObjects [ASLToAGL _pos, ["Building"], 50, true];

        _building = _buildings param [_buildings findIf {alive _x && {!isObjectHidden _x} && {(_x buildingPos -1) isNotEqualTo []}}, objNull];
    };

    if (isNull _building) exitWith {
        [LSTRING_ZEN(modules,buildingTooFar)] call zen_common_fnc_showMessage;
    };

    _building call FUNC(gui_garrisonBuilding);
}, ICON_PERSON] call zen_custom_modules_fnc_register;
