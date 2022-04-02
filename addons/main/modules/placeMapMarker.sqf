/*
 * Author: johnb43
 * Creates a module that allows the Zeus to place down markers more easily.
 */

["Zeus Additions - Utility", "Place Map Markers", {
    ["Place Map Markers", [
        ["OWNERS", ["Select sides or groups", "Select sides/groups. Group will have priority over side. It will disregard player selection."], [[], [], [], 0], true]
    ],
    {
        params ["_results"];
        _results params ["_selected"];
        _selected params ["_sides", "_groups"];

        // If no side or group is selected, exit
        if (_sides isEqualTo [] && {_groups isEqualTo []}) exitWith {
            ["Select a side or group!"] call zen_common_fnc_showMessage;
            playSound "FD_Start_F";
        };

        // Looks if a group or a side was selected. If both were selected, group has priority
        private _isGroup = _groups isNotEqualTo [];

        // Create unit based on which side we want to make a marker in; Important for group markers
        private _unitType = switch ([_sides select 0, side (_groups select 0)] select _isGroup) do {
            case west: {"B_Survivor_F"};
            case east: {"O_Survivor_F"};
            case independent: {"I_Survivor_F"};
            default {"C_man_1"};
        };

        // Create a helper unit to open map and place marker from there; Make unit join specific group for group markers
        private _group = [createGroup (_sides select 0), _groups select 0] select _isGroup;
        private _helperUnit = _group createUnit [_unitType, getPosASL curatorCamera, [], 0, "CAN_COLLIDE"];
        [_helperUnit] joinSilent _group;

        // Remove anything unnecessary; Add map and watch (for timestamp markers)
        removeAllWeapons _helperUnit;
        removeAllAssignedItems _helperUnit;
        removeAllContainers _helperUnit;
        removeHeadgear _helperUnit;
        removeGoggles _helperUnit;
        _helperUnit linkItem "ItemMap";
        _helperUnit linkItem "ItemWatch";

        // Do not allow the unit to move or interact with other objects; Make invisible and invincible
        _helperUnit enableSimulationGlobal false;
        _helperUnit allowDamage false;
        [_helperUnit, false] remoteExecCall ["hideObjectGlobal", 2];

        // Save old player object
        private _oldPlayer = player;
        private _isDamageAllowed = isDamageAllowed _oldPlayer;

        // Start remote controlling
        selectPlayer _helperUnit;

        _oldPlayer disableAI "ALL";
        _oldPlayer enableAI "ANIM";
        _oldPlayer allowDamage false;

        // Add default channels
        private _channelIDs = [0, 1, 2, 3, 4, 5];
        private _channelUnitList = [];

        // Add custom channels if existent and get their units
        for "_i" from 1 to 10 step 1 do {
            (radioChannelInfo _i) params ["", "", "", "_units", "", "_exists"];

            if (_exists) then {
                _channelIDs pushBack (_i + 5);
                _channelUnitList pushBack (_helperUnit in _units);
            };
        };

        // Get the previous settings, so they can be reversed later
        private _channelSettings = _channelIDs apply {channelEnabled _x};

        // Enable all channels whilst adding/editing markers
        {
            (_channelIDs select _forEachIndex) enableChannel [true, _x select 1];
        } forEach _channelSettings;

        // Add helper to custom channels if he didn't have access to them before; Null objects are automatically removed from list
        {
            if (!_x) then {
                _forEachIndex radioChannelAdd [_helperUnit];
            };
        } forEach _channelUnitList;

        // Set the channel according to what was chosen (side or group)
        setCurrentChannel ([1, 3] select _isGroup);

        [{
            // Wait until the Zeus interface is closed
            isNull (findDisplay IDD_RSCDISPLAYCURATOR);
        }, {
            // Open map when unit is being controlled
            openMap true;

            // Does not get triggered by the command above
            addMissionEventHandler ["Map", {
                _thisArgs params ["_helperUnit", "_oldPlayer", "_isDamageAllowed", "_channelSettings", "_channelIDs"];

                // Remove EH
                removeMissionEventHandler ["Map", _thisEventHandler];

                // Return channel settings to previous settings
                {
                    (_channelIDs select _forEachIndex) enableChannel _x;
                } forEach _channelSettings;

                // Switch back to old player
                selectPlayer _oldPlayer;

                _oldPlayer enableAI "ALL";
                _oldPlayer allowDamage _isDamageAllowed;

                [{
                    // Open curator interface
                    openCuratorInterface;

                    [{
                        // Remove helper unit
                        deleteVehicle _this;
                    }, _this] call CBA_fnc_execNextFrame;
                }, _helperUnit] call CBA_fnc_execNextFrame;
            }, _this];
        }, [_helperUnit, _oldPlayer, _isDamageAllowed, _channelSettings, _channelIDs]] call CBA_fnc_waitUntilAndExecute;
    }, {
        ["Aborted"] call zen_common_fnc_showMessage;
        playSound "FD_Start_F";
    }] call zen_dialog_fnc_create;
}, ICON_DOCUMENTS] call zen_custom_modules_fnc_register;
