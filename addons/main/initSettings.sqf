#define MAGAZINES_SETTINGS(NAME,INDEX)\
[\
    QGVAR(DOUBLES(NAME,mags)),\
    "EDITBOX",\
    [format ["%1 Ammunition", QUOTE(NAME)], "Used for the 'Spawn Ammo Resupply Crate' module. Must be an array of strings."],\
    [COMPONENT_NAME, MAGAZINES_DESC],\
    str GVAR(NAME),\
    0,\
    {\
        private _list = if (!isNil "_this") then {\
            if (_this isEqualType "") then {\
                parseSimpleArray _this;\
            } else {\
                [[], _this] select (_this isEqualType []);\
            };\
        };\
        GVAR(magsTotal) set [INDEX, _list];\
    }\
] call CBA_fnc_addSetting

#define HINT_SETTINGS(NAME,TEXT)\
[\
    QGVAR(NAME),\
    "CHECKBOX",\
    [TEXT, "Allows to toggle the hint on or off."],\
    [COMPONENT_NAME, "Modules"],\
    true\
] call CBA_fnc_addSetting

[
    QGVAR(enableExitUnconsciousUnit),
    "CHECKBOX",
    ["Enable leave unconscious unit", "Allows people to leave an unconscious remote controlled unit by pressing the ESCAPE key."],
    [COMPONENT_NAME, "Units"],
    false,
    0,
    {
        call FUNC(exitUnconsciousUnit);
    }
] call CBA_fnc_addSetting;

[
    QGVAR(enableJIP),
    "CHECKBOX",
    ["Enable JIP features", "Allows join-in-progress (JIP) functionality for some modules.\nIt requires a mission restart for it to be turned off."],
    [COMPONENT_NAME, "Modules"],
    false,
    0,
    {
        // If setting is off, already added or no curator object, don't do anything
        if !(_this && {!isNull (getAssignedCuratorLogic player)}) exitWith {};

        call FUNC(handleJIP);
    }
] call CBA_fnc_addSetting;

[
    QGVAR(enableMissionCounter),
    "CHECKBOX",
    ["Enable Mission Object Counter", "If enabled, all objects placed and deleted by the player's curator will be kept track of.\nIf turned off, it will remove everything related to the counter, but not resetting the counter in the process."],
    [COMPONENT_NAME, "Modules"],
    false,
    0,
    {
        private _curator = getAssignedCuratorLogic player;

        // If there is no curator object, don't do anything
        if (isNull _curator) exitWith {};

        // If setting is off and there is stuff still there, remove it
        if (!_this && {!isNil QGVAR(curatorHandleIDs)}) exitWith {
            GVAR(curatorHandleIDs) params ["_handleID1", "_handleID2", "_handleID3", "_handleID4"];

            _curator removeEventHandler ["CuratorObjectDeleted", _handleID1];
            _curator removeEventHandler ["CuratorObjectPlaced", _handleID2];
            _curator removeEventHandler ["CuratorGroupPlaced", _handleID3];
            _curator removeEventHandler ["CuratorPinged", _handleID4];

            GVAR(curatorHandleIDs) = nil;
        };

        call FUNC(objectsCounterMissionEH);
    }
] call CBA_fnc_addSetting;

[
    QGVAR(blacklistFKEnable),
    "CHECKBOX",
    ["Enable automatic blacklist detection for FK servers", "Allows the automatic adoption of the premade blacklist on FK servers. FK is an EU based unit."],
    [COMPONENT_NAME, MAGAZINES_DESC],
    false,
    0,
    {
        if (_this && {!isNil {"FKF/CfgArsenalBlacklist" call Clib_fnc_getSettings}}) then {
            GVAR(blacklist) = [];

            {
                GVAR(blacklist) append ((format ["FKF/CfgArsenalBlacklist/%1", _x]) call Clib_fnc_getSetting);
            } forEach ("FKF/CfgArsenalBlacklist" call Clib_fnc_getSettings);
        } else {
            GVAR(blacklist) = if (GVAR(blacklistSettings) isEqualType "") then {
                parseSimpleArray GVAR(blacklistSettings);
            } else {
                [[], GVAR(blacklistSettings)] select (GVAR(blacklistSettings) isEqualType []);
            };
        };
    }
] call CBA_fnc_addSetting;

[
    QGVAR(blacklistSettings),
    "EDITBOX",
    ["Blacklist for ammo resupply", "Filters whatever is in the box out of the resupply crate, only applies to the 'Spawn Ammo Resupply for unit' module. Must be an array of strings."],
    [COMPONENT_NAME, MAGAZINES_DESC],
    "[]",
    0,
    {
        if (GVAR(blacklistFKEnable) && {!isNil {"FKF/CfgArsenalBlacklist" call Clib_fnc_getSettings}}) exitWith {};

        GVAR(blacklist) = if (_this isEqualType "") then {
            parseSimpleArray _this;
        } else {
            [[], _this] select (_this isEqualType []);
        };
    }
] call CBA_fnc_addSetting;

MAGAZINES_SETTINGS(LATBLU,0);
MAGAZINES_SETTINGS(LATRED,1);
MAGAZINES_SETTINGS(MATBLU,2);
MAGAZINES_SETTINGS(MATRED,3);
MAGAZINES_SETTINGS(HATBLU,4);
MAGAZINES_SETTINGS(HATRED,5);
MAGAZINES_SETTINGS(AABLU,6);
MAGAZINES_SETTINGS(AARED,7);

HINT_SETTINGS(enableACECargoHint,"Enable ACE Cargo missing addon hint");
HINT_SETTINGS(enableACEDragHint,"Enable ACE Dragging missing addon hint");
HINT_SETTINGS(enableACEMedicalHint,"Enable ACE Medical missing addon hint");
HINT_SETTINGS(enableSnowScriptHint,"Enable Snow Script missing addon hint");
HINT_SETTINGS(enableTFARHint,"Enable Radio Range Script missing addon hint");
HINT_SETTINGS(enableRHSHint,"Enable RHS APS Script addon missing hint");
