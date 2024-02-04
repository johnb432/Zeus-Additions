#define MAGAZINES_SETTINGS(NAME,INDEX)\
[\
    QGVAR(DOUBLES(NAME,mags)),\
    "EDITBOX",\
    [format ["%1 Ammunition", QUOTE(NAME)], LSTRING(ammunitionSettingDesc)],\
    [COMPONENT_NAME, MAGAZINES_DESC],\
    str GVAR(NAME),\
    0,\
    {\
        GVAR(magsTotal) set [INDEX, ((if (_this isEqualType "") then {parseSimpleArray _this} else {[[], _this] select (_this isEqualType [])}) apply {configName (_x call CBA_fnc_getItemConfig)}) - [""]];\
    }\
] call CBA_fnc_addSetting

#define HINT_SETTINGS(NAME,TEXT)\
[\
    QGVAR(NAME),\
    "CHECKBOX",\
    [TEXT, LSTRING(hintSettingDesc)],\
    [COMPONENT_NAME, "str_a3_rscdisplaycurator_modemodules_tooltip"],\
    true\
] call CBA_fnc_addSetting

[
    QGVAR(enableBuildingDestructionHandling),
    "CHECKBOX",
    [LSTRING(enableBuildingDestructionSetting), LSTRING(enableBuildingDestructionSettingDesc)],
    [COMPONENT_NAME, "str_a3_rscdisplaycurator_modemodules_tooltip"],
    false,
    0,
    {
        // Let the server handle turning on & off
        [QGVAR(buildingDestruction), getPlayerUID player, _this && {!isNull curatorCamera}, QFUNC(handleBuildingDestruction)] call FUNC(changeReason);
    }
] call CBA_fnc_addSetting;

[
    QGVAR(enableMissionCounter),
    "CHECKBOX",
    [LSTRING(enableMissionCounterSetting), LSTRING(enableMissionCounterSettingDesc)],
    [COMPONENT_NAME, "str_a3_rscdisplaycurator_modemodules_tooltip"],
    false,
    0,
    {
        call FUNC(objectsCounterMissionEH);
    }
] call CBA_fnc_addSetting;

[
    QGVAR(blacklistFKEnable),
    "CHECKBOX",
    [LSTRING(enableBlacklistFKSetting), LSTRING(enableBlacklistFKSettingDesc)],
    [COMPONENT_NAME, MAGAZINES_DESC],
    false,
    0,
    {
        GVAR(blacklist) = ((if (_this && {!isNil {"FKF/CfgArsenalBlacklist" call Clib_fnc_getSettings}}) then {
            private _list = [];

            {
                _list append ((format ["FKF/CfgArsenalBlacklist/%1", _x]) call Clib_fnc_getSetting);
            } forEach ("FKF/CfgArsenalBlacklist" call Clib_fnc_getSettings);

            _list
        } else {
            if (GVAR(blacklistSettings) isEqualType "") then {
                parseSimpleArray GVAR(blacklistSettings)
            } else {
                [[], GVAR(blacklistSettings)] select (GVAR(blacklistSettings) isEqualType [])
            };
        }) apply {configName (_x call CBA_fnc_getItemConfig)}) - [""];
    }
] call CBA_fnc_addSetting;

[
    QGVAR(blacklistSettings),
    "EDITBOX",
    [LSTRING(blacklistSetting), LSTRING(blacklistSettingDesc)],
    [COMPONENT_NAME, MAGAZINES_DESC],
    "[]",
    0,
    {
        if (GVAR(blacklistFKEnable) && {!isNil {"FKF/CfgArsenalBlacklist" call Clib_fnc_getSettings}}) exitWith {};

        GVAR(blacklist) = ((if (_this isEqualType "") then {
            parseSimpleArray _this
        } else {
            [[], _this] select (_this isEqualType [])
        }) apply {configName (_x call CBA_fnc_getItemConfig)}) - [""];
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

HINT_SETTINGS(enableACEDragHint,LSTRING(aceDraggingHintSetting));
HINT_SETTINGS(enableACEMedicalHint,LSTRING(aceMedicalHintSetting));
HINT_SETTINGS(enableTFARHint,LSTRING(radioRangeHintSetting));
HINT_SETTINGS(enableRHSHint,LSTRING(rhsAPSHintSetting));
