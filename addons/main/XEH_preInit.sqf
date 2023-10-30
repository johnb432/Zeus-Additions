#include "script_component.hpp"

ADDON = false;

#include "XEH_PREP.hpp"

// Macros don't like commas in strings
INFO_ZA(FORMAT_2(QUOTE(PreInit: Net mode: ARR_2(%1,Functions) sent: %2),call BIS_fnc_getNetMode,!isNil QGVAR(functionsSent)));

// Execute init for everyone and JIP if init hasn't been run yet
if (isServer && {isNil QGVAR(functionsSent)}) then {
    SEND_MP(init);
    remoteExecCall [QFUNC(init), 0, QGVAR(initJIPId)];
};

// Default arrays for ammunition choice
GVAR(LATBLU) = ["UK3CB_BAF_AT4_CS_AP_Launcher","UK3CB_BAF_AT4_CS_AT_Launcher","rhs_weap_M136","rhs_weap_M136_hedp","rhs_weap_M136_hp","rhs_weap_m72a7"];
GVAR(LATRED) = ["rhs_weap_rpg18","rhs_weap_rpg26","rhs_weap_rshg2","rhs_weap_m80","rhs_weap_rpg75"];

GVAR(MATBLU) = ["rhs_mag_maaws_HE","rhs_mag_maaws_HEAT","MRAWS_HE_F","MRAWS_HEAT_F","rhs_mag_smaw_HEDP","rhs_mag_smaw_HEAA"];
GVAR(MATRED) = ["rhs_rpg7_OG7V_mag","rhs_rpg7_PG7V_mag","rhs_rpg7_PG7VL_mag","rhs_rpg7_PG7VM_mag","rhs_rpg7_PG7VR_mag","rhs_rpg7_TBG7V_mag","rhs_rpg7_type69_airburst_mag","RPG7_F","RPG32_HE_F","RPG32_F"];

GVAR(HATBLU) = ["UK3CB_BAF_Javelin_Slung_Tube","rhs_fgm148_magazine_AT"];
GVAR(HATRED) = ["Vorona_HE","Vorona_HEAT"];

GVAR(AABLU) = ["rhs_fim92_mag","Titan_AA"];
GVAR(AARED) = ["rhs_mag_9k38_rocket","Titan_AA"];

GVAR(magsTotal) = [];

// CBA Settings
#include "initSettings.sqf"

ADDON = true;
