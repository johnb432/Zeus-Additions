#define MAGAZINES_SETTINGS(NAME)\
[\
    QGVAR(DOUBLES(NAME,mags)),\
    "EDITBOX",\
    [format ["%1 Magazines", QUOTE(NAME)], RESUPPY_DESC],\
    [COMPONENT_NAME, MAGAZINES_DESC],\
    str GVAR(NAME)\
] call CBA_fnc_addSetting

[
    QGVAR(enableExitUnconsciousUnit),
    "CHECKBOX",
    ["Enable leave unconscious unit", "Allows people to leave an unconscious remote controlled unit by pressing the ESCAPE key."],
    [COMPONENT_NAME, "Units"],
    false,
    false,
    {
        call FUNC(exitUnconsciousUnit);
    }
] call CBA_fnc_addSetting;

[
    QGVAR(enableNoCuratorHint),
    "CHECKBOX",
    ["Enable no curator found hint", "Allows to toggle the hint on or off."],
    [COMPONENT_NAME, "Modules"],
    true,
    false
] call CBA_fnc_addSetting;

[
    QGVAR(enableSnowScriptHint),
    "CHECKBOX",
    ["Enable Snow Script missing addon hint", "Allows to toggle the hint on or off."],
    [COMPONENT_NAME, "Modules"],
    true,
    false
] call CBA_fnc_addSetting;

[
    QGVAR(enableTFARHint),
    "CHECKBOX",
    ["Enable TFAR addon missing hint", "Allows to toggle the hint on or off."],
    [COMPONENT_NAME, "Modules"],
    true,
    false
] call CBA_fnc_addSetting;

[
    QGVAR(enableJIP),
    "CHECKBOX",
    ["Enable JIP features", "Allows join-in-progress (JIP) functionality for some modules.\nIt requires a mission restart for it to be turned off."],
    [COMPONENT_NAME, "Modules"],
    false,
    false,
    {
        // If setting is off, already added or no curator object, don't do anything
        if (isNull (getAssignedCuratorLogic player)) exitWith {};

        call FUNC(handleJIP);
    }
] call CBA_fnc_addSetting;

[
    QGVAR(enableMissionCounter),
    "CHECKBOX",
    ["Enable Mission Object Counter", "If enabled, all objects placed and deleted by the player's curator will be kept track of.\nIf turned off, it will remove everything related to the counter, but not resetting the counter in the process."],
    [COMPONENT_NAME, "Modules"],
    false,
    false,
    {
        // If there is no curator object, don't do anything
        if (isNull (getAssignedCuratorLogic player)) exitWith {};

        // If setting is off and there is stuff still there, remove it
        if (!GVAR(enableMissionCounter) && {!isNil QGVAR(curatorHandleIDs)}) exitWith {
            GVAR(curatorHandleIDs) params ["_handleID1", "_handleID2", "_handleID3", "_handleID4"];

            (getAssignedCuratorLogic player) removeEventHandler ["CuratorObjectDeleted", _handleID1];
            (getAssignedCuratorLogic player) removeEventHandler ["CuratorObjectPlaced", _handleID2];
            (getAssignedCuratorLogic player) removeEventHandler ["CuratorGroupPlaced", _handleID3];
            (getAssignedCuratorLogic player) removeEventHandler ["CuratorPinged", _handleID4];

            GVAR(curatorHandleIDs) = nil;
        };

        call FUNC(objectsCounterMissionEH);
    }
] call CBA_fnc_addSetting;

[
    QGVAR(blacklistFKEnable),
    "CHECKBOX",
    ["Enable automatic blacklist detection for FK servers", "Allows the automatic adoption of the premade blacklist on FK servers. FK is a EU based unit."],
    [COMPONENT_NAME, MAGAZINES_DESC],
    false,
    false,
    {
        if (GVAR(blacklistFKEnable) && {!isNil {"FKF/CfgArsenalBlacklist" call Clib_fnc_getSettings}}) then {
            GVAR(blacklist) = [];

            {
                GVAR(blacklist) append ((format ["FKF/CfgArsenalBlacklist/%1", _x]) call Clib_fnc_getSetting);
            } forEach ("FKF/CfgArsenalBlacklist" call Clib_fnc_getSettings);
        } else {
            GVAR(blacklist) = parseSimpleArray GVAR(blacklistSettings);
        };
    }
] call CBA_fnc_addSetting;

[
    QGVAR(blacklistSettings),
    "EDITBOX",
    ["Blacklist for ammo resupply", "Filters whatever is in the box out of the resupply crate, only works for the 'Spawn Ammo Resupply for unit' module. Must be an array of strings."],
    [COMPONENT_NAME, MAGAZINES_DESC],
    "[]",
    false,
    {
        if (GVAR(blacklistFKEnable) && {!isNil {"FKF/CfgArsenalBlacklist" call Clib_fnc_getSettings}}) exitWith {};

        GVAR(blacklist) = parseSimpleArray GVAR(blacklistSettings);
    }
] call CBA_fnc_addSetting;

MAGAZINES_SETTINGS(545x39);
MAGAZINES_SETTINGS(762x39);
MAGAZINES_SETTINGS(762x54R);
MAGAZINES_SETTINGS(oddBLU);
MAGAZINES_SETTINGS(Stanag556);
MAGAZINES_SETTINGS(Misc556);
MAGAZINES_SETTINGS(Belt556);
MAGAZINES_SETTINGS(QBZ58KH65);
MAGAZINES_SETTINGS(MX65);
MAGAZINES_SETTINGS(All762);
MAGAZINES_SETTINGS(Belt762);
MAGAZINES_SETTINGS(12G);
MAGAZINES_SETTINGS(PistolBLU);
MAGAZINES_SETTINGS(PistolRED);
MAGAZINES_SETTINGS(UGLBLU);
MAGAZINES_SETTINGS(UGLRED);
MAGAZINES_SETTINGS(MATBLU);
MAGAZINES_SETTINGS(MATRED);
MAGAZINES_SETTINGS(HATRED);
MAGAZINES_SETTINGS(HATBLUAMMO);
MAGAZINES_SETTINGS(AABLU);
MAGAZINES_SETTINGS(AARED);
