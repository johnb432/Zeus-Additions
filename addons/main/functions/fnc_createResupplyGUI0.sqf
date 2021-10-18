[] spawn {

disableSerialization;

private _POS_CALC = ((safezoneW / safezoneH) min 1.2);
private _X_OFF = (safezoneX + (safezoneW - _POS_CALC) / 2);
private _Y_OFF = (safezoneY + (safezoneH - (_POS_CALC / 1.2)) / 2);
private _W_OFF = (_POS_CALC / 40);
private _H_OFF = (_POS_CALC / 30); // (_POS_CALC / 1.2) / 25

// Get magazines for resupply module
private _keys = [];
private _values = [];
private _magazinesList = [];
private _cfgMagazines = configFile >> "CfgMagazines";

{
    _magazinesList = [];

    {
        // Remove non-existent magazines; Then get case-senstive names of magazines to avoid problems
        _magazinesList append (((getArray _x) select {isClass (_cfgMagazines >> _x)}) apply {configName (_cfgMagazines >> _x)});
    } foreach configProperties [_x, "isArray _x", true];

    // Remove duplicates
    _magazinesList = _magazinesList arrayIntersect _magazinesList;

    // Add magazinewells and magazines themselves to hashmap only if it has items
    if (_magazinesList isNotEqualTo []) then {
        _keys pushBack configName _x;
        _values pushBack _magazinesList;
    };
} foreach configProperties [(configFile >> "CfgMagazineWells"), "isClass _x", true];

// Store hashmap with all info necessary
uiNamespace setVariable ["zeus_additions_magazinesHashmap", _keys createHashMapFromArray _values];

// Sort alphabetically
_keys sort true;
uiNamespace setVariable ["zeus_additions_sortedKeys", _keys];

// Dialog creation
private _display = findDisplay 46 createDisplay "RscDisplayEmpty";

if (isNull _display) exitWith {};

// Create group control
private _ctrlGroup = _display ctrlCreate ["RscControlsGroupNoHScrollbars", -1];
_ctrlGroup ctrlSetPosition [-2 * _W_OFF + _X_OFF, 0, 44.2 * _W_OFF, 21.3 * _H_OFF];
_ctrlGroup ctrlCommit 0;

// Title background
private _ctrlBackgroundTitle = _display ctrlCreate ["RscTextMulti", -1, _ctrlGroup];
_ctrlBackgroundTitle ctrlSetText "SELECT MAGAZINES";
_ctrlBackgroundTitle ctrlSetPosition [0, 0, 44.2 * _W_OFF, 1 * _H_OFF];
_ctrlBackgroundTitle ctrlSetBackgroundColor [0.13, 0.54, 0.21, 0.8];
_ctrlBackgroundTitle ctrlEnable false;
_ctrlBackgroundTitle ctrlCommit 0;

// Main background
private _ctrlBackground = _display ctrlCreate ["RscTextMulti", -1, _ctrlGroup];
_ctrlBackground ctrlSetPosition [0, 1.1 * _H_OFF + _Y_OFF, 44.2 * _W_OFF, 18.9 * _H_OFF];
_ctrlBackground ctrlSetBackgroundColor [0, 0, 0, 0.5];
_ctrlBackground ctrlEnable false;
_ctrlBackground ctrlCommit 0;

// Lists and their background
// Categories list
private _ctrlListCategories = _display ctrlCreate ["RscListBox", -1, _ctrlGroup];
_ctrlListCategories ctrlSetPosition [7.8 * _W_OFF + _X_OFF, 1.5 * _H_OFF + _Y_OFF, 12.5 * _W_OFF, 18 * _H_OFF];
_ctrlListCategories ctrlSetBackgroundColor [0, 0, 0, 0.6];
_ctrlListCategories ctrlCommit 0;
_ctrlListCategories ctrlAddEventHandler ["LBSelChanged", {
    disableSerialization;

    params ["_ctrl", "_selectedIndex"];

    [_ctrl, _selectedIndex] spawn {
        params ["_ctr", "_selectedIndex"];

        private _ctrl = uiNamespace getVariable ["zeus_additions_ctrlListMagazines", controlNull];

        diag_log text format ["ctrlListCategories, LBSelChanged: %1, %2, %3, %4", _ctr, _selectedIndex, _ctrl, lbSelection _ctrl];

        if (isNull _ctrl) exitWith {};

        // Deselect everything to avoid crashing
        //private _curSelection = lbSelection _ctrl;

        //if (_curSelection isNotEqualTo []) then {
            //{
            //    _ctrl lbSetSelected [_x, false];
            //} forEach _curSelection;
        //};

        //waitUntil {lbSelection _ctrl isEqualTo []};

        // Clear displayed magazines from previous category; lbClear causes crash
        diag_log text "clearing";

        private _size = lbSize _ctrl;

        if (_size isNotEqualTo 0) then {
            //for "_i" from (_size - 1) to 0 step -1 do {
                // //_ctrl lbSetValue [_i, 0];
                //_ctrl lbDelete _i;
            //};

            lbClear _ctrl;
        };

        waitUntil {lbSize _ctrl isEqualTo 0};

        diag_log text "cleared";

        private _ctrlListSelected = uiNamespace getVariable ["zeus_additions_ctrlListSelected", controlNull];

        if (isNull _ctrlListSelected) exitWith {};

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
            diag_log text format ["adding: %1, %2, %3, %4", _forEachIndex, _x, isText (_cfgMagazines >> _x >> "displayName"), isText (_cfgMagazines >> _x >> "picture")];

            // Don't add magazines that are in the selected list
            if (_x in _selectedMagazines) then {
                continue;
            };

            diag_log text "checked";

            _addedIndex = _ctrl lbAdd (getText (_cfgMagazines >> _x >> "displayName"));
            diag_log text "lbAdd";

            _ctrl lbSetPicture [_addedIndex, getText (_cfgMagazines >> _x >> "picture")];
            _ctrl lbSetTooltip [_addedIndex, _x];
            _ctrl lbSetValue [_addedIndex, 0];
        } forEach ((uiNamespace getVariable ["zeus_additions_magazinesHashmap", []]) get ((uiNamespace getVariable ["zeus_additions_sortedKeys", []]) select _selectedIndex));

        diag_log text "finished added";

        // Sort alphabetically
        lbSort _ctrl;

        diag_log text "sorted";
    };
}];
uiNamespace setVariable ["zeus_additions_ctrlListCategories", _ctrlListCategories];

// Add items to list
{
    _ctrlListCategories lbAdd _x;
} forEach (uiNamespace getVariable ["zeus_additions_sortedKeys", []]);

private _ctrlBackgroundListCategory = _display ctrlCreate ["RscTextMulti", -1, _ctrlGroup];
_ctrlBackgroundListCategory ctrlSetPosition [4 * _W_OFF + _X_OFF, 1.5 * _H_OFF + _Y_OFF, 3.7 * _W_OFF, 18 * _H_OFF];
_ctrlBackgroundListCategory ctrlSetBackgroundColor [0, 0, 0, 0.6];
_ctrlBackgroundListCategory ctrlSetText "Categories:";
_ctrlBackgroundListCategory ctrlSetTooltip "Allows you select different categories of magazines.";
_ctrlBackgroundListCategory ctrlEnable false;
_ctrlBackgroundListCategory ctrlCommit 0;

// Magazines list for categories
private _ctrlListMagazines = _display ctrlCreate ["RscListBoxMulti", -1, _ctrlGroup];
_ctrlListMagazines ctrlSetPosition [20.5 * _W_OFF + _X_OFF, 1.5 * _H_OFF + _Y_OFF, 12.5 * _W_OFF, 18 * _H_OFF];
_ctrlListMagazines ctrlSetBackgroundColor [0, 0, 0, 0.6];
_ctrlListMagazines ctrlCommit 0;
_ctrlListMagazines ctrlAddEventHandler ["LBDblClick", {
    params ["_ctrl", "_selectedIndex"];

    diag_log text format ["ctrlListMagazines, LBDblClick: %1, %2", _ctrl, _selectedIndex];

    private _ctrlListSelected = uiNamespace getVariable ["zeus_additions_ctrlListSelected", controlNull];

    if (isNull _ctrlListSelected) exitWith {};

    // Name is magazine display name, picture is magazine icon & tooltip is classname & set value to 0; Value is used for storing how many mags will be spawned
    private _addedIndex = _ctrlListSelected lbAdd (_ctrl lbText _selectedIndex);
    _ctrlListSelected lbSetPicture [_addedIndex, _ctrl lbPicture _selectedIndex];
    _ctrlListSelected lbSetTooltip [_addedIndex, _ctrl lbTooltip _selectedIndex];
    _ctrl lbSetValue [_addedIndex, 0];

    // Sort alphabetically
    lbSort _ctrlListSelected;

    // Delete entry in original list
    _ctrl lbDelete _selectedIndex;
}];
uiNamespace setVariable ["zeus_additions_ctrlListMagazines", _ctrlListMagazines];

// List for selected magazines
private _ctrlListSelected = _display ctrlCreate ["RscListBoxMulti", -1, _ctrlGroup];
_ctrlListSelected ctrlSetPosition [34.5 * _W_OFF + _X_OFF, 1.5 * _H_OFF + _Y_OFF, 12.5 * _W_OFF, 18 * _H_OFF];
_ctrlListSelected ctrlSetBackgroundColor [0, 0, 0, 0.6];
_ctrlListSelected ctrlCommit 0;
_ctrlListSelected ctrlAddEventHandler ["LBDblClick", {
    params ["_ctrl", "_selectedIndex"];

    diag_log text format ["ctrlListSelected, LBDblClick: %1, %2", _ctrl, _selectedIndex];

    private _ctrlListMagazines = uiNamespace getVariable ["zeus_additions_ctrlListMagazines", controlNull];
    private _toolTip = _ctrl lbTooltip _selectedIndex;

    // Move magazines back into selection if correct category
    if (_toolTip in ((uiNamespace getVariable ["zeus_additions_magazinesHashmap", []]) get ((uiNamespace getVariable ["zeus_additions_sortedKeys", []]) select (lbCurSel (uiNamespace getVariable ["zeus_additions_ctrlListCategories", controlNull]))))) then {
        // Name is magazine display name, picture is magazine icon & tooltip is classname
        private _addedIndex = _ctrlListMagazines lbAdd (_ctrl lbText _selectedIndex);
        _ctrlListMagazines lbSetPicture [_addedIndex, _ctrl lbPicture _selectedIndex];
        _ctrlListMagazines lbSetTooltip [_addedIndex, _toolTip];
    };

    // Sort alphabetically
    lbSort _ctrlListMagazines;

    // Delete entry in original list
    _ctrl lbDelete _selectedIndex;
}];
uiNamespace setVariable ["zeus_additions_ctrlListSelected", _ctrlListSelected];

// Buttons
private _ctrlButtonOk = _display ctrlCreate ["RscButtonMenu", -1, _ctrlGroup];
_ctrlButtonOk ctrlSetPosition [42.75 * _W_OFF + _X_OFF, 20.1 * _H_OFF + _Y_OFF, 4.8 * _W_OFF, 1.2 * _H_OFF];
_ctrlButtonOk ctrlSetBackgroundColor [0, 0, 0, 0.7];
_ctrlButtonOk ctrlSetFont "PuristaLight";
_ctrlButtonOk ctrlSetText "OK";
_ctrlButtonOk ctrlCommit 0;
_ctrlButtonOk ctrlAddEventHandler ["ButtonClick", {
    params ["_ctrl"];

    private _display = ctrlParent _ctrl;

    diag_log text format ["ctrlButtonOk, ButtonClick: %1, %2", _ctrl, _display];

    _ctrls = uiNamespace getVariable ["zeus_additions_ctrlListSelected", controlNull];

    // Do stuff with selection

    _display closeDisplay 1;
}];

private _ctrlButtonCancel = _display ctrlCreate ["RscButtonMenu", -1, _ctrlGroup];
_ctrlButtonCancel ctrlSetPosition [3.3 * _W_OFF + _X_OFF, 20.1 * _H_OFF + _Y_OFF, 5 * _W_OFF, 1.2 * _H_OFF];
_ctrlButtonCancel ctrlSetBackgroundColor [0, 0, 0, 0.7];
_ctrlButtonCancel ctrlSetFont "PuristaLight";
_ctrlButtonCancel ctrlSetText "CANCEL";
_ctrlButtonCancel ctrlCommit 0;
_ctrlButtonCancel ctrlAddEventHandler ["ButtonClick", {
    diag_log text format ["ctrlButtonCancel, ButtonClick: %1", _this select 0];
    ["Only launcher ammunition spawned"] call zen_common_fnc_showMessage;

    (ctrlParent (_this select 0)) closeDisplay 2;
}];

// Move chosen magazines from magazine list into selected magazines list
private _ctrlButtonMoveIntoSelected = _display ctrlCreate ["RscButtonMenu", -1, _ctrlGroup];
_ctrlButtonMoveIntoSelected ctrlSetPosition [33.2 * _W_OFF + _X_OFF, 10 * _H_OFF + _Y_OFF, 1.2 * _W_OFF, 1.2 * _H_OFF];
_ctrlButtonMoveIntoSelected ctrlSetBackgroundColor [0, 0, 0, 0.7];
_ctrlButtonMoveIntoSelected ctrlSetFont "PuristaLight";
_ctrlButtonMoveIntoSelected ctrlSetText ">";
_ctrlButtonMoveIntoSelected ctrlCommit 0;
_ctrlButtonMoveIntoSelected ctrlAddEventHandler ["ButtonClick", {
    diag_log text format ["ctrlButtonMoveIntoSelected, ButtonClick: %1", _this select 0];

    // Get current selection
    private _ctrl = uiNamespace getVariable ["zeus_additions_ctrlListMagazines", controlNull];
    private _selectedArray = lbSelection _ctrl;

    // Exit if nothing selected
    if (_selectedArray isEqualTo []) exitWith {};

    // Get new list
    private _ctrlListSelected = uiNamespace getVariable ["zeus_additions_ctrlListSelected", controlNull];
    private _addedIndex = -1;
    private _toolTip = "";
    private _cfgMagazines = configFile >> "CfgMagazines";

    {
        // Name is magazine display name, picture is magazine icon & tooltip is classname
        _toolTip = _ctrl lbTooltip _x;
        _addedIndex = _ctrlListSelected lbAdd (getText (_cfgMagazines >> _toolTip >> "displayName"));
        _ctrlListSelected lbSetPicture [_addedIndex, _ctrl lbPicture _x];
        _ctrlListSelected lbSetTooltip [_addedIndex, _toolTip];
    } forEach _selectedArray;

    // When deleting, start from end to beginning, otherwise it messes up
    reverse _selectedArray;

    // Delete entry in original list; Has to be done after, otherwise it messes up
    {
        _ctrl lbDelete _x;
    } forEach _selectedArray;

    // Sort alphabetically
    lbSort _ctrlListSelected;
}];

// Remove chosen magazines from selected magazines list
private _ctrlButtonMoveOutOfSelected = _display ctrlCreate ["RscButtonMenu", -1, _ctrlGroup];
_ctrlButtonMoveOutOfSelected ctrlSetPosition [33.2 * _W_OFF + _X_OFF, 12 * _H_OFF + _Y_OFF, 1.2 * _W_OFF, 1.2 * _H_OFF];
_ctrlButtonMoveOutOfSelected ctrlSetBackgroundColor [0, 0, 0, 0.7];
_ctrlButtonMoveOutOfSelected ctrlSetFont "PuristaLight";
_ctrlButtonMoveOutOfSelected ctrlSetText "<";
_ctrlButtonMoveOutOfSelected ctrlCommit 0;
_ctrlButtonMoveOutOfSelected ctrlAddEventHandler ["ButtonClick", {
    diag_log text format ["ctrlButtonMoveOutOfSelected, ButtonClick: %1", _this select 0];

    // Get current selection
    private _ctrl = uiNamespace getVariable ["zeus_additions_ctrlListSelected", controlNull];
    private _selectedArray = lbSelection _ctrl;

    // Exit if nothing selected
    if (_selectedArray isEqualTo []) exitWith {};

    // Get new list
    private _ctrlListMagazines = uiNamespace getVariable ["zeus_additions_ctrlListMagazines", controlNull];
    private _addedIndex = -1;
    private _toolTip = "";

    {
        _toolTip = _ctrl lbTooltip _x;
        // Move magazines back into selection if correct category
        if (_toolTip in ((uiNamespace getVariable ["zeus_additions_magazinesHashmap", []]) get ((uiNamespace getVariable ["zeus_additions_sortedKeys", []]) select (lbCurSel (uiNamespace getVariable ["zeus_additions_ctrlListCategories", controlNull]))))) then {
            // Name is magazine display name, picture is magazine icon & tooltip is classname
            _addedIndex = _ctrlListMagazines lbAdd (_ctrl lbText _x);
            _ctrlListMagazines lbSetPicture [_addedIndex, _ctrl lbPicture _x];
            _ctrlListMagazines lbSetTooltip [_addedIndex, _toolTip];
        };
    } forEach _selectedArray;

    // When deleting, start from end to beginning, otherwise it messes up
    reverse _selectedArray;

    // Delete entry in original list; Has to be done after, otherwise it messes up
    {
        _ctrl lbDelete _x;
    } forEach _selectedArray;

    // Sort alphabetically
    lbSort _ctrlListMagazines;
}];

// Clear current selection of magazines
private _ctrlButtonClear = _display ctrlCreate ["ctrlButtonPicture", -1, _ctrlGroup];
_ctrlButtonClear ctrlSetPosition [33.2 * _W_OFF + _X_OFF, 8 * _H_OFF + _Y_OFF, 1.2 * _W_OFF, 1.2 * _H_OFF];
_ctrlButtonClear ctrlSetBackgroundColor [0, 0, 0, 0.7];
_ctrlButtonClear ctrlSetFont "PuristaLight";
_ctrlButtonClear ctrlSetText "\a3\3den\data\cfg3den\history\deleteitems_ca.paa";
_ctrlButtonClear ctrlCommit 0;
_ctrlButtonClear ctrlAddEventHandler ["ButtonClick", {
    diag_log text format ["ctrlButtonClear, ButtonClick: %1", _this select 0];
    // Get selected category
    private _selectedIndex = lbCurSel (uiNamespace getVariable ["zeus_additions_ctrlListCategories", controlNull]);

    // Exit if no category was selected
    if (_selectedIndex isEqualTo -1) exitWith {};

    private _ctrl = uiNamespace getVariable ["zeus_additions_ctrlListSelected", controlNull];

    // Clear selected magazines
    lbClear _ctrl;

    _ctrl = uiNamespace getVariable ["zeus_additions_ctrlListMagazines", controlNull];

    // Clear displayed magazines from previous category
    lbClear _ctrl;

    private _cfgMagazines = configFile >> "CfgMagazines";

    // Add all magazines from currently selected category
    {
        // Name is magazine display name, picture is magazine icon & tooltip is classname
         _ctrl lbAdd (getText (_cfgMagazines >> _x >> "displayName"));
         _ctrl lbSetPicture [_forEachIndex, getText (_cfgMagazines >> _x >> "picture")];
         _ctrl lbSetTooltip [_forEachIndex, _x];
    } forEach ((uiNamespace getVariable ["zeus_additions_magazinesHashmap", []]) get ((uiNamespace getVariable ["zeus_additions_sortedKeys", []]) select _selectedIndex));

    // Sort alphabetically
    lbSort _ctrl;
}];

private _ctrlButtonIncrement = _display ctrlCreate ["RscButtonMenu", -1, _ctrlGroup];
_ctrlButtonIncrement ctrlSetPosition [33.2 * _W_OFF + _X_OFF, 1.5 * _H_OFF + _Y_OFF, 1.2 * _W_OFF, 1.2 * _H_OFF];
_ctrlButtonIncrement ctrlSetBackgroundColor [0, 0, 0, 0.7];
_ctrlButtonIncrement ctrlSetFont "PuristaLight";
_ctrlButtonIncrement ctrlSetText "+";
_ctrlButtonIncrement ctrlCommit 0;
// Using up event is much smoother, although it means one frame must be waited for getting valid selection
_ctrlButtonIncrement ctrlAddEventHandler ["MouseButtonUp", {
    params ["", "_button", "", "", "_shift", "_control"];

    diag_log text format ["ctrlButtonIncrement, MouseButtonUp: %1", _button];

    // If button is not left click, exit
    if (_button isNotEqualTo 0) exitWith {};

    [{
        params ["_shift", "_control"];

        private _ctrl = uiNamespace getVariable ["zeus_additions_ctrlListSelected", controlNull];

        private _selectedArray = lbSelection _ctrl;

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
            _value = (_ctrl lbValue _x) + _inc;
            _ctrl lbSetValue [_x, _value];
            _ctrl lbSetText [_x, format ["%1x %2", _value, getText (_cfgMagazines >> _ctrl lbTooltip _x >> "displayName")]];
        } forEach _selectedArray;
    }, [_shift, _control]] call CBA_fnc_execNextFrame;
}];

private _ctrlButtonDecrement = _display ctrlCreate ["RscButtonMenu", -1, _ctrlGroup];
_ctrlButtonDecrement ctrlSetPosition [33.2 * _W_OFF + _X_OFF, 3.0 * _H_OFF + _Y_OFF, 1.2 * _W_OFF, 1.2 * _H_OFF];
_ctrlButtonDecrement ctrlSetBackgroundColor [0, 0, 0, 0.7];
_ctrlButtonDecrement ctrlSetFont "PuristaLight";
_ctrlButtonDecrement ctrlSetText "-";
_ctrlButtonDecrement ctrlCommit 0;
// Using up event is much smoother, although it means one frame must be waited for getting valid selection
_ctrlButtonDecrement ctrlAddEventHandler ["MouseButtonUp", {
    params ["", "_button", "", "", "_shift", "_control"];

    diag_log text format ["ctrlButtonDecrement, MouseButtonUp: %1", _button];

    // If button is not left click, exit
    if (_button isNotEqualTo 0) exitWith {};

    [{
        params ["_shift", "_control"];

        private _ctrl = uiNamespace getVariable ["zeus_additions_ctrlListSelected", controlNull];

        private _selectedArray = lbSelection _ctrl;

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
            _value = ((_ctrl lbValue _x) + _inc) max 0;
            _ctrl lbSetValue [_x, _value];
            // Do not show "0x"
            _ctrl lbSetText [_x, format ["%1%2", ["", format ["%1x ", _value]] select (_value isNotEqualTo 0), getText (_cfgMagazines >> _ctrl lbTooltip _x >> "displayName")]];
        } forEach _selectedArray;
    }, [_shift, _control]] call CBA_fnc_execNextFrame;
}];

// Add display EH for Enter and Escape buttons
_display displayAddEventHandler ["KeyDown", {
    params ["_display", "_keyCode"];

    diag_log text format ["displayKeysID, KeyDown: %1", _keyCode];

    // Cancel
    if (_keyCode isEqualTo 0x01) then {
        //["Only launcher ammunition spawned"] call zen_common_fnc_showMessage;

        _display closeDisplay 2;
    };

    // Ok
    if (_keyCode isEqualTo 0x1C) then {
        private _ctrl = uiNamespace getVariable ["zeus_additions_ctrlListSelected", controlNull];
        private _object = uiNamespace getVariable ["zeus_additions_magazineInveotry", objNull];

        // Spawn in magazines
        for "_i" from 0 to (lbSize _ctrl - 1) step 1 do {
            _object addItemCargoGlobal [_ctrl lbTooltip _i, _ctrl lbValue _i];
        };

        //["Ammo crate created"] call zen_common_fnc_showMessage;

        _display closeDisplay 1;
    };

    false;
}];

};
