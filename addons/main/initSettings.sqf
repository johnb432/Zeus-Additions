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
    QGVAR(enableSnowScriptHint),
    "CHECKBOX",
    ["Enable Snow Script missing addon hint", "Allows people to toggle the hint on or off."],
    [COMPONENT_NAME, "Modules"],
    true,
    false
] call CBA_fnc_addSetting;

[
    QGVAR(blacklistFKEnable),
    "CHECKBOX",
    ["Enable automatic blacklist detection for FK servers", "Allows the automatic adoption of the premade blacklist on FK servers. FK is a EU based unit."],
    [COMPONENT_NAME, MAGAZINES_DESC],
    false,
    false,
    {
        if (GVAR(blacklistFKEnable) && {isClass (configFile >> "CfgPatches" >> "CLib")} && {!isNil {"FKF/CfgArsenalBlacklist" call Clib_fnc_getSettings}}) then {
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
        if !(GVAR(blacklistFKEnable) && {isClass (configFile >> "CfgPatches" >> "CLib")} && {!isNil {"FKF/CfgArsenalBlacklist" call Clib_fnc_getSettings}}) then {
            GVAR(blacklist) = parseSimpleArray GVAR(blacklistSettings);
        };
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
