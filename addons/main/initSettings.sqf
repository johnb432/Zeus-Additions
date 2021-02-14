[
    QGVAR(blacklistSettings),
    "EDITBOX",
    ["Blacklist for ammo resupply", "Filters whatever is in the box out of the resupply crate, only works for the 'Spawn Ammo Resupply for unit' module. Must be an array of strings."],
    [COMPONENT_NAME, MAGAZINES_DESC],
    "[]",
    false,
    {
        // Wait until FKFramework has updated to use
        //if (!GVAR(isClibPresent) || {isNil {"FKF/CfgArsenalBlacklist" call Clib_fnc_getSettings}}) then {
            GVAR(blacklist) = parseSimpleArray GVAR(blacklistSettings);
        //};
    }
] call CBA_fnc_addSetting;

[
    QGVAR(545x39Mags),
    "EDITBOX",
    ["545x39 Magazines", RESUPPY_DESC],
    [COMPONENT_NAME, MAGAZINES_DESC],
    str GVAR(545x39)
] call CBA_fnc_addSetting;

[
    QGVAR(762x39Mags),
    "EDITBOX",
    ["762x39 Magazines", RESUPPY_DESC],
    [COMPONENT_NAME, MAGAZINES_DESC],
    str GVAR(762x39)
] call CBA_fnc_addSetting;

[
    QGVAR(762x54RMags),
    "EDITBOX",
    ["762x54R Magazines", RESUPPY_DESC],
    [COMPONENT_NAME, MAGAZINES_DESC],
    str GVAR(762x54R)
] call CBA_fnc_addSetting;

[
    QGVAR(oddBluforMags),
    "EDITBOX",
    ["Odd BLUFOR Magazines", RESUPPY_DESC],
    [COMPONENT_NAME, MAGAZINES_DESC],
    str GVAR(oddBLU)
] call CBA_fnc_addSetting;

[
    QGVAR(556x45StanagMags),
    "EDITBOX",
    ["556x45 STANAG Magazines", RESUPPY_DESC],
    [COMPONENT_NAME, MAGAZINES_DESC],
    str GVAR(Stanag556)
] call CBA_fnc_addSetting;

[
    QGVAR(556x45MiscMags),
    "EDITBOX",
    ["556x45 Magazines", RESUPPY_DESC],
    [COMPONENT_NAME, MAGAZINES_DESC],
    str GVAR(Misc556)
] call CBA_fnc_addSetting;

[
    QGVAR(556x45Belts),
    "EDITBOX",
    ["556x45 Belts", RESUPPY_DESC],
    [COMPONENT_NAME, MAGAZINES_DESC],
    str GVAR(Belt556)
] call CBA_fnc_addSetting;

[
    QGVAR(58x4265x39Mags),
    "EDITBOX",
    ["QBZ 5.8x42mm/KH2002 6.5x39 Magazines", RESUPPY_DESC],
    [COMPONENT_NAME, MAGAZINES_DESC],
    str GVAR(QBZ58KH65)
] call CBA_fnc_addSetting;

[
    QGVAR(65x39Mags),
    "EDITBOX",
    ["MX 6.5x39 Magazines", RESUPPY_DESC],
    [COMPONENT_NAME, MAGAZINES_DESC],
    str GVAR(MX65)
] call CBA_fnc_addSetting;

[
    QGVAR(762x51Mags),
    "EDITBOX",
    ["762x51 Magazines", RESUPPY_DESC],
    [COMPONENT_NAME, MAGAZINES_DESC],
    str GVAR(All762)
] call CBA_fnc_addSetting;

[
    QGVAR(762x51Belts),
    "EDITBOX",
    ["762x51 Belts", RESUPPY_DESC],
    [COMPONENT_NAME, MAGAZINES_DESC],
    str GVAR(Belt762)
] call CBA_fnc_addSetting;

[
    QGVAR(12Gauge),
    "EDITBOX",
    ["12Gauge Magazines", RESUPPY_DESC],
    [COMPONENT_NAME, MAGAZINES_DESC],
    str GVAR(12G)
] call CBA_fnc_addSetting;

[
    QGVAR(BLUFORPistol),
    "EDITBOX",
    ["BLUFOR Pistol Magazines", RESUPPY_DESC],
    [COMPONENT_NAME, MAGAZINES_DESC],
    str GVAR(PistolBLU)
] call CBA_fnc_addSetting;

[
    QGVAR(REDFORPistol),
    "EDITBOX",
    ["REDFOR Pistol Magazines", RESUPPY_DESC],
    [COMPONENT_NAME, MAGAZINES_DESC],
    str GVAR(PistolRED)
] call CBA_fnc_addSetting;

[
    QGVAR(BLUFORUGL),
    "EDITBOX",
    ["BLUFOR UGL Grenades", RESUPPY_DESC],
    [COMPONENT_NAME, MAGAZINES_DESC],
    str GVAR(UGLBLU)
] call CBA_fnc_addSetting;

[
    QGVAR(REDFORUGL),
    "EDITBOX",
    ["REDFOR UGL Grenades", RESUPPY_DESC],
    [COMPONENT_NAME, MAGAZINES_DESC],
    str GVAR(UGLRED)
] call CBA_fnc_addSetting;

[
    QGVAR(BLUFORLAT),
    "EDITBOX",
    ["BLUFOR LAT", RESUPPY_DESC],
    [COMPONENT_NAME, MAGAZINES_DESC],
    str GVAR(LATBLU)
] call CBA_fnc_addSetting;

[
    QGVAR(REDFORLAT),
    "EDITBOX",
    ["REDFOR LAT", RESUPPY_DESC],
    [COMPONENT_NAME, MAGAZINES_DESC],
    str GVAR(LATRED)
] call CBA_fnc_addSetting;

[
    QGVAR(BLUFORMAT),
    "EDITBOX",
    ["BLUFOR MAT", RESUPPY_DESC],
    [COMPONENT_NAME, MAGAZINES_DESC],
    str GVAR(MATBLU)
] call CBA_fnc_addSetting;

[
    QGVAR(REDFORMAT),
    "EDITBOX",
    ["REDFOR MAT", RESUPPY_DESC],
    [COMPONENT_NAME, MAGAZINES_DESC],
    str GVAR(MATRED)
] call CBA_fnc_addSetting;

[
    QGVAR(BLUFORHATAMMO),
    "EDITBOX",
    ["BLUFOR HAT (Ammo)", RESUPPY_DESC],
    [COMPONENT_NAME, MAGAZINES_DESC],
    str GVAR(HATBLUAMMO)
] call CBA_fnc_addSetting;

[
    QGVAR(BLUFORHAT),
    "EDITBOX",
    ["BLUFOR HAT (Launcher)", RESUPPY_DESC],
    [COMPONENT_NAME, MAGAZINES_DESC],
    str GVAR(HATBLU)
] call CBA_fnc_addSetting;

[
    QGVAR(REDFORHAT),
    "EDITBOX",
    ["REDFOR HAT", RESUPPY_DESC],
    [COMPONENT_NAME, MAGAZINES_DESC],
    str GVAR(HATRED)
] call CBA_fnc_addSetting;

[
    QGVAR(BLUFORAA),
    "EDITBOX",
    ["BLUFOR AA", RESUPPY_DESC],
    [COMPONENT_NAME, MAGAZINES_DESC],
    str GVAR(AABLU)
] call CBA_fnc_addSetting;

[
    QGVAR(REDFORAA),
    "EDITBOX",
    ["REDFOR AA", RESUPPY_DESC],
    [COMPONENT_NAME, MAGAZINES_DESC],
    str GVAR(AARED)
] call CBA_fnc_addSetting;
