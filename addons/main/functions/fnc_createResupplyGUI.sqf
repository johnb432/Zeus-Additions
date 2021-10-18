#include "script_component.hpp"

/*
 * Author: johnb43
 * Creates a GUI to spawn in all available magazines in the game.
 * MUST BE CALLED WITH 'spawn' (see example)
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] spawn zeus_additions_main_fnc_createResupplyGUI;
 *
 * Public: No
 */

disableSerialization;

// Dialog creation
if (!createDialog QGVAR(RscDisplay)) exitWith {};

private _display = GETUVAR(QGVAR(display),displayNull);

if (isNull _display) exitWith {};

// Lists and their background
// Categories list
private _ctrlListCategories = _display displayCtrl IDC_LIST_CATEGORIES;
_ctrlListCategories ctrlAddEventHandler ["LBSelChanged", {
    disableSerialization;

    params ["_ctrlListCategories", "_selectedIndex"];

    [_ctrlListCategories, _selectedIndex] spawn {
        disableSerialization;

        params ["_ctrlListCategories", "_selectedIndex"];

        private _display = ctrlParent _ctrlListCategories;
        private _ctrlListMagazines = _display displayCtrl IDC_LIST_MAGAZINES;
        private _ctrlListSelected = _display displayCtrl IDC_LIST_SELECTED;

        if (isNull _ctrlListCategories || isNull _ctrlListSelected) exitWith {};

        diag_log text format ["ctrlListCategories, LBSelChanged: %1, %2, %4", _selectedIndex, _ctrlListMagazines, lbSelection _ctrlListMagazines];

        // Clear displayed magazines from previous category; lbClear causes crash
        diag_log text "clearing";

        private _size = lbSize _ctrlListMagazines;

        if (_size isNotEqualTo 0) then {
            /*
            for "_i" from (_size - 1) to 0 step -1 do {
                //_ctrl lbSetValue [_i, 0];
                _ctrl lbDelete _i;
            };
            */

            // CAUSES GAME TO CRASH FOR SOME REASON
            lbClear _ctrlListMagazines;
        };

        waitUntil {lbSize _ctrlListMagazines isEqualTo 0};

        diag_log text "cleared";

        private _selectedMagazines = [];

        // Get current selection in selected magazines
        _size = lbSize _ctrlListSelected;

        if (_size isNotEqualTo 0) then {
            for "_i" from 0 to (_size - 1) step 1 do {
                _selectedMagazines pushBack (_ctrlListSelected lbTooltip _i);
            };
        };

        private _cfgMagazines = configFile >> "CfgMagazines";
        private _addedIndex = -1;

        diag_log text format ["selectedMagazines: %1", _selectedMagazines];

        // Add magazines from currently selected category
        {
            // Name is magazine display name, picture is magazine icon & tooltip is classname
            diag_log text format ["adding: %1, %2", _forEachIndex, _x];

            // Don't add magazines that are in the selected list
            if (_x in _selectedMagazines || _x == "UK3CB_RPK_75rnd_762x39_RM") then {
                continue;
            };

            diag_log text "checked";

            _addedIndex = _ctrlListMagazines lbAdd (getText (_cfgMagazines >> _x >> "displayName"));
            diag_log text "lbAdd";

            _ctrlListMagazines lbSetPicture [_addedIndex, getText (_cfgMagazines >> _x >> "picture")];
            _ctrlListMagazines lbSetTooltip [_addedIndex, _x];
            _ctrlListMagazines lbSetValue [_addedIndex, 0];
        } forEach (GETUVAR(QGVAR(magazinesHashmap),[]) get (GETUVAR(QGVAR(sortedKeys),[]) select _selectedIndex));

        diag_log text "finished added";

        // Sort alphabetically
        lbSort _ctrlListMagazines;

        diag_log text "sorted";
    };
}];

// Add items to list
{
    _ctrlListCategories lbAdd _x;
} forEach GETUVAR(QGVAR(sortedKeys),[]);

// Magazines list for categories
private _ctrlListMagazines = _display displayCtrl IDC_LIST_MAGAZINES;
_ctrlListMagazines ctrlAddEventHandler ["LBDblClick", {
    params ["_ctrlListMagazines", "_selectedIndex"];

    private _ctrlListSelected = (ctrlParent _ctrlListMagazines) displayCtrl IDC_LIST_SELECTED;

    if (isNull _ctrlListSelected) exitWith {};

    // Name is magazine display name, picture is magazine icon & tooltip is classname & set value to 0; Value is used for storing how many mags will be spawned
    private _addedIndex = _ctrlListSelected lbAdd (_ctrlListMagazines lbText _selectedIndex);
    _ctrlListSelected lbSetPicture [_addedIndex, _ctrlListMagazines lbPicture _selectedIndex];
    _ctrlListSelected lbSetTooltip [_addedIndex, _ctrlListMagazines lbTooltip _selectedIndex];
    _ctrlListSelected lbSetValue [_addedIndex, 0];

    // Sort alphabetically
    lbSort _ctrlListSelected;

    // Delete entry in original list
    _ctrlListMagazines lbDelete _selectedIndex;
}];
_ctrlListMagazines ctrlAddEventHandler ["KeyDown", {
    params ["_ctrlListMagazines", "_key", "", "_control"];

    if (_key isNotEqualTo DIK_C || {!_control}) exitWith {};

    // Copy to clipboard
    "ace_clipboard" callExtension (str (_ctrlListMagazines lbTooltip (lbCurSel _ctrlListMagazines)) + ";");
    "ace_clipboard" callExtension "--COMPLETE--";

    false;
}];

// List for selected magazines
private _ctrlListSelected = _display displayCtrl IDC_LIST_SELECTED;
_ctrlListSelected ctrlAddEventHandler ["LBDblClick", {
    params ["_ctrlListSelected", "_selectedIndex"];

    private _display = ctrlParent _ctrlListSelected;
    private _ctrlListMagazines = _display displayCtrl IDC_LIST_MAGAZINES;

    private _toolTip = _ctrlListSelected lbTooltip _selectedIndex;

    // Move magazine back into selection if correct category
    if (_toolTip in (GETUVAR(QGVAR(magazinesHashmap),[]) get (GETUVAR(QGVAR(sortedKeys),[]) select (lbCurSel (_display displayCtrl IDC_LIST_CATEGORIES))))) then {
        // Name is magazine display name, picture is magazine icon & tooltip is classname
        private _addedIndex = _ctrlListMagazines lbAdd (_ctrlListSelected lbText _selectedIndex);
        _ctrlListMagazines lbSetPicture [_addedIndex, _ctrlListSelected lbPicture _selectedIndex];
        _ctrlListMagazines lbSetTooltip [_addedIndex, _toolTip];
    };

    // Sort alphabetically
    lbSort _ctrlListMagazines;

    // Delete entry in original list
    _ctrlListSelected lbDelete _selectedIndex;
}];
_ctrlListSelected ctrlAddEventHandler ["KeyDown", {
    params ["_ctrlListSelected", "_key", "", "_control"];

    if (_key isNotEqualTo DIK_C || {!_control}) exitWith {};

    // Copy to clipboard
    "ace_clipboard" callExtension (str (_ctrlListSelected lbTooltip (lbCurSel _ctrlListSelected)) + ";");
    "ace_clipboard" callExtension "--COMPLETE--";

    false;
}];

// Buttons
// Ok
(_display displayCtrl IDC_OK) ctrlAddEventHandler ["ButtonClick", {
    private _display = ctrlParent (_this select 0);
    private _ctrlListSelected = _display displayCtrl IDC_LIST_SELECTED;
    private _object = GETUVAR(QGVAR(magazineInventory),objNull);

    // Spawn in magazines
    for "_i" from 0 to (lbSize _ctrlListSelected - 1) step 1 do {
        _object addItemCargoGlobal [_ctrlListSelected lbTooltip _i, _ctrlListSelected lbValue _i];
    };

    ["Ammo crate created"] call zen_common_fnc_showMessage;

    _display closeDisplay IDC_OK;
}];

// Cancel
(_display displayCtrl IDC_CANCEL) ctrlAddEventHandler ["ButtonClick", {
    ["Only launcher ammunition spawned"] call zen_common_fnc_showMessage;

    (ctrlParent (_this select 0)) closeDisplay IDC_CANCEL;
}];

// Move chosen magazines from magazine list into selected magazines list
(_display displayCtrl IDC_BUTTON_INTO) ctrlAddEventHandler ["ButtonClick", {
    private _display = ctrlParent (_this select 0);

    // Get current selection
    private _ctrlListMagazines = _display displayCtrl IDC_LIST_MAGAZINES;
    private _selectedArray = lbSelection _ctrlListMagazines;

    // Exit if nothing selected
    if (_selectedArray isEqualTo []) exitWith {};

    // Get new list
    private _ctrlListSelected = _display displayCtrl IDC_LIST_SELECTED;
    private _addedIndex = -1;
    private _toolTip = "";
    private _cfgMagazines = configFile >> "CfgMagazines";

    {
        // Name is magazine display name, picture is magazine icon & tooltip is classname
        _toolTip = _ctrlListMagazines lbTooltip _x;
        _addedIndex = _ctrlListSelected lbAdd (getText (_cfgMagazines >> _toolTip >> "displayName"));
        _ctrlListSelected lbSetPicture [_addedIndex, _ctrlListMagazines lbPicture _x];
        _ctrlListSelected lbSetTooltip [_addedIndex, _toolTip];
    } forEach _selectedArray;

    // When deleting, start from end to beginning, otherwise it messes up
    reverse _selectedArray;

    // Delete entry in original list; Has to be done after, otherwise it messes up
    {
        _ctrlListMagazines lbDelete _x;
    } forEach _selectedArray;

    // Sort alphabetically
    lbSort _ctrlListSelected;
}];

// Remove chosen magazines from selected magazines list
private _ctrlButtonMoveOutOf = _display displayCtrl IDC_BUTTON_OUTOF;
_ctrlButtonMoveOutOf ctrlSetText "<"; // Because config doesn't do it properly for some reason
_ctrlButtonMoveOutOf ctrlAddEventHandler ["ButtonClick", {
    private _display = ctrlParent (_this select 0);

    // Get current selection
    private _ctrlListSelected = _display displayCtrl IDC_LIST_SELECTED;
    private _selectedArray = lbSelection _ctrlListSelected;

    // Exit if nothing selected
    if (_selectedArray isEqualTo []) exitWith {};

    // Get new list
    private _ctrlListMagazines = _display displayCtrl IDC_LIST_MAGAZINES;
    private _addedIndex = -1;
    private _toolTip = "";
    private _currentlySelected = GETUVAR(QGVAR(magazinesHashmap),[]) get (GETUVAR(QGVAR(sortedKeys),[]) select (lbCurSel (_display displayCtrl IDC_LIST_CATEGORIES)));

    {
        _toolTip = _ctrlListSelected lbTooltip _x;
        // Move magazines back into selection if correct category
        if (_toolTip in _currentlySelected) then {
            // Name is magazine display name, picture is magazine icon & tooltip is classname
            _addedIndex = _ctrlListMagazines lbAdd (_ctrlListSelected lbText _x);
            _ctrlListMagazines lbSetPicture [_addedIndex, _ctrlListSelected lbPicture _x];
            _ctrlListMagazines lbSetTooltip [_addedIndex, _toolTip];
        };
    } forEach _selectedArray;

    // When deleting, start from end to beginning, otherwise it messes up
    reverse _selectedArray;

    // Delete entry in original list; Has to be done after, otherwise it messes up
    {
        _ctrlListSelected lbDelete _x;
    } forEach _selectedArray;

    // Sort alphabetically
    lbSort _ctrlListMagazines;
}];

// Clear current selection of magazines
(_display displayCtrl IDC_BUTTON_CLR) ctrlAddEventHandler ["ButtonClick", {
    private _display = ctrlParent (_this select 0);
    // Get selected category
    private _selectedIndex = lbCurSel (_display displayCtrl IDC_LIST_CATEGORIES);

    // Exit if no category was selected
    if (_selectedIndex isEqualTo -1) exitWith {};

    // Clear selected magazines
    lbClear (_display displayCtrl IDC_LIST_SELECTED);

    // Clear displayed magazines from previous category
    private _ctrlListMagazines = _display displayCtrl IDC_LIST_MAGAZINES;
    lbClear _ctrlListMagazines;

    private _cfgMagazines = configFile >> "CfgMagazines";

    // Add all magazines from currently selected category
    {
        // Name is magazine display name, picture is magazine icon & tooltip is classname
         _ctrlListMagazines lbAdd (getText (_cfgMagazines >> _x >> "displayName"));
         _ctrlListMagazines lbSetPicture [_forEachIndex, getText (_cfgMagazines >> _x >> "picture")];
         _ctrlListMagazines lbSetTooltip [_forEachIndex, _x];
    } forEach (GETUVAR(QGVAR(magazinesHashmap),[]) get (GETUVAR(QGVAR(sortedKeys),[]) select _selectedIndex));

    // Sort alphabetically
    lbSort _ctrlListMagazines;
}];

// Using up event is much smoother
(_display displayCtrl IDC_BUTTON_INC) ctrlAddEventHandler ["MouseButtonUp", {
    params ["_ctrlButtonInc", "_button", "", "", "_shift", "_control"];

    // If button is not left click, exit
    if (_button isNotEqualTo 0) exitWith {};

    private _ctrlListSelected = (ctrlParent _ctrlButtonInc) displayCtrl IDC_LIST_SELECTED;
    private _selectedArray = lbSelection _ctrlListSelected;

    // Exit if nothing selected
    if (_selectedArray isEqualTo []) exitWith {};

    private _inc = 1;

    // Determine increments
    if (_shift) then {
        if (_control) then {
            _inc = 50;
        } else {
            _inc = 5;
        };
    } else {
        if (_control) then {
            _inc = 10;
        };
    };

    private _cfgMagazines = configFile >> "CfgMagazines";
    private _value = 0;

    {
        // Get old value and increment it
        _value = (_ctrlListSelected lbValue _x) + _inc;
        _ctrlListSelected lbSetValue [_x, _value];
        _ctrlListSelected lbSetText [_x, format ["%1x %2", _value, getText (_cfgMagazines >> _ctrlListSelected lbTooltip _x >> "displayName")]];
    } forEach _selectedArray;
}];

// Using up event is much smoother
(_display displayCtrl IDC_BUTTON_DEC) ctrlAddEventHandler ["MouseButtonUp", {
    params ["_ctrlButtonDec", "_button", "", "", "_shift", "_control"];

    // If button is not left click, exit
    if (_button isNotEqualTo 0) exitWith {};

    private _ctrlListSelected = (ctrlParent _ctrlButtonInc) displayCtrl IDC_LIST_SELECTED;
    private _selectedArray = lbSelection _ctrlListSelected;

    // Exit if nothing selected
    if (_selectedArray isEqualTo []) exitWith {};

    private _inc = -1;

    // Determine increments
    if (_shift) then {
        if (_control) then {
            _inc = -50;
        } else {
            _inc = -5;
        };
    } else {
        if (_control) then {
            _inc = -10;
        };
    };

    private _cfgMagazines = configFile >> "CfgMagazines";
    private _value = 0;

    {
        // Get old value and decrement it; if below 0, set to 0
        _value = ((_ctrlListSelected lbValue _x) + _inc) max 0;
        _ctrlListSelected lbSetValue [_x, _value];
        // Do not show "0x"
        _ctrlListSelected lbSetText [_x, format ["%1%2", ["", format ["%1x ", _value]] select (_value isNotEqualTo 0), getText (_cfgMagazines >> _ctrlListSelected lbTooltip _x >> "displayName")]];
    } forEach _selectedArray;
}];

// Add display EH for Enter and Escape buttons
_display displayAddEventHandler ["KeyDown", {
    params ["_display", "_keyCode"];

    // Cancel
    if (_keyCode isEqualTo DIK_ESCAPE) exitWith {
        ["Only launcher ammunition spawned"] call zen_common_fnc_showMessage;

        false;
    };

    // Ok
    if (_keyCode isEqualTo DIK_RETURN) exitWith {
        private _ctrlListSelected = _display displayCtrl IDC_LIST_SELECTED;
        private _object = GETUVAR(QGVAR(magazineInventory),objNull);

        // Spawn in magazines
        for "_i" from 0 to (lbSize _ctrlListSelected - 1) step 1 do {
            _object addItemCargoGlobal [_ctrlListSelected lbTooltip _i, _ctrlListSelected lbValue _i];
        };

        ["Ammo crate created"] call zen_common_fnc_showMessage;

        _display closeDisplay IDC_OK;

        false;
    };

    false;
}];
