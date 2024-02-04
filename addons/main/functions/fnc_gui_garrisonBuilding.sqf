#include "..\script_component.hpp"
/*
 * Author: johnb43, based off of zen_modules_fnc_gui_spawnReinforcements (mharis001)
 * Creates a GUI to garrison a building with units.
 *
 * Arguments:
 * 0: Building <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * call zeus_additions_main_fnc_gui_garrisonBuilding;
 *
 * Public: No
 */

// Dialog creation
if (!createDialog QGVAR(rscSpawnGarrison)) exitWith {};

disableSerialization;

private _display = GETUVAR(QGVAR(display),displayNull);

if (isNull _display) exitWith {};

params ["_building"];

_display setVariable [QGVAR(building), _building];

private _selections = zen_modules_saved getVariable [QGVAR(garrisonBuilding), [0, 0, [], false, false, 50, 0]];
_selections params ["_side", "_treeMode", "_unitTypes", "_dynamicSimulation", "_trigger", "_triggerRadius", "_unitBehaviour"];

private _ctrlSide = _display displayCtrl IDC_SPAWNGARRISON_SIDE;
_ctrlSide ctrlAddEventHandler ["LBSelChanged", {
    params ["_ctrlSide", "_sideIndex"];

    private _sideID = [1, 0, 2, 3] select _sideIndex;
    private _sideColor = [_sideID] call BIS_fnc_sideColor;

    private _display = ctrlParent _ctrlSide;
    private _cfgVehicles = configFile >> "CfgVehicles";
    private _cfgFactionClasses = configFile >> "CfgFactionClasses";
    private _cfgEditorSubcategories = configFile >> "CfgEditorSubcategories";

    uiNamespace getVariable "zen_modules_reinforcementsCache" params ["", "_infantryCache", "_groupsCache"];

    // Populate tree with premade groups of the selected side
    private _ctrlTreeGroups = _display displayCtrl IDC_SPAWNGARRISON_TREE_GROUPS;
    tvClear _ctrlTreeGroups;

    {
        private _factionIndex = _ctrlTreeGroups tvAdd [[], _x];

        {
            private _categoryIndex = _ctrlTreeGroups tvAdd [[_factionIndex], _x];

            {
                _x params ["_name", "_icon", "_units"];

                private _groupIndex = _ctrlTreeGroups tvAdd [[_factionIndex, _categoryIndex], _name];
                private _groupPath  = [_factionIndex, _categoryIndex, _groupIndex];

                _ctrlTreeGroups tvSetTooltip [_groupPath, _name];
                _ctrlTreeGroups tvSetPicture [_groupPath, _icon];
                _ctrlTreeGroups tvSetPictureColor [_groupPath, _sideColor];

                _ctrlTreeGroups tvSetData [_groupPath, str _groupPath];
                _ctrlTreeGroups setVariable [str _groupPath, _units];
            } forEach _y;

            _ctrlTreeGroups tvSort [[_factionIndex, _categoryIndex], false];
        } forEach _y;

        _ctrlTreeGroups tvSort [[_factionIndex], false];
    } forEach (_groupsCache select _sideIndex);

    _ctrlTreeGroups tvSort [[], false];

    // Populate tree with units of the selected side
    private _ctrlTreeUnits = _display displayCtrl IDC_SPAWNGARRISON_TREE_UNITS;
    tvClear _ctrlTreeUnits;

    {
        private _faction = getText (_cfgFactionClasses >> _x >> "displayName");
        private _factionIndex = _ctrlTreeUnits tvAdd [[], _faction];

        {
            private _category = getText (_cfgEditorSubcategories >> _x >> "displayName");
            private _categoryIndex = _ctrlTreeUnits tvAdd [[_factionIndex], _category];

            {
                private _name = getText (_cfgVehicles >> _x >> "displayName");
                private _icon = [_x] call zen_common_fnc_getVehicleIcon;

                private _unitIndex = _ctrlTreeUnits tvAdd [[_factionIndex, _categoryIndex], _name];
                private _unitPath  = [_factionIndex, _categoryIndex, _unitIndex];

                _ctrlTreeUnits tvSetTooltip [_unitPath, _name];
                _ctrlTreeUnits tvSetPicture [_unitPath, _icon];
                _ctrlTreeUnits tvSetPictureColor [_unitPath, _sideColor];
                _ctrlTreeUnits tvSetData [_unitPath, _x];
            } forEach _y;

            _ctrlTreeUnits tvSort [[_factionIndex, _categoryIndex], false];
        } forEach _y;

        _ctrlTreeUnits tvSort [[_factionIndex], false];
    } forEach (_infantryCache select _sideIndex);

    _ctrlTreeUnits tvSort [[], false];

    private _ctrlUnitList = _display displayCtrl IDC_SPAWNGARRISON_UNIT_LIST;
    lbClear _ctrlUnitList;

    private _ctrlUnitCount = _display displayCtrl IDC_SPAWNGARRISON_UNIT_COUNT;
    _ctrlUnitCount ctrlSetText "0";
}];

private _fnc_treeModeChanged = {
    params ["_ctrlTreeMode", "_mode"];

    private _display = ctrlParent _ctrlTreeMode;
    private _ctrlTreeGroups = _display displayCtrl IDC_SPAWNGARRISON_TREE_GROUPS;
    private _ctrlTreeUnits  = _display displayCtrl IDC_SPAWNGARRISON_TREE_UNITS;

    _ctrlTreeGroups ctrlShow (_mode == 0);
    _ctrlTreeUnits  ctrlShow (_mode == 1);
};

private _ctrlTreeMode = _display displayCtrl IDC_SPAWNGARRISON_TREE_MODE;
_ctrlTreeMode ctrlAddEventHandler ["ToolBoxSelChanged", _fnc_treeModeChanged];
_ctrlTreeMode lbSetCurSel _treeMode;

[_ctrlTreeMode, _treeMode] call _fnc_treeModeChanged;

private _ctrlTreeGroups = _display displayCtrl IDC_SPAWNGARRISON_TREE_GROUPS;
_ctrlTreeGroups ctrlAddEventHandler ["TreeDblClick", {
    params ["_ctrlTreeGroups", "_selectedPath"];

    // Exit if a group path was not selected
    if (count _selectedPath < 3) exitWith {};

    private _display = ctrlParent _ctrlTreeGroups;

    private _dataVar = _ctrlTreeGroups tvData _selectedPath;
    private _unitTypes = _ctrlTreeGroups getVariable _dataVar;
    private _fnc_addUnit = _display getVariable QFUNC(addUnit);

    {
        [_display, _x] call _fnc_addUnit;
    } forEach _unitTypes;
}];

(_display displayCtrl IDC_SPAWNGARRISON_TREE_UNITS) ctrlAddEventHandler ["TreeDblClick", {
    params ["_ctrlTreeUnits", "_selectedPath"];

    // Exit if a unit path was not selected
    if (count _selectedPath < 3) exitWith {};

    private _unit = _ctrlTreeUnits tvData _selectedPath;
    private _display = ctrlParent _ctrlTreeUnits;
    [_display, _unit] call (_display getVariable QFUNC(addUnit));
}];

private _fnc_addUnit = {
    params ["_display", "_unitClass"];

    private _ctrlUnitList = _display displayCtrl IDC_SPAWNGARRISON_UNIT_LIST;

    // Exit if max number of units have already been added
    if (lbSize _ctrlUnitList >= count ((_display getVariable [QGVAR(building), objNull]) buildingPos -1)) exitWith {
        [LSTRING_ZEN(ai,couldNotGarrisonAll)] call zen_common_fnc_showMessage;
    };

    private _unitConfig = configFile >> "CfgVehicles" >> _unitClass;
    private _unitName = getText (_unitConfig >> "displayName");
    private _unitSide = getNumber (_unitConfig >> "side");
    private _unitIcon = [_unitClass] call zen_common_fnc_getVehicleIcon;
    private _unitFaction  = getText (_unitConfig >> "faction");
    private _unitCategory = getText (_unitConfig >> "editorSubcategory");

    private _factionConfig = configFile >> "CfgFactionClasses" >> _unitFaction;
    private _factionName = getText (_factionConfig >> "displayName");
    private _factionIcon = getText (_factionConfig >> "icon");

    private _categoryName = getText (configFile >> "CfgEditorSubcategories" >> _unitCategory >> "displayName");
    private _tooltip = format ["%1\n%2\n%3", _unitName, _categoryName, _factionName];

    private _index = _ctrlUnitList lbAdd _unitName;
    _ctrlUnitList lbSetTooltip [_index, _tooltip];
    _ctrlUnitList lbSetPicture [_index, _unitIcon];
    _ctrlUnitList lbSetPictureRight [_index, _factionIcon];
    _ctrlUnitList lbSetPictureColor [_index, [_unitSide] call BIS_fnc_sideColor];
    _ctrlUnitList lbSetData [_index, _unitClass];

    private _ctrlUnitCount = _display displayCtrl IDC_SPAWNGARRISON_UNIT_COUNT;
    _ctrlUnitCount ctrlSetText str lbSize _ctrlUnitList;
};

_display setVariable [QFUNC(addUnit), _fnc_addUnit];

{
     [_fnc_addUnit, [_display, _x]] call CBA_fnc_execNextFrame;
} forEach _unitTypes;

private _ctrlUnitList = _display displayCtrl IDC_SPAWNGARRISON_UNIT_LIST;
_ctrlUnitList ctrlAddEventHandler ["KeyDown", {
    params ["_ctrlUnitList", "_keyCode"];

    if !(_keyCode == DIK_DELETE && {lbCurSel _ctrlUnitList != -1}) exitWith {};

    _ctrlUnitList lbDelete lbCurSel _ctrlUnitList;

    private _ctrlUnitCount = ctrlParent _ctrlUnitList displayCtrl IDC_SPAWNGARRISON_UNIT_COUNT;
    _ctrlUnitCount ctrlSetText str lbSize _ctrlUnitList;

    true // handled
}];
_ctrlUnitList ctrlAddEventHandler ["LBDblClick", {
    params ["_ctrlUnitList", "_selectedIndex"];

    _ctrlUnitList lbDelete _selectedIndex;

    private _ctrlUnitCount = ctrlParent _ctrlUnitList displayCtrl IDC_SPAWNGARRISON_UNIT_COUNT;
    _ctrlUnitCount ctrlSetText str lbSize _ctrlUnitList;
}];

(_display displayCtrl IDC_SPAWNGARRISON_UNIT_CLEAR) ctrlAddEventHandler ["ButtonClick", {
    params ["_ctrlUnitClear"];

    private _display = ctrlParent _ctrlUnitClear;

    private _ctrlUnitList = _display displayCtrl IDC_SPAWNGARRISON_UNIT_LIST;
    lbClear _ctrlUnitList;

    private _ctrlUnitCount = _display displayCtrl IDC_SPAWNGARRISON_UNIT_COUNT;
    _ctrlUnitCount ctrlSetText "0";
}];

private _ctrlTriggerRadius = _display displayCtrl IDC_SPAWNGARRISON_TRIGGER_RADIUS;
_ctrlTriggerRadius ctrlAddEventHandler ["SliderPosChanged", {
    params ["_ctrlTriggerRadius", "_newValue"];

    _ctrlTriggerRadius ctrlSetTooltip ((_newValue toFixed 0) + " m");
}];

_ctrlSide lbSetCurSel _side;
(_display displayCtrl IDC_SPAWNGARRISON_DYNAMIC_SIMULATION) cbSetChecked _dynamicSimulation;
(_display displayCtrl IDC_SPAWNGARRISON_TRIGGER) cbSetChecked _trigger;
_ctrlTriggerRadius sliderSetPosition _triggerRadius;
_ctrlTriggerRadius ctrlSetTooltip ((_triggerRadius toFixed 0) + " m");
(_display displayCtrl IDC_SPAWNGARRISON_UNIT_BEHAVIOUR) lbSetCurSel _unitBehaviour;

(_display displayCtrl IDC_OK) ctrlAddEventHandler ["ButtonClick", {
    params ["_ctrlButtonOK"];

    private _display = ctrlParent _ctrlButtonOK;
    private _building = _display getVariable [QGVAR(building), objNull];

    if (!alive _building || {isObjectHidden _building} || {(_building buildingPos -1) isEqualTo []}) exitWith {
        [LSTRING_ZEN(modules,buildingTooFar)] call zen_common_fnc_showMessage;
    };

    private _ctrlUnitList = _display displayCtrl IDC_SPAWNGARRISON_UNIT_LIST;
    private _lbSize = lbSize _ctrlUnitList;

    private _side = lbCurSel (_display displayCtrl IDC_SPAWNGARRISON_SIDE);
    private _treeMode = lbCurSel (_display displayCtrl IDC_SPAWNGARRISON_TREE_MODE);

    private _unitTypes = [];

    for "_i" from 0 to (_lbSize - 1) do {
        _unitTypes pushBack (_ctrlUnitList lbData _i);
    };

    private _dynamicSimulation = cbChecked (_display displayCtrl IDC_SPAWNGARRISON_DYNAMIC_SIMULATION);
    private _trigger = cbChecked (_display displayCtrl IDC_SPAWNGARRISON_TRIGGER);
    private _triggerRadius = sliderPosition (_display displayCtrl IDC_SPAWNGARRISON_TRIGGER_RADIUS);
    private _unitBehaviour = lbCurSel (_display displayCtrl IDC_SPAWNGARRISON_UNIT_BEHAVIOUR);

    // _unitTypes is copied, in case this is executed in SP (_unitTypes is passed by reference)
    zen_modules_saved setVariable [QGVAR(garrisonBuilding), [_side, _treeMode, +_unitTypes, _dynamicSimulation, _trigger, _triggerRadius, _unitBehaviour]];

    if (_lbSize == 0) exitWith {
        [LSTRING(selectAiUnits)] call zen_common_fnc_showMessage;
    };

    if (isNil QFUNC(garrisonBuilding)) then {
        PREP_SEND_SERVER(garrisonBuilding);
    };

    [QGVAR(executeFunction), [QFUNC(garrisonBuilding), [_building, _side, _unitTypes, _dynamicSimulation, _trigger, _triggerRadius, _unitBehaviour, clientOwner]]] call CBA_fnc_serverEvent;
}];
